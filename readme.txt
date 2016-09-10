Readme for Looter, a World of Warcraft Mod.
written by EVmaker and sjones321
Version 1.1.1
----
Looter by EVmaker and sjones321, original idea from Fast Disenchant by masahikotao

Looter currently is a multi-purpose looter, which will automatically loot any items gathered from:
Mining, Prospecting, Enchanting, Skinning, Herbalism, Tailoring, Fishes from Fishing, Health and/or Mana Potions,
Battleground items, Quest items, as well as looting items based on their value.

Current Notes: 
Fixed Delete Loot and Close Loot to be mutually exclusive (conflicted before when having them both enabled),
Added a 'block list', items added to the block list will not be looted regardless of any other setting if
using the blocklist is checked.  Also added 'loot by quality/rarity', which will loot items of that quality
or better (select common and it will loot common or better).
----
The custom loot list is no longer cleared after each new version with the reseting & updating of Looter's
saved variables.  Also a slash command method of adding items to the custom loot list by mouseover was added,
for example mouseover a 'plank of wood' and do /looter add, and it will add plank of wood to the custom loot
list (coincidentally, do /looter remove on said plank of wood and it will remove it from the custom loot
list).  I'm working on making a neater not needing a slash command method of doing this, but in the meantime
its there for those that want to use it.

Another implementation is 'loot by stack value'.  Take for example, you have your loot value set to 3 silver,
there are pelts dropping off the wolves your killing that are worth 20 copper, normally Looter would not loot
that since they aren't 3 silver by themself, however they have a stack size of 20, which would make the stack
value 4 silver which would fit your loot value.  So its up to you whether you would like to use the stack
value item looting, thats 4 silver worth of things that only take up one bag slot, same as one 4 silver item
would, the option is there.

There is a portal at: http://www.wowinterface.com/portal.php?&id=421
which has the most frequently updated news on Looter/Other mods I might be working on, as well as where bug
reports and feature requests can easily be posted by anyone and tracked.  (Current outstanding bugs will always
be listed in the bug reports section there)

Note on looting by Item Value:  You can now set a value you would like to loot anything at that value or above,
for example if you set gold to 0, silver to 50, and copper to 0, it will loot anything that is worth 50 silver or
more, if the loot by item value checkbox is on, which is off by default.  If you do turn it on make sure to set
it to whatever value you prefer, because if you leave each at 0, then it will look almost everything (as almost
everything is worth more then 0 copper)

Note on Battleground items:  Currently only auto loots the different battle ground items of Alterac Valley,
such as "Stormpike Soldier Flesh" and so on, if anyone knows of any other Battleground items to loot let me know.
(And that does not include the 'don't let them ress' corpse insignia, as that is not a physical item per se, as
it does not end up in your inventory.)

LDB Support, you should now be able to put Looter on any LDB compatible displayer (Titan Panel, Fubar, Docking
Station etc..)

Implemented is a working slash command system, including toggles for what to loot.  Check /looter for details.
Added a 'list custom' slash command for seeing what is currently set to be looted by the user, as well as a
'toggle status' command to see what looting options are toggled on or off.
* Added a version option to check Looter version.
* Added a reset option, to reset the toggles to default values (on) and clear the custom loot list.
* Added a clear option, to clear the custom loot list without having to do a reset or remove each item yourself.

Also implemented is a functional menu (GUI) which allows the easy toggling of the different looting options on
or off, as well as adding or removing items from the (also new) user custom loot list.  Will be adding new
features and options to the gui and slash system as time goes on.

The menu options, from the toggled loot checkboxes to the custom loot list are now saved in a savedvariables file,
no more having to toggle the looting options on or off every login (yes they're saved for the people who prefer
the slash commands as well).  Also saved is the custom loot list.

There is now a minimap button, which can be hidden or shown, which allows someone to left click the button to open
the Looter menu, or right click to update their quest item loot list from their current quests.

Important Note:
After thinking carefully about some comments received, Its been decided to split some of the 'extra features' that
have been talked about into a seperate addon called "LooterExtras" so that those that just want the small, compact
Looter as it is can keep using Looter itself for their looting needs.  LooterExtras will eventually incorporate
the more intensive or 'bloat' per se features that can be turned on in addition to Looter to give it more features
at the cost of more memory use/etc..

