--===============================================
--					DialogLib
--					   V1.1
--		Apollo Package for simple Pop Up Dialog Windows
--			Copyright (c) 2014 Brandon Petrie
--===============================================

--[[
The MIT License (MIT)

Copyright (c) 2014 Brandon Petrie

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]


local DialogLib = {}

local tXmlTable = {
	__XmlNode = "Forms",
	{ -- Form
		__XmlNode = "Form",
		BAnchorOffset = "125",
		BAnchorPoint = "0.5",
		BGColor = "ffffffff",
		Border = "1",
		Class = "Window",
		Escapable = "1",
		Font = "Default",
		LAnchorOffset = "-225",
		LAnchorPoint = "0.5",
		Moveable = "1",
		Name = "TwoButtonDialogForm",
		Overlapped = "1",
		Picture = "1",
		RAnchorOffset = "225",
		RAnchorPoint = "0.5",
		RelativeToClient = "1",
		SwallowMouseClicks = "1",
		TAnchorOffset = "-125",
		TAnchorPoint = "0.5",
		Template = "CRB_TooltipSimple",
		Text = "",
		TextColor = "ffffffff",
		Tooltip = "",
		TooltipColor = "",
		TooltipType = "OnCursor",
		UseTemplateBG = "1",
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "0",
			BAnchorPoint = "0.5",
			BGColor = "UI_WindowBGDefault",
			Class = "Window",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			Font = "Default",
			LAnchorOffset = "10",
			LAnchorPoint = "0",
			Name = "DialogTextBox",
			RAnchorOffset = "-10",
			RAnchorPoint = "1",
			RelativeToClient = "1",
			TAnchorOffset = "10",
			TAnchorPoint = "0",
			Template = "CRB_TooltipUpper",
			Text = "Text",
			TextColor = "UI_TextHoloTitle",
			TextId = "",
			TooltipColor = "",
			TooltipType = "OnCursor"
		},
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Large",
			BGColor = "ff00ff00",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "1",
			DisabledTextColor = "UI_BtnTextGreenDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextGreenFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "-200",
			LAnchorPoint = "0.5",
			Name = "ButtonGreen",
			NormalTextColor = "UI_BtnTextGreenNormal",
			PressedFlybyTextColor = "UI_BtnTextGreenPressedFlyby",
			PressedTextColor = "UI_BtnTextGreenPressed",
			RAnchorOffset = "-75",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Text = "Green",
			TextColor = "ffffffff",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
		{ --control
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Red",
			BGColor = "ffffffff",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "2",
			DisabledTextColor = "UI_BtnTextRedDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextRedFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "75",
			LAnchorPoint = "0.5",
			Name = "ButtonRed",
			NormalTextColor = "UI_BtnTextRedNormal",
			PressedFlybyTextColor = "UI_BtnTextRedPressedFlyby",
			PressedTextColor = "UI_BtnTextRedPressed",
			RAnchorOffset = "200",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Template = "CRB_TooltipSimple",
			Text = "Red",
			TextColor = "ffffffff",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
	},
	{ -- Form
		__XmlNode = "Form",
		BAnchorOffset = "125",
		BAnchorPoint = "0.5",
		BGColor = "ffffffff",
		Border = "1",
		Class = "Window",
		Escapable = "1",
		Font = "Default",
		LAnchorOffset = "-225",
		LAnchorPoint = "0.5",
		Moveable = "1",
		Name = "ThreeButtonDialogForm",
		Overlapped = "1",
		Picture = "1",
		RAnchorOffset = "225",
		RAnchorPoint = "0.5",
		RelativeToClient = "1",
		SwallowMouseClicks = "1",
		TAnchorOffset = "-125",
		TAnchorPoint = "0.5",
		Template = "CRB_TooltipSimple",
		Text = "",
		TextColor = "ffffffff",
		Tooltip = "",
		TooltipColor = "",
		TooltipType = "OnCursor",
		UseTemplateBG = "1",
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "0",
			BAnchorPoint = "0.5",
			BGColor = "UI_WindowBGDefault",
			Class = "Window",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			Font = "Default",
			LAnchorOffset = "10",
			LAnchorPoint = "0",
			Name = "DialogTextBox",
			RAnchorOffset = "-10",
			RAnchorPoint = "1",
			RelativeToClient = "1",
			TAnchorOffset = "10",
			TAnchorPoint = "0",
			Template = "CRB_TooltipUpper",
			Text = "Text",
			TextColor = "UI_TextHoloTitle",
			TextId = "",
			TooltipColor = "",
			TooltipType = "OnCursor"
		},
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Large",
			BGColor = "ff00ff00",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "1",
			DisabledTextColor = "UI_BtnTextGreenDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextGreenFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "-200",
			LAnchorPoint = "0.5",
			Name = "ButtonGreen",
			NormalTextColor = "UI_BtnTextGreenNormal",
			PressedFlybyTextColor = "UI_BtnTextGreenPressedFlyby",
			PressedTextColor = "UI_BtnTextGreenPressed",
			RAnchorOffset = "-75",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Text = "Green",
			TextColor = "ffffffff",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Red",
			BGColor = "ffffffff",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "2",
			DisabledTextColor = "UI_BtnTextRedDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextRedFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "75",
			LAnchorPoint = "0.5",
			Name = "ButtonRed",
			NormalTextColor = "UI_BtnTextRedNormal",
			PressedFlybyTextColor = "UI_BtnTextRedPressedFlyby",
			PressedTextColor = "UI_BtnTextRedPressed",
			RAnchorOffset = "200",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Template = "CRB_TooltipSimple",
			Text = "Red",
			TextColor = "ffffffff",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
		{
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Large",
			BGColor = "ffffffff",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "3",
			DisabledTextColor = "UI_BtnTextHoloDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextHoloFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "-62",
			LAnchorPoint = "0.5",
			Name = "ButtonBlue",
			NormalTextColor = "UI_BtnTextHoloNormal",
			PressedFlybyTextColor = "UI_BtnTextHoloPressedFlyby",
			PressedTextColor = "UI_BtnTextHoloPressed",
			RadioGroup = "",
			RAnchorOffset = "63",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Text = "Blue",
			TextColor = "ffffffff",
			TooltipColor = "",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
	},
	{ -- Form
		__XmlNode = "Form",
		BAnchorOffset = "125",
		BAnchorPoint = "0.5",
		BGColor = "ffffffff",
		Border = "1",
		Class = "Window",
		Escapable = "1",
		Font = "Default",
		LAnchorOffset = "-225",
		LAnchorPoint = "0.5",
		Moveable = "1",
		Name = "TextInputDialogForm",
		Overlapped = "1",
		Picture = "1",
		RAnchorOffset = "225",
		RAnchorPoint = "0.5",
		RelativeToClient = "1",
		SwallowMouseClicks = "1",
		TAnchorOffset = "-125",
		TAnchorPoint = "0.5",
		Template = "CRB_TooltipSimple",
		Text = "",
		TextColor = "ffffffff",
		Tooltip = "",
		TooltipColor = "",
		TooltipType = "OnCursor",
		UseTemplateBG = "1",
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "0",
			BAnchorPoint = "0.5",
			BGColor = "UI_WindowBGDefault",
			Class = "Window",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			Font = "Default",
			LAnchorOffset = "10",
			LAnchorPoint = "0",
			Name = "DialogTextBox",
			RAnchorOffset = "-10",
			RAnchorPoint = "1",
			RelativeToClient = "1",
			TAnchorOffset = "10",
			TAnchorPoint = "0",
			Template = "CRB_TooltipUpper",
			Text = "Text",
			TextColor = "UI_TextHoloTitle",
			TextId = "",
			TooltipColor = "",
			TooltipType = "OnCursor"
		},
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Large",
			BGColor = "green",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "1",
			DisabledTextColor = "UI_BtnTextGreenDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextGreenFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "-200",
			LAnchorPoint = "0.5",
			Name = "ButtonGreen",
			NormalTextColor = "UI_BtnTextGreenNormal",
			PressedFlybyTextColor = "UI_BtnTextGreenPressedFlyby",
			PressedTextColor = "UI_BtnTextGreenPressed",
			RadioGroup = "",
			RAnchorOffset = "-75",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Text = "Green",
			TextColor = "ffffffff",
			TextId = "",
			TooltipColor = "",
			TooltipType = "OnCursor",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "100",
			BAnchorPoint = "0.5",
			Base = "CRB_Basekit:kitBtn_Holo_Red",
			BGColor = "ffffffff",
			Border = "1",
			ButtonType = "PushButton",
			Class = "Button",
			ContentId = "2",
			DisabledTextColor = "UI_BtnTextRedDisabled",
			DT_CENTER = "1",
			DT_VCENTER = "1",
			FlybyTextColor = "UI_BtnTextRedFlyby",
			Font = "DefaultButton",
			LAnchorOffset = "75",
			LAnchorPoint = "0.5",
			Name = "ButtonRed",
			NewWindowDepth = "0",
			NormalTextColor = "UI_BtnTextRedNormal",
			Picture = "0",
			PressedFlybyTextColor = "UI_BtnTextRedPressedFlyby",
			PressedTextColor = "UI_BtnTextRedPressed",
			RadioGroup = "",
			RAnchorOffset = "200",
			RAnchorPoint = "0.5",
			TAnchorOffset = "50",
			TAnchorPoint = "0.5",
			Template = "CRB_TooltipSimple",
			Text = "Red",
			TextColor = "ffffffff",
			TextId = "",
			TooltipColor = "",
			TooltipType = "OnCursor",
			UseTemplateBG = "1",
			{ -- event
				__XmlNode = "Event",
				Function = "TriggerCallback",
				Name = "ButtonSignal"
			},
		},
		{ -- control
			__XmlNode = "Control",
			BAnchorOffset = "43",
			BAnchorPoint = "0.5",
			BGColor = "ffffffff",
			Border = "1",
			Class = "EditBox",
			Font = "CRB_Interface12",
			LAnchorOffset = "10",
			LAnchorPoint = "0",
			Name = "TextInputBox",
			RAnchorOffset = "-10",
			RAnchorPoint = "1",
			RelativeToClient = "1",
			TAnchorOffset = "5",
			TAnchorPoint = "0.5",
			Template = "HologramControl1",
			TextColor = "UI_TextHoloBodyHighlight",
			TextId = "",
			TooltipColor = "",
			TooltipType = "OnCursor",
			UseTemplateBG = "1",
		},
	},
	{ -- Form
		__XmlNode = "Form",
		BAnchorOffset = "125",
		BAnchorPoint = "0.5",
		BGColor = "ffffffff",
		Border = "1",
		Class = "Window",
		Escapable = "1",
		Font = "Default",
		LAnchorOffset = "-225",
		LAnchorPoint = "0.5",
		Moveable = "1",
		Name = "OneButtonDialogForm",
		Overlapped = "1",
		Picture = "1",
		RAnchorOffset = "225",
		RAnchorPoint = "0.5",
		RelativeToClient = "1",
		SwallowMouseClicks = "1",
		TAnchorOffset = "-125",
		TAnchorPoint = "0.5",
		Template = "CRB_TooltipSimple",
		Text = "",
		TextColor = "ffffffff",
		Tooltip = "",
		TooltipColor = "",
		TooltipType = "OnCursor",
		UseTemplateBG = "1",
			{ -- control
				__XmlNode = "Control",
				BAnchorOffset = "0",
				BAnchorPoint = "0.5",
				BGColor = "UI_WindowBGDefault",
				Class = "Window",
				DT_CENTER = "1",
				DT_VCENTER = "1",
				Font = "Default",
				LAnchorOffset = "10",
				LAnchorPoint = "0",
				Name = "DialogTextBox",
				RAnchorOffset = "-10",
				RAnchorPoint = "1",
				RelativeToClient = "1",
				TAnchorOffset = "10",
				TAnchorPoint = "0",
				Template = "CRB_TooltipUpper",
				Text = "Text",
				TextColor = "UI_TextHoloTitle",
				TextId = "",
				TooltipColor = "",
				TooltipType = "OnCursor"
			},
			{ -- control
				__XmlNode = "Control",
				BAnchorOffset = "100",
				BAnchorPoint = "0.5",
				Base = "CRB_Basekit:kitBtn_Holo_Large",
				BGColor = "ffffffff",
				ButtonType = "PushButton",
				Class = "Button",
				ContentId = "1",
				DisabledTextColor = "UI_BtnTextHoloDisabled",
				DT_CENTER = "1",
				DT_VCENTER = "1",
				FlybyTextColor = "UI_BtnTextHoloFlyby",
				Font = "DefaultButton",
				LAnchorOffset = "-62",
				LAnchorPoint = "0.5",
				Name = "ButtonBlue",
				NormalTextColor = "UI_BtnTextHoloNormal",
				PressedFlybyTextColor = "UI_BtnTextHoloPressedFlyby",
				PressedTextColor = "UI_BtnTextHoloPressed",
				RadioGroup = "",
				RAnchorOffset = "62",
				RAnchorPoint = "0.5",
				TAnchorOffset = "50",
				TAnchorPoint = "0.5",
				Text = "Blue",
				TextColor = "ffffffff",
				TextId = "",
				TooltipColor = "",
				TooltipType = "OnCursor",
				{ -- event
					__XmlNode = "Event",
					Function = "TriggerCallback",
					Name = "ButtonSignal"
				},
			},
	},
}

