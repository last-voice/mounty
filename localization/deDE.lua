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

L["options.Random"] = "Zufällig (anstatt der Reihe nach)"
L["options.Look"] = "Seht her! (In Ruhebereichen angeben)"
L["options.Stay"] = "In der Gruppe am Boden bleiben und nicht fliegen (außer du bist das Taxi)"
L["options.Taxi"] = "Taxi-Modus (In einer Gruppe immer dein Taxi-Reittier rufen)"
L["options.Debug"] = "Debug-Modus (nur englisch)"
L["options.Autoopen"] = "Automatisch mit der Reittiersammlung öffnen und schließen"
L["options.Durability"] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["options.JournalButtonOffset"] = "Offset des Buttons in der Reittiersammlung: %d (1 = verstecken)."
L["options.Hello"] = "So rufst du deinen Taxi-Gast"
L["options.Hello-Default"] = "Taxi!"
L["options.Helptext"] = "Mounts hier reinziehen. Rechtsklick, um Mount zu entfernen."
L["options.Profile"] = "Profil"
L["options.ShareProfiles"] = "Profile mit deinen anderen Charakteren teilen"
L["options.Already"] = "Das Reittier ist bereits in dieser Kategorie."

L["expanded.Add"] = "Aus Sammlung hinzufügen"
L["expanded.Refresh"] = "Ordnen"
L["expanded.Clear"] = "Leeren"
L["expanded.refresh-confirm"] = "Alle |cff00f010Lücken|r der aktuellen Kategorie schließen?"
L["expanded.clear-confirm"] = "Die aktuelle Kategoirie |cff00f010leeren|r?"
L["expanded.add-journal-confirm"] = "Alle |cff00f010aktuell gefilterten, gesammelten Reittiere|r zur Kategorie |cff00f010hinzufügen|r?"

L["profile.switched"] = "Zu Profil |cff00f010%s|r gewechselt."
L["profile.delete-confirm"] = "Das Profil |cff00f010%s|r wirklich löschen?"
L["profile.current"] = "Aktuelles Profil: |cff00f010%s|r"
L["profile.error"] = "Bitte nur |cff00f010Buchstaben und Ziffern|r verwenden."
L["profile.empty"] = "Bitte gib einen |cff00f010Profilnamen|r ein."
L["profile.none"] = "Das Profil |cff00f010%s|r existiert nicht."
L["profile.already"] = "Das Profil |cff00f010%s|r existiert bereits."
L["profile.copy-confirm"] = "Profile %s kopieren?\n\nEs wird nichts überschrieben oder gelöscht."
L["profile.copy-c>a"] = "von |cff00f010diesem Charakter|r zu |cff00f010accountweit|r"
L["profile.copy-a>c"] = "von |cff00f010accountweit|r zu |cff00f010diesem Charakter|r"

L["chat.Debug"] = "Debug: "
L["chat.Autoopen"] = "Auto öffnen: "
L["chat.Together"] = "Zusammen bleiben: "
L["chat.Showoff"] = "Angeberei: "
L["chat.Random"] = "Zufall: "
L["chat.Taxi"] = "Taxi-Modus: "

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

L["quick.title"] = "Quick-Start"
L["quick.text"] = "- Ziehe deine liebsten Reittiere mit der Maus in die entsprechenden Kategorien von Mounty #TLV.\n- Öffne WoWs Tastaturbelegungen, wähle Mounty #TLV und konfiguriere deine magische Taste.\n- Drücke deine magische Taste um hier und jetzt immer das perfekte Reittier zu rufen.\n- Genieße Mounty #TLV und schau dir gerne auch alle weiteren Optionen und Mögichkeiten an.\n\nIn der README findest du eine detaillierte Beschreibung."

L["readme.URL"] = "https://github.com/last-voice/mounty/blob/main/README.de.md"

L["upgrade"] = "Du hast nun 3 weitere Kategorien zu deiner freien Verfügung\n(via Tastaturbelegung)."

local _, TLV_AddOn = ...
TLV_AddOn.L = setmetatable(L, { __index = TLV_AddOn.L })
