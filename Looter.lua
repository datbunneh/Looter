--[[
Version 1.1.1
Looter by EVmaker and sjones321, original idea from Fast Disenchant by masahikotao.   With thanks to Cirk (of LootValue and other mods) for help with better GetSellValue/OnDemand support.
Functioning: Money, Leathers, Cloths, Mining, Prospecting, Enchanting, Fishing, Health and/or Mana Potions, Battleground, and Quest items.
Also Functioning: Working Slash command system, and toggleable looting.
Added a functional GUI, will be improved and added too as time goes on.
Added saved options, toggled looting and the custom loot list will be saved between sessions.
Added Minimap button to open the menu and update the quest item loot list.
Future Todo: (most everything will be toggeable to be enabled or disabled as you prefer)
* Be an all-purpose looter
* Titan/Fubar Compatibility
* Integrate with lib to allow 'autoloot of items above set amount of copper/silver/gold' settings *implemented*
* Autoloot skinnable corpses, so they can be skinned (with autoloot of skinning if enabled) *in question*
]]--

-- Looting Arrays (most have been moved into their own files)

-- Array to test with
local LooterTestItems = {
	-- For the coder's testing purposes (Testing)
	[17056] = true, -- Light Feather
	[4775] = true, -- Cracked Bill
	[4776] = true -- Ruffled Feather
}

local waitTable = {};
local waitFrame = nil;

