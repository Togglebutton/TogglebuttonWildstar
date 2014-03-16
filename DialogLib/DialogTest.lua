-----------------------------------------------------------------------------------------------
-- Client Lua Script for DialogTest
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- DialogTest Module Definition
-----------------------------------------------------------------------------------------------
local DialogTest = {} 
local DialogLib
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function DialogTest:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function DialogTest:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"DialogLib-1.0",
	}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- DialogTest OnLoad
-----------------------------------------------------------------------------------------------
function DialogTest:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("DialogTest.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	DialogLib = Apollo.GetPackage("DialogLib-1.0").tPackage
end

-----------------------------------------------------------------------------------------------
-- DialogTest OnDocLoaded
-----------------------------------------------------------------------------------------------
function DialogTest:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "DialogTestForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("dt", "OnDialogTestOn", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- DialogTest Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/dt"
function DialogTest:OnDialogTestOn()
	self.wndMain:Show(true) -- show the window
end


-----------------------------------------------------------------------------------------------
-- DialogTestForm Functions
-----------------------------------------------------------------------------------------------
function DialogTest:OnOK()
	DialogLib:ShowDialog("ThreeButton", "Test Text", { red = "Cancel", green = "OK", blue = "Other"}, "TestMethod", self)
end

-- when the Cancel button is clicked
function DialogTest:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

function DialogTest:TestMethod(strButtonID, strInput)
	Print(strButtonID)
	Print(strInput)
end
-----------------------------------------------------------------------------------------------
-- DialogTest Instance
-----------------------------------------------------------------------------------------------
local DialogTestInst = DialogTest:new()
DialogTestInst:Init()
