-----------------------------------------------------------------------------------------------
-- Client Lua Script for PDA
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "GameLib"
 
-----------------------------------------------------------------------------------------------
-- PDA Module Definition
-----------------------------------------------------------------------------------------------
local PDA = {} 
local RPCore
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
-- red = IC, Green = Available, Blue = in scene
local ktColors = {
	"ffffffff", -- white
	"ffffff00", --yellow
	"ff0000ff", --blue
	"ff00ff00", --green
	"ffff0000", --red
	"ff800080", --purple
	"ff00ffff", --cyan
	"ffff00ff", --magenta
}
local ktCSstrings = {
	Name = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Name: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Species = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Species: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Gender = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Gender: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Age = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Age: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Height = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Height: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Weight = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Weight: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Title = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Title: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Job = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Occupation: </T><T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</T>",
	Description = "<T font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloBodyHighlight\">Description: </T><BR/><P font=\"CRB_Interface12_BO\" TextColor=\"UI_TextHoloTitle\">%s</P>",
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function PDA:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function PDA:Init()
	local bHasConfigureButton = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"RPCore",
	}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- PDA OnLoad
-----------------------------------------------------------------------------------------------
function PDA:OnLoad()
    -- load our form file
	RPCore = Apollo.GetPackage("RPCore").tPackage
	self.xmlDoc = XmlDoc.CreateFromFile("PDA.xml")
	Apollo.RegisterSlashCommand("pda", "OnPDAOn", self)
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "PDAEditForm", nil, self)
	
	Apollo.RegisterEventHandler("UnitCreated","OnUnitCreated",self) 
	Apollo.RegisterEventHandler("UnitDestroyed","OnUnitDestroyed",self)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)
	
	Apollo.LoadSprites("PDA_Sprites.xml")
	self.bInitialLoadAllClear = false
	self.arDisplayedNameplates = {}
	self.arUnit2Nameplate = {}
	self.arFreeWindows = {}
	self.restored = false
end

-----------------------------------------------------------------------------------------------
-- PDA Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/pda"
function PDA:OnPDAOn()
	local rpFullname = RPCore:GetLocalTrait("fullname") or GameLib.GetPlayerUnit():GetName()
	local rpState = RPCore:GetLocalTrait("rpflag") or 1
	local rpShortBlurb = RPCore:GetLocalTrait("shortdesc") or "Unknown"
	local rpTitle = RPCore:GetLocalTrait("title") or "Unknown"
	local rpHeight = RPCore:GetLocalTrait("height") or "Unknown"
	local rpWeight = RPCore:GetLocalTrait("weight") or "Unknown"
	local rpAge = RPCore:GetLocalTrait("age") or "Unknown"
	local nRaceID = GameLib.GetPlayerUnit():GetRaceId()
	local rpRace = GameLib.CodeEnumRace[nRaceID] or "Unknown"
	local rpGender = GameLib.GetPlayerUnit():GetGender()
	local rpJob = RPCore:GetLocalTrait("job") or "Unknown"
	
	self.wndMain:FindChild("input_s_Name"):SetText(rpFullname)
	self.wndMain:FindChild("input_s_title"):SetText(rpTitle)
	self.wndMain:FindChild("input_s_description"):SetText(rpShortBlurb)
	self.wndMain:FindChild("input_s_Job"):SetText(rpJob)
	self.wndMain:FindChild("input_s_Race"):SetText(rpRace)
	self.wndMain:FindChild("input_s_Gender"):SetText(rpGender)
	self.wndMain:FindChild("input_s_Age"):SetText(rpAge)
	self.wndMain:FindChild("input_s_Height"):SetText(rpHeight)
	self.wndMain:FindChild("input_s_Weight"):SetText(rpWeight)

	for i = 1, 3 do 
		local wndButton = self.wndMain:FindChild("wnd_Controls:wnd_StatusDD:input_b_RoleplayToggle" .. i)
		wndButton:SetCheck(RPCore:HasBitFlag(rpState,i))
	end
	
	self.wndMain:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(GameLib.GetPlayerUnit())
	
	self.wndMain:Show(true) -- show the window
	self:OnStatusClick()
end
--[[
function PDA:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character) then return nil end 
	return { rpCore = RPCore:CacheAsTable() }
end 

function PDA:OnRestore(eLevel, tData)
	if (tData.rpCore ~= nil) then 
		RPCore:LoadFromTable(tData.rpCore)
		self.restored = true
	end
end
]]
function PDA:OnUnitCreated(unit)
	local rpVersion, rpAddons = RPCore:QueryVersion(unit:GetName())
	--if (unit:IsACharacter() and not unit:IsThePlayer() and rpVersion ~= nil) then
	if (unit:IsACharacter() and rpVersion ~= nil) then
		Print("Unit with RPCore Detected.")
		local idUnit = unit:GetId()
		-- don't create unit if we already know about it
		local tNameplate = self.arUnit2Nameplate[idUnit]
		if tNameplate ~= nil then return end
		tNameplate = self:CreateNameplateObject(unit)
		tNameplate.bBrandNew = true
	end
