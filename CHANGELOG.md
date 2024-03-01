## Mounty #TLV changelog

full changelog: https://github.com/last-voice/mounty/blob/main/CHANGELOG.md

v2.7.6.2
- fixed stupid bug

v2.7.6.1
- dragon riding and flyable mounts issues again - next try
- better selection of show off and taxi mounts when in flying areas

v2.7.5
- dragon riding and flyable mounts issues
- new dragonflight mode

v2.7.4.3
- dragon riding and flyable mounts issues
- Interface 100205

v2.7.4.2
- check for dragon flight now also includes check of flyable area.

v2.7.4.1
- minor code improvement

v2.7.4
- the detection of the players ability to use flight mounts was buggy. fixed it. (thanks to Paco-4272)
- chat command '/mounty random' did not work at all. fixed it. 
- chat command '/mounty random' now also changed to '/mounty surprise'.
- improved debug output and minor typos in README.md

v2.7.3
- The transforming mounts Sandstone Drake and Obsidian Nightwing will now correctly be recognized as flyable (cheers to khedrak, once again)

v2.7.2.2
- testing auto packaging of CurseForge

v2.7.2
- testing auto packaging of CurseForge

v2.7.1.8
- minor upgrade info bugfix, again ^^

v2.7.1.7
- missing backslashes in README (ty! to https://github.com/HugoVG)

v2.7.1.6
- minor upgrade info bugfix

v2.7.1.5
- hotfix, because C_Map.GetBestMapForUnit won't return anything whilst in Millennial's Threshold

v2.7.1.4
- in flyable areas only flying taxi mounts will be chosen

v2.7.1.3
- fixed bug when switching tabs in collections journals
- cleaned up SavedVariables
- interface: 100005

v2.7.1.2
- new chat message when mounting seems impossible
- some pimp my code

v2.7.1.1
- bugfix - dismount didn't work anymore when in situations where mounting is not possible, i.e. in combat. now fixed. 

v2.7.1
- after using portals, the map ip is set to the continent for a second. this is now checked before summoning.
- optimized the workflow and condition checks for better debugging  
- finally the button bottom right is now a 'close' button since i always hit the 'help' button myself to close mounty. ^^
- minor code improvement
- some wording

v2.7.0.3
- now also checks if a mount is collected and usable regarding faction
- now also checks if the player is falling or already casting a spell when pressing magic key
- chosen category now displayed in why mode choice too
- minor fixes + changes

v2.7.0.2
- fixed history bug in why mode
- why mode wording

v2.7
- the new 'why mode' is awesome, i promise!
- no automatic order of mounts in the grid anymore; more freedom to the users. ^^
- minor changes, minor fixes, minor improvements
- any donations via paypal to thank.you.tlv@gmail.com are welcome. of course no must! thank you ;)

v2.6
- new option to alternate between water mount and flying mounts whilst swimming
- if the player is currently casting any spell, mounty won't do anything no more
- dragonflight check modified because of a user's feedback of strange behaviour (different approach now)
- optimized check for usability of mounts at current time and place
- new logic: dragonflight before taxi mount (see readme)
- command line help
- much better command line handling
- minor improvements
- minor bug fixes
- readme updated and improved

v2.5.5
- introducing optional parachute mode - dismount anyway, no matter how high you fly and deep the fall (cheers to khedrak, again)
- i myself use elvui so i didn't take a closer look at mounty's layout without - fixed this now 

v2.5.4
- new feature: copy mounts by double clicking

v2.5.3.2
- peeps, i'm working on another add on. so i changed the file structure of mounty too. this caused quite some chaos. finally, this version should be stable again. sorry!

v2.5.3.1
- stupid me :-/

v2.5.3
- sorry, bad bug prevented mounty to upgrade from older versions. this is now fixed.
- also changed the too generic name of saved variable.

v2.5.2.3
- tlvlib in separate repo

v2.5.2.2
- the + buttons now toggle the expanded frame

v2.5.2.1
- the button in the mount journal can now be positioned or be hidden (cheers to khedrak)
- changed the grid size for a more compact design
- readme ist up to date

v2.5.2
- now all categories have their own key binding
- also there a 3 more categories custom 1 to 3 for your free use
- refactored code again for more oop
- readme will be up to date soon

v2.5.1.1
- colors

v2.5.1
- make up

v2.5
- 110 mounts per category!
- easily transfer all filtered mounts from mount journal into selected category

v2.4.3.2
- another bugfix in upgrade routine, this time well tested ^^

v2.4.3.1
- bugfix in upgrade routine

v2.4.3
- profiles can now be used account wide an so be shared between your characters
- profiles can also be copied from account to char and vice versa
- in dragonflight resting areas dragons are no preferred before show offs
- removed some chat commands - it became too complicated - sorry!
- readme up to date

v2.4.2.1
- fixed background strata bug

v2.4.2
- profile can be renamed
- code refactoring 
- readmes up to date

v2.4.1
- readmes up to date

v2.4
- here come the profiles
- version in title
- version via chat command (/mounty version)
- strata fixes
- code improvement during start of another add on
- quite some refactoring
- still learning lua
- ! readme update will follow

v2.3.2
- much better dragonflight check (i hope ;)
- updated preview screenshots

v2.3.1
- new key binding for ground mounts
- nicer wording
- readmes up to date
- quick start under options frame
- esc now closes options frame
- minor layout changes

v2.3
- ready for dragonflight
- automatically show off can now be disabled
- readmes will be updated soon (wanna ride the dragons now ;)

v2.2.1
- new quickstart in readme
- typos in readme
- bindings refactored

v2.2
- refactored quite some code #oop

v2.1.1.2
- improved tooltip to standard

v2.1.1.1
- minor changes in readmes

v2.1.1
- the user's ability to fly is now checked too
- fallbacks now change priority if or not user learned fly
- "hello taxi!" shout out only in group

v2.1.0.2
- fallbacks now work properly - bug fixed
- in flyable resting areas only flyable show off mounts will be chosen

v2.1.0.1
- auto open and close with mount journal is now an option
- new button in mount journal to open and close mounty #tlv
- command line options now in readme
- updated readme

v2.0.1
- options now automatically open with mount journal

v2.0
- fully adapted to 10.0.2
- mounty now opens in its own frame
- its frame can be moved with mouse
- minor layout changes

v1.8.4
- won't crash no more on 10.0.2
- sorry, you can't assign new mounts at the moment, i'm working on it

v1.8.3
- same magic - different order - easier to explain in readme

v1.8.2.3
- special keys won't dismount anymore whilst flying

v1.8.2.2
- stupid bug fixed: 'resting' and 'not resting' was mismatched

v1.8.2.1
- typos in readme.md

v1.8.2
- don't fly mode only whilst in a party (no sense at all whilst solo, he?)

v1.8.1
- readme.de.md in german/auf deutsch
- format of readmes

v1.8.0.1
- format of readme.md

v1.8
- full description (typos included)
- minor cosmetics

v1.7.2.1
- magic: show off mount if in resting area
- localizes key bindings
- optimized option frame
- mounts frame can now easily be opened with new button

v1.7.2
- minor bugs
- code nicyness
- better localization
- debug english only
- fallbacks for mount types

v1.7.1.2
- fixed: icons were overlapping labels

v1.7.1.1
- minor: fixed some string constants

v1.7.1
- first fixes
- key assignment fixed

v1.7
- localization dede
- localization enus
- refactored code

v1.6.2.2
- renamed _mounty_ to _mounty #tlv_

v1.6.2.1
- moved mounty to github
- changelog.md but txt