Features for LooterExtras: 
*Compatibility with Atlas Loot (If on AtlasLoot wish list, auto-roll need if it comes up)
*Autoloot skinnable corpses, so they can be skinned with GarbageFu support for whats looted
*If GarbageFu doesn't support it itself, auctioneer support to handle prices that could be gotten from auction to
 support it
*Probably more later
*Current feature requests on the Portal at http://www.wowinterface.com/portal.php?id=421

Old Part for reference.
For planned features see below, but to attempt to summarize (which I'm admittedly bad at):
The mod will have a GUI which will allow the users to enter items they wish looted whenever they show up on
their corpses, want Hearts of Fire, or Cores of Earth?  Enter it into the list and when one shows up on your
corpse it will grab it automatically.  The GUI will also allow the user to enable or disable any of the
availible options, as well as other features.

----
Todos:
	* TBD

Future Todo: (most everything will be toggeable to be enabled or disabled as user prefers)
	* Be an all-purpose looter
	* Be able to shift-click an item to add it to the custom loot list *working on*
	
----------------------------------------
Change History:
1.1.1:
Fixed Delete Loot and Close Loot to be mutually exclusive (conflicted before when having them both enabled),
Added a 'block list', items added to the block list will not be looted regardless of any other setting if
using the blocklist is checked.  Also added 'loot by quality/rarity', which will loot items of that quality
or better (select common and it will loot common or better).

1.1.0q:
Quick fix so that the misc profession loot option will actually loot again, thank you for pointing it out sdwwraith on WoWI.

1.1.0:
Decided to jump the version number with the number of additions in this version, but the changes are as follows:
    *Add an item to the item list by itemID as well as by exact name (/looter add itemid, or type the id in the
     area in the menu for adding items to the custom loot list).
    *Ability to change the right-click of the looter minimap or LDB (Titan Panel etc..) to something other then
     reloadui, right now just to open the menu (as leftclick has always and will remain to do).
    *Option to close the loot window after everything that meets current looting criteria is looted (instead of
     closing it on your own or moving or some other way of just closing the window).
    *Option to delete any excess items that don't meet the current loot criteria *Use at your own risk*, this
     has been tested a fair bit, by blizzard api changes really messing with looting api, it won't hurt your
	 items, it will simply loot and delete any items on a corpse not matching current loot criteria.  This can
	 cause things that you may want that just happened to be there to be destroyed (quality items, other things)
	 This is use at your own risk, its great for skinning, and those that hate seeing the sparkles after looting
	 a corpse, but it can be dangerous to the items on the corpse.
    *Fixed the already being rolled on bug, and added Dragonseyes to the prospecting loot list.

1.0.18:
Updated TOC and added a toggle for mount after looting while holding a modifier (alt or control), also made it so
that mount after gathering only triggers off gathering herbs, ores, or skins (also made it so it doesn't mount
after pickpocketing).

1.0.17q:
Quickfix for quest item looting, made a get to Looter's method of GetItemInfo, thought I'd updated all the calls
but apparently I missed the itemType call for quest items, my apologies for missing that and thank you for the
reports.

1.0.17:
3.2 Compatibility and TOC Update.  Added 3.1/3.2 Profession loot (such as Titanium Powder to prospecting which
can now be turned in for Jewelcrafters tokens).  Removed the don't loot if in-combat check, as the LootSlot API
was thankfully changed back to non-protected (as in, won't throw an error if it's called while still in combat).
Also now the Loot by value will work without needing any SellValue mod thanks to the items sell value now being
obtainable straight from the API.  Some code optimization, and finally getting Looter to use the merge method of
updating it's settings like my other mods, so no longer need to rechoose your settings after an update (though it
might be a good idea to do a /looter reset for this version just to make sure everythings setup).

1.0.16q:
Quickfix for an error introduced in the last version with the quest item looting code rewrite, with the old
function reference still being in, my apologies for missing that.