end 

function PDA:OnUnitDestroyed(unit) 
	
end

function PDA:CreateNameplateObject(unit)
	local tNameplate = {
		unitOwner 		= unit,
		idUnit 			= unit:GetId(),
		bOnScreen 		= false,
		bOccluded 		= false,
		bIsTarget 		= false,
		bInCombat		= false,
	}
	Print("Creating Nameplate Object.")
	self.arUnit2Nameplate[unit:GetId()] = tNameplate
	return tNameplate
end


function PDA:CreateNameplateWindow(tNameplate)

	if tNameplate.wndNameplate ~= nil then return end
	if tNameplate.unitOwner == nil then return end

	tNameplate.wndNameplate = table.remove(self.arFreeWindows)
	if tNameplate.wndNameplate == nil then
		Print("Creating Nameplate Window.")
		tNameplate.wndNameplate = Apollo.LoadForm(self.xmlDoc, "OverheadForm", "InWorldHudStratum", self)
	end
	Print("Setting Up Nameplate Window.")
	tNameplate.wndNameplate:SetData(tNameplate.unitOwner)
	tNameplate.wndNameplate:FindChild("wnd_Name"):SetData(tNameplate.unitOwner)
	tNameplate.wndNameplate:SetUnit(tNameplate.unitOwner, 1)  -- 1 for overhead, 0 for underfoot
	
	tNameplate.bOnScreen = tNameplate.wndNameplate:IsOnScreen()
	tNameplate.bOccluded = tNameplate.wndNameplate:IsOccluded()
	tNameplate.wndNameplate:Show(true, true)

	self.arDisplayedNameplates[tNameplate.wndNameplate:GetId()] = tNameplate
	return tNameplate.wndNameplate
end

function PDA:CreateCharacterSheet(wndHandler, wndControl)
	local unit = wndControl:GetParent():GetUnit()
		
	if not self.wndCS then
		self.wndCS = Apollo.LoadForm(self.xmlDoc, "CharSheetForm", nil, self)
		self.wndCS:Show(false)
	end
	
	local unitName = unit:GetName()
	local rpVersion, rpAddons = RPCore:QueryVersion(unit:GetName())
	local rpFullname, rpTitle, rpShortDesc, rpStateString, rpHeight, rpWeight, rpAge, rpRace, rpGender, rpJob
	
	local tCSString = {}
	
	local xmlCS = XmlDoc.new()
	
	if (rpVersion ~= nil) then
		rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
		rpTitle = RPCore:FetchTrait(unitName,"title")
		rpShortDesc = RPCore:GetTrait(unitName,"shortdesc")
		rpHeight = RPCore:GetTrait(unitName,"height")
		rpWeight = RPCore:GetTrait(unitName,"weight")
		rpAge = RPCore:GetTrait(unitName,"age")
		rpRace = GameLib.CodeEnumRace[unit:GetRaceId()]
		rpGender = unit:GetGender()
		rpJob = RPCore:GetTrait(unitName,"job") or GameLib.CodeEnumClass[unit:GetClassId()]
	
		if (rpFullname ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Name, rpFullname)) end
		if (rpTitle ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Title, rpTitle)) end
		if (rpRace ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Species, rpRace)) end
		if (rpGender ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Gender, rpGender)) end
		if (rpAge ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Age, rpAge)) end
		if (rpHeight ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Height, rpHeight)) end
		if (rpWeight ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Weight, rpWeight)) end
		if (rpTitle ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Title, rpTitle)) end
		if (rpJob ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Job, rpJob)) end
		if (rpShortDesc ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Description, rpShortDesc)) end
	end
	self.wndCS:FindChild("wnd_CharSheet"):SetDoc(xmlCS)
	self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(unit)
	self.wndCS:Show(true)
	
end

