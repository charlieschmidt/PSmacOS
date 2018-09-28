# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot)
    {
        $ProjectRoot = $PSScriptRoot
    }
    
    $Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}


Task Default -Depends Init,Build


Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Clean {
    push-location ./Output
    remove-item * -recurse -force
    Pop-Location

    push-location -Path $ProjectRoot/src/Native
    remove-item build -recurse -force -ErrorAction SilentlyContinue
    pop-location


    push-location -Path $ProjectRoot/src
    dotnet clean
    pop-location
}


Task Build -Depends CompileCSharp {
    Copy-Item "$PSScriptRoot\PSmacOS\*" "$PSScriptRoot\output\PSmacOS" -Recurse -Force
}

Task CompileCSharp -Depends CompileObjC {
    $lines
    'Compiling C#'
    push-location -Path "$ProjectRoot/src"
        dotnet build -o $ProjectRoot\output\PSmacOS\bin
    pop-location
}

Task CompileObjC {
    $lines
    'Compiling Objective-C bridging code'
    push-location -Path "$ProjectRoot/src/Native"
        new-item -name "build" -ItemType "Directory" -Force -ErrorAction SilentlyContinue | Out-Null
        push-location build
            cmake ..
            make
        pop-location
    pop-location
}

Task Test -Depends Build {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile" )
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Release -Depends Test {
    $lines
<#
    $lines
    
    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions

    # Bump the module version
    Update-Metadata -Path $env:BHPSModuleManifest
    #>
}

Task Deploy -Depends Release {
    $lines
<#
  # Gate deployment
    if (
        $ENV:BHBuildSystem -ne 'Unknown' -and
        $ENV:BHBranchName -eq "master" -and
        $ENV:BHCommitMessage -match '!deploy'
    )
    {
        $Params = @{
            Path  = $ProjectRoot
            Force = $true
        }

        Invoke-PSDeploy @Verbose @Params
    }
    else
    {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
        "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)"
    }
    #>
  
}