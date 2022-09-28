if( GetLocale() ~= "esES" ) then return end

local L = {}

local _, Mounty = ...
Mounty.L = setmetatable(L, {__index = Mounty.L})
