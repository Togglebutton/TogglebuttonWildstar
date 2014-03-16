# Syntax #

    DialogLib:ShowDialog(strTemplate, strText, tButtonText, strMethod, tAddon)

## Arguments: ##

### strTemplate ###

The name of the dialog style, choose form:

- **OneButton** - With one Blue button in the center
- **TwoButton** - With a Green and a Red button
- **ThreeButton** - With a Green, Blue, and Red button
- **TextInput** - With a Green and Red button, and an edit box for text input.

### strText ###
The text prompt for the dialog window

### tButtonText ###
A table that describes the text on the buttons, if not defined they will have their color.

    {
    	red = "Cancel",
    	blue = "Other",
    	green = "OK"
    }

### strMethod ###
The callback method's name.

### tAddon ###
The addon that contains the callback method, usually self.

## Callback Method Syntax ##

    Addon:MethodName(nButtonID, strEditBoxInput)

### nButtonID ###
A numerical value for the button that was clicked.

- 1 - Green Button
- 2 - Red Button
- 3 - Blue Button

### strEditBoxInput ###
The text input gathered from a TextInput type dialog.
