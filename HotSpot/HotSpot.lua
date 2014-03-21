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
local nSelectedHotSpot = 1

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
			icon = "Icon_SkillTemporary_Spell_Warrior_Smash",
			location = {"Somewhere","Everywhere"},
			details = "Test Details",
			type = "Tavern",
			host="Togglebutton",
			coords = {x=1,y=1,z=0},
		},
	]]
		
	self.tMyHotSpot = {}
		
    return o
end

function HotSpot:Init()
    Apollo.RegisterAddon(self, false, "", {})
end
 
-----------------------------------------------------------------------------------------------
-- HotSpot OnLoad
-----------------------------------------------------------------------------------------------


function HotSpot:OnLoad()
    -- Register handlers for events, slash commands and timer, etc.
    -- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
    Apollo.RegisterSlashCommand("hotspot", "OnHotSpotOn", self)
	Apollo.RegisterTimerHandler("HS_LoadIconTimer", "OnLoadIcons", self)
	self.chanHotSpot = ICCommLib.JoinChannel("HotSpotChannel", "OnMessRcv", self)
end

-----------------------------------------------------------------------------------------------
-- HotSpot Functions
-----------------------------------------------------------------------------------------------
-- on SlashCommand "/hotspot"
function HotSpot:OnHotSpotOn(command, ...)
	if not self.wndMain then
		self.wndMain = Apollo.LoadForm("HotSpot.xml", "HotSpotListWindow", nil, self)
		self.wndItemList = self.wndMain:FindChild("Grid")
	end
	
	self.wndMain:Show(true) -- show the window
	-- populate the item list
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
		self.wndCreate:Show(true)
		local wndIconFrame = self.wndCreate:FindChild("EventIcon")
		self.wndIconSprite = wndIconFrame:FindChild("Icon")
	else
		self.wndCreate:Show(true)
	end
end

function HotSpot:SetToolTip(nListItem)
	Print(nListItem)
	if nListItem then
		local tSpotInfo = self.tEventList[nListItem]
		self.wndTooltip = self.wndTooltip or self.wndMain:FindChild("Grid"):LoadTooltipForm("HotSpot.xml", "HotSpotTooltip", self)
		self.wndTooltip:FindChild("Title"):SetText(tSpotInfo.title)
		self.wndTooltip:FindChild("Loc"):SetText(string.format("%s, %s",tSpotInfo.location[1], tSpotInfo.location[2]))
		self.wndTooltip:FindChild("Coords"):SetText(string.format("X: %s, Y: %s", self:StringRound(tSpotInfo.coords.x, 2), self:StringRound(tSpotInfo.coords.y, 2)))
		self.wndTooltip:FindChild("Host"):SetText(tSpotInfo.host or "")
		self.wndTooltip:FindChild("Desc"):SetText(tSpotInfo.details or "")
		self.wndTooltip:FindChild("Icon"):SetSprite(tSpotInfo.icon)
	end
end

function HotSpot:ManualTransfer()
	self:SendAdopt(GameLib.GetTargetUnit():GetName())
end

function HotSpot:LocateHotSpot()
	if self.tEventList[nSelectedHotSpot] then
		GameLib.GetPlayerUnitByName(self.tEventList[nSelectedHotSpot or 1].host):ShowHintArrow()
	end
end

-----------------------------------------------------------------------------------------------
-- ItemList Functions
-----------------------------------------------------------------------------------------------
-- populate item list
function HotSpot:AddListItem(index, tCurr)
	local button = "<Form Class=\"Button\" Base=\"CRB_Basekit:kitBtn_Metal_MediumGreen\" Name=\"Button\" LAnchorPoint=\"0\" TAnchorPoint=\"0\" RAnchorPoint=\"1\" TAnchorPoint=\"1\" LAnchorOffset=\"0\" TAnchorOffset=\"0\" RAnchorOffset=\"0\" BAnchorOffset=\"0\" Tooltip=\"Click!\" BGColor=\"ffffffff\" TextColor=\"ffffffff\" TooltipType=\"OnCursor\" />"
	
	local iCurrRow = self.wndItemList:AddRow("")
	self.wndItemList:SetCellLuaData(iCurrRow, 1, index)
	self.wndItemList:SetCellImage(iCurrRow, 1, tCurr.icon)
	self.wndItemList:SetCellDoc(iCurrRow, 1, button)
	self.wndItemList:SetCellDoc(iCurrRow, 2, "<T Font=\"CRB_InterfaceSmall\" TextColor=\"ffffffff\">"..tCurr.type.."</T>")
	self.wndItemList:SetCellDoc(iCurrRow, 3, "<T Font=\"CRB_InterfaceSmall\" TextColor=\"ffffffff\">"..tCurr.title.."</T>")
	self.wndItemList:SetCellDoc(iCurrRow, 4, "<T Font=\"CRB_InterfaceSmall\" TextColor=\"ffffffff\">"..string.format("%s, %s",tCurr.location[1],tCurr.location[2]).."</T>")
	self.wndItemList:SetCellDoc(iCurrRow, 5, "<T Font=\"CRB_InterfaceSmall\" TextColor=\"ffffffff\">"..tCurr.host.."</T>")
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
	nSelectedHotSpot = self.wndItemList:GetCellData(iRow or iCurrRow, 1)
	if nSelectedHotSpot then
		self:SetToolTip(nSelectedHotSpot)
	end
