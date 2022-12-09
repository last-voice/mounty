local L = {}
-- local _G = _G

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

L["options.Random"] = "Random (If not checked, each category will cycle through)"
L["options.Look"] = "Look at me! Show off in resting areas"
L["options.Stay"] = "Stay together and don't fly in group (except as a taxi)"
L["options.Taxi"] = "Taxi mode"
L["options.Debug"] = "Debug mode"
L["options.Autoopen"] = "Auto open and close with mount journal"
L["options.Durability"] = "Summon repair mount if durability is less than %d%%."
L["options.Hello"] = "How to call a passenger"
L["options.Hello-Default"] = "Taxi!"
L["options.Helptext"] = "Drag mounts into here. Right click to remove a mount."
L["options.Profile"] = "Profile"
L["options.ShareProfiles"] = "Share profiles with your other characters"
L["options.Already"] = "The mount is already assigned to this category."

L["expanded.Add"] = "Add from journal"
L["expanded.Refresh"] = "Refresh"
L["expanded.Clear"] = "Clear"
L["expanded.refresh-confirm"] = "|cff00f000Close all gaps|r of the current category?"
L["expanded.clear-confirm"] = "|cff00f000Empty|r the current category?"
L["expanded.add-journal-confirm"] = "|cff00f000Add|r all |cff00f000currently filtered and collected mounts|r from the journal to the current category?"

L["profile.switched"] = "Switched to profile |cff00f000%s|r."
L["profile.delete-confirm"] = "Delete profile |cff00f000%s|r?"
L["profile.current"] = "Current profile: |cff00f000%s|r"
L["profile.error"] = "Please use |cff00f000letters and digits|r only."
L["profile.empty"] = "Please enter a |cff00f000profile name|r."
L["profile.none"] = "Profile |cff00f000%s|r not found."
L["profile.already"] = "Profile |cff00f000%s|r already exists."
L["profile.copy-confirm"] = "Copy profiles %s?\n\nNothing will be overwritten nor deleted."
L["profile.copy-c>a"] = "from |cff00f000this char|r to |cff00f000account wide shared|r"
L["profile.copy-a>c"] = "from |cff00f000account wide shared|r to |cff00f000this char|r"

L["chat.Debug"] = "Debug: "
L["chat.Autoopen"] = "Auto open & close: "
L["chat.Together"] = "Together mode: "
L["chat.Showoff"] = "Show off mode: "
L["chat.Random"] = "Random: "
L["chat.Taxi"] = "Taxi mode: "

L["on"] = "on"
L["off"] = "off"

L["button.OK"] = "OK"
L["button.Add"] = "Add"
L["button.Duplicate"] = "Copy"
L["button.Delete"] = "Delete"
L["button.Edit"] = "Edit"
L["button.CopyC2A"] = "Char > Account"
L["button.CopyA2C"] = "Account > Char"

L["Mount journal - Open Mounty"] = "Mounty #TLV"

L["quick.title"] = "Quick start"
L["quick.text"] = "- Pull your favourite mounts from the mount journal into the categories of Mounty #TLV.\n- Open WoW's settings for key bindings, select Mounty #TLV and configure your magic key to mount.\n- Press your magic key to pick up the perfect mount for here and now.\n- Enjoy Mounty #TLV and take a look and all the other options and possibilities."

L["upgrade"] = "You can now assign |cff00f000110 mounts|r to each category."

local _, Mounty = ...
Mounty.L = L