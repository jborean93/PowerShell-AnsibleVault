$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name ([System.IO.Path]::Combine($PSScriptRoot, '..', 'AnsibleVault')) -Force
. ([System.IO.Path]::Combine($PSScriptRoot, '..', 'AnsibleVault', 'Private', "$($module_name).ps1"))

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should get valid hex string' {
            $expected = "48656c6c6f"
            $actual = Convert-ByteToHex -Value ([byte[]]@(72, 101, 108, 108, 111))

            $actual | Should -Be $expected
        }
    }
}