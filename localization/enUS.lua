local L = {}

BINDING_NAME_MOUNTY_MAGIC = "|cfff0b040Summon magic mount|r"
BINDING_NAME_MOUNTY_GROUND = "Summon ground mount"
BINDING_NAME_MOUNTY_FLY = "Summon flying mount"
BINDING_NAME_MOUNTY_DRAGONFLIGHT = "Dragonflight"
BINDING_NAME_MOUNTY_WATER = "Summon water mount"
BINDING_NAME_MOUNTY_TAXI = "Summon taxi mount"
BINDING_NAME_MOUNTY_REPAIR = "Summon repair mount"
BINDING_NAME_MOUNTY_SHOWOFF = "Summon show off mount"
BINDING_NAME_MOUNTY_RANDOM = "Summon random mount"
BINDING_NAME_MOUNTY_DISMOUNT = "Force dismount"
BINDING_NAME_MOUNTY_CUSTOM1 = "|cfff07070Custom 1|r"
BINDING_NAME_MOUNTY_CUSTOM2 = "|cfff07070Custom 2|r"
BINDING_NAME_MOUNTY_CUSTOM3 = "|cfff07070Custom 3|r"

L["mode.Ground"] = "Ground"
L["mode.Flying"] = "Flying"
L["mode.Dragonflight"] = "Dragonflight"
L["mode.Water"] = "Water"
L["mode.Repair"] = "Repair"
L["mode.Taxi"] = "Taxi"
L["mode.Show off"] = "Show off"
L["mode.Random"] = "Random"
L["mode.Custom1"] = "|cfff07070Custom 1|r"
L["mode.Custom2"] = "|cfff07070Custom 2|r"
L["mode.Custom3"] = "|cfff07070Custom 3|r"

L["options.Random"] = "Random (instead of one by one)"
L["options.Look"] = "Look at me! (Show off in resting areas)"
L["options.Parachute"] = "Parachute mode - dismount anyway, no matter how high you fly and deep the fall"
L["options.Together"] = "In group: Stay on ground together and don't summon flying mounts (except taxi)"
L["options.AlternateSwimming"] = "Whilst swimming alternate between water mounts and flying mounts"
L["options.Taxi"] = "Taxi mode (Always summon taxi mount when in group)"
L["options.Debug"] = "Debug mode"
L["options.Autoopen"] = "Auto open and close with mount journal"
L["options.Durability"] = "Summon repair mount if durability is less than %d%%."
L["options.JournalButtonOffset"] = "Offset of the button in mount journal: %d (1 to hide)."
L["options.Hello"] = "How to call your taxi passenger"
L["options.Hello-Default"] = "Taxi!"
L["options.Helptext"] = "Drag mounts into here | Double click = Copy | Right click = Delete"
L["options.Profile"] = "Profile"
L["options.ShareProfiles"] = "Share profiles with your other characters"
L["options.popup.Already"] = "The mount is already assigned to this category."

L["expanded.Add"] = "Add from journal"
L["expanded.Refresh"] = "Refresh"
L["expanded.Clear"] = "Clear"
L["expanded.popup.refresh-confirm"] = "|cff00f010Close all gaps|r of the current category?"
L["expanded.popup.clear-confirm"] = "|cff00f010Empty|r the current category?"
L["expanded.popup.add-journal-confirm"] = "|cff00f010Add|r all |cff00f010currently filtered and collected mounts|r from the journal to the current category?"

L["profile.switched"] = "Switched to profile |cff00f010%s|r."
L["profile.popup.delete-confirm"] = "Delete profile |cff00f010%s|r?"
L["profile.current"] = "Current profile: |cff00f010%s|r"
L["profile.popup.error"] = "Please use |cff00f010letters and digits|r only."
L["profile.popup.empty"] = "Please enter a |cff00f010profile name|r."
L["profile.popup.none"] = "Profile |cff00f010%s|r not found."
L["profile.popup.already"] = "Profile |cff00f010%s|r already exists."
L["profile.popup.copy-confirm"] = "Copy profiles %s?\n\nNothing will be overwritten nor deleted."
L["profile.copy-c>a"] = "from |cff00f010this char|r to |cff00f010account wide shared|r"
L["profile.copy-a>c"] = "from |cff00f010account wide shared|r to |cff00f010this char|r"

L["chat.Debug"] = "Debug: "
L["chat.Autoopen"] = "Auto open & close: "
L["chat.Parachute"] = "Parachute mode: "
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
L["button.CopyC2A"] = "Char>Account"
L["button.CopyA2C"] = "Account>Char"
L["button.Journal"] = "Mount journal"
L["button.Help"] = "Help"

L["Mount journal - Open Mounty"] = "Mounty #TLV"

L["help"] = [[Insert coin and try again!\n
/mounty  - to open the options frame\n
/mounty magic - to let Mounty #TLV's magic happen\n
/mounty ground - to summon ground mount\n
/mounty fly - to summon fly mount\n
/mounty water - to summon water mount\n
/mounty repair - to summon repair mount\n
/mounty taxi - to summon taxi mount\n
/mounty showoff - to summon show off mount\n
/mounty random - to summon random mount\n
/mounty random on|off (Random or cycle throught)\n
/mounty showoff on|off (Show off, show off!)\n
/mounty parachute on|off (Dismount at any height)\n
/mounty together on|off (Let's stay together)\n
/mounty swim on|off (Rather swim than fly)\n
/mounty taxi on|off (Use taxi mounts)\n
/mounty auto on|off (Auto open options frame)\n
/mounty debug on|off (Show debug info)\n
/mounty profile - to show the current used profile\n
/mounty profile Heart - to switch to or create the profile Heart\n
/mounty version - to show the current version of the addon]]

L["quick.title"] = "Quick start"
L["quick.text"] = [[- Pull your favourite mounts from the mount journal into the categories of Mounty #TLV.\n
- Open WoW's settings for key bindings, select Mounty #TLV and configure your magic key to mount.\n
- Press your magic key to pick up the perfect mount for here and now.\n
- Enjoy Mounty #TLV and take a look and all the other options and possibilities.\n\n
Take a look at the README for all details.]]

L["readme.URL"] = "https://github.com/last-voice/mounty/blob/main/README.md"

L["upgrade.popup"] = "Introducing |cfff07070parachute mode|r.\nAt your own risk!"

local _, TLV_AddOn = ...
TLV_AddOn.L = L