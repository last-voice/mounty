if (GetLocale() ~= "deDE") then return end

local L = {}

L["mode.Ground"] = "Reiten"
L["mode.Flying"] = "Fliegen"
L["mode.Water"] = "Schwimmen"
L["mode.Repair"] = "Reparieren"
L["mode.Taxi"] = "Taxi"
L["mode.Show off"] = "Angeberei"
L["mode.Random"] = "Zufällig"

L["Summon magic mount"] = "Magisches Mount"
L["Summon water mount"] = "Wasser-Mount"
L["Summon taxi mount"] = "Taxi-Mount"
L["Summon repair mount"] = "Mount zum reparieren"
L["Summon show off mount"] = "Angeben!"
L["Summon random mount"] = "Ganz zufälliges Mount"
L["Force dismount"] = "Absteigen!"

L["Taxi!"] = "Taxi!"

L["Options"] = "Mounty #TLV - Optionen"
L["Random"] = "Zufällig"
L["Don't fly (except if taxi)"] = "Nicht in der Gruppe fliegen (außer als Taxi)"
L["Taxi mode"] = "Taxi-Modus"
L["Debug mode"] = "Debug-Modus (nur englisch)"
L["Auto open"] = "Automatisch mit der Reittiersammlung öffnen und schließen"
L["Summon repair mount if durability is less than %d%%."] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["How to call a passenger"] = "So rufst du deinen Passagier"

L["Helptext"] = "Mounts hier reinziehen. Rechtsklick, um Mount zu entfernen."

L["Debug: "] = "Debug: "
L["fly mode: "] = "Flug-Modus: "
L["random: "] = "Zufall: "
L["taxi: "] = "Taxi: "

L["on"] = "an"
L["off"] = "aus"

L["Open Mounty"] = "Mounty #TLV"

local _, Mounty = ...
Mounty.L = setmetatable(L, { __index = Mounty.L })