function defer(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

-- Declare the global settings
Looter_timerTask = "deleteitems";
Looter_Settings = {
["Version"] = "1.1.1",
["User"] = true,
["Leather"] = true,
["Mining"] = true,
["Herbs"] = true,
["Prospect"] = true,
["Milling"] = true,
["Enchant"] = true,
["Cloth"] = true,
["Fish"] = true, 
["Health"] = true,
["Mana"] = true,
["Rarity"] = false,
["Battleground"] = true,
["Quest"] = true,
["Value"] = false,
["StackValue"] = false,
["OnOff"] = true,
["useMMB"] = true,
["mountGather"] = false,
["mountKey"] = false,
["RightClick"] = "reload",
["CloseLoot"] = false,
["DeleteLoot"] = false,
["UseBlocked"] = true,
["Misc"] = true
}

-- What the user wants to loot
LooterUserInput = {
	[0] = "StartDontRemove"
}

-- What the user doesn't want to loot
LooterBlockList = {
	[0] = "StartDontRemove"
}

-- Value at or above the user wants to loot
LooterUserValue = {
	["Gold"] = 0,
	["Silver"] = 0,
	["Copper"] = 0
}

--[[
Looter version as a global saved variable, so that the mod can 'self-update'
the other saved variables after a new version (slightly annoying as toggles
need to be set again, but saves the headaches of features not working
because the person doesn't think to or know to do a /looter reset themself)
]]--

-- Declare the local defaults
local debugMode=false;
local LTR_EML = "Looter";
local Looter_hasUE=false;
local Looter_useTesting=0;
local Looter_doMount = false;
local Looter_updateInterval = 5.0;
local Looter_defaultSettings = {
["Version"] = "1.1.1",
["User"] = true,
["Leather"] = true,
["Mining"] = true,
["Herbs"] = true,
["Prospect"] = true,
["Milling"] = true,
["Enchant"] = true,
["Cloth"] = true,
["Fish"] = true, 
["Health"] = true,
["Mana"] = true,
["Rarity"] = false,
["Battleground"] = true,
["Quest"] = true,
["Value"] = false,
["StackValue"] = false,
["OnOff"] = true,
["useMMB"] = true,
["mountGather"] = false,
["mountKey"] = false,
["CloseLoot"] = false,
["DeleteLoot"] = false,
["RightClick"] = "reload",
["UseBlocked"] = true,
["Misc"] = true
}
local Looter_defaultQuestItems = {
	[0] = "StartDontRemove"
}
local Looter_defaultInput = {
	[0] = "StartDontRemove"
}
local Looter_defaultBlockList = {
	[0] = "StartDontRemove"
}
local Looter_defaultUserValue = {
	["Gold"] = 0,
	["Silver"] = 0,
	["Copper"] = 0
}
local Looter_lootValue=0;
local Looter_lootArray = {};
local Looter_questItem = select(12, GetAuctionItemClasses());
local Looter_testVar;

-- Looter slash handling
function Looter_SlashHandler(theMsg)
	msg = strtrim(strlower(theMsg or ""))
	if msg == "open gui" then
		EMLFrame_Toggle("Looter1","open")
		EMLChat("Opening GUI Frame","chat",LTR_EML)
	elseif strmatch(msg, "rightclick") then
		local theChoice = strmatch(msg, "rightclick (.*)");
		if (theChoice == "reloadui") then
			Looter_Settings["RightClick"] = "reload";
			EMLChat("Right clicking the minimap button will now reload the UI.","chat",LTR_EML)
		elseif (theChoice == "reload") then
			Looter_Settings["RightClick"] = "reload";
			EMLChat("Right clicking the minimap button will now reload the UI.","chat",LTR_EML)
		elseif (theChoice == "menu") then
			Looter_Settings["RightClick"] = "menu";
			EMLChat("Right clicking the minimap button will now open looter menu.","chat",LTR_EML)
		else
			EMLChat("Current options for right-clicking the minimap button are: reloadui, menu","chat",LTR_EML)
			EMLChat("which reload the ui, or open the looter menu respectively.","chat",LTR_EML)
		end
	elseif msg == "list custom" then
		EML_Display(LooterUserInput,LTR_EML)
	elseif (msg == "list block" or msg == "list blocked") then
		EML_Display(LooterBlockList,LTR_EML)
	elseif strmatch(msg, "block") then
		local theChoice = strmatch(theMsg, "block (.*)");
		if (theChoice == "" or theChoice == " " or theChoice == nil) then
			local itemArray = EML_toolInfo(nil,LTR_EML)
			if (itemArray) then
				EML_addTable(itemArray.Name,LooterBlockList)
				EMLChat("Adding "..itemArray.Name.." to the block list.","chat",LTR_EML)
			else
				EMLChat("Not moused over an item in your bags or bank.","chat",LTR_EML)
			end
		else
			EML_addTable(theChoice,LooterBlockList)
			EMLChat("Adding "..theChoice.." to the block list.","chat",LTR_EML)
		end
	elseif strmatch(msg, "unblock") then
		local theChoice = strmatch(theMsg, "unblock (.*)");
		if (theChoice == "" or theChoice == " " or theChoice == nil) then
			local itemArray = EML_toolInfo(nil,LTR_EML)
			if (itemArray) then
				EML_remTable(itemArray.Name,LooterBlockList)
				EML_remTable(tostring(itemArray.ID),LooterBlockList)
				EMLChat("Removing "..itemArray.Name.." from the block list.","chat",LTR_EML)
			else
				EMLChat("Not moused over an item in your bags or bank.","chat",LTR_EML)
			end
		else
			EML_remTable(theChoice,LooterBlockList)
			EMLChat("Removing "..theChoice.." from the block list.","chat",LTR_EML)
		end
	elseif strmatch(msg, "rarity") then
		theChoice = strmatch(msg, "rarity (.*)");
		if (theChoice == "grey" or theChoice == "junk" or theChoice == "0") then
			Looter_Settings["Rarity"] = 0;
			EMLChat("Loot rarity set to junk or better","chat",LTR_EML)
		elseif (theChoice == "white" or theChoice == "common" or theChoice == "1") then
			Looter_Settings["Rarity"] = 1;
			EMLChat("Loot rarity set to common or better","chat",LTR_EML)
		elseif (theChoice == "green" or theChoice == "uncommon" or theChoice == "2") then
			Looter_Settings["Rarity"] = 2;
			EMLChat("Loot rarity set to uncommon or better","chat",LTR_EML)
		elseif (theChoice == "blue" or theChoice == "rare" or theChoice == "3") then
			Looter_Settings["Rarity"] = 3;
			EMLChat("Loot rarity set to rare or better","chat",LTR_EML)
		elseif (theChoice == "purple" or theChoice == "epic" or theChoice == "4") then
			Looter_Settings["Rarity"] = 4;
			EMLChat("Loot rarity set to epic or better","chat",LTR_EML)
		elseif (theChoice == "orange" or theChoice == "legendary" or theChoice == "5") then
			Looter_Settings["Rarity"] = 5;
			EMLChat("Loot rarity set to legendary or better","chat",LTR_EML)
		else
			EMLChat("Need to set rarity to either grey, white, green, blue, purple, orange or junk, common, uncommon, rare, epic, legendary","chat",LTR_EML)
		end
	elseif (msg == "open menu" or msg == "menu") then
		EMLFrame_Toggle("Looter1","open")
		EMLChat("Opening Menu","chat",LTR_EML)
	elseif msg == "version" then
		EMLChat("This version of Looter is: "..Looter_defaultSettings["Version"],"chat",LTR_EML)
	elseif msg == "debug" then
		if (debugMode) then
			debugMode=false;
			EMLChat("Toggling debug mode off","chat",LTR_EML)
		else
			debugMode=true;
			EMLChat("Toggling debug mode on","chat",LTR_EML)
		end
	elseif msg == "test1" then
		Looter_testFunction()
	elseif msg == "test2" then
		Looter_testFunction2()
	elseif msg == "reload" then
		ReloadUI();
	elseif msg == "reloadui" then
		ReloadUI();
	elseif msg == "reset" then
		Looter_Reset()
	elseif msg == "clear" then
		local defaultInput = EML_copyTable(Looter_defaultInput);
		local defaultBlock = EML_copyTable(Looter_defaultBlockList);
		EML_clearTable(LooterUserInput)
		LooterUserInput=defaultInput;
		EML_clearTable(LooterBlockList)
		LooterBlockList=defaultBlock;
		EMLChat("Cleared custom loot and block lists","chat",LTR_EML)
	elseif msg == "authors" then
		EMLChat("evmaker, the Lua Coder.","chat",LTR_EML)
		EMLChat("sjones321, the XML Coder.","chat",LTR_EML)
	elseif msg == "evmaker" then
		EMLChat("EVmaker codes the Lua (primary) part of the mod.","chat",LTR_EML)
	elseif msg == "sjones321" then
		EMLChat("SJones321 codes the XML (GUI) part of the mod.","chat",LTR_EML)
	elseif msg == "add" then
		local itemArray = EML_toolInfo(nil,LTR_EML)
		if (itemArray) then
			EML_addTable(itemArray.Name,LooterUserInput)
			EMLChat("Adding "..itemArray.Name.." to the list.","chat",LTR_EML)
		else
			EMLChat("Not moused over an item in your bags or bank.","chat",LTR_EML)
		end
	elseif msg == "remove" then
		local itemArray = EML_toolInfo(nil,LTR_EML)
		if (itemArray) then
			EML_remTable(itemArray.Name,LooterUserInput)
			EML_remTable(tostring(itemArray.ID),LooterUserInput)
			EMLChat("Removing "..itemArray.Name.." from the list.","chat",LTR_EML)
		else
			EMLChat("Not moused over an item in your bags or bank.","chat",LTR_EML)
		end
	elseif strmatch(msg, "toggle") then
		local theToggle = strmatch(msg, "toggle (.*)");
		if (theToggle) then
			Looter_handleToggle(theToggle)
		else
			-- Do something
		end
	else
		EMLChat("Valid Options:","chat",LTR_EML)
		EMLChat("Under Construction (not a command)","chat",LTR_EML)
		EMLChat("Toggles: (each of the below toggles the looting on or off)","chat",LTR_EML)
		EMLChat("Default is on","chat",LTR_EML)
		EMLChat("-----------------","chat",LTR_EML)
		EMLChat("toggle user, (user supplied, via menu)","chat",LTR_EML)
		EMLChat("toggle blocklist, (don't loot items in the block list)","chat",LTR_EML)
		EMLChat("toggle cloth","chat",LTR_EML)
		EMLChat("toggle skinning","chat",LTR_EML)
		EMLChat("toggle herbs","chat",LTR_EML)
		EMLChat("toggle mining","chat",LTR_EML)
		EMLChat("toggle fish","chat",LTR_EML)
		EMLChat("toggle prospecting","chat",LTR_EML)
		EMLChat("toggle milling","chat",LTR_EML)
		EMLChat("toggle enchanting","chat",LTR_EML)
		EMLChat("toggle health, (potions)","chat",LTR_EML)
		EMLChat("toggle mana, (potions)","chat",LTR_EML)
		EMLChat("toggle battleground, (battleground items)","chat",LTR_EML)
		EMLChat("toggle misc, (miscellaneous profession items)","chat",LTR_EML)
		EMLChat("toggle quest, (quest items)","chat",LTR_EML)
		EMLChat("toggle value, (loot by item value)","chat",LTR_EML)
		EMLChat("toggle stackvalue, (loot items if stack value more then set value)","chat",LTR_EML)
		EMLChat("toggle closeloot, (closes the loot window after looting anything that matches current loot settings)","chat",LTR_EML)
		EMLChat("toggle destroyloot, (destroy any loot that doesn't match current loot settings *use at your own risk*","chat",LTR_EML)
		EMLChat("toggle mountgather, (mounting after gathering, if you have UsefulExtras mod)","chat",LTR_EML)
		EMLChat("toggle status, (check whats looting or not)","chat",LTR_EML)
		EMLChat("toggle looter, (toggle Looter on or off)","chat",LTR_EML)
		EMLChat("-----------------","chat",LTR_EML)
		EMLChat("Other Commands:","chat",LTR_EML)
		EMLChat("add, (adds the currently moused over item to the custom list)","chat",LTR_EML)
		EMLChat("remove, (removes the currently moused over item from the custom list)","chat",LTR_EML)
		EMLChat("menu or open menu, (open the menu/gui)","chat",LTR_EML)
		EMLChat("list custom, (list custom loot list)","chat",LTR_EML)
		EMLChat("version, (check your Looter version)","chat",LTR_EML)
		EMLChat("clear, (clears the custom loot list)","chat",LTR_EML)
		EMLChat("reset, (resets the toggles and clears the custom loot list)","chat",LTR_EML)
		EMLChat("-----------------","chat",LTR_EML)
		EMLChat("Authors, slashes for them as well.","chat",LTR_EML)
	end
end

-- Setup
function Looter_OnLoad()
	this:RegisterEvent("LOOT_OPENED")
	this:RegisterEvent("LOOT_CLOSED")
	this:RegisterEvent("ADDON_LOADED")
	SLASH_LOOTER1 = "/looter"
	SLASH_LOOTER2 = "/ltr"
	SlashCmdList["LOOTER"] = function(msg)
		Looter_SlashHandler(msg);
	end
	EMLChat("Looter "..Looter_defaultSettings["Version"].." loaded","plainchat",LTR_EML,"teal")
end

-- Starts the looting
function Looter_OnEvent(event)
	local slotnum;
	local Looter_localSettings=Looter_Settings;
	local Looter_localUserInput=LooterUserInput;
	local Looter_localUserValue=LooterUserValue;
	local autoLootOn=tonumber(GetCVar("autoLootDefault"))
	if (event == "ADDON_LOADED") and (arg1 == "Looter") then
		if (Looter_Settings["Version"] ~= Looter_defaultSettings["Version"]) then
			if (debugMode) then EMLChat("Version is different.","chat",LTR_EML) end
			Looter_Reset("version")
		else
			if (debugMode) then EMLChat("Version is the same.","chat",LTR_EML) end
		end
		Looter_setCheckBoxes()
		Looter_checkValue("set")
		Looter_Timer:Show()
	end
	if (event == "ADDON_LOADED") and (arg1 == "UsefulExtras") then
		Looter_hasUE = true;
	end
	if (not IsModifiedClick("AUTOLOOTTOGGLE") and autoLootOn ~= 1) and Looter_Settings["OnOff"] then
		if (event == "LOOT_OPENED") then
			local hasLooted = false;
			if (GetNumLootItems() == 0) then
				defer(.1, function () CloseLoot() end)
			else
--				if (not InCombatLockdown()) then
					if (IsStealthed()) then
						Looter_doMount = false;
						Looter_lootAll()
						return nil;
					end
					for slotnum = 1, GetNumLootItems() do
						if LootSlotIsCoin(slotnum) then
							defer(.1, function () LootSlot(slotnum) end)
							--LootSlot(slotnum)
						elseif (not LootSlotIsCoin(slotnum)) then
							LooterScanSlot(slotnum)
						end
						if (slotnum >= GetNumLootItems() and Looter_Settings["CloseLoot"]) then
							CloseLoot()
						elseif (slotnum >= GetNumLootItems() and not Looter_Settings["CloseLoot"]) then
							hasLooted = true;
						end
					end
					if (Looter_Settings["DeleteLoot"] and hasLooted == true) then
						Looter_timerTask = "deletedelay";
						Looter_Timer:Show()
					end
--				end
			end
		end
	end
	if (event == "LOOT_CLOSED") then
		if (Looter_Settings["mountGather"] and Looter_doMount) then
			Looter_mountUp()
		end
		if (Looter_Settings["mountKey"] and IsModifierKeyDown() and not IsModifiedClick("AUTOLOOTTOGGLE")) then
			Looter_mountUp()
		end
		if (Looter_Settings["DeleteLoot"]) then
			Looter_timerTask = "deleteitems";
			Looter_Timer:Show()
		end
	end
	if (IsModifiedClick("AUTOLOOTTOGGLE") and autoLootOn ~= 1) then
		Looter_lootAll()
	end
end

function Looter_rightClick()
	if (Looter_Settings["RightClick"] == "reload") then
		ReloadUI()
	elseif (Looter_Settings["RightClick"] == "menu") then
		EMLFrame_Toggle("Looter1")
	else
		-- Do nothing
	end
end

-- Handles the loot
function LooterScanSlot(slotnum)
	local link = GetLootSlotLink(slotnum)
	if not link then return end
	local _, itemName, itemQuantity, itemRarity = GetLootSlotInfo(slotnum)
	local itemArray = EML_getInfo(link);
	local newItemValue,stackValue;
	if (itemArray.Price and itemArray.StackCount) ~= nil then
		stackValue = (itemArray.Price*itemArray.StackCount)
	end
	if (itemArray.Price and itemQuantity) ~= nil then
		newItemValue = (itemArray.Price*itemQuantity)
		if (debugMode) and (stackValue ~= nil) then
--			EMLChat("Item Value is: "..Looter_processValue(newItemValue),"chat",LTR_EML)
--			EMLChat("Stack Value is: "..Looter_processValue(stackValue),"chat",LTR_EML)
		end
	end
	if (Looter_Settings["UseBlocked"]) and (EML_findTable(itemArray.Name,LooterBlockList) or EML_findTable(tostring(itemArray.ID),LooterBlockList)) then
		return false;
	end
  if ((GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) and (GetLootMethod() ~= "freeforall" and GetLootMethod() ~= "roundrobin") and itemArray.Rarity >= GetLootThreshold()) then
    return false;
  end
	if (Looter_Settings["Rarity"]) then
		if (itemArray.Rarity <= Looter_Settings["Rarity"] and itemArray.Price ~= nil and Looter_lootValue > 0) then
			if Looter_Settings["Value"] and Looter_Settings["StackValue"] then
				if (stackValue >= Looter_lootValue) then
					LootSlot(slotnum)
				end
			else
				if (newItemValue >= Looter_lootValue) and Looter_Settings["Value"] then
					LootSlot(slotnum)
				end
			end
		end
	end
	--if (Looter_lootValue < 1) and Looter_Settings["Value"] then
	--	Looter_lootAll()
	--end
	if (LooterMining[itemArray.ID] or LooterHerbs[itemArray.ID] or LooterLeathers[itemArray.ID]) then
		if (debugMode) then
			EMLChat("Mine, Herb, or Skin gathered.","chat",LTR_EML)
			Looter_doMount = true;
		end
	end
	if LooterLeathers[itemArray.ID] and Looter_Settings["Leather"] then
		LootSlot(slotnum)
		Looter_doMount = true;
	elseif LooterMining[itemArray.ID] and Looter_Settings["Mining"] then
		LootSlot(slotnum)
		Looter_doMount = true;
	elseif LooterHerbs[itemArray.ID] and Looter_Settings["Herbs"] then
		LootSlot(slotnum)
		Looter_doMount = true;
	elseif LooterProspecting[itemArray.ID] and Looter_Settings["Prospect"] then
		LootSlot(slotnum)
	elseif LooterMilling[itemArray.ID] and Looter_Settings["Milling"] then
		LootSlot(slotnum)
	elseif LooterEnchanting[itemArray.ID] and Looter_Settings["Enchant"] then
		LootSlot(slotnum)
	elseif LooterCloths[itemArray.ID] and Looter_Settings["Cloth"] then
		LootSlot(slotnum)
	elseif LooterFishs[itemArray.ID] and Looter_Settings["Fish"] then
		LootSlot(slotnum)
	elseif LooterHealths[itemArray.ID] and Looter_Settings["Health"] then
		LootSlot(slotnum)
	elseif LooterManas[itemArray.ID] and Looter_Settings["Mana"] then
		LootSlot(slotnum)
	elseif LooterBattleground[itemArray.ID] and Looter_Settings["Battleground"] then
		LootSlot(slotnum)
	elseif LooterGeneralProfession[itemArray.ID] and Looter_Settings["Misc"] then
		LootSlot(slotnum)
	end
	if Looter_Settings["Quest"] then
		if (itemArray.Type == Looter_questItem) then
			LootSlot(slotnum)
			if (debugMode) then EMLChat("Tried to loot quest item.","chat",LTR_EML) end
		else
			if (debugMode) then EMLChat("Didn't try to loot quest item.","chat",LTR_EML) end
		end
		if (debugMode) then EMLChat("Ran quest section.","chat",LTR_EML) end
	end
	if Looter_Settings["User"] then
		if (EML_findTable(itemArray.Name,LooterUserInput)) then
			LootSlot(slotnum)
		elseif (EML_findTable(tostring(itemArray.ID),LooterUserInput)) then
			LootSlot(slotnum)
		end
	end
end

-- Loots everything
function Looter_lootAll()
	for i = 1, GetNumLootItems() do
		LootSlot(i)
	end
end

-- Translates User amounts to GetSellValue amounts (1 gold to 10000 copper)
function Looter_setValue(amount,whatType)
	local theAmount=tonumber(amount)
	local theResult;
	if whatType == "gold" then
		theResult=theAmount*10000
	elseif whatType == "silver" then
		theResult=theAmount*100
	elseif whatType == "copper" then
		theResult=theAmount
	else
		if (debugMode) then EMLChat("Value must be Copper, Silver, or Gold","chat",LTR_EML) end
	end
	return theResult
end

-- Translates GetSellValue amounts to User amounts (10000 copper to 1 gold)
function Looter_getValue(amount)
	local theAmount=tonumber(amount)
	local lootGold,lootSilver,lootCopper;
	lootGold = floor(theAmount/10000)
	theAmount = mod(theAmount,10000)
	lootSilver = floor(theAmount/100)
	theAmount = mod(theAmount,100)
	lootCopper = mod(theAmount,100)
	return lootGold,lootSilver,lootCopper;
end

-- Proccesses Looter_getValue into straight normal WoW values (2 gold, 23 silver, 9 copper)
function Looter_processValue(amount)
    local lootGold,lootSilver,lootCopper=Looter_getValue(amount)
    local theValue,toReturn;
    if ((lootGold and lootSilver and lootCopper) ~= nil) then
        if (lootGold > 0) and (lootSilver > 0) then
            theValue=lootGold.." Gold, "..lootSilver.." Silver, "..lootCopper.." Copper."
        elseif (lootGold>0) and (lootSilver==0) then
            theValue=lootGold.." Gold, "..lootCopper.." Copper."
        elseif (lootGold==0) and (lootSilver>0) then
            theValue=lootSilver.." Silver, "..lootCopper.." Copper."
        elseif (lootGold==0) and (lootSilver==0) then
            theValue=lootCopper.." Copper."
        end
    end
    if (theValue ~= nil) then
        toReturn = tostring(theValue)
        return toReturn;
    else
        return nil;
    end
end

-- Add user input
function Looter_Add(arg1)
	local userInput=Looter1_InputBox:GetText()
	if Looter1_InputBox:GetText() then
		table.insert(LooterUserInput,userInput)
		EMLChat("Adding "..userInput.." to the list.","chat",LTR_EML)
		Looter1_InputBox:SetText("")
	end
end

-- Remove user input
function Looter_Remove(arg1)
	if Looter1_InputBox:GetText() then
		Looter_TableRemove(LooterUserInput)
		Looter1_InputBox:SetText("")
	end
end

-- Display for GUI
function Looter_DisplayGUI()
	EML_Display(LooterUserInput,LTR_EML)
end

-- Remove a value from a Looter array
function Looter_TableRemove(arg)
	local userInput=tostring(Looter1_InputBox:GetText())
	for index,value in pairs(arg) do
		if value == userInput then
			table.remove(arg,index)
			EMLChat("Removing "..userInput.." from the list.","chat",LTR_EML)
		end
	end
end

-- If using destroy non-looted items, will add items that don't match the currently used loot lists to the loot array to destroy
function Looter_destroyLoot(slotnum)
	local link = GetLootSlotLink(slotnum)
	if (link) then
		local _, _, itemCount, _ = GetLootSlotInfo(slotnum)
		local itemArray = EML_getInfo(link);
		LootSlot(slotnum)
		Looter_lootArray[itemArray.ID]=itemCount;
	end
end

-- Destroys the items that have not met the loot criteria if using that option
function Looter_doDestroy()
	for index,value in pairs(Looter_lootArray) do
		local itemArray = EML_getInfo(index);
		local searchArray = Looter_itemSearch(itemArray);
		if (not searchArray) then
			Looter_Timer:Hide()
			EMLChat("There was a bug with destroy items feature, nothing was destroyed, but please post the circumstances for EVmaker on the portal or mod comments.","chat",LTR_EML)
			return nil;
		end
		if (value == searchArray.Quantity) then
			PickupContainerItem(searchArray.Bag,searchArray.Slot)
			if CursorHasItem() then
				DeleteCursorItem()
				EML_remTable(index,Looter_lootArray)
				if (debugMode) then EMLChat("Destroying "..itemArray.Link..".","chat",LTR_EML) end
			else
				if (debugMode) then EMLChat("No cursor item.","chat",LTR_EML) end
			end
		elseif (value < searchArray.Quantity) then
			SplitContainerItem(searchArray.Bag,searchArray.Slot,value)
			if CursorHasItem() then
				DeleteCursorItem()
				EML_remTable(index,Looter_lootArray)
				if (debugMode) then EMLChat("Destroying "..itemArray.Link..".","chat",LTR_EML) end
			else
				if (debugMode) then EMLChat("No cursor item.","chat",LTR_EML) end
			end
		end
	end
end

-- Finds out the slots and quantity of an item in your inventory
function Looter_itemSearch(arg)
	local itemID;
	if (type(arg) == "table") then
		itemID = arg.ID;
	else
		itemID = arg;
	end
	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local _, itemCount, _ = GetContainerItemInfo(bag,slot)
			local itemLink = GetContainerItemLink(bag,slot)
			if (itemLink) then
				local itemArray = EML_getInfo(itemLink);
				if (itemID == itemArray.ID) then
					local tempArray = {
						["Bag"] = bag,
						["Slot"] = slot,
						["Quantity"] = itemCount,
					}
					return tempArray;
				end
			end
		end
	end
	return false;
end

-- Test whatever the coders working on (currently quest item looting)
function Looter_testFunction(arg)
	EML_Display(Looter_lootArray,LTR_EML)
end

-- Same as Looter_testFunction (currently alternate quest item looting)
function Looter_testFunction2(arg)
	-- Unused currently
end

-- Determine the status of the checkboxes and set things accordingly
function Looter_checkCheckBoxes()
	if (Looter1_Skinning:GetChecked()) then
		Looter_Settings["Leather"]=true
	else
		Looter_Settings["Leather"]=false
	end
	if (Looter1_Cloth:GetChecked()) then
		Looter_Settings["Cloth"]=true
	else
		Looter_Settings["Cloth"]=false
	end
	if (Looter1_Mining:GetChecked()) then
		Looter_Settings["Mining"]=true
	else
		Looter_Settings["Mining"]=false
	end
	if (Looter1_Herbalism:GetChecked()) then
		Looter_Settings["Herbs"]=true
	else
		Looter_Settings["Herbs"]=false
	end
	if (Looter1_Prospecting:GetChecked()) then
		Looter_Settings["Prospect"]=true
	else
		Looter_Settings["Prospect"]=false
	end
	if (Looter1_Milling:GetChecked()) then
		Looter_Settings["Milling"]=true
	else
		Looter_Settings["Milling"]=false
	end
	if (Looter1_Disenchanting:GetChecked()) then
		Looter_Settings["Enchant"]=true
	else
		Looter_Settings["Enchant"]=false
	end
	if (Looter1_Fishing:GetChecked()) then
		Looter_Settings["Fish"]=true
	else
		Looter_Settings["Fish"]=false
	end
	if (Looter1_Health:GetChecked()) then
		Looter_Settings["Health"]=true
	else
		Looter_Settings["Health"]=false
	end
	if (Looter1_Mana:GetChecked()) then
		Looter_Settings["Mana"]=true
	else
		Looter_Settings["Mana"]=false
	end
	if (Looter1_Battleground:GetChecked()) then
		Looter_Settings["Battleground"]=true
	else
		Looter_Settings["Battleground"]=false
	end
	if (Looter1_Quest:GetChecked()) then
		Looter_Settings["Quest"]=true
	else
		Looter_Settings["Quest"]=false
	end
	if (Looter1_Value:GetChecked()) then
		Looter_Settings["Value"]=true
	else
		Looter_Settings["Value"]=false
	end
	if (Looter1_StackValue:GetChecked()) then
		Looter_Settings["StackValue"]=true
	else
		Looter_Settings["StackValue"]=false
	end
	if (Looter1_User:GetChecked()) then
		Looter_Settings["User"]=true
	else
		Looter_Settings["User"]=false
	end
	if (Looter1_OnOff:GetChecked()) then
		Looter_Settings["OnOff"]=true
	else
		Looter_Settings["OnOff"]=false
	end
	if (Looter1_HideMMB:GetChecked()) then
		Looter_Settings["useMMB"]=true
		Looter_MinimapButton:Show()
	else
		Looter_Settings["useMMB"]=false
		Looter_MinimapButton:Hide()
	end
	if (Looter1_CloseLoot:GetChecked()) then
		if (not Looter1_DeleteLoot:GetChecked()) then
			Looter_Settings["CloseLoot"]=true
		else
			Looter_Settings["CloseLoot"]=false
			Looter_Settings["DeleteLoot"]=false
		end
	else
		Looter_Settings["CloseLoot"]=false
	end
	if (Looter1_DeleteLoot:GetChecked()) then
		if (not Looter1_CloseLoot:GetChecked()) then
			Looter_Settings["DeleteLoot"]=true
		else
			Looter_Settings["DeleteLoot"]=false
			Looter_Settings["CloseLoot"]=false
		end
	else
		Looter_Settings["DeleteLoot"]=false
	end
	if (Looter1_MountGather:GetChecked()) then
		Looter_Settings["mountGather"]=true
	else
		Looter_Settings["mountGather"]=false
	end
	if (Looter1_MountKey:GetChecked()) then
		Looter_Settings["mountKey"]=true
	else
		Looter_Settings["mountKey"]=false
	end
	if (Looter1_Misc:GetChecked()) then
		Looter_Settings["Misc"]=true
	else
		Looter_Settings["Misc"]=false
	end
	if (Looter1_UseBlocked:GetChecked()) then
		Looter_Settings["UseBlocked"]=true
	else
		Looter_Settings["UseBlocked"]=false
	end
	if (Looter1_Junk:GetChecked()) then
		if ((not Looter1_Common:GetChecked()) and (not Looter1_Uncommon:GetChecked()) and (not Looter1_Rare:GetChecked()) and (not Looter1_Epic:GetChecked()) and (not Looter1_Legendary:GetChecked())) then
			Looter_Settings["Rarity"] = 0;
		else
			Looter_Settings["Rarity"] = false;
		end
	end
	if (Looter1_Common:GetChecked()) then
		if ((not Looter1_Junk:GetChecked()) and (not Looter1_Uncommon:GetChecked()) and (not Looter1_Rare:GetChecked()) and (not Looter1_Epic:GetChecked()) and (not Looter1_Legendary:GetChecked())) then
			Looter_Settings["Rarity"] = 1;
		else
			Looter_Settings["Rarity"] = false;
		end
	end
	if (Looter1_Uncommon:GetChecked()) then
		if ((not Looter1_Junk:GetChecked()) and (not Looter1_Common:GetChecked()) and (not Looter1_Rare:GetChecked()) and (not Looter1_Epic:GetChecked()) and (not Looter1_Legendary:GetChecked())) then
			Looter_Settings["Rarity"] = 2;
		else
			Looter_Settings["Rarity"] = false;
		end
	end
	if (Looter1_Rare:GetChecked()) then
		if ((not Looter1_Junk:GetChecked()) and (not Looter1_Common:GetChecked()) and (not Looter1_Uncommon:GetChecked()) and (not Looter1_Epic:GetChecked()) and (not Looter1_Legendary:GetChecked())) then
			Looter_Settings["Rarity"] = 3;
		else
			Looter_Settings["Rarity"] = false;
		end
	end
	if (Looter1_Epic:GetChecked()) then
		if ((not Looter1_Common:GetChecked()) and (not Looter1_Uncommon:GetChecked()) and (not Looter1_Rare:GetChecked()) and (not Looter1_Junk:GetChecked()) and (not Looter1_Legendary:GetChecked())) then
			Looter_Settings["Rarity"] = 4;
		else
			Looter_Settings["Rarity"] = false;
		end
	end
	if (Looter1_Legendary:GetChecked()) then
		if ((not Looter1_Common:GetChecked()) and (not Looter1_Uncommon:GetChecked()) and (not Looter1_Rare:GetChecked()) and (not Looter1_Epic:GetChecked()) and (not Looter1_Junk:GetChecked())) then
			Looter_Settings["Rarity"] = 5;
		else
			Looter_Settings["Rarity"] = false;
		end
	end
	if ((not Looter1_Junk:GetChecked()) and (not Looter1_Common:GetChecked()) and (not Looter1_Uncommon:GetChecked()) and (not Looter1_Rare:GetChecked()) and (not Looter1_Epic:GetChecked()) and (not Looter1_Legendary:GetChecked())) then
		Looter_Settings["Rarity"] = false;
	end
end

-- Set the checkboxes on the menu based on variable/toggle status
function Looter_setCheckBoxes()
	if Looter_Settings["Leather"] then
		Looter1_Skinning:SetChecked(true)
	else
		Looter1_Skinning:SetChecked(nil)
	end
	if Looter_Settings["Mining"] then
		Looter1_Mining:SetChecked(true)
	else
		Looter1_Mining:SetChecked(nil)
	end
	if Looter_Settings["Herbs"] then
		Looter1_Herbalism:SetChecked(true)
	else
		Looter1_Herbalism:SetChecked(nil)
	end
	if Looter_Settings["Cloth"] then
		Looter1_Cloth:SetChecked(true)
	else
		Looter1_Cloth:SetChecked(nil)
	end
	if Looter_Settings["Prospect"] then
		Looter1_Prospecting:SetChecked(true)
	else
		Looter1_Prospecting:SetChecked(nil)
	end
	if Looter_Settings["Milling"] then
		Looter1_Milling:SetChecked(true)
	else
		Looter1_Milling:SetChecked(nil)
	end
	if Looter_Settings["Enchant"] then
		Looter1_Disenchanting:SetChecked(true)
	else
		Looter1_Disenchanting:SetChecked(nil)
	end
	if Looter_Settings["Fish"] then
		Looter1_Fishing:SetChecked(true)
	else
		Looter1_Fishing:SetChecked(nil)
	end
	if Looter_Settings["Health"] then
		Looter1_Health:SetChecked(true)
	else
		Looter1_Health:SetChecked(nil)
	end
	if Looter_Settings["Mana"] then
		Looter1_Mana:SetChecked(true)
	else
		Looter1_Mana:SetChecked(nil)
	end
	if Looter_Settings["Battleground"] then
		Looter1_Battleground:SetChecked(true)
	else
		Looter1_Battleground:SetChecked(nil)
	end
	if Looter_Settings["Quest"] then
		Looter1_Quest:SetChecked(true)
	else
		Looter1_Quest:SetChecked(nil)
	end
	if Looter_Settings["Value"] then
		Looter1_Value:SetChecked(true)
	else
		Looter1_Value:SetChecked(nil)
	end
	if Looter_Settings["StackValue"] then
		Looter1_StackValue:SetChecked(true)
	else
		Looter1_StackValue:SetChecked(nil)
	end
	if Looter_Settings["User"] then
		Looter1_User:SetChecked(true)
	else
		Looter1_User:SetChecked(nil)
	end
	if Looter_Settings["OnOff"] then
		Looter1_OnOff:SetChecked(true)
	else
		Looter1_OnOff:SetChecked(nil)
	end
	if Looter_Settings["useMMB"] then
		Looter1_HideMMB:SetChecked(true)
		Looter_MinimapButton:Show()
	else
		Looter1_HideMMB:SetChecked(nil)
		Looter_MinimapButton:Hide()
	end
	if Looter_Settings["CloseLoot"] then
		Looter1_CloseLoot:SetChecked(true)
		Looter1_DeleteLoot:SetChecked(nil)
	else
		Looter1_CloseLoot:SetChecked(nil)
	end
	if Looter_Settings["DeleteLoot"] then
		Looter1_DeleteLoot:SetChecked(true)
		Looter1_CloseLoot:SetChecked(nil)
	else
		Looter1_DeleteLoot:SetChecked(nil)
	end
	if Looter_Settings["mountGather"] then
		Looter1_MountGather:SetChecked(true)
	else
		Looter1_MountGather:SetChecked(nil)
	end
	if Looter_Settings["mountKey"] then
		Looter1_MountKey:SetChecked(true)
	else
		Looter1_MountKey:SetChecked(nil)
	end
	if Looter_Settings["Misc"] then
		Looter1_Misc:SetChecked(true)
	else
		Looter1_Misc:SetChecked(nil)
	end
	if Looter_Settings["UseBlocked"] then
		Looter1_UseBlocked:SetChecked(true)
	else
		Looter1_UseBlocked:SetChecked(nil)
	end
	if (Looter_Settings["Rarity"] == 0) then
		Looter1_Junk:SetChecked(true)
		Looter1_Common:SetChecked(nil)
		Looter1_Uncommon:SetChecked(nil)
		Looter1_Rare:SetChecked(nil)
		Looter1_Epic:SetChecked(nil)
		Looter1_Legendary:SetChecked(nil)
	elseif (Looter_Settings["Rarity"] == 1) then
		Looter1_Junk:SetChecked(nil)
		Looter1_Common:SetChecked(true)
		Looter1_Uncommon:SetChecked(nil)
		Looter1_Rare:SetChecked(nil)
		Looter1_Epic:SetChecked(nil)
		Looter1_Legendary:SetChecked(nil)
	elseif (Looter_Settings["Rarity"] == 2) then
		Looter1_Junk:SetChecked(nil)
		Looter1_Common:SetChecked(nil)
		Looter1_Uncommon:SetChecked(true)
		Looter1_Rare:SetChecked(nil)
		Looter1_Epic:SetChecked(nil)
		Looter1_Legendary:SetChecked(nil)
	elseif (Looter_Settings["Rarity"] == 3) then
		Looter1_Junk:SetChecked(nil)
		Looter1_Common:SetChecked(nil)
		Looter1_Uncommon:SetChecked(nil)
		Looter1_Rare:SetChecked(true)
		Looter1_Epic:SetChecked(nil)
		Looter1_Legendary:SetChecked(nil)
	elseif (Looter_Settings["Rarity"] == 4) then
		Looter1_Junk:SetChecked(nil)
		Looter1_Common:SetChecked(nil)
		Looter1_Uncommon:SetChecked(nil)
		Looter1_Rare:SetChecked(nil)
		Looter1_Epic:SetChecked(true)
		Looter1_Legendary:SetChecked(nil)
	elseif (Looter_Settings["Rarity"] == 5) then
		Looter1_Junk:SetChecked(nil)
		Looter1_Common:SetChecked(nil)
		Looter1_Uncommon:SetChecked(nil)
		Looter1_Rare:SetChecked(nil)
		Looter1_Epic:SetChecked(nil)
		Looter1_Legendary:SetChecked(true)
	else
		Looter1_Junk:SetChecked(nil)
		Looter1_Common:SetChecked(nil)
		Looter1_Uncommon:SetChecked(nil)
		Looter1_Rare:SetChecked(nil)
		Looter1_Epic:SetChecked(nil)
		Looter1_Legendary:SetChecked(nil)
	end
end

-- Timer to delay actions, not currently used
function Looter_waitTimer(self,elapsed,whatDo)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if (whatDo == "deletedelay" and Looter_Settings["DeleteLoot"]) then
		if (self.TimeSinceLastUpdate > 1.0) then
			self.TimeSinceLastUpdate = 0;
			if (debugMode) then EMLChat("Tick..","chat",LTR_EML) end
			if (GetNumLootItems() == 0) then
				CloseLoot()
			else
				for slotnum = 1, GetNumLootItems() do
					if (not LootSlotIsCoin(slotnum)) then
						Looter_destroyLoot(slotnum)
					end
					if (slotnum >= GetNumLootItems()) then
						CloseLoot()
					end
				end
			end
--			Looter_Timer:Hide()
		end
	end
	if (whatDo == "deleteitems" and Looter_Settings["DeleteLoot"]) then
		if (self.TimeSinceLastUpdate > 1.5) then
			self.TimeSinceLastUpdate = 0;
			if (debugMode) then EMLChat("Tick..","chat",LTR_EML) end
			Looter_doDestroy()
			Looter_Timer:Hide()
		end
	end
	if (self.TimeSinceLastUpdate > Looter_updateInterval and whatDo ~= "deleteitems" and whatDo ~= "deletedelay") then
		self.TimeSinceLastUpdate = 0;
		if (debugMode) then EMLChat("Hiding Timer, no task","chat",LTR_EML) end
		Looter_Timer:Hide()
	end
end

-- Gets/Sets the value of the items the user wanst to loot
function Looter_checkValue(arg)
	if (arg == "check") then
		local goldValue=tonumber(Looter1_GoldBox:GetText())
		local silverValue=tonumber(Looter1_SilverBox:GetText())
		local copperValue=tonumber(Looter1_CopperBox:GetText())
		local newGold=Looter_setValue(goldValue,"gold")
		local newSilver=Looter_setValue(silverValue,"silver")
		local newCopper=Looter_setValue(copperValue,"copper")
		local totalValue=newGold+newSilver+newCopper
		if ((goldValue and silverValue and copperValue) ~= nil) and (debugMode) then
			EMLChat("Gold value is: "..goldValue.." Silver value is: "..silverValue.." Copper value is: "..copperValue,"chat",LTR_EML)
			EMLChat("New Value is: "..totalValue,"chat",LTR_EML)
		end
		if ((goldValue and silverValue and copperValue) ~= (nil or "" or " ")) then
			Looter_lootValue=totalValue
			LooterUserValue["Gold"]=goldValue
			LooterUserValue["Silver"]=silverValue
			LooterUserValue["Copper"]=copperValue
		end
	end
	if (arg == "set") then
		local newGold=Looter_setValue(LooterUserValue["Gold"],"gold")
		local newSilver=Looter_setValue(LooterUserValue["Silver"],"silver")
		local newCopper=Looter_setValue(LooterUserValue["Copper"],"copper")
		local totalValue=newGold+newSilver+newCopper
		Looter_lootValue=totalValue
		Looter1_GoldBox:SetText(LooterUserValue["Gold"])
		Looter1_SilverBox:SetText(LooterUserValue["Silver"])
		Looter1_CopperBox:SetText(LooterUserValue["Copper"])
	end
end

-- Resets everything to the defaults
function Looter_Reset(arg)
	local localSettings = EML_copyTable(Looter_defaultSettings);
	local localValue = EML_copyTable(Looter_defaultUserValue);
	local localInput = EML_copyTable(Looter_defaultInput);
	local localBlock = EML_copyTable(Looter_defaultBlockList);
	Looter_Settings=EML_mergeTable(Looter_Settings,localSettings);
	if (arg == "version") then
		Looter_Settings["Version"] = localSettings["Version"];
		EMLChat("Version is changed, resetting and updating settings.","chat",LTR_EML)
	else
		EMLChat("Everythings reset","chat",LTR_EML)
		EML_clearTable(Looter_Settings)
		Looter_Settings=localSettings;
		EML_clearTable(LooterUserValue)
		LooterUserValue=localValue;
		EML_clearTable(LooterUserInput)
		LooterUserInput=localInput;
		EML_clearTable(LooterBlockList)
		LooterBlockList=localBlock;
	end
	Looter_setCheckBoxes()
	Looter_checkValue("set")
end

-- If user has Useful Extras mod, and has mount after gathering enabled, will mount up on best availible mount
function Looter_mountUp()
	Looter_doMount = false;
	if (Looter_hasUE) then
		UE_pickMount("smart")
	else
		EMLChat("You must have the Useful Extras mod to use mounting after looting.","chat",LTR_EML,"red")
	end
end

function Looter_handleToggle(msg)
	if msg == "testing" then
		if Looter_useTesting==0 then
			Looter_useTesting=1;
			EMLChat("Test looting toggled on","chat",LTR_EML)
		else
			Looter_useTesting=0;
			EMLChat("Test looting toggled off","chat",LTR_EML)
		end
	elseif msg == "user" then
		if Looter_Settings["User"]==false then
			Looter_Settings["User"]=true;
			EMLChat("User supplied toggled on","chat",LTR_EML)
		else
			Looter_Settings["User"]=false;
			EMLChat("User supplied toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "blocklist" then
		if Looter_Settings["UseBlocked"]==false then
			Looter_Settings["UseBlocked"]=true;
			EMLChat("Items on the block list will not be looted","chat",LTR_EML)
		else
			Looter_Settings["UseBlocked"]=false;
			EMLChat("Items on the block list will still be looted","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "cloth" then
		if Looter_Settings["Cloth"]==false then
			Looter_Settings["Cloth"]=true;
			EMLChat("Cloth looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Cloth"]=false;
			EMLChat("Cloth looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "skinning" then
		if Looter_Settings["Leather"]==false then
			Looter_Settings["Leather"]=true;
			EMLChat("Leather looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Leather"]=false;
			EMLChat("Leather looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "herbs" then
		if Looter_Settings["Herbs"]==false then
			Looter_Settings["Herbs"]=true;
			EMLChat("Herbs looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Herbs"]=false;
			EMLChat("Herbs looting toggled on","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "mining" then
		if Looter_Settings["Mining"]==false then
			Looter_Settings["Mining"]=true;
			EMLChat("Mining looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Mining"]=false;
			EMLChat("Mining looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "fish" then
		if Looter_Settings["Fish"]==false then
			Looter_Settings["Fish"]=true;
			EMLChat("Fish looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Fish"]=false;
			EMLChat("Fish looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "prospecting" then
		if Looter_Settings["Prospect"]==false then
			Looter_Settings["Prospect"]=true;
			EMLChat("Prospect looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Prospect"]=false;
			EMLChat("Prospect looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "milling" then
		if Looter_Settings["Milling"]==false then
			Looter_Settings["Milling"]=true;
			EMLChat("Mill looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Milling"]=false;
			EMLChat("Mill looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "enchanting" then
		if Looter_Settings["Enchant"]==false then
			Looter_Settings["Enchant"]=true;
			EMLChat("Disenchant looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Enchant"]=false;
			EMLChat("Disenchant looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "health" then
		if Looter_Settings["Health"]==false then
			Looter_Settings["Health"]=true;
			EMLChat("Health Potion looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Health"]=false;
			EMLChat("Health Potion looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "mana" then
		if Looter_Settings["Mana"]==false then
			Looter_Settings["Mana"]=true;
			EMLChat("Mana Potion looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Mana"]=false;
			EMLChat("Mana Potion looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "battleground" then
		if Looter_Settings["Battleground"]==false then
			Looter_Settings["Battleground"]=true;
			EMLChat("Battleground looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Battleground"]=false;
			EMLChat("Battleground looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "quest" then
		if Looter_Settings["Quest"]==false then
			Looter_Settings["Quest"]=true;
			EMLChat("Quest looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Quest"]=false;
			EMLChat("Quest looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "value" then
		if Looter_Settings["Value"]==false then
			Looter_Settings["Value"]=true;
			EMLChat("Value looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Value"]=false;
			EMLChat("Value looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "stackvalue" then
		if Looter_Settings["StackValue"]==false then
			Looter_Settings["StackValue"]=true;
			EMLChat("Stack Value looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["StackValue"]=false;
			EMLChat("Stack Value looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "looter" then
		if Looter_Settings["OnOff"]==false then
			Looter_Settings["OnOff"]=true;
			EMLChat("Looter turned on","chat",LTR_EML)
		else
			Looter_Settings["OnOff"]=false;
			EMLChat("Looter turned off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "minimap" then
		if Looter_Settings["useMMB"]==false then
			Looter_Settings["useMMB"]=true;
			EMLChat("Minimap button toggled","chat",LTR_EML)
		else
			Looter_Settings["useMMB"]=false;
			EMLChat("Minimap button toggled","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "deleteloot" then
		if Looter_Settings["DeleteLoot"]==false then
			Looter_Settings["DeleteLoot"]=true;
			Looter_Settings["CloseLoot"]=false;
			EMLChat("*use at own risk* Looter will now delete items not matching current loot lists","chat",LTR_EML)
		else
			Looter_Settings["DeleteLoot"]=false;
			EMLChat("Looter will not delete items that don't match the current loot lists","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "closeloot" then
		if Looter_Settings["CloseLoot"]==false then
			Looter_Settings["CloseLoot"]=true;
			Looter_Settings["DeleteLoot"]=false;
			EMLChat("Looter will close the loot window after looting what matches the current loot lists","chat",LTR_EML)
		else
			Looter_Settings["CloseLoot"]=false;
			EMLChat("Looter will not close the loot window after looting what matches the current loot lists","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "mountgather" then
		if Looter_Settings["mountGather"]==false then
			Looter_Settings["mountGather"]=true;
			EMLChat("Mount after gathering turned on","chat",LTR_EML)
		else
			Looter_Settings["mountGather"]=false;
			EMLChat("Mount after gathering turned off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "mountkey" then
		if Looter_Settings["mountKey"]==false then
			Looter_Settings["mountKey"]=true;
			EMLChat("Mount after looting with key down turned on","chat",LTR_EML)
		else
			Looter_Settings["mountKey"]=false;
			EMLChat("Mount after looting with key down turned off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "misc" then
		if Looter_Settings["Misc"]==false then
			Looter_Settings["Misc"]=true;
			EMLChat("Misc. Profession looting toggled on","chat",LTR_EML)
		else
			Looter_Settings["Misc"]=false;
			EMLChat("Misc. Profession looting toggled off","chat",LTR_EML)
		end
		Looter_setCheckBoxes()
	elseif msg == "status" then
		EMLChat("Status of Looting is:","chat",LTR_EML)
		if Looter_Settings["User"] then
			EMLChat("Looting of user given items is on","chat",LTR_EML)
		else
			EMLChat("Looting of user given items is off","chat",LTR_EML)
		end
		if Looter_Settings["UseBlocked"] then
			EMLChat("Items on the block list will not be looted","chat",LTR_EML)
		else
			EMLChat("Items on the block list will be looted","chat",LTR_EML)
		end
		if Looter_Settings["Cloth"] then
			EMLChat("Looting cloth is on","chat",LTR_EML)
		else
			EMLChat("Looting cloth is off","chat",LTR_EML)
		end
		if Looter_Settings["Mining"] then
			EMLChat("Looting mining is on","chat",LTR_EML)
		else
			EMLChat("Looting mining is off","chat",LTR_EML)
		end
		if Looter_Settings["Leather"] then
			EMLChat("Looting leather is on","chat",LTR_EML)
		else
			EMLChat("Looting leather is off","chat",LTR_EML)
		end
		if Looter_Settings["Herbs"] then
			EMLChat("Looting herbs is on","chat",LTR_EML)
		else
			EMLChat("Looting herbs is off","chat",LTR_EML)
		end
		if Looter_Settings["Prospect"] then
			EMLChat("Looting prospecting is on","chat",LTR_EML)
		else
			EMLChat("Looting prospecting is off","chat",LTR_EML)
		end
		if Looter_Settings["Milling"] then
			EMLChat("Looting milling is on","chat",LTR_EML)
		else
			EMLChat("Looting milling is off","chat",LTR_EML)
		end
		if Looter_Settings["Enchant"] then
			EMLChat("Looting disenchant is on","chat",LTR_EML)
		else
			EMLChat("Looting disenchant is off","chat",LTR_EML)
		end
		if Looter_Settings["Fish"] then
			EMLChat("Looting fish is on","chat",LTR_EML)
		else
			EMLChat("Looting fish is off","chat",LTR_EML)
		end
		if Looter_Settings["Health"] then
			EMLChat("Looting health potions is on","chat",LTR_EML)
		else
			EMLChat("Looting health potions is off","chat",LTR_EML)
		end
		if Looter_Settings["Mana"] then
			EMLChat("Looting mana potions is on","chat",LTR_EML)
		else
			EMLChat("Looting mana potions is off","chat",LTR_EML)
		end
		if Looter_Settings["Battleground"] then
			EMLChat("Looting battleground items is on","chat",LTR_EML)
		else
			EMLChat("Looting battleground items is off","chat",LTR_EML)
		end
		if Looter_Settings["Misc"] then
			EMLChat("Looting miscellaneous profession items is on","chat",LTR_EML)
		else
			EMLChat("Looting miscellaneous profession items is off","chat",LTR_EML)
		end
		if Looter_Settings["Quest"] then
			EMLChat("Looting quest items is on","chat",LTR_EML)
		else
			EMLChat("Looting quest items is off","chat",LTR_EML)
		end
		if Looter_Settings["Value"] then
			EMLChat("Value looting is on","chat",LTR_EML)
		else
			EMLChat("Value looting is off","chat",LTR_EML)
		end
		if Looter_Settings["StackValue"] then
			EMLChat("Stack Value looting is on","chat",LTR_EML)
		else
			EMLChat("Stack Value looting is off","chat",LTR_EML)
		end
		if Looter_Settings["OnOff"] then
			EMLChat("Looter is on","chat",LTR_EML)
		else
			EMLChat("Looter is off","chat",LTR_EML)
		end
		if Looter_Settings["DeleteLoot"] then
			EMLChat("Deleting un-looted items is on (use at your own risk)","chat",LTR_EML)
		else
			EMLChat("Deleting un-looted items is off","chat",LTR_EML)
		end
		if Looter_Settings["CloseLoot"] then
			EMLChat("Looter closing the loot window after looting is on","chat",LTR_EML)
		else
			EMLChat("Looter closing the loot window after looting is off","chat",LTR_EML)
		end
		if Looter_Settings["mountGather"] then
			EMLChat("Mount after gathering is on","chat",LTR_EML)
		else
			EMLChat("Mount after gathering is off","chat",LTR_EML)
		end
		if Looter_Settings["mountKey"] then
			EMLChat("Mount after looting with key down is on","chat",LTR_EML)
		else
			EMLChat("Mount after looting with key down is off","chat",LTR_EML)
		end
		if Looter_Settings["useMMB"] then
			EMLChat("Minimap button is shown","chat",LTR_EML)
		else
			EMLChat("Minimap button is hidden","chat",LTR_EML)
		end
		if Looter_Settings["Rarity"] then
			if (Looter_Settings["Rarity"] == 0) then
				EMLChat("Junk or better will be looted","chat",LTR_EML)
			elseif (Looter_Settings["Rarity"] == 1) then
				EMLChat("Common or better will be looted","chat",LTR_EML)
			elseif (Looter_Settings["Rarity"] == 2) then
				EMLChat("Uncommon or better will be looted","chat",LTR_EML)
			elseif (Looter_Settings["Rarity"] == 3) then
				EMLChat("Rare or better will be looted","chat",LTR_EML)
			elseif (Looter_Settings["Rarity"] == 4) then
				EMLChat("Epic or better will be looted","chat",LTR_EML)
			elseif (Looter_Settings["Rarity"] == 5) then
				EMLChat("Legendary or better will be looted","chat",LTR_EML)
			end
		else
			EMLChat("Looting by quality is off","chat",LTR_EML)
		end
	end
end
-- The End