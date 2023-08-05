--[[
	#Kent Hook Library.
	
	Idea of this hook library is to maximize performance by using function recursion.

	Cons:
		Be extremely cautios of what you put as arguments. It doesn't have any tests cuz of performance reasons.
		Do not try to change hook.GetTable() and hooks (except the hook that's called by now) themselves while in hook.Call.
		second arg for hook.Call literally doesn't do anything. If your addon relies of using gamemode table argument for hook.Call, then i send you my regards.
		It WILL likely (99%) break your gmod. You need to patch a lot of stuff to get it to work.
	Pros:
		Max performance as possible.
		Literraly almost 0 overhead if hook has only 1 event.
		By bytecode means, kent hook library has less bytecode per 'call' function, than DASH.

	TODO:
		Make hook priority like in srlion's lib (very easy tbh)

	CREDITS:
		Made by kentovka team.
			Jaff&Radon
--]]

local originalHooks = {}
local hook = {}
local hooks = {}

local funcGM = GM or GAMEMODE or {}

local function createFunc(eventTable, name)
	local tab = {}
	local len = 0

	for k, v in pairs(eventTable) do
		if k ~= 0 then
			len = len + 1
			tab[len] = v
		end
	end


	local gmFunc = funcGM[name]

	if gmFunc then
		return function(...)
			local ln, i = len, 0
			::start::
			i = i + 1

			local a, b, c, d, e, f = tab[i](...)

			if a ~= nil then
				return a, b, c, d, e, f
			end

			if i ~= ln then goto start end

			return gmFunc(funcGM, ...)
		end
	else
		return function(...)
			local ln, i = len, 0
			::start::
			i = i + 1

			local a, b, c, d, e, f = tab[i](...)

			if a ~= nil then
				return a, b, c, d, e, f
			end

			if i ~= ln then goto start end
		end
	end
end

local function createSingleFunc(eventTable, name)
	local _, func = next(eventTable, 0)
	local gmFunc = (funcGM)[name]

	if gmFunc then
		return function(...)
			local a, b, c, d, e, f = func(...)

			if a == nil then
				return gmFunc(funcGM, ...)
			end
			
			return a, b, c, d, e, f
		end
	else
		return func
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

	local newFunc, start
	if funcGM[name] then
		local gmFunc = funcGM[name]

		newFunc = function(...)
			return gmFunc(funcGM, ...)
		end

		start = 1
	else
		newFunc = tab[1]
		start = 2
	end

	for i = start, len do
		local oldFunc = newFunc
		local func = tab[i]

		newFunc = function(...)
			
			local a, b, c, d, e, f = func(...)

			if a ~= nil then
				return a, b, c, d, e, f
			end

			return oldFunc(...)
		end
	end

	return newFunc
end

local function createGamemodeFunc(eventTable, eventName)
	local gmFunc = funcGM[eventName]

	if gmFunc then
		return function(...)
			return gmFunc(funcGM, ...)
		end
	end
end

local function setHookFuncion(eventName, eventTable)
	hooks[eventName] = ( (eventTable == nil or eventTable[0] == 0) and createGamemodeFunc or 
		eventTable[0] == 1 and createSingleFunc or 
		eventTable[0] < 4 and createRecursedFunc or 
		createFunc)(eventTable, eventName)
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

	if eventTable and eventTable[name] then
		eventTable[name] = nil
		eventTable[0] = eventTable[0] - 1
		setHookFuncion(eventName, eventTable)
	end
end

function hook.Call(eventName, _, ...)
	local func = hooks[eventName]

	if func then
		return func(...)
	end
end

function hook.Run(eventName, ...)
	local func = hooks[eventName]

	if func then
		return func(...)
	end
end


hook.Add('PostGamemodeLoaded', 'Kent hook', function()
	funcGM = GM or GAMEMODE
	for k, v in pairs(funcGM) do
		if isfunction(v) then
			setHookFuncion(k)
		end
	end

	hook.Remove("PostGamemodeLoaded", "Kent hook")
end)

_G['hook'] = hook
