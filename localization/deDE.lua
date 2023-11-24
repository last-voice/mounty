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
BINDING_NAME_MOUNTY_SHOWOFF = "Protzen!"
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
L["mode.Show off"] = "Protzerei"
L["mode.Random"] = "Zufällig"
L["mode.Custom1"] = "|cfff07070Custom 1|r"
L["mode.Custom2"] = "|cfff07070Custom 2|r"
L["mode.Custom3"] = "|cfff07070Custom 3|r"

L["mount.Ground"] = "Boden-Mount"
L["mount.Flying"] = "Flug-Mount"
L["mount.Dragonflight"] = "Drachen"
L["mount.Water"] = "Wasser-Mount"
L["mount.Repair"] = "Reparier-Mount"
L["mount.Taxi"] = "Taxi-Mount"
L["mount.Show off"] = "Protz-Mount"
L["mount.Random"] = "Zufalls-Mount"

L["options.Why"] = "Warum-Modus - |cfff07070Magie|r immer im Chat erklären"
L["options.WhyAutoShort"] = "Kürzere Erklärung"
L["options.Random"] = "Zufalls-Modus - Zufällig anstatt eins nach dem anderen"
L["options.Look"] = "Protz-Modus - Protzerei in Ruhebereichen (außerhalb von Dracheninseln)"
L["options.Together"] = "Nicht-fliegen-Modus - In der Gruppe am Boden bleiben und nicht fliegen"
L["options.Amphibian"] = "Amphibien-Modus - Im Wasser abwechselnd Wasser- und Flug-Mounts rufen"
L["options.Taxi"] = "Taxi-Modus - In einer Gruppe immer dein Taxi-Reittier rufen"
L["options.Hello"] = "So rufst du deinen Taxi-Gast"
L["options.Hello-Default"] = "Taxi!"
L["options.Durability"] = "Service! - Das Reparier-Mount kommt bei weniger als %d %% Haltbarkeit."
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
L["chat.Showoff"] = "Protzerei: "
L["chat.Taxi"] = "Taxi-Modus: "
L["chat.Together"] = "Zusammen bleiben: "
L["chat.WhyAuto"] = "Warum-Modus automatisch: "
L["chat.WhyAutoShort"] = "Warum-Modus im kürzeren Format: "

L["on"] = "an"
L["off"] = "aus"

L["cannot mount"] = "Du kannst hier und jetzt kein Mount rufen."

L["button.OK"] = "OK"
L["button.Add"] = "Neu"
L["button.Duplicate"] = "Kopie"
L["button.Delete"] = "Löschen"
L["button.Edit"] = "Ändern"
L["button.CopyC2A"] = "Char>Account"
L["button.CopyA2C"] = "Account>Char"
L["button.Journal"] = "Reittiere"
L["button.Help"] = "Hilfe"
L["button.Close"] = "Schließen"

