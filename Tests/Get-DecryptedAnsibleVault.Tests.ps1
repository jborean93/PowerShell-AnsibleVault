[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification="Need to create secure string from samples in tests")]
param()

$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name $PSScriptRoot\..\AnsibleVault -Force

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It "Can decrypt vault <Vault> with password <VaultSecret>" -TestCases @(
            @{ Vault = "small_1.1"; VaultSecret = 'password' }
            @{ Vault = "large_1.1"; VaultSecret = 'Ye^wS##X9qAC4lHDY^ajMvZ*IZrv47Px^hv2#&a8#$KncjKK^T8eJGWcH&Q@yaj4J7rP%ktyMeYTx!ZU2Ce&GeT$$vmSWRq4fqvs' }
            @{
                Vault = "unicode_1.1";
                # Due to unique encoding issues with the test and PowerShell
                # we revert to storing the password as a byte array and setting
                # that as the secure string at runtime
                VaultSecret = [byte[]]@(
                    195, 162, 194, 157, 197, 146, 195, 162,
                    197, 190, 226, 128, 147, 195, 162, 197,
                    190, 226, 128, 162, 195, 162, 197, 190,
                    226, 128, 147, 195, 162, 197, 190, 226,
                    128, 162, 195, 162, 197, 190, 226, 128,
                    147, 195, 162, 194, 173, 226, 128, 162)
            }
            @{ Vault = "dev_1.2"; VaultSecret = 'WsT2Wf!MnHctYXIQbI%xr$L8aid@fLTS6tA*' }
        ) {
            param ($Vault, $VaultSecret)

            if ($VaultSecret -is [byte[]]) {
                $VaultSecret = [System.Text.Encoding]::UTF8.GetString($VaultSecret)
            }

            $vault_contents = Get-Content -Path "$PSScriptRoot\Resources\$Vault.vault" -Raw
            $expected = (Get-Content -Path "$PSScriptRoot\Resources\$Vault.yml" -Raw).Replace("`r`n", "`n")
            $password = ConvertTo-SecureString -String $VaultSecret -AsPlainText -Force

            $actual = Get-DecryptedAnsibleVault -Value $vault_contents -Password $password
            $actual | Should -Be $expected

            $actual = Get-DecryptedAnsibleVault -Path "$PSScriptRoot\Resources\$Vault.vault" -Password $password
            $actual | Should -Be $expected

            # repeat again and make sure omitting -Path is for the path to a vault file
            $actual = Get-DecryptedAnsibleVault "$PSScriptRoot\Resources\$Vault.vault" -Password $password
            $actual | Should -Be $expected

            $actual = $vault_contents | Get-DecryptedAnsibleVault -Password $password
            $actual | Should -Be $expected
        }
        It "Can decrypt vault file in pwd not absolute path" {
            $password = ConvertTo-SecureString -String "password" -AsPlainText -Force
            $previous_pwd = (Get-Location).Path
            Set-Location -Path $PSScriptRoot\Resources

            $expected = (Get-Content -Path "$PSScriptRoot\Resources\small_1.1.yml" -Raw).Replace("`r`n", "`n")
            $actual = Get-DecryptedAnsibleVault -Path "small_1.1.vault" -Password $password
            Set-Location -Path $previous_pwd
            $actual | Should -Be $expected
        }

        It "Throw exception on invalid header" {
            $password = ConvertTo-SecureString -String "pass" -AsPlainText -Force
            { Get-DecryptedAnsibleVault -Value '$FAKE_VAULT;' -Password $password } |
                Should -Throw 'Vault text does not start with the header $ANSIBLE_VAULT;'
        }

        It "Throw exception on invalid version <Version>" -TestCases @(
            @{ Version = "1.0" }
            @{ Version = "1.3" }
        ) {
            param ($Version)

            $vault_contents = Get-Content -Path "$PSScriptRoot\Resources\small_1.1.vault" -Raw
            $vault_contents = "`$ANSIBLE_VAULT;$Version;AES256`n" + $vault_contents.Substring(31)

            $password = ConvertTo-SecureString -String "pass" -AsPlainText -Force
            { Get-DecryptedAnsibleVault -Value $vault_contents -Password $password } |
                Should -Throw "Cannot parse vault version $Version, currently only 1.1 and 1.2 is supported by this tool"
        }

        It "Throw exception on invalid password" {
            $vault_contents = Get-Content -Path "$PSScriptRoot\Resources\small_1.1.vault" -Raw
            $password = ConvertTo-SecureString -String "invalid_pass" -AsPlainText -Force
            { Get-DecryptedAnsibleVault -Value $vault_contents -Password $password } |
                Should -Throw "HMAC verification failed, was the wrong password entered?"
        }
    }
}
