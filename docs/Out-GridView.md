---
external help file: PSmacOS.dll-Help.xml
Module Name: PSmacOS
online version:
schema: 2.0.0
---

# Out-GridView

## SYNOPSIS
Sends output to an interactive table in a separate window.

## SYNTAX

### PassThru (Default)
```
Out-GridView [-InputObject <PSObject>] [-Title <String>] [-PassThru] [<CommonParameters>]
```

### Wait
```
Out-GridView [-InputObject <PSObject>] [-Title <String>] [-Wait] [<CommonParameters>]
```

### OutputMode
```
Out-GridView [-InputObject <PSObject>] [-Title <String>] [-OutputMode <OutputModeOption>] [<CommonParameters>]
```

## DESCRIPTION
The Out-GridView cmdlet sends the output from a command to a grid view window where the output is displayed in an interactive table.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-Process | Out-GridView
```

Gets current processes and sends them to a grid view window

### Example 2
```powershell
PS C:\> Get-Process | Out-GridView -PassThru | Export-Csv selected-processes.csv
```

Gets current processes and sends them to a grid view window, the console will block until the window is closed.  Any rows selected in the grid view window will be output from the function

## PARAMETERS

### -InputObject
Specifies that the cmdlet accepts input for Out-GridView.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OutputMode
Specifies the items that the interactive window sends down the pipeline as input to other commands. By default, this cmdlet does not generate any output. To send items from the interactive window down the pipeline, click to select the items and then click OK.
The values of this parameter determine how many items you can send down the pipeline.

* None. No items. This is the default value.
* Single. Zero items or one item. Use this value when the next command can take only one input object.
* Multiple. Zero, one, or many items. Use this value when the next command can take multiple input objects. This value is equivalent to the Passthru parameter.

```yaml
Type: OutputModeOption
Parameter Sets: OutputMode
Aliases:
Accepted values: None, Single, Multiple

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Indicates that the cmdlet sends items from the interactive window down the pipeline as input to other commands. By default, this cmdlet does not generate any output. This parameter is equivalent to using the Multiple value of the OutputMode parameter.

```yaml
Type: SwitchParameter
Parameter Sets: PassThru
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
Specifies the text that appears in the title bar of the Out-GridView window.

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

### -Wait
Indicates that the cmdlet suppresses the command prompt and prevents PowerShell from closing until the Out-GridView window is closed. By default, the command prompt returns when the Out-GridView window opens.

```yaml
Type: SwitchParameter
Parameter Sets: Wait
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.PSObject
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Show-MessageBox]()
