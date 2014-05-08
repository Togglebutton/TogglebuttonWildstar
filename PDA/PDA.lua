-----------------------------------------------------------------------------------------------
-- 			PDA: Personnel Data Accessor
-- 		
-----------------------------------------------------------------------------------------------
require "Window"
require "GameLib"
 
-----------------------------------------------------------------------------------------------
-- PDA Module Definition
-----------------------------------------------------------------------------------------------
local PDA = {} 
local RPCore = _G["GeminiPackages"]:GetPackage("RPCore-1.1")


-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local ktRPColors = {
	[0] = "ffffffff", -- white
	[1] = "ffffff00", --yellow
	[2] = "ff0000ff", --blue
	[3] = "ff00ff00", --green
	[4] = "ffff0000", --red
	[5] = "ff800080", --purple
	[6] = "ff00ffff", --cyan
	[7] = "ffff00ff", --magenta
}

local knTargetRange = 400

local ktRaceSprites = {
	[GameLib.CodeEnumRace.Human] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_HuM_ExFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_HuF_ExFlyby", [2] = "CRB_CharacterCreateSprites:btnCharC_RG_HuM_DomFlyby", [3] = "CRB_CharacterCreateSprites:btnCharC_RG_HuF_DomFlyby"},
	[GameLib.CodeEnumRace.Granok] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_GrMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_GrFFlyby"},--
	[GameLib.CodeEnumRace.Aurin] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_AuMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_AuFFlyby"},--
	[GameLib.CodeEnumRace.Draken] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_DrMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_DrFFlyby"},--
	[GameLib.CodeEnumRace.Mechari] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_MeMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_MeFFlyby"},--
	[GameLib.CodeEnumRace.Chua] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_ChuFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_ChuFlyby", [2] = "CRB_CharacterCreateSprites:btnCharC_RG_ChuFlyby"},--
	[GameLib.CodeEnumRace.Mordesh] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_MoMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_MoMFlyby"},--
}

local ktCSColors = {
	strLabelColor = "UI_TextHoloBodyHighlight",
	strEntryColor = "UI_TextHoloTitle",
}

local karRaceToString =
{
	[GameLib.CodeEnumRace.Human] 	= Apollo.GetString("RaceHuman"),
	[GameLib.CodeEnumRace.Granok] 	= Apollo.GetString("RaceGranok"),
	[GameLib.CodeEnumRace.Aurin] 	= Apollo.GetString("RaceAurin"),
	[GameLib.CodeEnumRace.Draken] 	= Apollo.GetString("RaceDraken"),
	[GameLib.CodeEnumRace.Mechari] 	= Apollo.GetString("RaceMechari"),
	[GameLib.CodeEnumRace.Chua] 	= Apollo.GetString("RaceChua"),
	[GameLib.CodeEnumRace.Mordesh] 	= Apollo.GetString("CRB_Mordesh"),
}

local ktCSstrings = {
	Name = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Name: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Species = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Species: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Gender = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Gender: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Age = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Age: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Height = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Height: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Weight = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Weight: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Title = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Title: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Job = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Occupation: </T><T font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</T>",
	Description = "<T font=\"CRB_Interface12_BO\" TextColor=\"%s\">Description: \n</T><P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P>",
}
local enumGender = {
	[0] = Apollo.GetString("CRB_Male"),
	[1] = Apollo.GetString("CRB_Female"),
	[2] = Apollo.GetString("CRB_UnknownType"),
}

local knDescriptionMax = 250
local knBioMaxMax = 2500

--[[
	local pixieClickBar = wndClickTimeFrame:GetPixieInfo(1)
	pixieClickBar.cr = crBarColor
	wndClickTimeFrame:UpdatePixie(1, pixieClickBar)
]]
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
	o.nMaxRange = 400
	o.bShowMyNameplate = true
    return o
end

function PDA:Init()
	local bHasConfigureButton = false
	local strConfigureButtonText = ""
	local tDependencies = {}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
	
end
 
