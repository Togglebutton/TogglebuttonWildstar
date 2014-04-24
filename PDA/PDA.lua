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
local enumGender = {
	"Male",
	"Female",
	"Unknown"
}
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function PDA:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	
	o.arUnit2Nameplate = {}
	o.arWnd2Nameplate = {}

    return o
end

function PDA:Init()
	local bHasConfigureButton = true
	local strConfigureButtonText = "PDA"
	local tDependencies = {
		"RPCore",
	}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- PDA OnLoad
-----------------------------------------------------------------------------------------------
function PDA:OnLoad()
	RPCore = Apollo.GetPackage("RPCore").tPackage
	
	self.xmlDoc = XmlDoc.CreateFromFile("PDA.xml")	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "PDAEditForm", nil, self)
	self.wndOptions = Apollo.LoadForm(self.xmlDoc, "OptionsForm", nil, self)
	
	Apollo.LoadSprites("PDA_Sprites.xml")
	
	Apollo.RegisterEventHandler("UnitCreated","OnUnitCreated",self) 
	Apollo.RegisterEventHandler("UnitDestroyed","OnUnitDestroyed",self)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)
	
	Apollo.RegisterSlashCommand("pda", "OnPDAOn", self)
	
end

-----------------------------------------------------------------------------------------------
-- PDA Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/pda"
function PDA:OnPDAOn()
	self.wndMain:Show(true) -- show the window
	self.wndMain:FindChild("wnd_Controls:wnd_StatusDD"):Show(false)
end

function PDA:OnEditShow()
	local rpFullname = RPCore:GetLocalTrait("fullname") or GameLib.GetPlayerUnit():GetName()
	local rpState = RPCore:GetLocalTrait("rpflag") or 1
	local rpShortBlurb = RPCore:GetLocalTrait("shortdesc")
	local rpTitle = RPCore:GetLocalTrait("title")
	local rpHeight = RPCore:GetLocalTrait("height")
	local rpWeight = RPCore:GetLocalTrait("weight")
	local rpAge = RPCore:GetLocalTrait("age")
	local rpRace = GameLib.CodeEnumRace[GameLib.GetPlayerUnit():GetRaceId()]
	local rpGender = enumGender[GameLib.GetPlayerUnit():GetGender()]
	local rpJob = RPCore:GetLocalTrait("job")
	
	self.wndMain:FindChild("input_s_Name"):SetText(rpFullname)
	if string.len(tostring(rpTitle)) < 1 then self.wndMain:FindChild("input_s_Title"):SetText(rpTitle) end
	if string.len(tostring(rpShortBlurb)) < 1 then self.wndMain:FindChild("input_s_Description"):SetText(rpShortBlurb) end
	if string.len(tostring(rpJob)) < 1 then self.wndMain:FindChild("input_s_Job"):SetText(rpJob) end
	if string.len(tostring(rpRace)) < 1 then self.wndMain:FindChild("input_s_Race"):SetText(rpRace) end
	if string.len(tostring(rpGender)) < 1 then self.wndMain:FindChild("input_s_Gender"):SetText(rpGender) end
	if string.len(tostring(rpAge)) < 1 then self.wndMain:FindChild("input_s_Age"):SetText(rpAge) end
	if string.len(tostring(rpHeight)) < 1 then self.wndMain:FindChild("input_s_Height"):SetText(rpHeight) end
	if string.len(tostring(rpWeight)) < 1 then self.wndMain:FindChild("input_s_Weight"):SetText(rpWeight) end

	for i = 1, 3 do 
		local wndButton = self.wndMain:FindChild("wnd_Controls:wnd_StatusDD:input_b_RoleplayToggle" .. i)
		wndButton:SetCheck(RPCore:HasBitFlag(rpState,i))
	end
	
	self.wndMain:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(GameLib.GetPlayerUnit())
end

function PDA:OnConfigure()
	self.wndOptions:Show(true)
end

function PDA:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account) then return nil end 
	return { PDAoptions = {} }
