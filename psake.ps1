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


Task Default -Depends Init,Clean,Build,Test,Deploy


Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Clean -PreCondition { Test-Path $ENV:BHBuildOutput } {
    push-location $ENV:BHBuildOutput
        remove-item * -recurse -force
    Pop-Location

    push-location -Path $ProjectRoot/src/GridViewer
        remove-item build -recurse -force -ErrorAction SilentlyContinue
    pop-location

    push-location -Path $ProjectRoot/src/libpsmacosbridging
        remove-item build -recurse -force -ErrorAction SilentlyContinue
    pop-location

    push-location -Path $ProjectRoot/src
        dotnet clean
        if ($lastexitcode -ne 0)
        {
            throw "dotnet clean failed"
        }
    pop-location
}

Task CompileObjC {
    $lines
    'Compiling Objective-C bridging code'
    push-location -Path "$ProjectRoot/src/GridViewer"
        if ($env:BHBuildSystem -eq 'Travis CI') {
            $configuration = "Release"
        } else {
            $Configuration = "Debug"
        }

        xcrun xcodebuild -alltargets -configuration $Configuration
        if ($lastexitcode -ne 0)
        {
            throw "xcrun xcodebuild failed"
        }
        Copy-Item -Path "./Build/$Configuration/GridViewer.app" -Destination $ENV:BHBuildOutput\PSmacOS\bin -Recurse -Force
    pop-location

    push-location -Path "$ProjectRoot/src/libpsmacosbridging"
        new-item -name "build" -ItemType "Directory" -Force -ErrorAction SilentlyContinue | Out-Null
        push-location build
            cmake ..
            if ($lastexitcode -ne 0)
            {
                throw "cmake failed"
            }

            make
            if ($lastexitcode -ne 0)
            {
                throw "make failed"
            }

            copy-item "./lib/*.dylib" $ENV:BHBuildOutput\PSmacOS\bin -Recurse -Force
        pop-location
    pop-location
    
    "`n"
}

Task CompileCSharp -Depends CompileObjC {
    $lines
    'Compiling C#'
    push-location -Path "$ProjectRoot/src"
        dotnet build -o $ENV:BHBuildOutput\PSmacOS\bin
        if ($lastexitcode -ne 0)
        {
            throw "dotnet build failed"
        }
    pop-location
    "`n"
}

Task Build -Depends CompileCSharp {
    $lines
    'Assembling Module'
    Copy-Item "$PSScriptRoot\PSmacOS\*" "$($ENV:BHBuildOutput)\PSmacOS" -Recurse -Force
    "`n"
}

Task Test -Depends Build {
    $lines
    if ($env:BHBuildSystem -eq 'Travis CI' -or $env:BHBranchName -eq "master") {
        "Testing with PowerShell $PSVersion"

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
    } else {
        "Skipping testing"
    }
    "`n"
}

Task BumpVersion -Depends {
    $lines
    
    Update-Metadata -Path $env:BHPSModuleManifest  
}

Task Deploy -Depends Test {
    $lines

    $Params = @{
        Path = $ProjectRoot
        Force = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }

    Invoke-PSDeploy @Verbose @Params
}