-----------------------------------------------------------------------------------------------
-- PDA OnLoad
-----------------------------------------------------------------------------------------------
function PDA:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("PDA.xml")
	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "PDAEditForm", nil, self)
	self.wndMain:Show(false)
	
	self.wndMain:FindChild("btn_EditProfile"):SetCheck(true)
	self.wndMain:FindChild("btn_EditBackground"):Enable(false)
	
	self.wndMain:FindChild("wnd_EditProfile"):Show(true)
	self.wndMain:FindChild("wnd_LookupProfile"):Show(false)
	self.wndMain:FindChild("wnd_EditBackground"):Show(false)
	self.wndMain:FindChild("wnd_Options"):Show(false)
	self.wndMain:FindChild("wnd_Portrait"):Show(false)
	
	Apollo.LoadSprites("PDA_Sprites.xml")
	
	Apollo.RegisterEventHandler("UnitCreated","OnUnitCreated",self) 
	Apollo.RegisterEventHandler("UnitDestroyed","OnUnitDestroyed",self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
	Apollo.RegisterEventHandler("ToggleAddon_PDA", "OnPDAOn", self)
	--Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)
	
	Apollo.RegisterTimerHandler("PDA_RefreshTimer","RefreshPlates",self)
	
	Apollo.RegisterSlashCommand("pda", "OnPDAOn", self)
	
	Apollo.CreateTimer("PDA_RefreshTimer", 60, true)
end

-----------------------------------------------------------------------------------------------
-- PDA Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/pda"
function PDA:OnPDAOn()
	self.wndMain:Show(true) -- show the window
end

function PDA:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "PDA", {"ToggleAddon_PDA", "", "PDA_Sprites:RPIcon"})
end

function PDA:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account) then return nil end 
	return { tPDAOptions = self.tPDAOptions, }
end

function PDA:OnRestore(eLevel, tData)

	if (tData.tPDAoptions ~= nil) then
		self.tPDAOptions = tData.tPDAOptions
		if self.tPDAOptions.bShowMyNameplate then self.bShowMyNameplate = self.tPDAOptions.bShowMyNameplate end
	end
	
end

function PDA:UpdateTimer(nNewTime)
	
end

-----------------------------------------------------------------------------------------------
-- PDA Nameplate Functions
-----------------------------------------------------------------------------------------------
function PDA:OnUnitCreated(unitNew)
	
	if unitNew:IsACharacter() then
		local rpVersion, rpAddons = RPCore:QueryVersion(unitNew:GetName())
		if rpVersion ~= nil then
			--Print("RPCore enabled Unit found.")
			
			local strUnitName = unitNew:GetName()
			if self.arUnit2Nameplate[strUnitName] ~= nil then
				return
			end
			
			local wnd = Apollo.LoadForm(self.xmlDoc, "OverheadForm", "InWorldHudStratum", self)
			wnd:SetUnit(unitNew)
			wnd:Show(true)

			local tNameplate =
			{
				unitOwner 		= unitNew,
				idUnit 			= unitNew:GetId(),
				unitName		= strUnitName,
				wndNameplate	= wnd,
				bOnScreen 		= wnd:IsOnScreen(),
				bOccluded 		= wnd:IsOccluded(),
				bInCombat		= false,
				eDisposition	= unitNew:GetDispositionTo(GameLib.GetPlayerUnit()),
			}
			
			self.arUnit2Nameplate[strUnitName] = tNameplate
			
			self:DrawNameplate(tNameplate)
		end
	end
end 

function PDA:OnUnitDestroyed(unitOwner)
	if unitOwner:IsACharacter() then
		
		local strUnitName = unitOwner:GetName()
		if self.arUnit2Nameplate[strUnitName] == nil then
			return
		end
		
		local wndNameplate = self.arUnit2Nameplate[strUnitName].wndNameplate
		
		wndNameplate:Destroy()
		self.arUnit2Nameplate[strUnitName] = nil
	end
end

local nFrame = 0

