--[[
	#Kent Hook Library.
	
	Idea of this hook library is to maximize performance by using function recursion.

	Cons:
		Be extremely cautios of what you put as arguments. It doesn't have any tests cuz of performance reasons.
		Do not try to change hook.GetTable() and hooks (except the hook that's called by now) themselves while in hook.Call.
	Pros:
		Max performance.


	как работает для себя

--]]

local originalHooks = {}
local hook = {}
local hooks = {}

local function createFunc(eventTable, name)
	local tab = {}
	local len = 0

	for k, v in pairs(eventTable) do
		if k ~= 0 then
			len = len + 1
			tab[len] = v
		end
	end	

	local a, b, c, d, e, f

	local gmFunc = (GM or GAMEMODE)[name]

	return function(...)
		for i = 1, len do
			a, b, c, d, e, f = tab[i](...)

			if a ~= nil then
				return a, b, c, d, e, f
			end
		end


		if gmFunc then
			return gmFunc(funcGM, ...)
		end
	end
end


local function createRecursedFunc(eventTable, name)
	local tab = {}
	local len = 0

	for k, v in pairs(eventTable) do
		if k ~= 0 then
			len = len + 1
			tab[len] = v
		end
	end

	local newFunc = (GM or GAMEMODE)[name]
	local start = 1
	if newFunc == nil then
		newFunc = tab[1]
		start = 2
	end

	local a, b, c, d, e, f

	for i = start, len do
		local oldFunc = newFunc
		local func = tab[i]

		newFunc = function(...)
			a, b, c, d, e, f = func(...)

			if a == nil then
				a, b, c, d, e, f = oldFunc(...)
			end

			return a, b, c, d, e, f
		end
	end

	return newFunc
end

local function setHookFuncion(eventName, eventTable)
	hooks[eventName] = (eventTable[0] <= 5 and createRecursedFunc or createFunc)(eventTable, eventName)
end

function hook.GetTable()
	return originalHooks
end

function hook.Add(eventName, name, func)
	local eventTable = originalHooks[eventName]
	if eventTable == nil then
		eventTable = {[0] = 0}
		originalHooks[eventName] = eventTable
	end

	if eventTable[name] == nil then
		eventTable[0] = eventTable[0] + 1
	end

	eventTable[name] = func

	setHookFuncion(eventName, eventTable)
end

function hook.Remove(eventName, name)
	local eventTable = originalHooks[eventName]

	eventTable[name] = nil
	eventTable[0] = eventTable[0] - 1

	setHookFuncion(eventName, eventTable)
end

function hook.Call(eventName, gm, ...)
	local func = hooks[eventName]

	if func then
		return func(...)
	end
end

_G['hook'] = hook