L["why.long.repair"] = "Deine |hRüstung ist unter %s %%|r."
L["why.long.repair.no"] = "Deine |hRüstung ist mindestens bei %s %%|r. Das Reparier-Mount bleibt im Stall."
L["why.long.repair.use"] = "Hier ist dein |hReparier-Mount|r."
L["why.long.repair.empty"] = "Ups, du hast noch kein Reparier-Mount zugeordnet."
L["why.long.amphibian"] = "Du |hschwimmst und der Amphibien-Modus|r ist aktiv."
L["why.long.amphibian.use"] = "Dieses Mal ist dein |hWasser-Mount|r an der Reihe."
L["why.long.amphibian.alt"] = "Immer abwechselnd, und daher jetzt |hkein Wasser-Mount|r."
L["why.long.amphibian.empty"] = "Wenn Du denn Mounty #TLV eines zugewiesen hättest."
L["why.long.dragonflight"] = "Hier und jetzt kannst du |hDrachen reiten|r."
L["why.long.dragonflight.no"] = "Schade, hier sind |hDrachen verboten|r oder du hast noch keinen."
L["why.long.dragonflight.use"] = "Dann wollen wir mal den |hDrachen|r wecken."
L["why.long.dragonflight.empty"] = "Allerdings schlummert noch keiner in Mounty #TLV."
L["why.long.taxi"] = "Der |hTaxi-Modus|r ist aktiv und du hast Begleitung."
L["why.long.taxi.no1"] = "Du bist |halleine unterwegs|r, ein Taxi-Mount für zwei rufen wir also nicht."
L["why.long.taxi.no2"] = "Du bist zwar in einer Gruppe unterwegs, aber der |hTaxi-Modus ist nicht aktiv|r."
L["why.long.taxi.use"] = "Also sind wir hilfsbereit und rufen unser |hTaxi-Mount|r."
L["why.long.taxi.empty"] = "Es kommt aber keins, denn in Mounty #TLV ist keines zu finden."
L["why.long.taxi.call"] = "Zuerst aber bitten wir deine Begleitung, |haufzuspringen|r."
L["why.long.showoff"] = "Prima, hier ist ein |hRuhebereich|r und du gibst gerne mal an."
L["why.long.showoff.no1"] = "|hKein Ruhebereich|r, keine Protzerei."
L["why.long.showoff.no2"] = "Obwohl hier ein Ruhebereich ist möchtest du |hnicht so gerne protzen|r."
L["why.long.showoff.no3"] = "Um anzugeben müsstest du kurz |haus dem Wasser steigen|r."
L["why.long.showoff.use"] = "Mounty #TLV wird also eines deiner atemberaubenden |hProtz-Mounts|r beschwören."
L["why.long.showoff.empty"] = "Was nicht so einfach ist, denn die Kategorie ist leer."
L["why.long.category.flyable"] = "Und weil du hier |hfliegen|r kannst, gibt es auch eines mit Flügeln."
L["why.long.fly"] = "Lass uns abheben, du |hkannst hier fliegen|r."
L["why.long.fly.no"] = "Hier und jetzt ist |hFliegen keine Option|r für dich."
L["why.long.fly.no.together"] = "Halt, Stopp. Du möchtest ja |hmit deiner Gruppe zusammen am Boden bleiben|r."
L["why.long.fly.ok1"] = "Und du bist |hallein|r."
L["why.long.fly.ok2"] = "Mit deiner Gruppe am Boden bleiben möchtest du auch nicht."
L["why.long.fly.use"] = "Hier kommt also dein |hFlug-Mount|r."
L["why.long.fly.empty"] = "Oh, kommt es nicht, denn du hast Mounty #TLV noch keines zugewiesen."
L["why.long.water"] = "Du |hschwimmst|r."
L["why.long.water.no"] = "Wenigstens |hschwimmt du nicht|r im kalten Wasser."
L["why.long.water.use"] = "Es gibt ja ein paar spezielle |hWasser-Mounts|r. Suchen wir eines davon aus."
L["why.long.water.empty"] = "Deine Auswahl an Wasser-Mounts in Mounty #TLV ist allerdings leer."
L["why.long.ground.use"] = "Aller Magie zum Trotz scheint ein |hBoden-Mount|r die einzige Möglichkeit. Nehmen wir eins."
L["why.long.ground.empty"] = "|hDas endet nicht gut|r. Selbst ein Boden-Mount ist in Mounty #TLV nicht zu finden."
L["why.long.usable.one"] = "|hDas einzige|r, das du hast, ist nutzbar."
L["why.long.usable.all"] = "|hAlle %s|r sind hier und jetzt nutzbar."
L["why.long.usable.some"] = "Hier sind gerade nur |h%s von %s|r einsetzbar."
L["why.long.usable.none"] = "Doch |hkeins der %s|r ist hier gerade nutzbar."
L["why.long.usable.null"] = "Mounty #TLV hat aber |hkein einziges gefunden|r."
L["why.long.fallback.ground"] = "Als |hFallback|r beschören wir nun also ein |hBoden-Mount|r."
L["why.long.fallback.fly"] = "Alternativ versuchen wir es mit einem |hFlug-Mount|r als |hFallback|r."
L["why.long.fallback.random"] = "Die allerletzte Option bleibt |hirgend ein zufälliges Mount|r aus deiner Reittiersammlung."
L["why.long.pick.random"] = "Davon soll es ein |hzufälliges|r sein."
L["why.long.pick.iterator"] = "Und immer |hder Reihe nach|r."
L["why.long.picked"] = "Hier ist dein |h%s|r: |h%s|r. Festhalten!"
L["why.long.lost"] = "|hLost|r. Kein Mount gefunden!"