function PDA:OnFrame()
	
	if nFrame >= 60 then
		for idx, tNameplate in pairs(self.arUnit2Nameplate) do
			if self.bFrameAlt then
				self:DrawNameplate(tNameplate)
			else
				self:FastDrawNameplate(tNameplate)
			end
		end
		self.bFrameAlt = not self.bFrameAlt
		nFrame = 0
	else
		nFrame = nFrame + 1
	end	
end

function PDA:RefreshPlates()
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
	
	if not wndNameplate then
		local wnd = Apollo.LoadForm(self.xmlDoc, "OverheadForm", "InWorldHudStratum", self)
		wnd:SetUnit(unitNew)
		wnd:Show(true)
		tNameplate.wndNameplate = wnd
		wndNameplate = wnd
	end
	
	local bShowNameplate = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
	wndNameplate:Show(bShowNameplate)
	if not bShowNameplate then
		return
	end
	
	if self.tPDAOptions and self.tPDAOptions.nOffset then
		if tNameplate.nOffset ~= self.tPDAOptions.nOffset then
			tNameplate.nOffset = self.tPDAOptions.nOffset
			local nL, nT, nR, nB = wndNameplate:GetAnchorOffsets()
			wndNameplate:SetAnchorOffsets(nL, nT - tNameplate.nOffset, nR, nB - tNameplate.nOffset)
		end
	end
		
	if unitOwner:IsMounted() and wndNameplate:GetUnit() == unitOwner then
		wndNameplate:SetUnit(tNameplate.unitOwner:GetUnitMount(), 1)
    elseif not unitOwner:IsMounted() and wndNameplate:GetUnit() ~= unitOwner then
		wndNameplate:SetUnit(unitOwner, 1)
    end
	
	self:DrawRPNamePlate(tNameplate)	
end

function PDA:FastDrawNameplate(tNameplate)
	local wndNameplate = tNameplate.wndNameplate

	local bShowNameplate = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
	wndNameplate:Show(true)
	if not bShowNameplate then
		return
	end
	self:DrawRPNamePlate(tNameplate)
end

function PDA:DrawRPNamePlate(tNameplate)
	--Print("Drawing NamePlate")
	local tRPColors, tCSColors
	local rpFullname, rpTitle, rpStatus, strNameString
	local unitName = tNameplate.unitName
	local xmlNamePlate = XmlDoc:new()
	local wndNameplate = tNameplate.wndNameplate
	local wndName = wndNameplate:FindChild("wnd_Name")
	
	if self.tPDAOptions and self.tPDAOptions.tRPColors and self.tPDAOptions.tCSColors then
		tRPColors = self.tPDAOptions.tRPColors
		tCSColors = self.tPDAOptions.tCSColors
	else
		tRPColors = ktRPColors
		tCSColors = ktCSColors
	end
	
	rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
	rpTitle = RPCore:FetchTrait(unitName,"title")
	rpStatus = RPCore:GetTrait(unitName, "rpflag")
	
	if (rpFullname ~= nil) then xmlNamePlate:AddLine(rpFullname, tCSColors.strEntryColor, "CRB_Interface12_BO", "Center")  end
	if (rpTitle ~= nil) then xmlNamePlate:AddLine(rpTitle, tCSColors.strLabelColor, "CRB_Interface8","Center") end
	wndName:SetDoc(xmlNamePlate)
	if rpStatus ~= nil then wndNameplate:FindChild("btn_RP"):SetBGColor(tRPColors[rpStatus]) end
	wndNameplate:Show(true)
end

function PDA:HelperVerifyVisibilityOptions(tNameplate)
	
	local unitPlayer = GameLib.GetPlayerUnit()
	local unitOwner = tNameplate.unitOwner
	local eDisposition = tNameplate.eDisposition
	local wndNameplate = tNameplate.wndNameplate
	local bShowNameplate
	
	if unitOwner:IsOccluded() or not unitOwner:ShouldShowNamePlate() then return false end

	local bShowNameplate = false

	if unitOwner:GetType() == "Player" then bShowNameplate = true end
	
	if unitOwner:IsThePlayer() then
		if self.bShowMyNameplate == true and not unitOwner:IsDead() then
			bShowNameplate = true
		else
			bShowNameplate = false
		end
	end

	return bShowNameplate
