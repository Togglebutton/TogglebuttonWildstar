-----------------------------------------------------------------------------------------------
-- 			PDA: Personnel Data Accessor
-- 			By: Togglebutton
--			Thanks to: Sinalot, PacketDancer, Draftomatic
-----------------------------------------------------------------------------------------------
require "Window"
require "GameLib"
require "Unit"
require "GameLib"

-----------------------------------------------------------------------------------------------
-- PDA Module Definition
-----------------------------------------------------------------------------------------------
local PDA = {}
local RPCore
local GeminiColor

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

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

local karGenderToString =
{
	[0] = Apollo.GetString("CRB_Male"),
	[1] = Apollo.GetString("CRB_Female"),
	[2] = Apollo.GetString("CRB_UnknownType"),
}

local ktCSstrings =
{
	Name = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Name: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Species = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Species: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Gender = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Gender: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Age = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Age: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Height = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Height: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Weight = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Weight: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Title = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Title: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Job = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Occupation: <P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
	Description = "<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Description: <BR /><P font=\"CRB_Interface12_BO\" TextColor=\"%s\">%s</P></P>",
}

local ktPDAOptions =
{
	nOffset = 0,
	bShowMyNameplate = true,
	tRPColors = {
		[0] = "ffffffff", -- white
		[1] = "ffffff00", --yellow
		[2] = "ff0000ff", --blue
		[3] = "ff00ff00", --green
		[4] = "ffff0000", --red
		[5] = "ff800080", --purple
		[6] = "ff00ffff", --cyan
		[7] = "ffff00ff", --magenta
	},
	tCSColors = {
		strLabelColor = "UI_TextHoloBodyHighlight",
		strEntryColor = "UI_TextHoloTitle",
	},
	tMarkupStyles = {
		{tag = "h1", font = "CRB_Interface14_BBO", color = "UI_TextHoloTitle", align = "Center"},
		{tag = "h2", font = "CRB_Interface12_BO", color = "UI_TextHoloTitle", align = "Left"},
		{tag = "h3", font = "CRB_Interface12_I", color = "UI_TextHoloBodyHighlight", align = "Left"},
		{tag = "p", font = "CRB_Interface12", color = "UI_TextHoloBodyHighlight", align = "Left"},
		{tag = "li", font = "CRB_Interface12", color = "UI_TextHoloBodyHighlight", align = "Left"},
	},
}

local ktRaceSprites =
{
	[GameLib.CodeEnumRace.Human] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_HuM_ExFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_HuF_ExFlyby", [2] = "CRB_CharacterCreateSprites:btnCharC_RG_HuM_DomFlyby", [3] = "CRB_CharacterCreateSprites:btnCharC_RG_HuF_DomFlyby"},
	[GameLib.CodeEnumRace.Granok] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_GrMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_GrFFlyby"},
	[GameLib.CodeEnumRace.Aurin] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_AuMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_AuFFlyby"},
	[GameLib.CodeEnumRace.Draken] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_DrMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_DrFFlyby"},
	[GameLib.CodeEnumRace.Mechari] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_MeMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_MeFFlyby"},
	[GameLib.CodeEnumRace.Chua] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_ChuFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_ChuFlyby"},
	[GameLib.CodeEnumRace.Mordesh] = {[0] = "CRB_CharacterCreateSprites:btnCharC_RG_MoMFlyby", [1] = "CRB_CharacterCreateSprites:btnCharC_RG_MoMFlyby"},
}

local knDescriptionMax = 250
local knBioMax = 2500
local knTargetRange = 40

