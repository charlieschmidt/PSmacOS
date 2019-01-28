---
external help file: PSmacOS.dll-Help.xml
Module Name: PSmacOS
online version:
schema: 2.0.0
---

# Show-MessageBox

## SYNOPSIS
Show a message/alert box for the user to respond to

## SYNTAX

### SwitchButtons (Default)
```
Show-MessageBox [-Title <String>] -Message <String> [-Timeout <Double>] [-Type <Type>] [-Buttons <String>]
 [<CommonParameters>]
```

### AnyButtons
```
Show-MessageBox [-Title <String>] -Message <String> [-Timeout <Double>] [-Type <Type>]
 [-ButtonOneLabel <String>] [-ButtonTwoLabel <String>] [-ButtonThreeLabel <String>] [<CommonParameters>]
```

## DESCRIPTION
Show a native message/alert box for the user to respond to

## EXAMPLES

### Example 1
```powershell
PS C:\> Show-MessageBox -Title "Title" -Message "This is the message text.  It is important."
```

Shows a message box with 1 button, on the right side, with text of `Ok`

### Example 2
```powershell
PS C:\> Show-MessageBox -Title "Oh Noes" -Message "Something terrible happened." -Buttons "AbortRetryIgnore"
```

Shows a message box with 3 buttons - Abort, Retry, Ignore.

### Example 3
```powershell
PS C:\> Show-MessageBox -Title "Custom!" -Message "Some weird message" -ButtonOneLabel "Push Me" -ButtonTwoLabel "Don't Push Me"
```

Shows a message box with 2 custom buttons.

## PARAMETERS

### -ButtonOneLabel
Text for the first button

```yaml
Type: String
Parameter Sets: AnyButtons
Aliases:

Required: False
Position: Named
Default value: Ok
Accept pipeline input: False
Accept wildcard characters: False
```

### -ButtonTwoLabel
Text for the second button

```yaml
Type: String
Parameter Sets: AnyButtons
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ButtonThreeLabel
Text for the third button

```yaml
Type: String
Parameter Sets: AnyButtons
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Buttons
Use a predefined set of buttons

```yaml
Type: String
Parameter Sets: SwitchButtons
Aliases:
Accepted values: AbortRetryIgnore, OK, OKCancel, RetryCancel, YesNo, YesNoCancel

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
Main body text of the message box

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
Keep the message box open for a certain time, then close and return indicating no selection

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
Title for the message box window

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Type for the message box window.  This will change the icon used in the alert.

* Plain - default macOS application icon (paper with A from ruler/paintbrush)
* Caution - yellow triangle
* Stop - red stop sign
* Note - speech bubble with exclaimation mark

```yaml
Type: Type
Parameter Sets: (All)
Aliases:
Accepted values: Stop, Note, Caution, Plain

Required: False
Position: Named
Default value: Plain
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Double
### PSmacOS.NativeBridge.MessageBox+Type
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Out-GridView]()