end

-----------------------------------------------------------------------------------------------
-- CreateHotSpotWindow Functions
-----------------------------------------------------------------------------------------------

function HotSpot:OnCreateOK()
	local strType = self.strEventType
	local strTitle = self.wndCreate:FindChild("EventTitle"):FindChild("EditBox"):GetText()
	local strDetails = self.wndCreate:FindChild("EventDetails"):FindChild("EditBox"):GetText()
	local strIcon = self.wndIconSprite:GetSprite("Icon")
	local tNewHotSpot = {
		title = strTitle,
		icon = strIcon,
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
		if self.DDMenu then
			self.DDMenu:Destroy()
			self.DDMenu = nil
		end
		self.wndIconSprite = nil
		self.wndCreate = nil
		self.strEventType = nil
	end
end

function HotSpot:CreateDropDown()
	self.DDMenu = Apollo.LoadForm("HotSpot.xml", "DropDownMenu", self.wndCreate, self)
	for i,v in pairs(tTypeDDList) do
		local wndCurr = Apollo.LoadForm("HotSpot.xml", "DDButton", self.DDMenu, self)
		wndCurr:SetText(v)
		wndCurr:SetData(i)
	end
	self.DDMenu:ArrangeChildrenVert()
	local wndPar = self.wndCreate:FindChild("EventType")
	local nParL, nParT, nParR, nParB = wndPar:GetAnchorOffsets()
	local nOffL, nOffT, nOffR, nOffB = self.DDMenu:GetAnchorOffsets()
	self.DDMenu:SetAnchorOffsets(nParL, nParB, (nParL + nOffR), (nParB + ( #tTypeDDList * 24 )) )
	self.DDMenu:ToFront()
end

function HotSpot:OnDDClick()
	if self.DDMenu and self.DDMenu:IsShown() == false then
		self.DDMenu:Show(true)
		self.DDMenu:ToFront()
	elseif self.DDMenu and self.DDMenu:IsShown() == true then
		self.DDMenu:Show(false)
	elseif not self.DDMenu then
		self:CreateDropDown()
	end
end

function HotSpot:DDButtonClick(wndHandler, wndControl)
	local strEventType = wndControl:GetText()
	self.wndCreate:FindChild("EventType"):FindChild("Button"):FindChild("Text"):SetText(strEventType)
	self.strEventType = strEventType
	self.DDMenu:Show(false)
end
---------------------------------------------------------------------------------------------------
-- Icon Selections (wndIcon)
---------------------------------------------------------------------------------------------------
function HotSpot:OnIconClick(wndHandler, wndControl)
    self:OpenIconWnd()
end

function HotSpot:OpenIconWnd()
	if self.wndIcon == nil then
		self.wndIcon = Apollo.LoadForm("HotSpot.xml", "SelectIcon", nil, self)
        Apollo.CreateTimer("HS_LoadIconTimer", 0.1, false)
		Apollo.StartTimer("HS_LoadIconTimer")
	else
		self.wndIcon:ToFront()
	end
end

function HotSpot:OnLoadIcons()
	self.wndIconList = self.wndIcon:FindChild("IconList")
	self.wndIconList:SetFocus()
	
	-- create the list of icons
	local arStrMacroIcons = MacrosLib.GetMacroIconList()
	 
	local wndFirstIcon = nil;
	
	for idx,value in pairs(arStrMacroIcons) do	
	
         if self.wndIcon == nil then -- in case when user quits before done loading
            break
         end
	
         local wnd = Apollo.LoadForm("HotSpot.xml", "IconItem", self.wndIconList, self)

         if idx == 1 then
             wndFirstIcon = wnd
         end
		 
         wnd:SetSprite(value)
		 
		 self.wndIconSprite:SetSprite(value)
		 
         local strSelectedIconSprite = self.wndCreate:FindChild("Icon"):GetSprite()
         if strSelectedIconSprite == value then
            self:SelectIcon(wnd)
         end
		 
	end
	
	if self.strSelectedIcon == nil and wndFirstIcon ~= nil then 
        self:SelectIcon(wndFirstIcon) -- select the first icon
    end
		
	self.wndIconList:ArrangeChildrenTiles()
end

function HotSpot:DestroyIconWnd()
	if not ( self.wndIcon == nil ) then
		self.wndIcon:Destroy()
		self.wndIcon = nil
		self.strSelectedIcon = nil
	end
end

function HotSpot:OnIconOK()
    if self.strSelectedIcon ~= nil then
        -- assign the selected icon to the icon in edit wnd
        self.wndIconSprite:SetSprite( self.strSelectedIcon)
    end
	self:DestroyIconWnd()
end

function HotSpot:OnIconCancel()
	self:DestroyIconWnd()
end

function HotSpot:SelectIcon(wnd)
	self.strSelectedIcon = wnd:GetSprite()
	self.wndIconSprite:SetSprite( self.strSelectedIcon )

end

function HotSpot:OnIconSelect(wndHandler, wndControl)
    self:SelectIcon(wndControl)   
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
function HotSpot:OnRcvAdopt(strSender)
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