-----------------------------------------------------------------------------------------------
-- Local Functions
-----------------------------------------------------------------------------------------------
local function BuildFontDropDown(self, wndButton)
	local wndDDList = wndButton:FindChild("ddList")
	local tGameFontList = Apollo.GetGameFonts()
	local tFontList = {}
	
	for i, v in pairs(tGameFontList) do
		if string.find(v.name, "CRB_Interface%d?%d") then
			table.insert(tFontList, v.name)
		elseif string.find(v.name, "CRB_Header%d?%d") then
			table.insert(tFontList, v.name)
		end
	end		
	table.sort(tFontList)
	-- from hhtp://lua-users.org/wiki/TableUtils
	
	local function table_count(tt, item)
	  local count
	  count = 0
	  for ii,xx in pairs(tt) do
		if item == xx then count = count + 1 end
	  end
	  return count
	end
	
	local function table_unique(tt)
	  local newtable
	  newtable = {}
	  for ii,xx in ipairs(tt) do
		if(table_count(newtable, xx) == 0) then
		  newtable[#newtable+1] = xx
		end
	  end
	  return newtable
	end
	
	tFontList = table_unique(tFontList)
	
	for i, v in pairs(tFontList) do
		local wnd = Apollo.LoadForm(self.xmlDoc, "DropDownItemForm", wndDDList, self)
		wnd:SetText(v)
		wnd:SetName("btn_"..v)
		wnd:SetFont(v)
	end
	
	wndDDList:ArrangeChildrenVert()
	wndDDList:Show(false, true)
end

local function SetDDSelectByName(self, wndDDList, strName)
	local tButtonList = wndDDList:GetChildren()
	for i,v in pairs(tButtonList) do
		if v:GetName() == "btn_"..strName then
			wndDDList:SetRadioSelButton("DDList", v)
			return v
		end
	end
end

local function BuildHeadingMenu(self, tTag)
	local wnd = Apollo.LoadForm(self.xmlDoc, "HeaderOptionsForm", self.wndOptions:FindChild("wnd_ScrollFrame:group_BioMarkupStyles") , self)
	wnd:FindChild("wnd_label"):SetText(tTag.tag)
	wnd:SetName("wnd_"..tTag.tag)
	wnd:FindChild("btn_DDAlign:ddList"):Show(false)	
	local wndButton = wnd:FindChild("btn_DDFont")
	BuildFontDropDown(self, wndButton)
	wnd:FindChild("btn_DDFont"):SetText(tTag.font)
	SetDDSelectByName(self, wnd:FindChild("btn_DDFont:ddList"), tTag.font)
	
	wnd:FindChild("btn_DDAlign"):SetText(tTag.align)
	SetDDSelectByName(self, wnd:FindChild("btn_DDAlign:ddList"), tTag.align)
	
	wnd:FindChild("btn_Color:swatch"):SetBGColor(tTag.color)	
	local sampleTest = string.format("<P Align=\"%s\" Font=\"%s\" TextColor=\"%s\"> {%s} Text Sample</P>",tTag.align, tTag.font, tTag.color, tTag.tag)
	wnd:FindChild("wnd_Sample"):SetAML(sampleTest)
	
end

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
	o.nMaxRange = 200
	o.tPDAOptions = ktPDAOptions
	self.unitPlayer = GameLib.GetPlayerUnit()
	self.nMaxRange = 40
    return o
end

function PDA:Init()
	local bHasConfigureButton = true
	local strConfigureButtonText = "PDA"
	local tDependencies = {
	"GeminiColor",
	}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- PDA Default Apollo Methods
-----------------------------------------------------------------------------------------------
function PDA:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("PDA.xml")
	self.xmlDoc:RegisterCallback("OnDocumentLoaded", self)
end

function PDA:OnDocumentLoaded()

	GeminiColor = Apollo.GetPackage("GeminiColor").tPackage
	RPCore = _G["GeminiPackages"]:GetPackage("RPCore-1.1")
	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "PDAEditForm", nil, self)
	self.wndMain:Show(false)

	self.wndMain:FindChild("btn_LookupProfile"):SetCheck(true)
	self.wndMain:FindChild("wnd_EditProfile"):Show(false)
	self.wndMain:FindChild("wnd_EditProfile:input_s_Description"):SetMaxTextLength(knDescriptionMax)
	self.wndMain:FindChild("wnd_LookupProfile"):Show(true)
	self.wndMain:FindChild("wnd_EditBackground"):Show(false)
	self.wndMain:FindChild("wnd_EditBackground:input_s_History"):SetMaxTextLength(knBioMax)
	
	self.wndMain:FindChild("wnd_Portrait"):Show(false)

	self.wndOptions = Apollo.LoadForm(self.xmlDoc, "OptionsForm", nil, self)
	self.wndOptions:Show(false)
	local tagCount = 0
	for i,v in pairs(self.tPDAOptions.tMarkupStyles) do
		BuildHeadingMenu(self, v)
		tagCount = tagCount + 1
	end

	self.wndOptions:FindChild("wnd_ScrollFrame:group_BioMarkupStyles"):ArrangeChildrenVert(1)	

	Apollo.LoadSprites("PDA_Sprites.xml", "PDA_Sprites")

	Apollo.RegisterEventHandler("UnitCreated","OnUnitCreated",self) 
	Apollo.RegisterEventHandler("UnitDestroyed","OnUnitDestroyed",self)
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
	Apollo.RegisterEventHandler("PDA_HeaderColorUpdated", "UpdateHeadingDisplay", self)
	Apollo.RegisterEventHandler("ToggleAddon_PDA", "OnPDAOn", self)
	Apollo.RegisterEventHandler("RPCore_VersionUpdated", "OnRPCoreCallback", self)
	Apollo.RegisterSlashCommand("pda", "OnPDAOn", self)
	Apollo.RegisterEventHandler("ChangeWorld", "UpdatePlayerNameplate", self)

	Apollo.RegisterTimerHandler("PDA_RefreshTimer","RefreshPlates",self)
	Apollo.CreateTimer("PDA_RefreshTimer", 1, true)
	
	Apollo.RegisterTimerHandler("PDA_UpdateMyTimer","UpdateMyNameplate",self)
	Apollo.CreateTimer("PDA_UpdateMyTimer", 5, false)
end

function PDA:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "PDA", {"ToggleAddon_PDA", "", "PDA_Sprites:RPIcon"})
end

