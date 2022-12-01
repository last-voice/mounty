local L = {}
local _G = _G

_G["BINDING_NAME_MOUNTY_MAGIC"] = "Summon magic mount"
_G["BINDING_NAME_MOUNTY_GROUND"] = "Summon ground mount"
_G["BINDING_NAME_MOUNTY_WATER"] = "Summon water mount"
_G["BINDING_NAME_MOUNTY_TAXI"] = "Summon taxi mount"
_G["BINDING_NAME_MOUNTY_REPAIR"] = "Summon repair mount"
_G["BINDING_NAME_MOUNTY_SHOWOFF"] = "Summon show off mount"
_G["BINDING_NAME_MOUNTY_RANDOM"] = "Summon random mount"
_G["BINDING_NAME_MOUNTY_DISMOUNT"] = "Force dismount"

L["mode.Ground"] = "Ground"
L["mode.Flying"] = "Flying"
L["mode.Dragonflight"] = "Dragonflight"
L["mode.Water"] = "Water"
L["mode.Repair"] = "Repair"
L["mode.Taxi"] = "Taxi"
L["mode.Show off"] = "Show off"
L["mode.Random"] = "Random"

L["Taxi!"] = "Taxi!"

L["Options"] = "Mounty #TLV - Options"
L["Quick start"] = "Quick start"
L["Random"] = "Random (If not checked, each category will cycle through)"
L["Look at me!"] = "Look at me! Show off in resting areas"
L["Stay together"] = "Stay together and don't fly in group (except as a taxi)"
L["Taxi mode"] = "Taxi mode"
L["Debug mode"] = "Debug mode"
L["Auto open"] = "Auto open and close with mount journal"
L["Summon repair mount if durability is less than %d%%."] = "Summon repair mount if durability is less than %d%%."
L["How to call a passenger"] = "How to call a passenger"

L["Helptext"] = "Drag mounts into here. Right click to remove a mount."

L["Debug: "] = "Debug: "
L["Auto open & close: "] = "Auto open & close: "
L["Together mode: "] = "Together mode: "
L["Show off mode: "] = "Show off mode: "
L["Random: "] = "Random: "
L["Taxi mode: "] = "Taxi mode: "

L["on"] = "on"
L["off"] = "off"

L["Open Mounty"] = "Mounty #TLV"

L["Quick start full"] = "- Pull your favourite mounts from the mount journal into the categories of Mounty #TLV.\n- Open WoW's settings for key bindings, select Mounty #TLV and configure your magic key to mount.\n- Press your magic key to pick up the perfect mount for here and now.\n- Enjoy Mounty #TLV and take a look and all the other options and possibilities."

local _, Mounty = ...
Mounty.L = L