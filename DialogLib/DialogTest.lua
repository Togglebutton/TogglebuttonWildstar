require "Window"
 
-----------------------------------------------------------------------------------------------
-- DialogTest Module Definition
-----------------------------------------------------------------------------------------------
local DialogTest = {} 
local DialogLib
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local ktDialogTypes = {
	{template = "OneButton", dialogText = "This is an example One Button Dialog. This is good for a simple notification prompt.", buttons = {blue="OK"}},
	{template = "TwoButton", dialogText = "This is an example Two Button Dialog. This is good for a standard OK - Cancel Dialog.", buttons = {red = "Cancel", blue="OK"}},
	{template = "ThreeButton", dialogText = "This is an example of a Three Button Dialog. This is good for a Ys, No, Cancel Dialog.", buttons = {red = "Cancel", green= "Yes", blue="No"}},
	{template = "TextInput", dialogText = "This is an example Text Input Dialog. This is good for gatherign small amounts of input from a user. Please enter some text in the box below.", buttons = {green= "OK"}},
}

local ktButtonTypes = {
	"Green Button",
	"Red Button",
	"Blue Button",
}

local ksButtonPressed = "%s pressed. The return value from the Popup Dialog was %i."
local ksTextInput = "The text input returned from the Popup Dialog was %s."
 
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
	local bHasConfigureButton = false
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
	DialogLib = Apollo.GetPackage("DialogLib-1.0").tPackage
	self.wndMain = Apollo.LoadForm("DialogTest.xml", "DialogTestForm", nil, self)
	self.wndMain:Show(false, true)
	Apollo.RegisterSlashCommand("dialogtest", "OnDialogTestOn", self)
end

-----------------------------------------------------------------------------------------------
-- DialogTest Functions
-----------------------------------------------------------------------------------------------
-- on SlashCommand "/dt"
function DialogTest:OnDialogTestOn()
	self.wndMain:Show(true) -- show the window
end

-- Dialog Callback Method
function DialogTest:DialogCallbackMethod(strButtonID, strInput)
	local strText = string.format(ksButtonPressed, ktButtonTypes[strButtonID], strButtonID)
	local strInputText = string.format(ksTextInput, strInput)
	
	Print(strText)
	if strInput then
		Print(strInputText)
	end
	
end

-----------------------------------------------------------------------------------------------
-- DialogTestForm Functions
-----------------------------------------------------------------------------------------------
function DialogTest:OnButtonClick(wndHandler, wndControl)
	local nButtonId = wndControl:GetContentId()
	-- get the content ID of the button, to look up the right set of parameters in the list.
	
	DialogLib:ShowDialog(ktDialogTypes[nButtonId].template, ktDialogTypes[nButtonId].dialogText, ktDialogTypes[nButtonId].buttons, "DialogCallbackMethod", self)
end

function DialogTest:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

local DialogTestInst = DialogTest:new()
DialogTestInst:Init()
