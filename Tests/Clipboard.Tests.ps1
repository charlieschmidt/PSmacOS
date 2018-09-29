Import-Module $PSScriptRoot/../Output/PSmacOS/PSmacOS.psd1

InModuleScope 'PSmacOS' {
    Describe "Clipboard Tests" {
        It "Gets and sets the macOS clipboard" {
            "asdf" | Set-Clipboard
            Get-Clipboard | Should -Be "asdf"

            Set-Clipboard "asdf","asdf"
            Get-Clipboard | Should -Be "asdf`nasdf"
        }
    }
}