function PDA:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account) then return nil end 
	return { tPDAOptions = self.tPDAOptions, }
end

function PDA:OnRestore(eLevel, tData)
	if (tData.tPDAOptions ~= nil) then
		for i,v in pairs(tData.tPDAOptions) do
			self.tPDAOptions[i] = v
		end
	end	
end

function PDA:OnConfigure()
	self.wndOptions:Show(true)
end

-----------------------------------------------------------------------------------------------
-- PDA Functions
-----------------------------------------------------------------------------------------------
function PDA:OnPDAOn()
	self.wndMain:Show(true) -- show the window
end

-----------------------------------------------------------------------------------------------
-- PDA Nameplate Functions
-----------------------------------------------------------------------------------------------
function PDA:UpdateMyNameplate()
	if self.tPDAOptions.bShowMyNameplate then
		self:OnRPCoreCallback({player = GameLib.GetPlayerUnit():GetName()})
	end
end

function PDA:OnUnitCreated(unitNew)
	if not self.unitPlayer then
		self.unitPlayer = GameLib.GetPlayerUnit()
	end
	if unitNew:IsThePlayer() then
		self:OnRPCoreCallback({player = unitNew:GetName()})
	end
	if unitNew:IsACharacter() then
		local rpVersion, rpAddons = RPCore:QueryVersion(unitNew:GetName())
	end
end

function PDA:OnRPCoreCallback(tArgs)
	local strUnitName = tArgs.player
	local unit = GameLib.GetPlayerUnitByName(strUnitName)
	local idUnit = unit:GetId()
	if self.arUnit2Nameplate[idUnit] ~= nil and self.arUnit2Nameplate[idUnit].wndNameplate:IsValid() then
		return
	end
	
	local wnd = Apollo.LoadForm(self.xmlDoc, "OverheadForm", "InWorldHudStratum", self)
	wnd:Show(false, true)
	wnd:SetUnit(unit, 1)
	
	local tNameplate =
	{
		unitOwner 		= unit,
		idUnit 			= unit:GetId(),
		unitName		= strUnitName,
		wndNameplate	= wnd,
		bOnScreen 		= wnd:IsOnScreen(),
		bOccluded 		= wnd:IsOccluded(),
		eDisposition	= unit:GetDispositionTo(self.unitPlayer),
		bShow			= false,
	}
	
	self.arUnit2Nameplate[idUnit] = tNameplate
	self.arWnd2Nameplate[wnd:GetId()] = tNameplate
	
	self:DrawNameplate(tNameplate)
end

function PDA:OnUnitDestroyed(unitOwner)
	if unitOwner:IsACharacter() then
		local idUnit = unitOwner:GetId()
		if self.arUnit2Nameplate[idUnit] == nil then
			return
		end
		
		local wndNameplate = self.arUnit2Nameplate[idUnit].wndNameplate
		
		self.arWnd2Nameplate[wndNameplate:GetId()] = nil
		wndNameplate:Destroy()
		self.arUnit2Nameplate[idUnit] = nil
	end
end

function PDA:RefreshPlates()
	for idx, tNameplate in pairs(self.arUnit2Nameplate) do
		local bNewShow = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
		if bNewShow ~= tNameplate.bShow then
			tNameplate.wndNameplate:Show(bNewShow)
			tNameplate.bShow = bNewShow
		end
		self:DrawNameplate(tNameplate)
	end
end

function PDA:CheckDrawDistance(tNameplate)
	local unitPlayer = self.unitPlayer
	local unitOwner = tNameplate.unitOwner
	
	if not unitOwner or not unitPlayer then
	    return false
	end

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

function PDA:HelperVerifyVisibilityOptions(tNameplate)
	local unitPlayer = self.unitPlayer
	local unitOwner = tNameplate.unitOwner
	local eDisposition = tNameplate.eDisposition

	local bHiddenUnit = not unitOwner:ShouldShowNamePlate()
	if bHiddenUnit then
		return false
	end
	
	if tNameplate.bOccluded or not tNameplate.bOnScreen then
		return false
	end
	
	if unitOwner:IsThePlayer() then
		if self.tPDAOptions.bShowMyNameplate and not unitOwner:IsDead() then
			bShowNameplate = true
		else
			bShowNameplate = false
		end
	end

	return bShowNameplate or tNameplate.bIsTarget
end

function PDA:OnUnitOcclusionChanged(wndHandler, wndControl, bOccluded)
	local idUnit = wndHandler:GetId()
	if self.arWnd2Nameplate[idUnit] ~= nil then
		self.arWnd2Nameplate[idUnit].bOccluded = bOccluded
		self:UpdateNameplateVisibility(self.arWnd2Nameplate[idUnit])
	end
end

function PDA:UpdateNameplateVisibility(tNameplate)
	local bNewShow = self:HelperVerifyVisibilityOptions(tNameplate) and self:CheckDrawDistance(tNameplate)
	if bNewShow ~= tNameplate.bShow then
		tNameplate.wndNameplate:Show(bNewShow)
		tNameplate.bShow = bNewShow
	end
