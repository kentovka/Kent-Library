--[[
	Kent-Hook-Library
	This is gamemode library for kent-hook-library.
	Pros:
		Should be faster than regular gamemode library.
	Cons:
		Untested.

	Credits: Kentovka
		Jaff&Radon

]]

local gamemode = {}

local gamemodes = {}

local currentGM
local callFunc

function gamemode.Register(tab, name, derived)
	currentGM = gmod.GetGamemode()

	if currentGM then
		if currentGM.FolderName == name then 
			table.Merge( currentGM, tab ) -- why it isn't called table.mixin?
			gamemode.Call( "OnReloaded" )
		end

		local baseClass = currentGM.BaseClass

		if baseClass and baseClass.FolderName == name then
			table.Merge( baseClass, tab )
			gamemode.Call( "OnReloaded" )
		end

	end

	-- This gives the illusion of inheritence
	if name ~= "base" then
		local baseTable = gamemodes[derived]

		if baseTable then
			tab = table.Inherit( tab, baseTable )
		else
			print("Warning: Couldn't find derived gamemode (", derived, ")")
		end
	end

	gamemodes[ name ] = tab

	baseclass.Set( "gamemode_" .. name, tab )
end

function gamemode.Get(name)
	return gamemodes[name]
end

local function call(name, ...)
	if currentGM[name] == nil then return false end

	return callFunc(name, currentGM, ...)
end

timer.Simple(1, function() -- very bad btw
	callFunc = hook.Call
	currentGM = gmod.GetGamemode()

	gamemode.Call = call
end)

function gamemode.Call(name, ...) -- at first launch it basically same shit.
	currentGM = gmod.GetGamemode()

	if currentGM and currentGM[name] == nil then return false end

	return hook.Call(name, currentGM, ...)
end

_G['gamemode'] = gamemode
