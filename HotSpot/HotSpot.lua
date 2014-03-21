-----------------------------------------------------------------------------------------------
-- Client Lua Script for HotSpot
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "MacrosLib"
require "GameLib"
require "ICCommLib"

local ktDiaogInfo = {
	["AdoptReq"] = {
		template = "TwoButton",
		buttons = {green = "Adopt", red = "Ignore"},
		text = "A Hot Spot host would like someone to adopt their Hot Spot. Will you take it over?",
		method = "AdoptReceiveCallback",
	},
	["HaveAdopted"] = {
		template = "OneButton",
		buttons = {green = "OK"},
		text = "You have adopted the Hot Spot.",
	},
	["WillAdopt"] = {
		template = "OneButton",
		buttons = {green = "OK"},
		text = "Someone has agreed to adopt your Hot Spot.",
	}
	
} 
local tTypeDDList = {
	"Tavern",
	"Social Gathering",
	"Combat Event: PVE",
	"Combat Event: PVP",		
}
local bHasHotSpot = false


-----------------------------------------------------------------------------------------------
-- HotSpot Module Definition
-----------------------------------------------------------------------------------------------
local HotSpot = {} 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function HotSpot:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	
	self.tEventList = {}
	
	--[[ -- Data Structure for Table
		{
			title = "Test Event Name",
			location = {"Somewhere","Everywhere"},
			details = "Test Details",
			type = "Tavern",
			host="Togglebutton",
			coords = {x=1,y=1,z=0},
		},
	]]
		
	self.tMyHotSpot = {}
	self.nSelectedHotSpot = 0
    return o
end

function HotSpot:Init()
    Apollo.RegisterAddon(self, false, "", {})
end
 
-----------------------------------------------------------------------------------------------
-- HotSpot OnLoad
-----------------------------------------------------------------------------------------------


function HotSpot:OnLoad()
    Apollo.RegisterSlashCommand("hotspot", "OnHotSpotOn", self)
	self.chanHotSpot = ICCommLib.JoinChannel("HotSpotChannel", "OnMessRcv", self)
	self.wndMain = Apollo.LoadForm("HotSpot.xml", "HotSpotListWindow", nil, self)
	self.wndItemList = self.wndMain:FindChild("Grid")
	self.wndMain:Show(false)
end

-----------------------------------------------------------------------------------------------
-- HotSpot Functions
-----------------------------------------------------------------------------------------------
-- on SlashCommand "/hotspot"
function HotSpot:OnHotSpotOn(command, ...)
	-- populate the item list
	self.wndMain:Show(true) -- show the window
	self:PopulateItemList()
end

-----------------------------------------------------------------------------------------------
-- HotSpotListWindow Functions
-----------------------------------------------------------------------------------------------

function HotSpot:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

function HotSpot:CreateSpotClick()
	if not self.wndCreate then
		self.wndCreate = Apollo.LoadForm("HotSpot.xml", "CreateHotSpotWindow", nil, self)
		self.DDMenu = self.wndCreate:FindChild("DropDownMenu")
		self:CreateDropDown()
		self.DDMenu:Show(false)
		self.wndCreate:Show(true)
	else
		self.wndCreate:Show(true)
	end
end

function HotSpot:SetToolTip()
	
	if self.nSelectedHotSpot >= 1 then
		local xmlTooltip = XmlDoc.new()
		local tSpotInfo = self.tEventList[self.nSelectedHotSpot]
		xmlTooltip:AddLine("<T Font=\"CRB_Interface14_BO\" TextColor=\"xkcdAmber\">"..tSpotInfo.title.."</T>")
		xmlTooltip:AddLine(string.format("<T Font=\"CRB_Interface12_BO\" TextColor=\"green\">%s, %s</T>",tSpotInfo.location[1], tSpotInfo.location[2]))
		xmlTooltip:AddLine(string.format("<T Font=\"CRB_Interface12_BO\" TextColor=\"green\">X: %s, Y: %s</T>", self:StringRound(tSpotInfo.coords.x, 2), self:StringRound(tSpotInfo.coords.y, 2)))
		xmlTooltip:AddLine("<T Font=\"CRB_Interface10_BO\" TextColor=\"cyan\">"..tSpotInfo.host.."</T>")
		xmlTooltip:AddLine("<T Font=\"CRB_Interface11\" TextColor=\"white\">"..tSpotInfo.details.."</T>")
		
		self.wndItemList:SetTooltipDoc(xmlTooltip)
	else
		self.wndItemList:SetTooltipDoc(nil)
	end