end

function PDA:OnRestore(eLevel, tData)
	if (tData.PDAoptions ~= nil) then
		self.PDAOptions = tData.PDAoptions
	end
end

-----------------------------------------------------------------------------------------------
-- PDA Nameplate Functions
-----------------------------------------------------------------------------------------------
function PDA:OnUnitCreated(unit)
	if not unit:ShouldShowNamePlate() 
		return
	end
	
	local rpVersion, rpAddons = RPCore:QueryVersion(unit:GetName())
	if (unit:IsACharacter() and not unit:IsThePlayer() and rpVersion ~= nil) then
		OnUnitCreated(unitNew) -- build main options here
		if not unitNew:ShouldShowNamePlate() then
			return
		end

		local idUnit = unitNew:GetId()
		if self.arUnit2Nameplate[idUnit] ~= nil then
			return
		end
		
		local wnd = tNameplate.wndNameplate = Apollo.LoadForm(self.xmlDoc, "OverheadForm", "InWorldHudStratum", self)
		wnd:Show(false)
		wnd:SetUnit(unitNew, 1)
		Print("Creating Nameplate Window.")
		local tNameplate =
		{
			unitOwner 		= unitNew,
			idUnit 			= unitNew:GetId(),
			unitName		= unitNew:GetName(),
			wndNameplate	= wnd,
			bOnScreen 		= wnd:IsOnScreen(),
			bOccluded 		= wnd:IsOccluded(),
			bInCombat		= false,
			eDisposition	= unitNew:GetDispositionTo(GameLib.GetPlayerUnit()),
		}
		
		self.arUnit2Nameplate[idUnit] = tNameplate
		self.arWnd2Nameplate[wnd:GetId()] = tNameplate

	end
end 

function :OnUnitDestroyed(unitOwner)
	local idUnit = unitOwner:GetId()
	if self.arUnit2Nameplate[idUnit] == nil then
		return
	end
	
	local wndNameplate = self.arUnit2Nameplate[idUnit].wndNameplate
	
	self.arWnd2Nameplate[wndNameplate:GetId()] = nil
	wndNameplate:Destroy()
	self.arUnit2Nameplate[idUnit] = nil
end

function PDA:OnFrame()
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		if self.bFrameAlt then
			self:DrawNameplate(tNameplate)
		else
			self:FastDrawNameplate(tNameplate)
		end
	end
	self.bFrameAlt = not self.bFrameAlt
end

function PDA:DrawNameplate(tNameplate)
	local unitPlayer = GameLib.GetPlayerUnit()
	local unitOwner = tNameplate.unitOwner
	local wndNameplate = tNameplate.wndNameplate
	
	local bShowNameplate = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
	wndNameplate:Show(bShowNameplate)
	if not bShowNameplate then
		return
	end

	tNameplate.eDisposition = unitOwner:GetDispositionTo(unitPlayer)
	
	if unitOwner:IsMounted() and wndNameplate:GetUnit() == unitOwner then
		wndNameplate:SetUnit(unitOwner:GetUnitMount(), 1)
	elseif not unitOwner:IsMounted() and wndNameplate:GetUnit() ~= unitOwner then
		wndNameplate:SetUnit(unitOwner, 1)
	end
	
	self:DrawRPNamePlate(tNameplate)
	
end

function PDA:FastDrawNameplate(tNameplate)
	local wndNameplate = tNameplate.wndNameplate

	local bShowNameplate = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
	wndNameplate:Show(bShowNameplate)
	if not bShowNameplate then
		return
	end
	self:DrawRPNamePlate(tNameplate)
end