end

function PDA:OnWorldLocationOnScreen(wndHandler, wndControl, bOnScreen)
	local idUnit = wndHandler:GetId()
	if self.arWnd2Nameplate[idUnit] ~= nil then
		self.arWnd2Nameplate[idUnit].bOnScreen = bOnScreen
	end
end

function PDA:DrawNameplate(tNameplate)
	
	if not tNameplate.bShow then
		return
	end
	
	local unitPlayer = self.unitPlayer
	local unitOwner = tNameplate.unitOwner
	local wndNameplate = tNameplate.wndNameplate
	
	tNameplate.eDisposition = unitOwner:GetDispositionTo(unitPlayer)
	
	if unitOwner:IsMounted() and wndNameplate:GetUnit() == unitOwner then
		wndNameplate:SetUnit(unitOwner:GetUnitMount(), 1)
	elseif not unitOwner:IsMounted() and wndNameplate:GetUnit() ~= unitOwner then
		wndNameplate:SetUnit(unitOwner, 1)
	end

	local bShowNameplate = self:CheckDrawDistance(tNameplate) and self:HelperVerifyVisibilityOptions(tNameplate)
	wndNameplate:Show(bShowNameplate, false)
	if not bShowNameplate then
		return
	end
	
	if self.tPDAOptions.nOffset then
		if tNameplate.nOffset ~= self.tPDAOptions.nOffset then
			tNameplate.nOffset = self.tPDAOptions.nOffset
			local nL, nT, nR, nB = wndNameplate:GetAnchorOffsets()
			wndNameplate:SetAnchorOffsets(nL, nT - tNameplate.nOffset, nR, nB - tNameplate.nOffset)
		end
	end
	
	self:DrawRPNamePlate(tNameplate)	
end

function PDA:DrawRPNamePlate(tNameplate)
	local tRPColors, tCSColors
	local rpFullname, rpTitle, rpStatus, strNameString
	local unitName = tNameplate.unitName
	local xmlNamePlate = XmlDoc:new()
	local wndNameplate = tNameplate.wndNameplate
	local wndName = wndNameplate:FindChild("wnd_Name")
	
	tRPColors = self.tPDAOptions.tRPColors
	tCSColors = self.tPDAOptions.tCSColors
		
	rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
	rpTitle = RPCore:FetchTrait(unitName,"title")
	rpStatus = RPCore:GetTrait(unitName, "rpflag")
	
	if (rpFullname ~= nil) then xmlNamePlate:AddLine(rpFullname, tCSColors.strLabelColor, "CRB_Interface12_BO", "Center")  end
	if (rpTitle ~= nil) then xmlNamePlate:AddLine(rpTitle, tCSColors.strEntryColor, "CRB_Interface8","Center") end
	wndName:SetDoc(xmlNamePlate)
	if rpStatus ~= nil then wndNameplate:FindChild("btn_RP"):SetBGColor(tRPColors[rpStatus]) end
end