function PDA:DrawNameplate(tNameplate)
	local bShowNameplate = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)

	if not bShowNameplate then
		self:UnattachNameplateWindow(tNameplate); return false;
	end

	self:CreateNameplateWindow(tNameplate)

	-- Nameplate should be viewable? --and not tNameplate.bOccluded --and not self.bBlinded -- No thanks.
	bShowNameplate = bShowNameplate and tNameplate.bOnScreen 

	-- Check Occlusion setting.				
	if self.setEnableOcclusion and tNameplate.bOccluded then bShowNameplate = false end

	-- Show Nameplate?
	if self.setNeverShow or not bShowNameplate then
		if tNameplate.wndNameplate ~= nil then tNameplate.wndNameplate:Show(false) end
		return false
	end

	if tNameplate.unitOwner == nil then return false end
	local unitOwner = tNameplate.unitOwner
	local namePlate = tNameplate.wndNameplate
	
	local wndName = namePlate:FindChild("wnd_Name")
	local rpFullname, rpTitle, rpStatus, strNameString
	
	rpFullname = RPCore:GetTrait(unitOwner:GetName(),"fullname") or unitOwner:GetName()
	rpTitle = RPCore:FetchTrait(unitOwner:GetName(),"title")
	rpStatus = RPCore:GetTrait(unitOwner:GetName(), "rpflag")
	
	local xmlNamePlate = XmlDoc:new()
	if (rpFullname ~= nil) then xmlNamePlate:AddLine(rpFullname, "UI_TextHoloTitle", "CRB_Interface12_BO", "Center")  end
	if (rpTitle ~= nil) then xmlNamePlate:AddLine(rpTitle, "UI_TextHoloBodyHighlight", "CRB_Interface8","Center") end
	wndName:SetDoc(xmlNamePlate)
	if rpStatus ~= nil then tNameplate.wndNameplate:FindChild("btn_RP"):SetBGColor(ktColors[(rpStatus + 1)]) end

	namePlate:Show(true)

	return bShowNameplate
end

function PDA:OnFrame()
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		local bShowNameplate = self:DrawNameplate(tNameplate)
	end
end

function PDA:HelperVerifyVisibilityOptions(tNameplate)
	local unitOwner = tNameplate.unitOwner
	local bHiddenUnit = not unitOwner:ShouldShowNamePlate()		
	
	--if bHiddenUnit and not tNameplate.bIsTarget then
	if bHiddenUnit and tNameplate.bIsTarget == false then
		tNameplate.bBrandNew = false
		return false
	else
		tNameplate.bBrandNew = false
		return true
	end
end

function PDA:CheckDrawDistance(tNameplate)
	local unitOwner = tNameplate.unitOwner

	if not unitOwner or self.setDrawDistance == nil then
	    return
	end

	local unitPlayer = GameLib.GetPlayerUnit()

	tPosTarget = unitOwner:GetPosition()
	tPosPlayer = unitPlayer:GetPosition()

	if tPosTarget == nil then
		return
	end

	local nDeltaX = tPosTarget.x - tPosPlayer.x
	local nDeltaY = tPosTarget.y - tPosPlayer.y
	local nDeltaZ = tPosTarget.z - tPosPlayer.z

	local nDistance = (nDeltaX * nDeltaX) + (nDeltaY * nDeltaY) + (nDeltaZ * nDeltaZ)
	
	bInRange = nDistance < (self.setDrawDistance * self.setDrawDistance ) -- squaring for quick maths
	return bInRange

end

-----------------------------------------------------------------------------------------------
-- PDAForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function PDA:OnOK()
	self.wndMain:Show(false) -- hide the window
	
	local strFullname = self.wndMain:FindChild("input_s_Name"):GetText()
	local strCharTitle = self.wndMain:FindChild("input_s_title"):GetText()
	local strBlurb = self.wndMain:FindChild("input_s_description"):GetText()
	local strHeight = self.wndMain:FindChild("input_s_Height"):GetText()
	local strWeight = self.wndMain:FindChild("input_s_Weight"):GetText()
	local strAge = self.wndMain:FindChild("input_s_Age"):GetText()
	local strJob = self.wndMain:FindChild("input_s_Job"):GetText()
	local rpState = 0
	
	for i = 1, 3 do 
		local wndButton = self.wndMain:FindChild("wnd_Controls:wnd_StatusDD:input_b_RoleplayToggle" .. i) 
		rpState = RPCore:SetBitFlag(rpState,i,wndButton:IsChecked())
	end 
	
	RPCore:SetLocalTrait("fullname",strFullname)
	RPCore:SetLocalTrait("rpflag",rpState)
	RPCore:SetLocalTrait("title",strCharTitle) 
	RPCore:SetLocalTrait("shortdesc", strBlurb)
	RPCore:SetLocalTrait("height", strHeight)
	RPCore:SetLocalTrait("weight", strWeight)
	RPCore:SetLocalTrait("age", strAge)
	RPCore:SetLocalTrait("job", strJob)
	
	self:DrawNameplate(self.arUnit2Nameplate[GameLib.GetPlayerUnit():GetId()])
	
end

-- when the Cancel button is clicked
function PDA:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

function PDA:OnPortrait(wndHandler, wndControl)
	local wndPortrait = wndControl:GetParent():FindChild("wnd_Portrait")
	wndPortrait:Show( not wndPortrait:IsShown() )
end

function PDA:OnStatusClick(wndHandler, wndControl)
	local wndDD = self.wndMain:FindChild("wnd_Controls:wnd_StatusDD")
	wndDD:Show(not (wndDD:IsShown()))
end
-----------------------------------------------------------------------------------------------
-- PDA Instance
-----------------------------------------------------------------------------------------------
local PDAInst = PDA:new()
PDAInst:Init()
