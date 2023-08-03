--[[
    Recursive hook library
    Still breaks gmod (for now) since it doesnt support objects as an hook name,
    but works faster than kent/dash/srlion in some (most (should be in any)) cases.
    Based on the tailcall optimization.
]]

local lib = {}
local hooks = {}
-- for hook.Remove and hook.GetTable
local hooksNormalTable = {}

local function recursionInsert(oldFunc, func)
    return function(a, b, c, d, e, f, g)
        local r1, r2, r3, r4, r5, r6, r7, r8 = oldFunc(a, b, c, d, e, f, g)
        if r1 ~= nil then
            return r1, r2, r3, r4, r5, r6, r7, r8
        else
            return func(a, b, c, d, e, f, g)
        end
    end
end

-- to not duplicate data in `hooksNormalTable`
local function attachFunctionToEvent(eventName, func)
    local curEventRecursion = hooks[eventName]
    if curEventRecursion then
        curEventRecursion = recursionInsert(curEventRecursion, func)
    else
        hooks[eventName] = func
    end
end

local function add(eventName, hookName, func)
    attachFunctionToEvent(eventName, func)

    local curFunctions = hooksNormalTable[eventName]
    if curFunctions then
        local newInsertionsAmount = curFunctions[0] + 1
        curFunctions[0] = newInsertionsAmount
        curFunctions[hookName] = {newInsertionsAmount, func}
    else
        hooksNormalTable[eventName] = {
            -- insertion amount. Using this we can keep the order the hooks being added
            [0] = 1,
            [hookName] = {
                -- order
                1,
                func}
        }
    end
end

local function rebuildEventFunctions(eventName)
    hooks[eventName] = nil
    local curOriginals = hooksNormalTable[eventName]
    -- to restore it
    local insertionAmount = curOriginals[0]
    curOriginals[0] = nil

    local keys = table.GetKeys(curOriginals)
    table.sort(keys, function(a, b)
        return curOriginals[a][1] < curOriginals[b][1]
    end)

    curOriginals[0] = insertionAmount
    for _, hookName in ipairs(keys) do
        attachFunctionToEvent(eventName, curOriginals[hookName][2])
    end
end

local function remove(eventName, hookName)
    local curOriginals = hooksNormalTable[eventName]
    if curOriginals then
        curOriginals[hookName] = nil
        rebuildEventFunctions(eventName)
    end

    -- nothing to remove in the other case
end

local function call(eventName, gmTable, ...)
    local curEventHooks = hooks[eventName]
    if curEventHooks then
        local r1, r2, r3, r4, r5, r6 = curEventHooks(...)
        if r1 ~= nil then
            return r1, r2, r3, r4, r5, r6
        end
    end
    
    if gmTable then
        local gmFunc = gmTable[eventName]
        if gmFunc then
            return gmFunc(...)
        end
    end
end

local function run(eventName, ...)
    return call(eventName, GM or GAMEMODE, ...)
end

local function getTable()
    local tab = {}
    for eventName, functions in pairs(hooksNormalTable) do
        tab[eventName] = {}
        for hookName, functionData in pairs(functions) do
            if hookName == 0 then
                continue
            end
            tab[eventName][hookName] = functionData[2]
        end
    end

    return tab
end

local hook = {
    Add = add,
    Remove = remove,
    Call = call,
    Run = run,
    GetTable = getTable
}

_G['hook'] = hook
