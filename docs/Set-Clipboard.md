---
external help file: PSmacOS.dll-Help.xml
Module Name: PSmacOS
online version:
schema: 2.0.0
---

# Set-Clipboard

## SYNOPSIS
Set the macOS clipboard

## SYNTAX

```
Set-Clipboard [-Value] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Set the macOS clipboard from a string or string array.  This is similar to the `pbcopy` command native to macOS, but with a PowerShell bent.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-Clipboard -Value "TheString"
```

Set the conents of the clipboard to `TheString`

## PARAMETERS

### -Value
The value to set to the clipboard

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
