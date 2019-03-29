$script:kind = 'PSMacOSSecret'
Function Set-Secret
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Account,

        [Parameter(Mandatory)]
        [string]
        $Service,

        [Parameter(Mandatory)]
        [String]
        $Secret
    )

    if($IsMacOS)
    {
        security add-generic-password -a $Account -w $Secret -s $Service -D $script:kind
    }
    else {
        throw "OS not supported"
    }
}

function Get-Secret
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Account,

        [Parameter(Mandatory)]
        [string]
        $Service
    )

    return (security find-generic-password -D $script:kind -a $Account -s $Service -w)
}

Export-ModuleMember -Function @(
    'Set-Secret',
    'Get-Secret'
)