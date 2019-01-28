---
external help file: PSmacOS.dll-Help.xml
Module Name: PSmacOS
online version:
schema: 2.0.0
---

# Invoke-AppleScript

## SYNOPSIS
Invoke AppleScript

## SYNTAX

```
Invoke-AppleScript -Script <String> [-FunctionName <String>] [-Arguments <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will invoke AppleScript.  Arguments can be optionally passed, and any value returned by the AppleScript will be output by the cmdlet.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-AppleScript -Script 'return "Hello" & " " & "World"'
```

Invoke a simple Hello World AppleScript

### Example 2
```powershell
PS C:\> Invoke-AppleScript -Script @"
on myFunction(arg1,arg2)
   return arg1 & " " & arg2
end myFunction
"@ -FunctionName myFunction -Arguments "Hello","World"
```

Invoke a more complicated Hello World AppleScript

## PARAMETERS

### -Arguments
Argument(s) to pass to the AppleScript function

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FunctionName
Function in the AppleScript to run

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

### -Script
AppleScript to run

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