end

function HotSpot:ManualTransfer()
	self:SendAdopt(GameLib.GetTargetUnit():GetName())
end

function HotSpot:LocateHotSpot()
	if self.tEventList[self.nSelectedHotSpot] then
		GameLib.GetPlayerUnitByName(self.tEventList[self.nSelectedHotSpot or 1].host):ShowHintArrow()
	end
end

-----------------------------------------------------------------------------------------------
-- ItemList Functions
-----------------------------------------------------------------------------------------------
-- populate item list
function HotSpot:AddListItem(index, tCurr)
	
	local iCurrRow = self.wndItemList:AddRow("")
	self.wndItemList:SetCellLuaData(iCurrRow, 1, index)
	self.wndItemList:SetCellText(iCurrRow, 1, tCurr.type)
	self.wndItemList:SetCellText(iCurrRow, 2, tCurr.title)
	self.wndItemList:SetCellText(iCurrRow, 3, string.format("%s, %s",tCurr.location[1],tCurr.location[2]))
	self.wndItemList:SetCellText(iCurrRow, 4, tCurr.host)
end

function HotSpot:PopulateItemList()
	self.wndItemList:DeleteAll()
	if #self.tEventList > 0 and self.tEventList[1].host then
		for i, tCurr in pairs(self.tEventList) do
			self:AddListItem(i, tCurr)
		end
	end
end

-- when a list item is selected
function HotSpot:OnListItemSelected(wndControl, wndHandler, iRow, iCol,iCurrRow, iCurrCol)
	--Print(iRow)
	self.nSelectedHotSpot = iRow or self.nSelectedHotSpot
	self:SetToolTip()
end

-----------------------------------------------------------------------------------------------
-- CreateHotSpotWindow Functions
-----------------------------------------------------------------------------------------------

function HotSpot:OnCreateOK()
	local strType = self.wndCreate:FindChild("EventType"):FindChild("Button"):FindChild("Text"):GetText()
	local strTitle = self.wndCreate:FindChild("EventTitle"):FindChild("EditBox"):GetText()
	local strDetails = self.wndCreate:FindChild("EventDetails"):FindChild("EditBox"):GetText()
	local tNewHotSpot = {
		title = strTitle,
		location = {GameLib.GetCurrentZoneMap().strName,GetCurrentZoneName()},
		coords = GameLib.GetPlayerUnit():GetPosition(),
		details = strDetails,
		type = strType,
		host= GameLib.GetPlayerUnit():GetName(),
	}
	self:SetMyHotSpot(tNewHotSpot)
	self:CreateClose()
end

function HotSpot:CreateClose()
	self.wndCreate:Show(false)
	self:DestroyCreateWindow()
end

function HotSpot:DestroyCreateWindow()
	if self.wndCreate then
		self.wndCreate:Destroy()
		self.wndCreate = nil
		self.strEventType = nil
	end
end