-----------------------------------------------------------------------------------------------
-- PDA Character Sheet Functions
-----------------------------------------------------------------------------------------------
function PDA:DrawCharacterSheet(unitName)

	local rpFullname, rpTitle, rpShortDesc, rpStateString, rpHeight, rpWeight, rpAge, rpRace, rpGender, rpJob, bPublicHistory, rpHistory
	local xmlCS = XmlDoc.new()
	local unit = GameLib.GetPlayerUnitByName(unitName)
	
	local strCharacterSheet = ""
	
	rpFullname = RPCore:GetTrait(unitName,"fullname") or unitName
	
	rpTitle = RPCore:FetchTrait(unitName,"title")
	rpShortDesc = RPCore:GetTrait(unitName,"shortdesc")
	rpHeight = RPCore:GetTrait(unitName,"height")
	rpWeight = RPCore:GetTrait(unitName,"weight")
	rpAge = RPCore:GetTrait(unitName,"age")
	bPublicHistory = RPCore:GetTrait(unitName, "publicBio") or false
	rpHistory = RPCore:GetTrait(unitName, "biography")
	
	self.wndCS:FindChild("wnd_Tabs:btn_History"):Enable(bPublicHistory)
		
	if unit then
		rpRace = RPCore:GetTrait(unitName, "race") or karRaceToString[unit:GetRaceId()]
		rpGender = RPCore:GetTrait(unitName, "gender") or karGenderToString[unit:GetGender()]
		rpJob = RPCore:GetTrait(unitName,"job") or GameLib.CodeEnumClass[unit:GetClassId()]
	else
		rpRace = RPCore:GetTrait(unitName, "race")
		rpGender = RPCore:GetTrait(unitName, "gender")
		rpJob = RPCore:GetTrait(unitName,"job")
	end
	

	local tCSColors = self.tPDAOptions.tCSColors
	
	if (rpFullname ~= nil) then
		strCharacterSheet = strCharacterSheet .. string.format(ktCSstrings.Name, self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpFullname)
	end
	if self.wndCS:FindChild("wnd_Tabs:btn_Profile"):IsChecked() == true then
		if (rpTitle ~= nil) then
			strCharacterSheet = strCharacterSheet .. string.format(ktCSstrings.Title, self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpTitle)
		end
		if (rpRace ~= nil) then 
			if type(rpRace) == "string" then
				strCharacterSheet = strCharacterSheet .. string.format(ktCSstrings.Species, self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpRace)
			elseif type(rpRace) == "number" then
				strCharacterSheet = strCharacterSheet.. string.format(ktCSstrings.Species,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, karRaceToString[rpRace])
			end
		end
		if (rpGender ~= nil) then strCharacterSheet = strCharacterSheet..string.format(ktCSstrings.Gender,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpGender) end
		if (rpAge ~= nil) then strCharacterSheet = strCharacterSheet.. string.format(ktCSstrings.Age,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpAge) end
		if (rpHeight ~= nil) then strCharacterSheet = strCharacterSheet..string.format(ktCSstrings.Height,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpHeight) end
		if (rpWeight ~= nil) then strCharacterSheet = strCharacterSheet..string.format(ktCSstrings.Weight,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpWeight) end
		if (rpJob ~= nil) then strCharacterSheet = strCharacterSheet..string.format(ktCSstrings.Job,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpJob) end
		if (rpShortDesc ~= nil) then strCharacterSheet = strCharacterSheet..string.format(ktCSstrings.Description,  self.tPDAOptions.tCSColors.strLabelColor, self.tPDAOptions.tCSColors.strEntryColor, rpShortDesc) end
	end
	
	if self.wndCS:FindChild("wnd_Tabs:btn_History"):IsChecked() == true and bPublicHistory == true then
		if rpHistory ~= nil then
			local parsedHistory = self:ParseMarkup(rpHistory)
			strCharacterSheet = strCharacterSheet..string.format("<P font=\"CRB_Interface12_BO\" TextColor=\"%s\">Biographical Information: </P>",  self.tPDAOptions.tCSColors.strLabelColor)..parsedHistory
		end
	end
	
	return strCharacterSheet
end

function PDA:ParseMarkup(strText)
	strText = string.gsub(strText, "\n", "")
	for i, v in pairs(self.tPDAOptions["tMarkupStyles"]) do
		local strOpenTag = "\{"..v.tag.."\}"
		local strCloseTag = "\{\/"..v.tag.."\}"
		local strSubTagOpen= [[<P Font="]]..v.font..[[" Align="]]..v.align..[[" TextColor="]]..v.color..[[">]]
		local strSubTagClose = "</P>"

		if v.tag == "li" then
			strSubTagOpen= strSubTagOpen..[[  ●  ]]
		end
		if string.find(strText, strOpenTag) then
			strText = string.gsub(strText, strOpenTag, strSubTagOpen)
		end
		if string.find(strText, strCloseTag) then
			
			strText = string.gsub(strText, strCloseTag, strSubTagClose)
		end
	end
	local _, nOpenCount = string.gsub(strText, "<P", "")
	local _, nCloseCount = string.gsub(strText, "/P>", "")
	
	--[[if nOpenCount < nCloseCount then
		local nCloseTagsNeeded = nOpenCount - nCloseCount
		for i = 1, nCloseTagsNeeded do
			strText = strText.."</P>"
		end
	elseif nCloseCount > nOpenCount then
		local nCloseTagsNeeded = nCloseCount - nOpenCount
		for i = 1, nCloseTagsNeeded do
			strText = "<P>"..strText
		end
	end]]
	return strText
end

function PDA:CreateCharacterSheet(wndHandler, wndControl)
	local unit = wndControl:GetParent():GetUnit()
		
	if not self.wndCS then
		self.wndCS = Apollo.LoadForm(self.xmlDoc, "CharSheetForm", nil, self)
		self.wndCS:FindChild("wnd_Tabs:btn_Profile"):SetCheck(true)
		self.wndCS:Show(false)
	end
	
	local unitName = unit:GetName()
	local rpVersion, rpAddons = RPCore:QueryVersion(unitName)
	
	if (rpVersion ~= nil) then
		self.wndCS:SetData(unitName)
		self.wndCS:FindChild("wnd_CharSheet"):SetAML(self:DrawCharacterSheet(unitName))
		self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(unit)
		self.wndCS:Show(true)
		self.wndCS:ToFront()
	end	
end

function PDA:UpdateCharacterSheet(wndHandler, wndControl)
	local player = self.wndCS:GetData()
	self.wndCS:FindChild("wnd_CharSheet"):SetAML(self:DrawCharacterSheet(player))
end

function PDA:OnCharacterSheetClose(wndHandler, wndControl)
	self.wndCS:Show(false)
end

-----------------------------------------------------------------------------------------------
-- PDA Edit Form Functions
-----------------------------------------------------------------------------------------------
---- General UI Methods ----

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

function PDA:OnPortraitOpen(wndHandler, wndControl)
	wndControl:GetParent():FindChild("wnd_Portrait"):Show(true)
