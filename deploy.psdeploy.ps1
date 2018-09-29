if(
    $env:BHProjectName -and $env:BHProjectName.Count -eq 1 -and
    $env:BHBuildSystem -eq 'Travis CI' -and
    $env:BHBranchName -eq "master" -and
    ($env:BHCommitMessage -match '!deploy' -or $env:BHCommitMessage -match '!release')
)
{
    push-location Output
    Deploy Module {
        By PSGalleryModule {
            FromSource "$($ENV:BHBuildOutput)/$($ENV:BHProjectName)"
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    }
    pop-location
}
else
{
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* Your commit message includes !deploy or !release (Current: $ENV:BHCommitMessage)" |
        Write-Host
}
