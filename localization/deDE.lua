if (GetLocale() ~= "deDE") then
    return
end

local L = {}

BINDING_NAME_MOUNTY_MAGIC = "|cfff0b040Magisches Mount|r"
BINDING_NAME_MOUNTY_GROUND = "Boden-Mount"
BINDING_NAME_MOUNTY_FLY = "Flug-Mount"
BINDING_NAME_MOUNTY_DRAGONFLIGHT = "Dragonflight"
BINDING_NAME_MOUNTY_WATER = "Wasser-Mount"
BINDING_NAME_MOUNTY_TAXI = "Taxi-Mount"
BINDING_NAME_MOUNTY_REPAIR = "Reparier-Mount"
BINDING_NAME_MOUNTY_SHOWOFF = "Angeben!"
BINDING_NAME_MOUNTY_RANDOM = "Zufälliges Mount"
BINDING_NAME_MOUNTY_DISMOUNT = "Absteigen!"
BINDING_NAME_MOUNTY_CUSTOM1 = "|cfff07070Custom 1|r"
BINDING_NAME_MOUNTY_CUSTOM2 = "|cfff07070Custom 2|r"
BINDING_NAME_MOUNTY_CUSTOM3 = "|cfff07070Custom 3|r"

L["mode.Ground"] = "Reiten"
L["mode.Flying"] = "Fliegen"
L["mode.Dragonflight"] = "Dragonflight"
L["mode.Water"] = "Schwimmen"
L["mode.Repair"] = "Reparieren"
L["mode.Taxi"] = "Taxi"
L["mode.Show off"] = "Angeberei"
L["mode.Random"] = "Zufällig"
L["mode.Custom1"] = "|cfff07070Custom 1|r"
L["mode.Custom2"] = "|cfff07070Custom 2|r"
L["mode.Custom3"] = "|cfff07070Custom 3|r"

L["options.Random"] = "Zufalls-Modus - Zufällig anstatt eins nach dem anderen"
L["options.Look"] = "Angeber-Modus - In Ruhebereichen mit Angeber-Mounts protzen"
L["options.Together"] = "Nicht-fliegen-Modus - In der Gruppe am Boden bleiben und nicht fliegen"
L["options.Amphibian"] = "Amphibien-Modus - Im Wasser abwechselnd Wasser- und Flug-Mounts rufen"
L["options.Taxi"] = "Taxi-Modus - In einer Gruppe immer dein Taxi-Reittier rufen"
L["options.Hello"] = "So rufst du deinen Taxi-Gast"
L["options.Hello-Default"] = "Taxi!"
L["options.Durability"] = "Service! - Das Reparier-Mount kommt bei weniger als %d%% Rüstung."
L["options.Profile"] = "Profil"
L["options.ShareProfiles"] = "Profile mit deinen anderen Charakteren teilen"
L["options.Parachute"] = "Fallschirm-Modus - Immer absitzen, egal wie hoch du fliegst und tief du fällst"
L["options.Autoopen"] = "Auto-öffnen-Modus - Automatisch mit der Reittiersammlung öffnen und schließen"
L["options.Debug"] = "Debug-Modus - Zeige wilde Infos im Chat (nur englisch)"
L["options.JournalButtonOffset"] = "Offset des Buttons in der Reittiersammlung: %d (1 = verstecken)"
L["options.Helptext"] = "Mounts reinziehen | Doppelklick = Kopieren | Rechtsklick = Löschen"
L["options.popup.Already"] = "Das Reittier ist bereits in dieser Kategorie."

L["expanded.Add"] = "Aus Sammlung hinzufügen"
L["expanded.Refresh"] = "Ordnen"
L["expanded.Clear"] = "Leeren"
L["expanded.popup.refresh-confirm"] = "Alle |cff00f010Lücken|r der aktuellen Kategorie schließen?"
L["expanded.popup.clear-confirm"] = "Die aktuelle Kategoirie |cff00f010leeren|r?"
L["expanded.popup.add-journal-confirm"] = "Alle |cff00f010aktuell gefilterten, gesammelten Reittiere|r zur Kategorie |cff00f010hinzufügen|r?"

L["profile.switched"] = "Zu Profil |cff00f010%s|r gewechselt."
L["profile.current"] = "Aktuelles Profil: |cff00f010%s|r"
L["profile.copy-c>a"] = "von |cff00f010diesem Charakter|r zu |cff00f010accountweit|r"
L["profile.copy-a>c"] = "von |cff00f010accountweit|r zu |cff00f010diesem Charakter|r"
L["profile.popup.delete-confirm"] = "Das Profil |cff00f010%s|r wirklich löschen?"
L["profile.popup.copy-confirm"] = "Profile %s kopieren?\n\nEs wird nichts überschrieben oder gelöscht."
L["profile.popup.error"] = "Bitte nur |cff00f010Buchstaben und Ziffern|r verwenden."
L["profile.popup.empty"] = "Bitte gib einen |cff00f010Profilnamen|r ein."
L["profile.popup.none"] = "Das Profil |cff00f010%s|r existiert nicht."
L["profile.popup.already"] = "Das Profil |cff00f010%s|r existiert bereits."

L["chat.Amphibian"] = "Amphibien-Modus: "
L["chat.Autoopen"] = "Auto öffnen: "
L["chat.Debug"] = "Debug: "
L["chat.Parachute"] = "Fallschirm-Modus: "
L["chat.Random"] = "Zufall: "
L["chat.Showoff"] = "Angeberei: "
L["chat.Taxi"] = "Taxi-Modus: "
L["chat.Together"] = "Zusammen bleiben: "

L["on"] = "an"
L["off"] = "aus"

L["button.OK"] = "OK"
L["button.Add"] = "Neu"
L["button.Duplicate"] = "Kopie"
L["button.Delete"] = "Löschen"
L["button.Edit"] = "Ändern"
L["button.CopyC2A"] = "Char>Account"
L["button.CopyA2C"] = "Account>Char"
L["button.Journal"] = "Reittiere"
L["button.Help"] = "Hilfe"

L["Mount journal - Open Mounty"] = "Mounty #TLV"

L["help"] = [[It's a kind of magic ...
|cfff0b040Optionsfenster öffnen|r
/mounty
|cfff0b040Reittier beschwören|r
/mounty magic||dragonflight||fly||ground||random||repair||showoff||taxi||water
|cfff0b040Optionen setzen|r
/mounty set amphibian||auto||debug||parachute||random||showoff||taxi||together on||off
|cfff0b040Profile|r
/mounty profile (Aktuelles Profil anzeigen)
/mounty profile Heart (Profil Heart auswählen oder erstellen)
|cfff0b040Version|r
/mounty version
]]

L["quick.title"] = "Quick-Start"
L["quick.text"] = [[- Ziehe deine liebsten Reittiere mit der Maus in die entsprechenden Kategorien von Mounty #TLV.
- Öffne WoWs Tastaturbelegungen, wähle Mounty #TLV und konfiguriere deine magische Taste.
- Drücke deine magische Taste um hier und jetzt immer das perfekte Reittier zu rufen.
- Genieße Mounty #TLV und schau dir gerne auch alle weiteren Optionen und Mögichkeiten an.

In der README findest du eine detaillierte Beschreibung.]]

L["readme.URL"] = "https://github.com/last-voice/mounty/blob/main/README.de.md"

L["upgrade.popup"] = "Jetzt mit |cfff07070Amphibien-Modus|r.\nLuft anhalten!\n\n(Im CHANGELOG findest du weitere Updates.)"

local _, TLV_AddOn = ...
TLV_AddOn.L = setmetatable(L, { __index = TLV_AddOn.L })