end

function PDA:OnPortraitClose(wndHandler, wndControl)
	wndControl:GetParent():Show(false)
end

function PDA:OnStatusShow(wndHandler, wndControl)
	if RPCore then
		local rpState = RPCore:GetLocalTrait("rpflag") or 1
		for i = 1, 3 do
			local check = RPCore:HasBitFlag(rpState,i)
			self.wndMain:FindChild("wnd_Status:input_b_RoleplayToggle" .. i):SetCheck(check)
		end
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

function PDA:OnEditShow(wndHandler, wndControl)
	local wndEditProfile = self.wndMain:FindChild("wnd_EditProfile")
	
	local rpFullname = RPCore:GetLocalTrait("fullname") or GameLib.GetPlayerUnit():GetName()
	local rpShortBlurb = RPCore:GetLocalTrait("shortdesc")
	local rpTitle = RPCore:GetLocalTrait("title")
	local rpHeight = RPCore:GetLocalTrait("height")
	local rpWeight = RPCore:GetLocalTrait("weight")
	local rpAge = RPCore:GetLocalTrait("age")
	local rpRace = karRaceToString[GameLib.GetPlayerUnit():GetRaceId()]
	local rpJob = RPCore:GetLocalTrait("job")
	local rpGender = RPCore:GetLocalTrait("gender") or karGenderToString[GameLib.GetPlayerUnit():GetGender()]
	
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
	local nRace = GameLib.GetPlayerUnit():GetRaceId()
	local nSex = GameLib.GetPlayerUnit():GetGender()
	local nFaction = GameLib.GetPlayerUnit():GetFaction()
	
	RPCore:SetLocalTrait("fullname",strFullname)
	RPCore:SetLocalTrait("sex", nSex)
	RPCore:SetLocalTrait("race", nRace)
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
	--self.wndMain:FindChild("wnd_EditProfile"):Show(false)
	self:OnEditShow()
end

---- Profile Viewer Methods ----

function PDA:FillProfileList()
	local tCacheList = RPCore:GetCachedPlayerList()

	if #tCacheList > 1 then
		table.sort(tCacheList)
	end
	
	local wndGrid = self.wndMain:FindChild("wnd_LookupProfile:Grid")
	
	wndGrid:DeleteAll()
	
	for i,strPlayerName in pairs(tCacheList) do
		local strIcon
		local unit = GameLib.GetPlayerUnitByName(strPlayerName)
		local nRace, nSex, nFaction
		
		local strName = RPCore:GetTrait(strPlayerName, "fullname")
		
		if unit then
			nRace = unit:GetRaceId() or "Unknown"
			nSex = unit:GetGender() or "Unknown"
			nFaction = unit:GetFaction() or  Unit.CodeEnumFaction.ExilePlayer
		else
			nRace = RPCore:GetTrait(strPlayerName, "race") or "Unknown"
			nSex = RPCore:GetTrait(strPlayerName, "sex") or "Unknown"
			nFaction = RPCore:GetTrait(strPlayerName, "faction") or  Unit.CodeEnumFaction.ExilePlayer
		end
		
		if type(nRace) == "number" and type(nSex) == "number" then
			if nRace == GameLib.CodeEnumRace.Human then
				if nFaction == Unit.CodeEnumFaction.DominionPlayer then
					nSex = nSex + 2
				end
			end
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

	self.wndCS:FindChild("wnd_CharSheet"):SetAML(self:DrawCharacterSheet(strPlayerName))
	if GameLib.GetPlayerUnitByName(strPlayerName) then
		self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(GameLib.GetPlayerUnitByName(strPlayerName))
		self.wndCS:FindChild("wnd_Portrait"):Show(true)
	else
		self.wndCS:FindChild("wnd_Portrait"):FindChild("costumeWindow_Character"):SetCostume(nil)
		self.wndCS:FindChild("wnd_Portrait"):Show(false)
	end
	self.wndCS:SetData(strPlayerName)
	self.wndCS:Show(true)
	self.wndCS:ToFront()
end

---- Edit History ----

function PDA:OnEditHistoryShow(wndHandler, wndControl)
	local wndPublicBio = self.wndMain:FindChild("wnd_EditBackground:input_b_PublicHistory")
	local strBioText = RPCore:GetLocalTrait("biography") or ""
	local bPublicBio = RPCore:GetLocalTrait("publicBio") or false
	local wndEditBox = self.wndMain:FindChild("wnd_EditBackground:input_s_History")
	strBioText = string.gsub(strBioText, "<BR />", "\n")
	
	wndEditBox:SetText(strBioText)
	wndPublicBio:SetCheck(bPublicBio)
	self:OnEditHistoryBoxChanged( wndEditBox, wndEditBox)
end

function PDA:OnEditHistoryBoxChanged( wndHandler, wndControl, strText )
	local wndCounter = wndControl:GetParent():FindChild("wnd_CharacterCount")
	if wndCounter:IsShown() ~= true then return end
	local nCharacterCount = string.len(wndControl:GetText())
	wndCounter:SetText(tostring(knBioMax - nCharacterCount))