end

function PDA:CheckDrawDistance(tNameplate)
	local unitOwner = tNameplate.unitOwner

	if not unitOwner then
	    return false
	end
	
	if unitOwner:IsThePlayer() == true then return true end

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

-----------------------------------------------------------------------------------------------
-- PDA Character Sheet Functions
-----------------------------------------------------------------------------------------------
function PDA:DrawCharacterSheet(unitName)
	local tCSColors
	local rpFullname, rpTitle, rpShortDesc, rpStateString, rpHeight, rpWeight, rpAge, rpRace, rpGender, rpJob
	local xmlCS = XmlDoc.new()
	local unit = GameLib.GetPlayerUnitByName(unitName)
	
	if self.tPDAOptions and self.tPDAOptions.tCSColors then
		tCSColors = self.tPDAOptions.tCSColors
	else
		tCSColors = ktCSColors
	end
	
	rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
	rpTitle = RPCore:FetchTrait(unitName,"title")
	rpShortDesc = RPCore:GetTrait(unitName,"shortdesc")
	rpHeight = RPCore:GetTrait(unitName,"height")
	rpWeight = RPCore:GetTrait(unitName,"weight")
	rpAge = RPCore:GetTrait(unitName,"age")
	rpRace = RPCore:GetTrait(unitName, "race") or karRaceToString[unit:GetRaceId()]
	rpGender = RPCore:GetTrait(unitName, "gender") or enumGender[unit:GetGender()]
	rpJob = RPCore:GetTrait(unitName,"job") or GameLib.CodeEnumClass[unit:GetClassId()]

	if (rpFullname ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Name, tCSColors.strLabelColor, tCSColors.strEntryColor, rpFullname)) end
	if (rpTitle ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Title,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpTitle)) end
	if (rpRace ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Species,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpRace)) end
	if (rpGender ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Gender,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpGender)) end
	if (rpAge ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Age,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpAge)) end
	if (rpHeight ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Height,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpHeight)) end
	if (rpWeight ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Weight,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpWeight)) end
	if (rpJob ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Job,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpJob)) end
	if (rpShortDesc ~= nil) then xmlCS:AddLine(string.format(ktCSstrings.Description,  tCSColors.strLabelColor, tCSColors.strEntryColor, rpShortDesc)) end
	
	return xmlCS
end

function PDA:CreateCharacterSheet(wndHandler, wndControl)
	local unit = wndControl:GetParent():GetUnit()
		
	if not self.wndCS then
		self.wndCS = Apollo.LoadForm(self.xmlDoc, "CharSheetForm", nil, self)
		self.wndCS:Show(false)
	end
	
	local unitName = unit:GetName()
	local rpVersion, rpAddons = RPCore:QueryVersion(unitName)
		
	if (rpVersion ~= nil) then	
		self.wndCS:FindChild("wnd_CharSheet"):SetDoc(self:DrawCharacterSheet(unitName))
		self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(unit)
		self.wndCS:Show(true)		
	end	
end

-----------------------------------------------------------------------------------------------
-- PDA Edit Form Functions
-----------------------------------------------------------------------------------------------

---- General Methods ----
function PDA:TabShow(wndHandler, wndControl)
	local btnName = wndControl:GetName()
	if btnName == "btn_EditBackground" or btnName == "btn_LookupProfile" or btnName == "btn_EditProfile" then
		self.wndMain:FindChild("wnd_EditProfile"):Show(self.wndMain:FindChild("btn_EditProfile"):IsChecked())
		self.wndMain:FindChild("wnd_LookupProfile"):Show(self.wndMain:FindChild("btn_LookupProfile"):IsChecked())
		self.wndMain:FindChild("wnd_EditBackground"):Show(self.wndMain:FindChild("btn_EditBackground"):IsChecked())
	end
end