1.0.16:
Rewrote the Quest item looting code, should no longer have any problems looting a quest item, even if it is one
that is not listed on the quest objectives (such as collecting two parts of an amulet which combine into the
final amulet which is the only thing asked for in the quest objectives), and the code is smaller to boot.

1.0.15:
3.1 Compatibility, Added loot everything for pickpocketing, in-combat check for looting since apparently they
changed LootSlot to a protected api (can't be used in combat), and TOC update.

1.0.14:
Integrated LDB support, can now be put onto Titan Panel, Fubar, or other LDB compatible mods (DockingStation).

1.0.13q:
Quick change to when the Mount after Looting is called for those using that option, should be a bit better.

1.0.13:
Black Vitriol was added to the Misc Profession looting section, a mount after gathering option (see the
'remount' feature request on the portal for more information), possible fix for the once mentioned can't
autoloot with modifier down issue.

1.0.12:
Looter has finally been updated to use EMLib, mentioned in prior posts on the mod portal.  Also updated health,
mana, and prospecting (gems) sections to use WoTLK items (somehow I missed those sections, my apologies).

1.0.11:
Added the Milling and Miscellaneous Profession loot toggles, so for all those inscriptionists out there, you can
now automatically loot those pigments from your milling.  Also the new toggle for Miscellaneous Profession loot
will loot those miscellaneous items used for profession such as Hearts of the Wild, Spider Silks, Venom Sacs,
Motes, and so on that don't fit in the main loot categories. 

1.0.10:
Changed how the reset & update works when Looter detects the users saved variables are from a version older then
the current version, specifically, since how the custom loot list works isn't changed very much, the clearing of
it after each new version was removed (if a future version does require it, the manual /looter reset still does
a full reset, and I'll make sure to let people know to do it).  Also implemented a slash command method of adding
items to the custom loot list, for example, mouse over an Iron Ore, and do /looter add, and it'll add iron ore to
the custom loot list (coincedentally, mouse over the same iron ore, and do /looter remove, and it will remove it
from the list).  I'll continue working on a way to do this without needing a slash command, but its there for
those that will find it helpful.

1.0.9:
Improved GetSellValue support (thanks Cirk for the help), Looter should now work just fine with any GetSellValue
mod.  Also implemented is 'Loot by Stack Value', you have an item that is worth 20 copper, stacks in lots of 20,
thats 4 silver for one bag slot, if your loot value is 3 silver and you have loot by stack value on, it'd loot
those items since the stack can be valued over your loot value.  Whether you wish to use stack value looting is
up to you.

1.0.8:
Release for 3.0.2, might need a quick fix version later depending, it shouldn't need one as everything should be
all set, but as I still can't log into my server to test personally I cannot say.  Added most known WoTLK Leather,
Mining, Herb, Enchanting and Fishing items to Looter, This will currently only be useful to beta testers, but once
WoTLK releases in around a month it'll be all set to go for everyone else.

1.0.7:
WoTLK compatible, see readme for details, but essentially it is just a small change to make the mod compatible, it
is still fully compatible with the normal live servers, and there isn't really any reason to upgrade to 1.0.7 over
1.0.6 besides to be fully up-to-date and be compatible when WoTLK is actually released (bar major API changes).

1.0.6:
Added the ability for Looter to tell if the version of the User's saved settings is different then the new version
and automatically do a reset and update of their settings (you will have to redo the toggles/custom loot list).

Also fixed the three bugs listed on the portal (to summarize, the bug if not using a "GetSellValue" mod, ala
informant, itempricetooltips, etc..  The bug where the loot by value wasn't looting based on users value after
a reconnect or reload ui, and Looter not looting heavy stones if mining is on.)

1.0.5:
The minimap button can now be shown or hidden at will with the menu or the /looter toggle minimap slash command.
Items can also now be looted based on their value, using the menu to set what you want to loot at or above, with
slash toggle and menu option to turn item value looting on or off.

1.0.4:
Added code so that the quest item loot list will automatically update on logging into your character, so you don't
have to manually update the list or talk to a quest giver first in order to go out looting quest items if you have
quest item looting enabled.  Slightly changed the text of Prospecting (so people know gem looting is part of that)
and the on/off checkbox to be more understandable (checked being on).  Found a uncommon but not so uncommon bug
where some quest items would not be added correctly on accepting a quest due to cache, and fixed that.  Also added
a /looter clear slash command to clear the custom loot list without doing a /looter reset (and hence clearing the
toggles as well) or having to 'type and hit remove' for each one.

1.0.3:
Well, after a good bit of time (more then I really should be awake) figured out the way to handle the problem of
grabbing quest items after getting a new quest (as removing the items not needed was never a problem), so all should
be well now there.  Next is to find a way for the mod to 'self-update' for people using older versions that upgrade
so that it updates the old saved variable to the new with the new toggles.  In the meantime, just do a /looter reset
after any version that adds a new toggle you'll be fine.

P.S. For anyone that has all autolooting just stop, the above might be the reason, so just do a /looter reset and it
should be fine.  (Particularly from people updating from versions prior to 1.0.1 with the Looter on/off toggle)

1.0.2q:
Sorry for another quick fix guys, but I'm sleep deprived and forgot to remove another small debug message pertaining
to the new quest item updating method.

1.0.2:
Changed the event that triggers the quest item updating, it should now automatically grab the quest items needing
to be looted, and take them off the list when they aren't needed anymore, so in essence manually updating the quest
item loot list shouldn't be needed anymore, but its still there if needed.

1.0.1q:
Fixed a small bug with the quest item looting conflicting with the user selected list.

1.0.1:
Added a Looter on/off toggle with slash and menu option, so you can turn off looter whenever you want to just
loot things yourself, without having to turn all the checkboxes off.  Also added checks for when looting everything
with shift-key or blizzard's 'autoloot all' toggle.

1.0.0q:
(figured to use q for quickfix rather then jump the version again since it really is just a small fix)
Quickfix in the new quest item setting function to remove a small doubling.

1.0.0:
Added Quest item looting with slash and menu option.  Also added /looter reset slash command for reseting the
toggle options back to default (on) and clear the custom loot list.  Also fixed the version command/version number
which wasn't updated in the last version.  Also implemented a functional minimap button, with right click to
auto-update quest loot items based on active quests (see readme for notes on that and the quest item looting).

0.9.6b:
Added Battleground item looting with appropriate slash toggle and menu option, for the moment its only the different
items you can loot and turnin for faction quests in alterac valley, if anyone knows of other battleground items let
me know (and that doesn't include the corpse insiginia, as it isn't a physical item/end up your inventory).

0.9.5b:
Implemented saved options.  All toggle options and the custom loot list will now be saved between sessions.  Next
on list is hopefully a working scroll box, minimap button, and then item value loot options.

0.9b:
Implemented a functional gui, read the readme for comments on that, but essentially it allows the easy toggling of the
different looting options on or off, as well as adding or removing items to a custom loot list.  Also added two new
slash commands (/looter list custom and /looter toggle status) which will allow people to see whats in the custom
loot list, or what loot options are on or off respectively.  Next on the list is getting a scroll box in the menu so
that people can easily see whats in the loot list without having it sent to chat, and then probably item value looting
options.  P.S. its 0.9b instead of 1.0 even though everything on the complete by end of Beta is done, because I don't
feel that the menu is *really* done till its got the scroll box, and options are saved over sessions (which is almost
done, but I'm too dead tired to finish it tonight).

0.2.1b:
oops, my mistake, quick fix to remove a little debug (not to worry haven't found any) line in regards to money.

0.2b:
Finished a working slash command system using /looter, which lets people toggle the different looting on or off. Also added
Health and/or Mana potion looting.

0.1b:
First beta release,
Rewrote the code, now also handles Tailoring and Fishing. Currently when looting corpses for Tailoring, or Fishing for fish,
it will loot the cloths or fish, but leave the window open with the rest, next on the list is get the GUI working, so that people
can choose what exactly they wish to loot.

0.02a:
Second alpha release,
Leatherworking and Herbalism are working.

0.01a:
First release version (alpha)
Mining, Prospecting and Enchanting are working.

----------------------------------------