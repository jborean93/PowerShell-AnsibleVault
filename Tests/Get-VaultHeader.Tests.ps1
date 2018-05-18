$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name $PSScriptRoot\..\AnsibleVault -Force
. $PSScriptRoot\..\AnsibleVault\Private\$module_name.ps1
. $PSScriptRoot\..\AnsibleVault\Private\Convert-HexToByte.ps1

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should get cipher <Cipher>, version <Version>, id <Id> for header <Header>' -TestCases @(
            @{ Header = "`$ANSIBLE_VAULT;1.1;AES256`n01"; Cipher = 'AES256'; Version = [Version]"1.1"; Id = $null }
            @{ Header = "`$ANSIBLE_VAULT;1.2;AES256;dev`r`n01"; Cipher = 'AES256'; Version = [Version]"1.2"; Id = "dev" }
            # this is not a real header but it tests the flexibility of the parser
            @{ Header = "`$ANSIBLE_VAULT;1.1;AES512`n`r01"; Cipher = 'AES512'; Version = [Version]"1.1"; Id = $null }
        ) {
            param($Header, $Cipher, $Version, $Id)

            $actual_version, $actual_cipher, $actual_id, $actual_bytes = Get-VaultHeader -Value $Header
            $actual_version | Should -Be $Version
            $actual_cipher | Should -Be $Cipher
            $actual_id | Should -Be $Id
            $actual_bytes | Should -Be ([byte[]]@(1))
        }

        It 'should fail with invalid version for version <Version>' -TestCases @(
            @{ Version = "1.0" }
            @{ Version = "1.3" }
        ) {
            param($Version)

            $header = "`$ANSIBLE_VAULT;$Version;AES256`n01"
            { Get-VaultHeader -Value $header } | Should -Throw "Cannot parse vault version $Version, currently only 1.1 and 1.2 is supported by this tool"
        }
    }
}