function PDA:OnClose()
	self.wndMain:Show(false) -- hide the window
end

function PDA:OnPortrait(wndHandler, wndControl)
	local wndPortrait
	if wndControl:GetParent():GetName() == "wnd_Portrait" then
		wndPortrait = wndControl:GetParent()
	else
		wndPortrait = wndControl:GetParent():FindChild("wnd_Portrait")
		
	end
	wndPortrait:Show( not wndPortrait:IsShown() )
end

function PDA:OnStatusShow()
	local rpState = RPCore:GetLocalTrait("rpflag") or 1
	for i = 1, 3 do
		local wndButton = self.wndMain:FindChild("wnd_Status:input_b_RoleplayToggle" .. i)
		wndButton:SetCheck(RPCore:HasBitFlag(rpState,i))
	end
end

function PDA:OnStatusCheck(wndHandler, wndControl)
	local rpState = 0
	for i = 1, 3 do 
		local wndButton = wndHandler:FindChild("input_b_RoleplayToggle" .. i) 
		rpState = RPCore:SetBitFlag(rpState,i,wndButton:IsChecked())
	end 
	RPCore:SetLocalTrait("rpflag",rpState)
end

---- Edit Profile Methods ----
function PDA:OnEditShow()
	local wndEditProfile = self.wndMain:FindChild("wnd_EditProfile")
	
	local rpFullname = RPCore:GetLocalTrait("fullname") or GameLib.GetPlayerUnit():GetName()
	local rpShortBlurb = RPCore:GetLocalTrait("shortdesc")
	local rpTitle = RPCore:GetLocalTrait("title")
	local rpHeight = RPCore:GetLocalTrait("height")
	local rpWeight = RPCore:GetLocalTrait("weight")
	local rpAge = RPCore:GetLocalTrait("age")
	local rpRace = karRaceToString[GameLib.GetPlayerUnit():GetRaceId()]
	local rpJob = RPCore:GetLocalTrait("job")
	local rpGender = RPCore:GetLocalTrait("gender") or enumGender[GameLib.GetPlayerUnit():GetGender()]
	
	wndEditProfile:FindChild("input_s_Name"):SetText(rpFullname)
	if rpTitle and string.len(tostring(rpTitle)) > 1 then wndEditProfile:FindChild("input_s_Title"):SetText(rpTitle) end
	if rpShortBlurb and string.len(tostring(rpShortBlurb)) > 1 then wndEditProfile:FindChild("input_s_Description"):SetText(rpShortBlurb) end
	if rpJob and string.len(tostring(rpJob)) > 1 then wndEditProfile:FindChild("input_s_Job"):SetText(rpJob) end
	if rpRace and string.len(tostring(rpRace)) > 1 then wndEditProfile:FindChild("input_s_Race"):SetText(rpRace) end
	if rpGender and string.len(tostring(rpGender)) > 1 then wndEditProfile:FindChild("input_s_Gender"):SetText(rpGender) end
	if rpAge and string.len(tostring(rpAge)) > 1 then wndEditProfile:FindChild("input_s_Age"):SetText(rpAge) end
	if rpHeight and string.len(tostring(rpHeight)) > 1 then wndEditProfile:FindChild("input_s_Height"):SetText(rpHeight) end
	if rpWeight and string.len(tostring(rpWeight)) > 1 then wndEditProfile:FindChild("input_s_Weight"):SetText(rpWeight) end
	if rpGender and string.len(tostring(rpGender)) > 1 then wndEditProfile:FindChild("input_s_Gender"):SetText(rpGender) end

	self.wndMain:FindChild("wnd_Portrait"):Show(false)
	self.wndMain:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(GameLib.GetPlayerUnit())
end

