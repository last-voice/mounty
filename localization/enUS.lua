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

L["options.Random"] = "Random mode - Choose random mount instead of one by one"
L["options.Look"] = "Show off mode - Show off in resting areas"
L["options.Together"] = "Together mode tay together whilst in group and don't summon flying mounts"
L["options.Amphibian"] = "Amphibian mode - Whilst swimming alternate between water and flying mounts"
L["options.Taxi"] = "Taxi mode - Always summon taxi mount when in group"
L["options.Hello"] = "How to call your taxi passenger"
L["options.Hello-Default"] = "Taxi!"
L["options.Durability"] = "Service! - Summon your repair mount if durability is below %d%%."
L["options.Profile"] = "Profile"
L["options.ShareProfiles"] = "Share profiles with your other characters"
L["options.Parachute"] = "Parachute mode - Dismount anyway, no matter how high you fly and deep the fall"
L["options.Autoopen"] = "Auto open mode - Auto open and close with mount journal"
L["options.Debug"] = "Debug mode - Show lots of weird data in the chat"
L["options.JournalButtonOffset"] = "Offset of the button in mount journal: %d (1 to hide)."
L["options.Helptext"] = "Drag mounts into here | Double click = Copy | Right click = Delete"
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

L["chat.Amphibian"] = "Amphibian mode: "
L["chat.Autoopen"] = "Auto open & close: "
L["chat.Debug"] = "Debug: "
L["chat.Parachute"] = "Parachute mode: "
L["chat.Random"] = "Random: "
L["chat.Showoff"] = "Show off mode: "
L["chat.Taxi"] = "Taxi mode: "
L["chat.Together"] = "Together mode: "

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

L["why.repair"] = "Your durability is below %d%%."
L["why.repair.no"] = "Your durability is fine."
L["why.repair.use"] = "So Mounty #TLV will try to summon a repair mount."
L["why.repair.empty"] = "But you have not assigned a repair mount to be summoned."
L["why.amphibian"] = "You are swimming and amphibian mode is active."
L["why.amphibian.use"] = "So this time a water mount is chosen."
L["why.amphibian.empty"] = "Since you don't have a water mount assigned, none can be chosen."
L["why.dragonflight"] = "This is a good place cause dragons can be used."
L["why.dragonflight.no"] = "Sadly, this is no area where dragons can be used or you haven't got one yet."
L["why.dragonflight.use"] = "Let's try to call a dragon, then."
L["why.dragonflight.empty"] = "And this is a bad idea, because you don't seem to have one assigned."
L["why.taxi"] = "With a friend at your side and taxi mode active."
L["why.taxi.no1"] = "You are in no group, so why be a taxi?"
L["why.taxi.no2"] = "You are in company but the taxi mode is not active."
L["why.taxi.use"] = "So you are polite and invite your friend for a ride and call a taxi mount."
L["why.taxi.empty"] = "If you would have had assigned a taxi mount, you'd rather carry your friend around. But you haven't."
L["why.taxi.call"] = "But let's call your friend to hopp on first."
L["why.showoff"] = "This is a resting area and you want to show off."
L["why.showoff.no1"] = "No resting area, no show off."
L["why.showoff.no2"] = "Although in a resting area, you just don't want to show off."
L["why.showoff.no3"] = "To show off in this resting area you should get out of the water first."
L["why.showoff.use"] = "Mounty #TLV will try summon one of your beautiful show off mounts."
L["why.showoff.empty"] = "But there is no show off mount found in Mounty #TLV's category."
L["why.showoff.flyable"] = "And for it's a flying area, only your flying show off mounts will be chosen of."
L["why.fly"] = "Up, up, up, my friend. You can fly in this area."
L["why.fly.no"] = "Over here flying is no option. Or you haven't learned it yet."
L["why.fly.no.together"] = "But since you are in company and want to stay on the ground together you won't take off."
L["why.fly.ok1"] = "And you are on your own."
L["why.fly.ok2"] = "And you don't have to stay on the ground with your company."
L["why.fly.use"] = "We better try to quickly summon a flying mount."
L["why.fly.empty"] = "On the other hand you have no flying mount assigned in Mounty #TLV."
L["why.water"] = "You are swimming."
L["why.water.no"] = "You are on dry land. And least your feet touch the ground."
L["why.water.use"] = "There are only a few water mounts to summon. Let's choose one."
L["why.water.empty"] = "No water mount can be found in Mounty #TLV, so none can be summoned."
L["why.ground.use"] = "No magic needed. A ground mount seems to be best. Let's get one."
L["why.usable.all"] = "All of your %d assigned mounts are usable here and now."
L["why.usable.some"] = "At this time and place you can use %d of your %d assigned mounts."
L["why.usable.none"] = "None of your %d assigned mounts can be used by now for any reason."
L["why.usable.null"] = "Mounty #TLV has not found any assigned mount in this category."
L["why.fallback.ground"] = "So we try to summon a ground mount then."
L["why.fallback.fly"] = "As a fallback Mounty #TLV will switch to flying mounts instead."
L["why.fallback.random"] = "The last straw is to summon any random mount out of your mount journal."
L["why.pick.random"] = "Out of these a random one will be picked."
L["why.pick.iterator"] = "The next in line of these will be picked."
L["why.picked"] = "And finally this is your mount: |cfff07070%s|r. Enjoy the ride!"
L["why.out"] = "|cfff07070Tell me why!|r"
L["why.out.none"] = "I can't tell you why. No history entry found."

L["help"] = [[It's a kind of magic ...
|cfff0b040Open options frame|r
/mounty
|cfff0b040Summon mount|r
/mounty magic||dragonflight||fly||ground||random||repair||showoff||taxi||water
|cfff0b040Tell me why|r
/mounty why 1-%d (Why was the former mount chosen?)
|cfff0b040Set options|r
/mounty set amphibian||auto||debug||parachute||random||showoff||taxi||together on||off
|cfff0b040Profiles|r
/mounty profile (Show current profile)
/mounty profile Heart (Select or create profile Heart)
|cfff0b040Show version|r
/mounty version
]]

L["quick.title"] = "Quick start"
L["quick.text"] = [[- Pull your favourite mounts from the mount journal into the categories of Mounty #TLV.
- Open WoW's settings for key bindings, select Mounty #TLV and configure your magic key to mount.
- Press your magic key to pick up the perfect mount for here and now.
- Enjoy Mounty #TLV and take a look and all the other options and possibilities.

Take a look at the README for all details.]]

L["readme.URL"] = "https://github.com/last-voice/mounty/blob/main/README.md"

L["upgrade.popup"] = "Introducing |cfff07070Amphibia mode|r.\nHold your breath!\n\n(See CHANGELOG for more updates.)"

local _, TLV_AddOn = ...
TLV_AddOn.L = L