function HotSpot:CreateDropDown()
	for i,v in pairs(tTypeDDList) do
		local wndCurr = Apollo.LoadForm("HotSpot.xml", "DDButton", self.DDMenu, self)
		wndCurr:SetText(v)
		wndCurr:SetData(i)
	end
	self.DDMenu:ArrangeChildrenVert()
	local nL, nT, nR, nB = self.DDMenu:GetAnchorOffsets()
	self.DDMenu:SetAnchorOffsets(nL, nT, nR, (nT + ( #tTypeDDList * 30 )) )
	self.DDMenu:ToFront()
end

function HotSpot:OnDDClick()
	if self.DDMenu and self.DDMenu:IsShown() == false then
		self.DDMenu:Show(true)
		self.DDMenu:ToFront()
	elseif self.DDMenu and self.DDMenu:IsShown() == true then
		self.DDMenu:Show(false)	
	end
end

function HotSpot:DDButtonClick(wndHandler, wndControl)
	local strEventType = wndControl:GetText()
	self.wndCreate:FindChild("EventType"):FindChild("Button"):FindChild("Text"):SetText(strEventType)
	self.strEventType = strEventType
	self.DDMenu:Show(false)
end

-----------------------------------------------------------------------------------------------
-- Communication Functions
-----------------------------------------------------------------------------------------------
function HotSpot:OnMessRcv(channel, tMsg, strSender)
	if tMsg.prefix == "ReqAll" then
		self:OnReqAll(strSender)
	elseif tMsg.prefix == "SpotInfo" then
		self:OnSpotReceive(tMsg.data)
	elseif tMsg.prefix == "Clear" then
		self:OnClearRcv(strSender)
	elseif tMsg.prefix == "Ann" then
		self:OnAnnRcv(strSender)
	elseif tMsg.prefix == "Req" then
		self:OnReqRcv(strSender)
	elseif tMsg.prefix == "Adopt" then
		self:OnAdoptRcv(strSender)
	elseif tMsg.prefix == "WillAdopt" then
		self:OnWillAdoptRcv(strSender)
	elseif tMsg.prefix == "AdoptOK" then
		self:OnAdoptOK(tMsg)
	end
end 

-- Sends
function HotSpot:SendReqAll()
	self.chanHotSpot:SendMessage({prefix="ReqAll"})
end

function HotSpot:SendTestMessage()
	self.chanHotSpot:SendPrivateMessage({GameLib.GetPlayerUnit():GetName()},{prefix = "Test"})
end

function HotSpot:SendSpotInfo(strTarget, tSpotTable)
	self.chanHotSpot:SendPrivateMessage({strTarget},{prefix = "SpotInfo",data = tSpotTable})
end

function HotSpot:SendClear()
	self.chanHotSpot:SendMessage({prefix = "Clear"})
end

function HotSpot:SendAnnounce()
	self.chanHotSpot:SendMessage({prefix="Ann"})
end

function HotSpot:SendAdopt(strTarget)
	if strTarget then
		self.chanHotSpot:SendPrivateMessage({strTarget},{prefix="Adopt"})
	else
		self.chanHotSpot:SendMessage({prefix="Adopt"})
	end
end

function HotSpot:SendWillAdopt(strTarget)
	self.chanHotSpot:SendPrivateMessage({strTarget},{prefix = "WillAdopt"})
end

function HotSpot:SendAdoptOK(strTarget, tData)
	self.chanHotSpot:SendPrivateMessage({strTarget},{prefix = "AdoptOK", data = tData})
end

-- receives
function HotSpot:OnReqAll(strSender)
	if bHasHotSpot == true then
		self:SendSpotInfo(strSender, self.tMyHotSpot)
	end
end

function HotSpot:OnSpotReceive(tSpotTable)
    self:RemoveHotSpot(tSpotTable.contact)
	self:AddHotSpot(tSpotTable)
end

function HotSpot:OnClearRcv(strSender)
	self:RemoveHotSpot(strSender)
end

function HotSpot:OnAnnRcv(strSender)
	if bHasHotSpot == false then
		self.chanHotSpot:SendPrivateMessage({strSender},{prefix = "Req"})
	end
end

function HotSpot:OnReqRcv(strSender)
	if bHasHotSpot == true then
		self:SendSpotInfo(strSender, self.tMyHotSpot)
	end
end
-- Adoption
function HotSpot:OnAdoptRcv(strSender)
	-- someone has requested adoption
	if bHasHotSpot == false then
		local tSpot = self:GetPlayerHotSpot(strSender)
		if tSpot then
			if self:LeaveRangeCheck(tSpot.coords) == false then
				self.AdoptPlayerRequest = strSender
				DialogLib:ShowDialog(ktDiaogInfo["AdoptReq"].template, ktDiaogInfo["AdoptReq"].text, ktDiaogInfo["AdoptReq"].buttons, ktDiaogInfo["AdoptReq"].method, self)
			end
		end
	end
end

function HotSpot:AdoptReceiveCallback(nWindID, strInput)
	-- Adoption request dialog callback
	if nWindID == 1 then
		self:SendWillAdopt(self.AdoptPlayerRequest)
	end
end

function HotSpot:OnWillAdoptRcv(strSender)
	if bHasHotSpot == true then
		DialogLib:ShowDialog(ktDiaogInfo["WillAdopt"].template, ktDiaogInfo["WillAdopt"].text, ktDiaogInfo["WillAdopt"].buttons, ktDiaogInfo["WillAdopt"].method, self)
		self:SendAdoptOK(strSender, self.tMyHotSpot)
		self:ClearMyHotSpot()
	end
end

function HotSpot:OnAdoptOK(tMsg)
	DialogLib:ShowDialog(ktDiaogInfo["HaveAdopted"].template, ktDiaogInfo["HaveAdopted"].text, ktDiaogInfo["HaveAdopted"].buttons, ktDiaogInfo["HaveAdopted"].method, self)
	self.SetMyHotSpot(tMsg.data)
end

-----------------------------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------------------------
function HotSpot:StringRound(strIn, nPlaces)
	if not nPlaces then nPlaces = 0 end
	local nDeciPlace = string.find(strIn, ".")
	return tonumber(string.sub(strIn,0, (nDeciPlace + nPlaces)))
end

function HotSpot:LeaveRangeCheck(tCoords)
    if not tCoords then
        return nil
    end
	local tCurrPos = GameLib.GetPlayerUnit():GetPosition()
	local xDiff = tCoords.x - tCurrPos.x;
	local yDiff = tCoords.y - tCurrPos.y;
	return math.abs(math.sqrt(xDiff * xDiff + yDiff * yDiff)) <= 10
end

function HotSpot:WipeTable(tTable)
	for i, v in pairs(tTable) do
		tTable[i] = nil
	end
end

function HotSpot:SetTableToTable(tDest, tSource)
	self:WipeTable(tDest)
	for i,v in pairs(tSource) do
		tDest[i] = v
	end
end

-----------------------------------------------------------------------------------------------
-- Spot Control Functions
-----------------------------------------------------------------------------------------------

-- removes a HotSpot form the event listing table based on a contact's name
function HotSpot:RemoveHotSpot(strContact)
    for i,v in pairs(self.tEventList) do
        if v.host == strContact then
            table.remove(self.tEventList, i)
        end
    end
	self:PopulateItemList()
end

-- adds a hot spot into the event listing table
function HotSpot:AddHotSpot(tSpotTable)
	table.insert(self.tEventList, tSpotTable)
	self:PopulateItemList()
end

-- returns a HotSpot table of a specific player name
function HotSpot:GetPlayerHotSpot(strContact)
	for i,v in pairs(self.tEventList[nSpot]) do
		if v.host == strContact then
			return v
		end
	end
end

-- Removes the player's set up HotSpot
function HotSpot:ClearMyHotSpot()
	self:WipeTable(self.tMyHotSpot)
	bHasHotSpot = false
	self:RemoveHotSpot(GameLib.GetPlayerUnit():GetName())
	self:SendClear()
end

-- sets the player's HotSpot
function HotSpot:SetMyHotSpot(tHotSpot)
	self:SetTableToTable(self.tMyHotSpot,tHotSpot)
	bHasHotSpot = true
	self:AddHotSpot(tHotSpot)
	self:SendAnnounce()
end

-- removes all HotSpots in the list.
function HotSpot:RemoveAllHotSpots()
	self:WipeTable(self.tEventList)
	self:PopulateItemList()
end

function HotSpot:RefreshList()
	self:RemoveAllHotSpots()
	self:SendReqAll()
	if bHasHotSpot == true then
		self:AddHotSpot(self.tMyHotSpot)
	end
end

-----------------------------------------------------------------------------------------------
-- HotSpot Instance
-----------------------------------------------------------------------------------------------
local HotSpotInst = HotSpot:new()
HotSpotInst:Init()