function PDA:HelperVerifyVisibilityOptions(tNameplate)
	local unitPlayer = GameLib.GetPlayerUnit()
	local unitOwner = tNameplate.unitOwner
	local eDisposition = tNameplate.eDisposition

	local bHiddenUnit = not unitOwner:ShouldShowNamePlate() or unitOwner:IsDead()
	if bHiddenUnit and not tNameplate.bIsTarget then
		return false
	end
	
	if (self.bUseOcclusion and tNameplate.bOccluded) or not tNameplate.bOnScreen then
		return false
	end

	local bShowNameplate = false

	if self.bShowDispositionFriendlyPlayer and eDisposition == Unit.CodeEnumDisposition.Friendly and unitOwner:GetType() == "Player" then
		bShowNameplate = true
	end

	local tActivation = unitOwner:GetActivationState()

	if bShowNameplate then
		bShowNameplate = not (self.bPlayerInCombat and self.bHideInCombat)
	end
	
	if unitOwner:IsThePlayer() then
		if self.bShowMyNameplate and not unitOwner:IsDead() then
			bShowNameplate = true
		else
			bShowNameplate = false
		end
	end

	return bShowNameplate or tNameplate.bIsTarget
end

function PDA:CheckDrawDistance(tNameplate)
	local unitOwner = tNameplate.unitOwner

	if not unitOwner then
	    return false
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

	if tNameplate.bIsTarget or tNameplate.bIsCluster then
		bInRange = nDistance < knTargetRange
		return bInRange
	else
		bInRange = nDistance < (self.nMaxRange * self.nMaxRange) -- squaring for quick maths
		return bInRange
	end
end

function PDA:DrawRPNamePlate(tNameplate)
	local wndName = namePlate:FindChild("wnd_Name")
	local rpFullname, rpTitle, rpStatus, strNameString
	local unitName = tNameplate.unitName
	rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
	rpTitle = RPCore:FetchTrait(unitName,"title")
	rpStatus = RPCore:GetTrait(unitName, "rpflag")
	
	local xmlNamePlate = XmlDoc:new()
	if (rpFullname ~= nil) then xmlNamePlate:AddLine(rpFullname, "UI_TextHoloTitle", "CRB_Interface12_BO", "Center")  end
	if (rpTitle ~= nil) then xmlNamePlate:AddLine(rpTitle, "UI_TextHoloBodyHighlight", "CRB_Interface8","Center") end
	wndName:SetDoc(xmlNamePlate)
	if rpStatus ~= nil then tNameplate.wndNameplate:FindChild("btn_RP"):SetBGColor(ktColors[(rpStatus + 1)]) end
end

-----------------------------------------------------------------------------------------------
-- PDA Character Sheet Functions
-----------------------------------------------------------------------------------------------
function PDA:DrawCharacterSheet(unitName)
	rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
	rpTitle = RPCore:FetchTrait(unitName,"title")
	rpShortDesc = RPCore:GetTrait(unitName,"shortdesc")
	rpHeight = RPCore:GetTrait(unitName,"height")
	rpWeight = RPCore:GetTrait(unitName,"weight")
	rpAge = RPCore:GetTrait(unitName,"age")
	rpRace = GameLib.CodeEnumRace[unit:GetRaceId()]
	rpGender = enumGender[unit:GetGender()]
	rpJob = RPCore:GetTrait(unitName,"job") or GameLib.CodeEnumClass[unit:GetClassId()]

	if (rpFullname ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Name, rpFullname)) end
	if (rpTitle ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Title, rpTitle)) end
	if (rpRace ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Species, rpRace)) end
	if (rpGender ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Gender, rpGender)) end
	if (rpAge ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Age, rpAge)) end
	if (rpHeight ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Height, rpHeight)) end
	if (rpWeight ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Weight, rpWeight)) end
	if (rpJob ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Job, rpJob)) end
	if (rpShortDesc ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Description, rpShortDesc)) end
	
	self.wndCS:FindChild("wnd_CharSheet"):SetDoc(xmlCS)
	self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(unit)
	self.wndCS:Show(true)
end

