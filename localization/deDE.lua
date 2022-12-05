if (GetLocale() ~= "deDE") then
    return
end

local L = {}
local _G = _G

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

L["options.Hello-Default"] = "Taxi!"

L["options.Random"] = "Zufällig (Wenn nicht angehakt, kommen die Mounts je Kategorie der Reihe nach)"
L["options.Look"] = "Seht her! Angeberei in Ruhebereichen"
L["options.Stay"] = "Als Gruppe zusammen bleiben, nicht fliegen (außer als Taxi)"
L["options.Taxi"] = "Taxi-Modus"
L["options.Debug"] = "Debug-Modus (nur englisch)"
L["options.Autoopen"] = "Automatisch mit der Reittiersammlung öffnen und schließen"
L["options.Durability"] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["options.Hello"] = "So rufst du deinen Passagier"
L["options.Helptext"] = "Mounts hier reinziehen. Rechtsklick, um Mount zu entfernen."
L["options.Profile"] = "Aktuelles Profil (Siehe README für weitere Infos.)"

L["chat.profile-switched"] = "Zu Profil |cff00f000%d|r gewechselt."
L["chat.profile-deleted"] = "Profil |cff00f000%d|r wurde gelöscht."
L["chat.profile-current"] = "Aktuelles Profil: %d."
L["chat.profile-error"] = "Bitte |cff00f000eine Nummer|r eingeben."
L["chat.profile-empty"] = "Profil |cff00f000%d|r ist leer."
L["chat.profile-copied"] = "Profil |cff00f000%d|r zu |cff00f000%d|r kopiert."


L["chat.Debug"] = "Debug: "
L["chat.Autoopen"] = "Auto öffnen: "
L["chat.Together"] = "Zusammen bleiben: "
L["chat.Showoff"] = "Angeberei: "
L["chat.Random"] = "Zufall: "
L["chat.Taxi"] = "Taxi-Modus: "

L["on"] = "an"
L["off"] = "aus"

L["Mount journal - Open Mounty"] = "Mounty #TLV"

L["quick.title"] = "Quick-Start"
L["quick.text"] = "- Ziehe deine liebsten Reittiere mit der Maus in die entsprechenden Kategorien von Mounty #TLV.\n- Öffne WoWs Tastaturbelegungen, wähle Mounty #TLV und konfiguriere deine magische Taste.\n- Drücke deine magische Taste um hier und jetzt immer das perfekte Reittier zu rufen.\n- Genieße Mounty #TLV und schau dir gerne auch alle weiteren Optionen und Mögichkeiten an."

local _, Mounty = ...
Mounty.L = setmetatable(L, { __index = Mounty.L })
