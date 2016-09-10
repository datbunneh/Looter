--[[
Lua for the minimap button of Looter
]]--

-- Declare minimap saved variable
LooterMiniMap_Settings = {
	["MinimapPos"] = -20
}

-- Declare minimap defaults
LooterMiniMap_defaultSettings = {
	["MinimapPos"] = -20
}

function Looter_MinimapButton_Reposition()
	Looter_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(LooterMiniMap_Settings["MinimapPos"])),(80*sin(LooterMiniMap_Settings["MinimapPos"]))-52)
end


function Looter_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	LooterMiniMap_Settings["MinimapPos"] = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	Looter_MinimapButton_Reposition() -- move the button
end


function LooterMiniMap_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED"); 
end
 

function LooterMiniMap_OnEvent()
	-- VARIABLES_LOADED event
	if ( event == "VARIABLES_LOADED" ) then
		-- execute event code in this function
		Looter_MinimapButton_Reposition()
	end
end
 
Looter_Minimap_Button_OnEnter = function()
	if ( GameTooltip.lmmbfinished ) then
		return;
	end
	local text;
	GameTooltip.lmmbfinished = 1;
	GameTooltip:SetOwner(Looter_MinimapButton, "ANCHOR_TOP");
	if (Looter_Settings["RightClick"] == "reload") then
		text = "Looter|n______ |n|nLeft click to open the menu. |nRight click to reload ui. |nClick and drag to move Minimap Button.";
	elseif (Looter_Settings["RightClick"] == "menu") then
		text = "Looter|n______ |n|nLeft or right click to open the menu. |nClick and drag to move the Minimap Button.";
	else
		text = "Looter|n______ |n|nLeft click to open the menu. |nClick and drag to move the Minimap Button.";
	end
--   local text = "Looter|n______ |n|nLeft click to open the menu. |nRight click to Reload the  UI.|nClick and drag to move Minimap Button."
	GameTooltip:AddLine(text,.8,.8,.8,1);
	GameTooltip:Show();
end

Looter_Minimap_Button_OnLeave = function()
   GameTooltip:Hide();
   GameTooltip.lmmbfinished = nil;
end


function Looter_MinimapButton_OnClick(button)
	if ( button == "RightButton" ) then
		Looter_rightClick()
	else
		EMLFrame_Toggle("Looter1")
	end
end
