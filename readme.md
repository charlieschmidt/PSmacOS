[![Build Status](https://travis-ci.com/charlieschmidt/PSmacOS.svg?branch=master)](https://travis-ci.com/charlieschmidt/PSmacOS)

PSmacOS
========

PowerShell module containing convience or platform-specific cmdlets for macOS.

## Installation

`Install-Module PSmacOS` to install from PSGallery

## Documentation

Look in the [docs](docs/) folder.

## Cmdlet list

* [Get-Clipboard](docs/Get-Clipboard.md) - get clipboard content as a string and return to the pipeline

* [Set-Clipboard](docs/Set-Clipboard.md) - set clipboard content

* [Show-MessageBox](docs/Show-MessageBox.md) - show a message/alert box

    ![Show-MessageBox Plain Type screenshot](/Resources/Screenshot-Show-MessageBox-Plain.png)
    ![Show-MessageBox Note Type screenshot](/Resources/Screenshot-Show-MessageBox-Note.png)
    ![Show-MessageBox Caution Type screenshot](/Resources/Screenshot-Show-MessageBox-Caution.png)
    ![Show-MessageBox Stop Type screenshot](/Resources/Screenshot-Show-MessageBox-Stop.png)


* [Out-GridView](docs/Out-GridView.md) - show a searchable table of objects from the pipeline

    ![Out-GridView screenshot](/Resources/Screenshot-Out-GridView.png)
    
## Planned/Future

* `Start-Process` or equivalent that knows about macOS app bundles [like the `open` command but powershelly]

* `Invoke-AppleScript` - why not?