function PDA:CreateCharacterSheet(wndHandler, wndControl)
	local unit = wndControl:GetParent():GetUnit()
		
	if not self.wndCS then
		self.wndCS = Apollo.LoadForm(self.xmlDoc, "CharSheetForm", nil, self)
		self.wndCS:Show(false)
	end
	
	local unitName = unit:GetName()
	local rpVersion, rpAddons = RPCore:QueryVersion(unitName)
	local rpFullname, rpTitle, rpShortDesc, rpStateString, rpHeight, rpWeight, rpAge, rpRace, rpGender, rpJob
	
	local tCSString = {}
	
	local xmlCS = XmlDoc.new()
	
	if (rpVersion ~= nil) then
		self:DrawCharacterSheet(unitName)
	end	
end
-----------------------------------------------------------------------------------------------
-- PDA Edit Form Functions
-----------------------------------------------------------------------------------------------

function PDA:OnOK()
	self.wndMain:Show(false) -- hide the window
	
	local strFullname = self.wndMain:FindChild("input_s_Name"):GetText()
	local strCharTitle = self.wndMain:FindChild("input_s_Title"):GetText()
	local strBlurb = self.wndMain:FindChild("input_s_Description"):GetText()
	local strHeight = self.wndMain:FindChild("input_s_Height"):GetText()
	local strWeight = self.wndMain:FindChild("input_s_Weight"):GetText()
	local strAge = self.wndMain:FindChild("input_s_Age"):GetText()
	local strJob = self.wndMain:FindChild("input_s_Job"):GetText()
	local rpState = 0
	
	for i = 1, 3 do 
		local wndButton = self.wndMain:FindChild("wnd_Controls:btn_StatusDD:wnd_StatusDD:input_b_RoleplayToggle" .. i) 
		rpState = RPCore:SetBitFlag(rpState,i,wndButton:IsChecked())
	end 
	
	RPCore:SetLocalTrait("fullname",strFullname)
	RPCore:SetLocalTrait("rpflag",rpState)
	if string.len(tostring(strCharTitle)) < 1 then RPCore:SetLocalTrait("title",strCharTitle) end
	if string.len(tostring(strBlurb)) < 1 then RPCore:SetLocalTrait("shortdesc", strBlurb) end
	if string.len(tostring(strHeight)) < 1 then RPCore:SetLocalTrait("height", strHeight) end
	if string.len(tostring(strWeight)) < 1 then RPCore:SetLocalTrait("weight", strWeight) end
	if string.len(tostring(strAge)) < 1 then RPCore:SetLocalTrait("age", strAge) end
	if string.len(tostring(strJob)) < 1 then RPCore:SetLocalTrait("job", strJob) end
	
	--self:DrawNameplate(self.arUnit2Nameplate[GameLib.GetPlayerUnit():GetId()])
	
end

function PDA:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

function PDA:OnPortrait(wndHandler, wndControl)
	local wndPortrait = wndControl:GetParent():FindChild("wnd_Portrait")
	wndPortrait:Show( not wndPortrait:IsShown() )
end

function PDA:OnStatusClick(wndHandler, wndControl)
	local wndDD = wndControl:FindChild("wnd_StatusDD")
	wndDD:Show(not (wndDD:IsShown()))
end

-----------------------------------------------------------------------------------------------
-- PDA Options Form Functions
-----------------------------------------------------------------------------------------------

function PDA:OnOptionsOK()
	local bShowMyNameplate = self.wndOptions:FindChild("input_b_ShowPlayerNameplate"):IsChecked()
	local strColorType = self.wndOptions:FindChild("group_NameplateColors"):GetRadioSel("ColorType")
	self.wndOptions:Show(false) -- hide the window
end

function PDA:OnOptionsCancel()
	self.wndOptions:Show(false) -- hide the window
end

function PDA:OnDefaultCheck()
	self.wndOptions:FindChild("group_NameplateColors:group_CustomColors"):Show(false)
end

function PDA:OnCustomCheck()
	self.wndOptions:FindChild("group_NameplateColors:group_CustomColors"):Show(true)
end

-----------------------------------------------------------------------------------------------
-- PDA Instance
-----------------------------------------------------------------------------------------------
local PDAInst = PDA:new()
PDAInst:Init()
