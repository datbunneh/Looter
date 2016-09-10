-- LibDataBroker Support for Looter
assert(LibStub, "LooterLDB requires LibStub")
assert(LibStub:GetLibrary("LibDataBroker-1.1"), "LooterLDB requires LibDataBroker-1.1")

local brokertext  = "Looter";
local lootertext = "Left click to open the menu. |nRight click to Reload the UI.";
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

function LooterLDB_OnLoad()
Looterbroker = ldb:NewDataObject(brokertext, {
	type = "launcher",
	label = brokertext,
	icon = "Interface\\Icons\\INV_Misc_Bag_17",
	OnClick = function(self, button)
		if button == "LeftButton" then
			EMLFrame_Toggle("Looter1")
		elseif button == "RightButton" then
			Looter_rightClick()
		end
	end,
    OnEnter = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
--		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(brokertext,0,1,0)
		GameTooltip:AddLine("------------------------------------",0.8,0.8,1)
		GameTooltip:AddLine(lootertext,1,1,1)
		GameTooltip:Show()
	end,
	OnLeave = function()
		GameTooltip:Hide()
    end,
})
end
-- End of code