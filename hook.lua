local NO_FUNCTIONS = false
--Setting it to true will use different hook calling mechanism.
--It MIGHT be faster due to Lua JIT incapability to compile closures


if NO_FUNCTIONS then
	AddCSLuaFile("hook_no_functions.lua") -- currently there is no implementation of that.
	include("hook_no_functions.lua ") --It should be a modification of DASH's hook library, but faster.
else
	AddCSLuaFile("hook_functions.lua")
	include("hook_functions.lua ")
end