[![Build Status](https://travis-ci.com/charlieschmidt/PSmacOS.svg?branch=master)](https://travis-ci.com/charlieschmidt/PSmacOS)

PSmacOS
========

PowerShell module containing convience or platform-specific cmdlets for macOS.

## Installation

`Install-Module PSmacOS` to install from PSGallery

## Cmdlet list

* `Get-Clipboard` - get clipboard content as a string and return to the pipeline

* `Set-Clipboard` - set clipboard content

## In Progress

* [outgridview branch]( 
https://github.com/charlieschmidt/PSmacOS/tree/outgridview)

    * `Show-MessageBox` - show a message/alert box

    * `Out-GridView` - native implementation of the PowerShell 5.1 command

## Planned/Future

* `Start-Process` or equivalent that knows about macOS app bundles [like the `open` command but powershelly]

* `Invoke-AppleScript` - why not?