end

function PDA:InsertTag(wndHandler, wndControl)
	local wndEditBox = wndControl:GetParent():FindChild("input_s_History")
	local tagType = string.sub(wndControl:GetName(), 5)
	local tSelected = wndEditBox:GetSel()
	
	if (tSelected.cpEnd - tSelected.cpBegin ) > 0 then
		local strSelectedText = string.sub(wndEditBox:GetText(), tSelected.cpBegin, tSelected.cpEnd)
		wndEditBox:InsertText(string.format("\{%s\}%s\{/%s\}",tagType, strSelectedText, tagType))
	else
		wndEditBox:InsertText(string.format("\{%s\}\{/%s\}",tagType, tagType))
		wndEditBox:SetSel(string.len(wndEditBox:GetText()) - (string.len(tagType) + 3), string.len(wndEditBox:GetText()) - (string.len(tagType) + 3))
	end
	
end

function PDA:OnEditHistoryOK(wndHandler, wndControl)
	local editBox = self.wndMain:FindChild("wnd_EditBackground:input_s_History")
	local bioText = editBox:GetText()
	RPCore:SetLocalTrait("biography", bioText)
end

function PDA:OnEditHistoryCancel(wndHandler, wndControl)
	self:OnEditHistoryShow()
end

function PDA:OnPublicHistoryCheck(wndHandler, wndControl)
	RPCore:SetLocalTrait("publicBio", wndControl:IsChecked())
end

-----------------------------------------------------------------------------------------------
-- PDA Options Form Functions
-----------------------------------------------------------------------------------------------

function PDA:OnOptionsOK()
	local wndOptions = self.wndOptions:FindChild("wnd_ScrollFrame")
	local strLabelColor
	local strEntryColor
	
	for i = 0, 7 do
		local color = wndOptions:FindChild("btn_Color_State"..tostring(i)):FindChild("swatch"):GetBGColor():ToTable()
		self.tPDAOptions.tRPColors[i] = GeminiColor:RGBAPercToHex(color.r, color.g, color.b, color.a)
	end
	
	local tColor = wndOptions:FindChild("btn_Color_Name"):FindChild("swatch"):GetBGColor():ToTable()
	strLabelColor = GeminiColor:RGBAPercToHex(tColor.r, tColor.g, tColor.b, tColor.a)
	
	tColor = wndOptions:FindChild("btn_Color_Title"):FindChild("swatch"):GetBGColor():ToTable()
	strEntryColor = GeminiColor:RGBAPercToHex(tColor.r, tColor.g, tColor.b, tColor.a)
	
	local wndStyles = wndOptions:FindChild("group_BioMarkupStyles")
	
	for i,v in pairs(self.tPDAOptions.tMarkupStyles) do
		local wndStylePanel = wndStyles:FindChild("wnd_"..v.tag)
		local strFont = wndStylePanel:FindChild("btn_DDFont:ddList"):GetRadioSelButton("DDList"):GetName()
		local tColor = wndStylePanel:FindChild("btn_Color:swatch"):GetBGColor():ToTable()
		local strColor = GeminiColor:RGBAPercToHex(tColor.r, tColor.g, tColor.b, tColor.a) --
		local strAlign = wndStylePanel:FindChild("btn_DDAlign:ddList"):GetRadioSelButton("DDList"):GetName()
		
		v.align = string.sub(strAlign,5)
		v.color = strColor
		v.font = string.sub(strFont, 5)
	end
	
	self.tPDAOptions.tCSColors.strLabelColor = strLabelColor
	self.tPDAOptions.tCSColors.strEntryColor = strEntryColor
	self.tPDAOptions.nOffset = wndOptions:FindChild("input_n_Offset"):GetValue()
	self.tPDAOptions.bShowMyNameplate = wndOptions:FindChild("input_b_ShowPlayerNameplate"):IsChecked()

	self.wndOptions:Show(false) -- hide the window
end

function PDA:OnOptionsCancel()
	self.wndOptions:Show(false) -- hide the window
end

