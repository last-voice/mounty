if (GetLocale() ~= "deDE") then return end

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

L["Taxi!"] = "Taxi!"

L["Options"] = "Mounty #TLV - Optionen"
L["Quick start"] = "Quick-Start"
L["Random"] = "Zufällig (Wenn nicht angehakt, kommen die Mounts je Kategorie der Reihe nach)"
L["Look at me!"] = "Seht her! Angeberei in Ruhebereichen"
L["Stay together"] = "Als Gruppe zusammen bleiben, nicht fliegen (außer als Taxi)"
L["Taxi mode"] = "Taxi-Modus"
L["Debug mode"] = "Debug-Modus (nur englisch)"
L["Auto open"] = "Automatisch mit der Reittiersammlung öffnen und schließen"
L["Summon repair mount if durability is less than %d%%."] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["How to call a passenger"] = "So rufst du deinen Passagier"

L["Helptext"] = "Mounts hier reinziehen. Rechtsklick, um Mount zu entfernen."

L["Debug: "] = "Debug: "
L["Auto open & close: "] = "Auto öffnen: "
L["Together mode: "] = "Zusammen bleiben: "
L["Show off mode: "] = "Angeberei: "
L["Random: "] = "Zufall: "
L["Taxi mode: "] = "Taxi-Modus: "

L["on"] = "an"
L["off"] = "aus"

L["Open Mounty"] = "Mounty #TLV"

L["Quick start full"] = "- Ziehe deine liebsten Reittiere mit der Maus in die entsprechenden Kategorien von Mounty #TLV.\n- Öffne WoWs Tastaturbelegungen, wähle Mounty #TLV und konfiguriere deine magische Taste.\n- Drücke deine magische Taste um hier und jetzt immer das perfekte Reittier zu rufen.\n- Genieße Mounty #TLV und schau dir gerne auch alle weiteren Optionen und Mögichkeiten an."

local _, Mounty = ...
Mounty.L = setmetatable(L, { __index = Mounty.L })
