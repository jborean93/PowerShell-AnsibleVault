# thanks to http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/

function Resolve-Module
{
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$Name
    )
    Process
    {
        foreach ($ModuleName in $Name)
        {
            $Module = Get-Module -Name $ModuleName -ListAvailable
            Write-Verbose -Message "Resolving Module $($ModuleName)"

            if ($Module)
            {
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                $GalleryVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

                if ($Version -lt $GalleryVersion)
                {
                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

                    Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"
                    Install-Module -Name $ModuleName -Force
                    Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
                }
                else
                {
                    Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            }
            else
            {
                Write-Verbose -Message "$($ModuleName) Missing, installing Module"
                if ($ModuleName -eq "PSScriptAnalyzer"){
                    # PSScriptAnalyzer v1.18.3 (2019.09.17) is only compatible with pwsh v6.2.0+,
                    # but pwsh v6.1.0 is installed on Appveyor.
                    if (($PSVersionTable.PSVersion.Major -ge 6 ) -and ($PSVersionTable.PSVersion -lt "6.2.0")) {
                        $Version = "1.18.2"
                    }
                }
                Install-Module -Name $ModuleName -Force -RequiredVersion $Version
                Import-Module -Name $ModuleName -Force -RequiredVersion $Version
            }
        }
    }
}

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Resolve-Module Psake, PSDeploy, Pester, BuildHelpers, PsScriptAnalyzer

Get-ChildItem env:BH* | ForEach-Object {[Environment]::SetEnvironmentVariable($_.name, "")}
Set-BuildEnvironment

Invoke-psake .\psake.ps1
exit ( [int]( -not $psake.build_success ) )