DialogLib.XmlDoc = XmlDoc.CreateFromTable(tXmlTable)

function DialogLib:ShowDialog(strTemplate, strText, tButtonText, strMethod, tAddon)
	local tInstance = DialogLib:new()

	tInstance.dialogMethod = strMethod
	tInstance.dialogAddon = tAddon	
	tInstance.wndDialog = Apollo.LoadForm(self.XmlDoc, strTemplate.."DialogForm", nil, tInstance)
	tInstance.wndDialog:FindChild("DialogTextBox"):SetText(strText)
	if tInstance.wndDialog:FindChild("ButtonGreen") then
		tInstance.wndDialog:FindChild("ButtonGreen"):SetText(tButtonText.green)
	end
	if tInstance.wndDialog:FindChild("ButtonRed") then
		tInstance.wndDialog:FindChild("ButtonRed"):SetText(tButtonText.red)
	end
	if tInstance.wndDialog:FindChild("ButtonBlue") then
		tInstance.wndDialog:FindChild("ButtonBlue"):SetText(tButtonText.blue)
	end
	tInstance.wndDialog:Show(true)

end

function DialogLib:TriggerCallback(wndHandler, wndControl)
	local strWindID = wndControl:GetContentId()
	local strInput
	
	if self.wndDialog:FindChild("TextInputBox") then
		strInput = self.wndDialog:FindChild("TextInputBox"):GetText()
	end
	
	if self.dialogMethod then
		self.dialogAddon[self.dialogMethod](self, strWindID, strInput)
	end
	self.wndDialog:Show(false)
	self.wndDialog:Destroy()
end

function DialogLib:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
    return o
end


Apollo.RegisterPackage(DialogLib, "DialogLib-1.0", 2, {})