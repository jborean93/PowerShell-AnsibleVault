$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name $PSScriptRoot\..\AnsibleVault -Force
. $PSScriptRoot\..\AnsibleVault\Private\$module_name.ps1

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should get valid bytes' {
            $expected = [byte[]]@(72, 101, 108, 108, 111)
            $actual = Convert-HexToByte -Value "48656c6c6f"

            $actual.Length | Should -Be $expected.Count
            for ($i = 0; $i -lt $actual.Count; $i++) {
                $actual[$i] | Should -Be $expected[$i]
            }
        }
    }
}