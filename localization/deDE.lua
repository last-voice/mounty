if (GetLocale() ~= "deDE") then
    return
end

local L = {}
-- local _G = _G

_G["BINDING_NAME_MOUNTY_MAGIC"] = "Magisches Mount"
_G["BINDING_NAME_MOUNTY_GROUND"] = "Boden-Mount"
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

L["options.Random"] = "Zufällig (Wenn nicht angehakt, kommen die Mounts je Kategorie der Reihe nach)"
L["options.Look"] = "Seht her! Angeberei in Ruhebereichen"
L["options.Stay"] = "Als Gruppe zusammen bleiben, nicht fliegen (außer als Taxi)"
L["options.Taxi"] = "Taxi-Modus"
L["options.Debug"] = "Debug-Modus (nur englisch)"
L["options.Autoopen"] = "Automatisch mit der Reittiersammlung öffnen und schließen"
L["options.Durability"] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["options.Hello"] = "So rufst du deinen Passagier"
L["options.Hello-Default"] = "Taxi!"
L["options.Helptext"] = "Mounts hier reinziehen. Rechtsklick, um Mount zu entfernen."
L["options.Profile"] = "Profil"
L["options.ShareProfiles"] = "Profile mit deinen anderen Charakteren teilen"

L["profile.switched"] = "Zu Profil |cff00f000%s|r gewechselt."
L["profile.delete-confirm"] = "Das Profil |cff00f000%s|r wirklich löschen?"
L["profile.current"] = "Aktuelles Profil: |cff00f000%s|r"
L["profile.error"] = "Bitte nur |cff00f000Buchstaben und Ziffern|r verwenden."
L["profile.empty"] = "Bitte gib einen |cff00f000Profilnamen|r ein."
L["profile.none"] = "Das Profil |cff00f000%s|r existiert nicht."
L["profile.already"] = "Das Profil |cff00f000%s|r existiert bereits."
L["profile.copy-confirm"] = "Profile %s kopieren?\n\nEs wird nichts überschrieben oder gelöscht."
L["profile.copy-c>a"] = "von |cff00f000diesem Charakter|r zu |cff00f000accountweit|r"
L["profile.copy-a>c"] = "von |cff00f000accountweit|r zu |cff00f000diesem Charakter|r"

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
L["button.CopyC2A"] = "Char > Account"
L["button.CopyA2C"] = "Account > Char"

L["Mount journal - Open Mounty"] = "Mounty #TLV"

L["quick.title"] = "Quick-Start"
L["quick.text"] = "- Ziehe deine liebsten Reittiere mit der Maus in die entsprechenden Kategorien von Mounty #TLV.\n- Öffne WoWs Tastaturbelegungen, wähle Mounty #TLV und konfiguriere deine magische Taste.\n- Drücke deine magische Taste um hier und jetzt immer das perfekte Reittier zu rufen.\n- Genieße Mounty #TLV und schau dir gerne auch alle weiteren Optionen und Mögichkeiten an."

local _, Mounty = ...
Mounty.L = setmetatable(L, { __index = Mounty.L })