function PDA:OnEditOK()
	local wndEditProfile = self.wndMain:FindChild("wnd_EditProfile")
		
	local strFullname = wndEditProfile:FindChild("input_s_Name"):GetText()
	local strCharTitle = wndEditProfile:FindChild("input_s_Title"):GetText()
	local strBlurb = wndEditProfile:FindChild("input_s_Description"):GetText()
	local strHeight = wndEditProfile:FindChild("input_s_Height"):GetText()
	local strWeight = wndEditProfile:FindChild("input_s_Weight"):GetText()
	local strAge = wndEditProfile:FindChild("input_s_Age"):GetText()
	local strJob = wndEditProfile:FindChild("input_s_Job"):GetText()
	local strGender = wndEditProfile:FindChild("input_s_Gender"):GetText()
	local nSex = GameLib.GetPlayerUnit():GetGender()
	local nFaction = GameLib.GetPlayerUnit():GetFaction()
	
	RPCore:SetLocalTrait("fullname",strFullname)
	RPCore:SetLocalTrait("sex", nSex)
	RPCore:SetLocalTrait("faction", nFaction)
	
	if string.len(tostring(strCharTitle)) > 1 then RPCore:SetLocalTrait("title",strCharTitle) else RPCore:SetLocalTrait("title",nil) end
	if string.len(tostring(strBlurb)) > 1 then RPCore:SetLocalTrait("shortdesc", strBlurb) else RPCore:SetLocalTrait("shortdesc", nil) end
	if string.len(tostring(strHeight)) > 1 then RPCore:SetLocalTrait("height", strHeight) else RPCore:SetLocalTrait("height", nil) end
	if string.len(tostring(strWeight)) > 1 then RPCore:SetLocalTrait("weight", strWeight) else RPCore:SetLocalTrait("weight", nil) end
	if string.len(tostring(strAge)) > 1 then RPCore:SetLocalTrait("age", strAge) else RPCore:SetLocalTrait("age", nil) end
	if string.len(tostring(strJob)) > 1 then RPCore:SetLocalTrait("job", strJob) else RPCore:SetLocalTrait("job", nil) end
	if string.len(tostring(strGender)) > 1 then RPCore:SetLocalTrait("gender", strGender) else RPCore:SetLocalTrait("gender", nil) end
	
	
	self:OnEditShow() -- hide the window
end

function PDA:OnEditCancel()
	self.wndMain:FindChild("wnd_EditProfile"):Show(false)
end

function PDA:OnDecriptionBoxChanged( wndHandler, wndControl, strText )
	local nCharacterCount = string.len(wndControl:GetText())
	local wndCounter = wndControl:GetParent():FindChild("sprite_div:wnd_Counter")
	
	wndCounter:SetText(tostring(250 - nCharacterCount))
end
-- Segoe UI Bold, Semibold, Italic
-- Cube Offc Cond
-- 10, 12, 14, 16, 18
--[[
{
	face = "",
	index = n,
	name = "",
	size = n,
}
]]

---- Options Methods ----
function PDA:OnOptionsOK()
	local wndOptions = self.wndMain:FindChild("wnd_Options")
	local bShowMyNameplate = wndOptions:FindChild("input_b_ShowPlayerNameplate"):IsChecked()
	local bCustomColor = wndOptions:FindChild("group_NameplateColors"):GetRadioSel("ColorType") == 2
	local nOffset = wndOptions:FindChild("input_n_Offset"):GetValue()
	
	if bCustomColor == true then
		if not self.tPDAOptions then
			self.tPDAOptions = {}
		end
		self.tPDAOptions.tRPColors = {}
		self.tPDAOptions.tCSColors = {}
	elseif bCustomColor == false then
		if not self.tPDAOptions then
			self.tPDAOptions = {}
		end
		self.tPDAOptions.tRPColors = nil
		self.tPDAOptions.tCSColors = nil
	end	
	
	if nOffset > 0 then
		if not self.tPDAOptions then
			self.tPDAOptions = {}
		end
		self.tPDAOptions.nOffset = nOffset
	else
		if not self.tPDAOptions then
			self.tPDAOptions = {}
		end
		self.tPDAOptions.nOffset = nil
	end
	
	if bShowMyNameplate == true then
		if not self.tPDAOptions then
			self.tPDAOptions = {}
		end
		self.tPDAOptions.bShowMyNameplate = true
	else
		if not self.tPDAOptions then
			self.tPDAOptions = {}
		end
		self.tPDAOptions.bShowMyNameplate = nil
	end
	
	if #self.tPDAOptions < 1 then
		self.tPDAOptions = nil
	end
	
	wndOptions:Show(false) -- hide the window
	local button = self.wndMain:GetRadioSelButton("PDATab")
	self.wndMain:FindChild("wnd_EditProfile"):Show(self.wndMain:FindChild("btn_EditProfile"):IsChecked())
	self.wndMain:FindChild("wnd_LookupProfile"):Show(self.wndMain:FindChild("btn_LookupProfile"):IsChecked())
	self.wndMain:FindChild("wnd_EditBackground"):Show(self.wndMain:FindChild("btn_EditBackground"):IsChecked())
