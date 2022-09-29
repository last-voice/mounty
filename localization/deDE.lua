if( GetLocale() ~= "deDE" ) then return end

local L = {}

L["Ground"] = "Reiten"
L["Flying"] = "Fliegen"
L["Water"] = "Schwimmen"
L["Repair"] = "Reparieren"
L["Taxi"] = "Taxi"
L["Show off"] = "Angeberei"

L["Armor is at"] = "Rüstung"
L["is usable: "] = "benutzbar: "
L["key pressed"] = "Taste gedrückt"
L["key: "] = "Taste: "
L["is mounted"] = "auf Mount"
L["special key"] = "Sondertaste"
L["magic key"] = "Magische Taste"
L["category: "] = "Kategorie: "
L["selected "] = "ausgewählt "
L["No mount found!"] = "Nicht gefunden!"

L["Category: "] = "Kategorie: "
L["Type: "] = "Typ: "

L["fail"] = "Fehler"
L["already"] = "doppelt"
L["saved: "] = "Gespeichert: "
L["deleted: "] = "Gelöscht: "

L["Taxi!"] = "Taxi!"

L["Options"] = "Optionen"
L["Random"] = "Zufällig"
L["Don't fly (except if taxi)"] = "Nicht fliegen (außer wenn Taxi)"
L["Taxi mode"] = "Taxi-Modus"
L["Debug mode"]= "Debug-Modus"
L["Summon repair mount if durability is less than %d%%."] = "Das Repair kommt bei weniger als %d%% Rüstung."
L["How to call a passenger"] = "So rufst du deinen Passagier"

L["Debug: "] = "Debug: "
L["fly mode: "] = "Flug-Modus: "
L["random: "] = "Zufall: "
L["taxi: "] = "Taxi: "

L["on"] = "an"
L["off"] = "aus"

local _, Mounty = ...
Mounty.L = setmetatable(L, {__index = Mounty.L})
