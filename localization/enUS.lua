local L = {}
local _G = _G

_G["BINDING_NAME_MOUNTY_MAGIC"] = "Summon magic mount"
_G["BINDING_NAME_MOUNTY_WATER"] = "Summon water mount"
_G["BINDING_NAME_MOUNTY_TAXI"] = "Summon taxi mount"
_G["BINDING_NAME_MOUNTY_REPAIR"] = "Summon repair mount"
_G["BINDING_NAME_MOUNTY_SHOWOFF"] = "Summon show off mount"
_G["BINDING_NAME_MOUNTY_RANDOM"] = "Summon random mount"
_G["BINDING_NAME_MOUNTY_DISMOUNT"] = "Force dismount"

L["mode.Ground"] = "Ground"
L["mode.Flying"] = "Flying"
L["mode.Water"] = "Water"
L["mode.Repair"] = "Repair"
L["mode.Taxi"] = "Taxi"
L["mode.Show off"] = "Show off"
L["mode.Random"] = "Random"

L["Taxi!"] = "Taxi!"

L["Options"] = "Mounty #TLV - Options"
L["Random"] = "Random"
L["Don't fly (except if taxi)"] = "Don't fly in group (except as a taxi)"
L["Taxi mode"] = "Taxi mode"
L["Debug mode"] = "Debug mode"
L["Auto open"] = "Auto open and close with mount journal"
L["Summon repair mount if durability is less than %d%%."] = "Summon repair mount if durability is less than %d%%."
L["How to call a passenger"] = "How to call a passenger"

L["Helptext"] = "Drag mounts into here. Right click to remove a mount."

L["Debug: "] = "Debug: "
L["fly mode: "] = "fly mode: "
L["random: "] = "random: "
L["taxi: "] = "taxi: "

L["on"] = "on"
L["off"] = "off"

L["Open Mounty"] = "Mounty #TLV"

local _, Mounty = ...
Mounty.L = L