end

function PDA:OnOptionsCancel()
	self.wndMain:FindChild("wnd_Options"):Show(false) -- hide the window
	local button = self.wndMain:GetRadioSelButton("PDATab")
	self.wndMain:FindChild("wnd_EditProfile"):Show(self.wndMain:FindChild("btn_EditProfile"):IsChecked())
	self.wndMain:FindChild("wnd_LookupProfile"):Show(self.wndMain:FindChild("btn_LookupProfile"):IsChecked())
	self.wndMain:FindChild("wnd_EditBackground"):Show(self.wndMain:FindChild("btn_EditBackground"):IsChecked())
end

function PDA:OnDefaultCheck()
	self.wndOptions:FindChild("group_NameplateColors:group_CustomColors"):Show(false)
end

function PDA:OnCustomCheck()
	self.wndOptions:FindChild("group_NameplateColors:group_CustomColors"):Show(true)
end

function PDA:OnShowOptions( wndHandler, wndControl )
	wndControl:FindChild("group_NameplateColors"):Show(false)
	wndControl:FindChild("input_n_Offset"):SetMinMax(0,100)
	wndControl:FindChild("input_b_ShowPlayerNameplate"):SetCheck(self.bShowMyNameplate)
	if self.tPDAOptions and self.tPDAOptions.nOffset then
		wndControl:FindChild("input_n_Offset"):SetValue(self.tPDAOptions.nOffset)
	end
end

function PDA:ShowOptionsPanel()
	self.wndMain:FindChild("wnd_EditProfile"):Show(false)
	self.wndMain:FindChild("wnd_LookupProfile"):Show(false)
	self.wndMain:FindChild("wnd_EditBackground"):Show(false)
	self.wndMain:FindChild("wnd_Options"):Show(true)
	
end

---- Profile Viewer Methods ----

function PDA:FillProfileList()
	local tCacheList = RPCore:GetCachedPlayerList()
	
	tCacheList:sort()
	
	local wndGrid = self.wndMain:FindChild("wnd_LookupProfile:Grid")
	
	wndGrid:DeleteAll()
	
	for i,v in pairs(tCacheList) do
		local strIcon
		local strPlayerName = v
		local strName = RPCore:GetTrait(strPlayerName, "fullname")
		local nRace = RPCore:GetTrait(strPlayerName, "race") or Apollo.GetPlayerUnitByName(strPlayerName, ):GetRaceId()
		local nSex = RPCore:GetTrait(strPlayerName, "sex") or Apollo.GetPlayerUnitByName(strPlayerName, ):GetGender()
		local nFaction = RPCore:GetTrait(strPlayerName, "faction") or Apollo.GetPlayerUnitByName(strPlayerName, ):GetFaction() or GameLib.CodeEnumFaction.ExilePlayer
		
		if nRace == GameLib.CodeEnumRace.Human then
			if nFaction == GameLib.CodeEnumFaction.DominionPlayer then
				nSex = nSex + 2
			end
		end
		
		if nRace and nSex then
			strIcon = ktRaceSprites[nRace][nSex]
		else
			strIcon = "CRB_Tradeskills:sprSchemIntroArt"
		end
		
		local iCurrRow = wndGrid:AddRow("")
		wndGrid:SetCellLuaData(iCurrRow, 1, strPlayerName)
		wndGrid:SetCellImage(iCurrRow, 1, strIcon)
		wndGrid:SetCellText(iCurrRow, 2, strName)
	end
	wndGrid:SetSortColumn(2)
