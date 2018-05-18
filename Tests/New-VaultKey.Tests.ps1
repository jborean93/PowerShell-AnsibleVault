[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification="Need to create secure string from samples in tests")]
param()

$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name $PSScriptRoot\..\AnsibleVault -Force
. $PSScriptRoot\..\AnsibleVault\Private\$module_name.ps1
. $PSScriptRoot\..\AnsibleVault\Private\New-PBKDF2Key.ps1
. $PSScriptRoot\..\AnsibleVault\Private\Invoke-Win32Api.ps1

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should get expected return results' {
            $sec_pass = ConvertTo-SecureString "pass" -AsPlainText -Force
            $actual = New-VaultKey -Password $sec_pass -Salt (New-Object -TypeName byte[] -ArgumentList 32)
            $actual.Count | Should -Be 3

            # New-PBKDF2Key returns a random string so let's just make sure the
            # count is good
            $actual[0].Count | Should -Be 32
            $actual[1].Count | Should -Be 32
            $actual[2].Count | Should -Be 16
        }
    }
}