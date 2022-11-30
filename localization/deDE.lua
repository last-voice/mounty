if (GetLocale() ~= "deDE") then return end

local L = {}
local _G = _G

_G["BINDING_NAME_MOUNTY_MAGIC"] = "Magisches Mount"
_G["BINDING_NAME_MOUNTY_WATER"] = "Wasser-Mount"
_G["BINDING_NAME_MOUNTY_TAXI"] = "Taxi-Mount"
_G["BINDING_NAME_MOUNTY_REPAIR"] = "Reparier-Mount"
_G["BINDING_NAME_MOUNTY_SHOWOFF"] = "Angeben!"
_G["BINDING_NAME_MOUNTY_RANDOM"] = "Zufälliges Mount"
_G["BINDING_NAME_MOUNTY_DISMOUNT"] = "Absteigen!"


L["mode.Ground"] = "Reiten"
L["mode.Flying"] = "Fliegen"
L["mode.Dragonflight"] = "Dragonflight"
L["mode.Water"] = "Schwimmen"
L["mode.Repair"] = "Reparieren"
L["mode.Taxi"] = "Taxi"
L["mode.Show off"] = "Angeberei"
L["mode.Random"] = "Zufällig"

L["Taxi!"] = "Taxi!"

L["Options"] = "Mounty #TLV - Optionen"
L["Random"] = "Zufällig"
L["Don't show off in resting areas"] = "Keine automatische Angeberei in Ruhebereichen"
L["Don't fly (except if taxi)"] = "Nicht in der Gruppe fliegen (außer als Taxi)"
L["Taxi mode"] = "Taxi-Modus"
L["Debug mode"] = "Debug-Modus (nur englisch)"
L["Auto open"] = "Automatisch mit der Reittiersammlung öffnen und schließen"
L["Summon repair mount if durability is less than %d%%."] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["How to call a passenger"] = "So rufst du deinen Passagier"

L["Helptext"] = "Mounts hier reinziehen. Rechtsklick, um Mount zu entfernen."

L["Debug: "] = "Debug: "
L["fly mode: "] = "Flug-Modus: "
L["random: "] = "Zufall: "
L["taxi: "] = "Taxi: "

L["on"] = "an"
L["off"] = "aus"

L["Open Mounty"] = "Mounty #TLV"

local _, Mounty = ...
Mounty.L = setmetatable(L, { __index = Mounty.L })