function PDA:OnShowOptions(wndHandler, wndControl)
	if wndHandler ~= wndControl then return end
	local wndOptions = self.wndOptions:FindChild("wnd_ScrollFrame")
	
	for i = 0, 7 do
		wndOptions:FindChild("btn_Color_State"..tostring(i)):FindChild("swatch"):SetBGColor(self.tPDAOptions.tRPColors[i])
	end
	
	for i,tTag in pairs(self.tPDAOptions.tMarkupStyles) do
		local wndStylePanel = wndOptions:FindChild("group_BioMarkupStyles:wnd_"..tTag.tag)
		wndStylePanel:FindChild("btn_DDFont"):SetText(tTag.font)
		SetDDSelectByName(self, wndStylePanel:FindChild("btn_DDFont:ddList"), tTag.font)
		wndStylePanel:FindChild("btn_DDAlign"):SetText(tTag.align)
		SetDDSelectByName(self, wndStylePanel:FindChild("btn_DDAlign:ddList"), tTag.align)
		wndStylePanel:FindChild("btn_Color:swatch"):SetBGColor(tTag.color)
		local sampleTest = string.format("<P Align=\"%s\" Font=\"%s\" TextColor=\"%s\"> {%s} Text Sample</P>",tTag.align, tTag.font, tTag.color, tTag.tag)
		wndStylePanel:FindChild("wnd_Sample"):SetAML(sampleTest)
	end
	
	wndOptions:FindChild("btn_Color_Name"):FindChild("swatch"):SetBGColor(self.tPDAOptions.tCSColors.strLabelColor)
	wndOptions:FindChild("btn_Color_Title"):FindChild("swatch"):GetBGColor(self.tPDAOptions.tCSColors.strEntryColor)
	wndOptions:FindChild("input_b_ShowPlayerNameplate"):SetCheck(self.tPDAOptions.bShowMyNameplate)
	wndOptions:FindChild("input_n_Offset"):SetMinMax(0,100)
	wndOptions:FindChild("input_n_Offset"):SetValue(self.tPDAOptions.nOffset or 0)
	
	wndOptions:SetFocus()
	wndOptions:SetVScrollPos(1)
end

function PDA:UpdateHeadingDisplay()
	local wndOptions = self.wndOptions:FindChild("wnd_ScrollFrame")
	for i,tTag in pairs(ktPDAOptions.tMarkupStyles) do
		local wndStylePanel = wndOptions:FindChild("group_BioMarkupStyles:wnd_"..tTag.tag)
		local strFont = wndStylePanel:FindChild("btn_DDFont"):GetText()
		local strAlign = wndStylePanel:FindChild("btn_DDAlign"):GetText()
		local tColor = wndStylePanel:FindChild("btn_Color"):FindChild("swatch"):GetBGColor():ToTable()
		local strColor = GeminiColor:RGBAPercToHex(tColor.r, tColor.g, tColor.b, tColor.a)
		
		local sampleTest = string.format("<P Align=\"%s\" Font=\"%s\" TextColor=\"%s\"> {%s} Text Sample</P>",strAlign, strFont, strColor, tTag.tag)
		wndStylePanel:FindChild("wnd_Sample"):SetAML(sampleTest)
	end	
end

function PDA:OptionsDDClick(wndHandler, wndControl)
	local bDDListShown = wndControl:FindChild("ddList"):IsShown()
	wndControl:FindChild("ddList"):Show(not (bDDListShown))
end

function PDA:OptionsDDListItemClick(wndHandler, wndControl)
	local ddList = wndControl:GetParent()
	local ddButton = ddList:GetParent()
	
	ddButton:SetText(wndControl:GetText())
	ddList:Show(false)
	self:UpdateHeadingDisplay()
end

function PDA:HeaderColorButtonClick(wndHandler, wndControl)
	local funcs = {
		ChangeSwatchColor = function(self, strColor)
			wndControl:FindChild("swatch"):SetBGColor(strColor)
			Event_FireGenericEvent("PDA_HeaderColorUpdated")
		end,
	}
	GeminiColor:ShowColorPicker(funcs, "ChangeSwatchColor", true)	
end

function PDA:ColorButtonClick(wndHandler, wndControl)
	local funcs = {
		ChangeSwatchColor = function(self, strColor)
			wndControl:FindChild("swatch"):SetBGColor(strColor)
		end,
	}
	GeminiColor:ShowColorPicker(funcs, "ChangeSwatchColor", true)	
end

function PDA:ResetHeadingStyles(wndHandler, wndControl)
	self.tPDAOptions.tMarkupStyles = ktPDAOptions.tMarkupStyles
	self:OnShowOptions(self.wndOptions,self.wndOptions)
end

function PDA:ResetNameplateColors(wndHandler, wndControl)
	self.tPDAOptions.tRPColors = ktPDAOptions.tRPColors
	self.tPDAOptions.tCSColors = ktPDAOptions.tCSColors
	self:OnShowOptions(self.wndOptions,self.wndOptions)
end

--[[
function PDA:StringSubUTF8(str, startChar, numChars)
-- modified from http://wowprogramming.com/snippets/UTF-8_aware_stringsub_7
	local function chsize(currChar)
		if not currChar then
			return 0
		elseif currChar > 240 then
			return 4
		elseif currChar > 225 then
			return 3
		elseif currChar > 192 then
			return 2
		else
			return 1
		end
	end

	local startIndex = 1
	while startChar > 1 do
		local char = string.byte(str, startIndex)
		startIndex = startIndex + chsize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex

	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str, currentIndex)
		currentIndex = currentIndex + chsize(char)
		numChars = numChars -1
	end
	return str:sub(startIndex, currentIndex - 1)
end
]]

-----------------------------------------------------------------------------------------------
-- PDA Instance
-----------------------------------------------------------------------------------------------
local PDAInst = PDA:new()
PDAInst:Init()
