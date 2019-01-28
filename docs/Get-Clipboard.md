---
external help file: PSmacOS.dll-Help.xml
Module Name: PSmacOS
online version:
schema: 2.0.0
---

# Get-Clipboard

## SYNOPSIS
Get the macOS clipboard

## SYNTAX

```
Get-Clipboard [<CommonParameters>]
```

## DESCRIPTION
Get the contents of the macOS clipboard and return them as a string.  This is similar to the `pbpaste` command native to macOS, but with a PowerShell bent.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-Clipboard
```

Fetch the contents of the clipboard and output them

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