L["why.short.repair"] = "Haltbarkeit < %s %%"
L["why.short.repair.no"] = "Haltbarkeit >= %s %%"
L["why.short.repair.use"] = "rufe Reparier-Mount"
L["why.short.repair.empty"] = "nix zugewiesen"
L["why.short.amphibian"] = "im Wasser & Amphibien-Modus"
L["why.short.amphibian.use"] = "rufe Wasser-Mount"
L["why.short.amphibian.alt"] = "immer abwechselnd"
L["why.short.amphibian.empty"] = "nix zugewiesen"
L["why.short.dragonflight"] = "Dragonflight"
L["why.short.dragonflight.no"] = "kein Dragonflight"
L["why.short.dragonflight.use"] = "rufe Drachen"
L["why.short.dragonflight.empty"] = "nix zugewiesen"
L["why.short.taxi"] = "in Gruppe & Taxi-Modus"
L["why.short.taxi.no1"] = "keine Gruppe = kein Taxi"
L["why.short.taxi.no2"] = "in Gruppe & kein Taxi-Modus"
L["why.short.taxi.use"] = "rufe Taxi-Mount"
L["why.short.taxi.empty"] = "nix zugewiesen"
L["why.short.taxi.call"] = "Spring auf!"
L["why.short.showoff"] = "Ruhebereich & Protzerei"
L["why.short.showoff.no1"] = "kein Ruhebereich = keine Protzerei"
L["why.short.showoff.no2"] = "Protzerei deaktiviert"
L["why.short.showoff.no3"] = "im Wasser = keine Protzerei"
L["why.short.showoff.use"] = "rufe Protz-Mount"
L["why.short.showoff.empty"] = "nix zugewiesen"
L["why.short.category.flyable"] = "nur fliegende Mounts"
L["why.short.fly"] = "Flugbereich"
L["why.short.fly.no"] = "kein Flugbereich"
L["why.short.fly.no.together"] = "in Gruppe & zusammen bleiben"
L["why.short.fly.ok1"] = "ganz allein"
L["why.short.fly.ok2"] = "in Gruppe & nicht zusammen bleiben"
L["why.short.fly.use"] = "rufe Flug-Mount"
L["why.short.fly.empty"] = "nix zugewiesen"
L["why.short.water"] = "im Wasser"
L["why.short.water.no"] = "nicht im Wasser"
L["why.short.water.use"] = "rufe Wasser-Mount"
L["why.short.water.empty"] = "nix zugewiesen"
L["why.short.ground.use"] = "rufe Boden-Mount"
L["why.short.ground.empty"] = "nix zugewiesen"
L["why.short.usable.one"] = "ist nutzbar"
L["why.short.usable.all"] = "alle %s nutzbar"
L["why.short.usable.some"] = "%s von %s nutzbar"
L["why.short.usable.none"] = "keins von %s nutzbar"
L["why.short.usable.null"] = "keins gefunden"
L["why.short.fallback.ground"] = "Fallback: Boden-Mount"
L["why.short.fallback.fly"] = "Fallback: Flug-Mount"
L["why.short.fallback.random"] = "letzte Option: Irgendein zufälliges Mount"
L["why.short.pick.random"] = "zufällige Auswahl"
L["why.short.pick.iterator"] = "immer der Reihe nach"
L["why.short.picked"] = "also: |h%s|r - |h%s|r"
L["why.short.lost"] = "kein Mount gefunden!"

L["why.out.header"] = "|hWieso, weshalb, warum?|r"
L["why.out.none"] = "Keine Ahnung, die Historie ist leer."

L["Mount journal - Open Mounty"] = "Mounty #TLV"

L["help"] = [[It's a kind of magic ...
|hOptionsfenster öffnen|r
/mounty
|hReittier beschwören|r
/mounty magic|ddragonflight|dfly|dground|drandom|drepair|dshowoff|dtaxi|dwater
|hWieso, weshalb, warum?|r
/mounty why (Das zuletzt gewählte Mount erläutern)
/mounty why 2-%d (Zeige einen älteren Eintrag der Historie an)
/mounty why all (Zeige die ganze Historie an)
|hOptionen setzen|r
/mounty set amphibian|dauto|ddebug|dparachute|drandom|dshowoff|dtaxi|dtogether|dwhy|dwhyshort on|doff
|hProfile|r
/mounty profile (Aktuelles Profil anzeigen)
/mounty profile Heart (Profil Heart auswählen oder erstellen)
|hVersion|r
/mounty version
]]

L["quick.title"] = "Quick-Start"
L["quick.text"] = [[- Ziehe deine liebsten Reittiere mit der Maus in die entsprechenden Kategorien von Mounty #TLV.
- Öffne WoWs Tastaturbelegungen, wähle Mounty #TLV und konfiguriere deine magische Taste.
- Drücke deine magische Taste um hier und jetzt immer das perfekte Reittier zu rufen.
- Genieße Mounty #TLV und schau dir gerne auch alle weiteren Optionen und Mögichkeiten an.

In der README findest du eine detaillierte Beschreibung.]]

L["readme.URL"] = "https://github.com/last-voice/mounty/blob/main/README.de.md"

L["why.example"] = "Das gerade war ein einmaliges Beispiel für den |cfff07070Warum-Modus|r. Kommt nicht nochmal. Tippe |cfff07070/mounty why|r oder |cfff07070/mounty why 2-10|r jederzeit im Chat, um Erklärungen für die letzten Mounts zu bekommen. Oder aktiviere den |cfff07070automatischen Warum-Modus|r in den Optionen von Mounty #TLV."

--L["upgrade.popup"] = "Voll toll, der neue |cfff07070Warum-Modus|r inkl. Historie.\nSofort ausprobieren!\n\n(In den Optionen einschalten oder\nim Chat '/mounty why' eingeben.\nTippe '/mounty help' für mehr.)\n\n--° -°° °°° °.° ..° ... °.. °.° °°° °°- °--\n\nKleine Spenden sind willkommen. Siehe README."
L["upgrade.popup"] = "Auch in der |cfff07070Jahrhunderschwelle|r werden nun Reittiere gerufen. Allerdings war dafür ein kleiner Workaround notwendig, denn laut WOW-API befindet ihr euch dort eigentlich im |cfff07070Nirgendwo|r.\n\n--° -°° °°° °.° ..° ... °.. °.° °°° °°- °--\n\nKleine Spenden sind willkommen. Siehe README."

local _, TLV_AddOn = ...
TLV_AddOn.L = setmetatable(L, { __index = TLV_AddOn.L })