end

function PDA:ShowCharacterSheet(wndControl, wndHandler, iRow, iCol)
	local strPlayerName = wndControl:GetCellData(iRow, 1)
	if not self.wndCS then
		self.wndCS = Apollo.LoadForm(self.xmlDoc, "CharSheetForm", nil, self)
		self.wndCS:Show(false)
	end

	self.wndCS:FindChild("wnd_CharSheet"):SetDoc(self:DrawCharacterSheet(strPlayerName))
	if Apollo.GetPlayerUnitByName(strPlayerName) then
		self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(Apollo.GetPlayerUnitByName(strPlayerName))
		self.wndCS:FindChild("wnd_Portrait"):Show(true)
	else
		self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(nil)
		self.wndCS:FindChild("wnd_Portrait"):Show(false)
	end
	self.wndCS:Show(true)		
end

---- Edit History ----
--[[
	
	[*] = bullet point --</T><T Image=""></T>
	[b] [/b] = bold --</T><T Font="CRB_Interface12_B">  --</T>
	[i] [/i] = italic --</T><T Font="CRB_Interface12_I"> --</T>
]]

function PDA:ParseMarkup(strText)
	
	local tTags = {
		["[h1]"] = "<P Font=\"%s\" Align=\"%s\">",
		["[/h1]"] = "</P>",
		["[h2]"] = "<P Font=\"%s\" Align=\"%s\">",
		["[/h2]"] = "</P>",
		["[h3]"] = "<P Font=\"%s\" Align=\"%s\">",
		["[/h3]"] = "</P>",
		["[li]"] = "<P Font=\"%s\" Align=\"%s\">\u25E6 \u2022 •",
		["[/li]"] = "</P>",
		["[p]"] = "<P Font=\"%s\" Align=\"%s\">",
		["[p]"] = "</P>",
	}
	
	for tag, subTag in pairs(tTags) do
		strText = gsub:strText(tag, subTag)	
	end
	local _, nOpenCount = string.gsub(strText, "<P", "")
	local _, nCloseCount = string.gsub(strText, "/P>", "")
	
	if nOpenCount < nCloseCount then
		local nCloseTagsNeeded = nOpenCount - nCloseCount
		for i = 1, nCloseTagsNeeded do
			strText = strText.."</P>"
		end
	end
	
	return strText
end

function PDA:InsertTag(wndHandler, wndControl)
	local wndEditBox = self.wndMain:FindChild("wnd_EditBackground:input_s_History")
	local ktTagTypes = { "h1", "h2", "h3", "li", "p",}
	local tagType = string.sub(wndControl:GetText(), 5)
	local strSelected = wndEditBox:GetSel()
	if strSelected:len < 1 then
		wndEditBox:InsertText("\[%s\]\[/%s\]")
	elseif strSelected:len > 0 then
		
	end
	
end

function PDA:TestGetSel(wndHandler, wndControl)
	local tTest = {self.wndMain:FindChild("wnd_EditBackground:input_s_History"):GetSel()}
	local strTest = table.concat(tTest)
	Print(strTest)
end

function PDA:TestInsert(wndHandler, wndControl)
	self.wndMain:FindChild("wnd_EditBackground:input_s_History"):InsertText("• \u25E6 \u2022 TEST")
end

-----------------------------------------------------------------------------------------------
-- PDA Character Sheet Form Functions
-----------------------------------------------------------------------------------------------
function PDA:OnCharacterSheetClose(wndHandler, wndControl)
	self.wndCS:Show(false)
end


-----------------------------------------------------------------------------------------------
-- PDA Instance
-----------------------------------------------------------------------------------------------
local PDAInst = PDA:new()
PDAInst:Init()
