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

        It "Can encrypt vault <Vault> with password <VaultSecret>" -TestCases @(
            @{ Vault = "small_1.1"; VaultSecret = 'password' }
            @{ Vault = "large_1.1"; VaultSecret = 'Ye^wS##X9qAC4lHDY^ajMvZ*IZrv47Px^hv2#&a8#$KncjKK^T8eJGWcH&Q@yaj4J7rP%ktyMeYTx!ZU2Ce&GeT$$vmSWRq4fqvs' }
            @{ Vault = "unicode_1.1"; VaultSecret = '❌➖➕➖➕➖⭕' }
            @{ Vault = "dev_1.2"; VaultSecret = 'WsT2Wf!MnHctYXIQbI%xr$L8aid@fLTS6tA*' }
        ) {
            param ($Vault, $VaultSecret)
            
            $path = "$PSScriptRoot\Resources\$Vault.yml"
            $plaintext = (Get-Content -Path $path -Raw).Replace("`r`n", "`n")
            $password = ConvertTo-SecureString -String $VaultSecret -AsPlainText -Force

            $actual = Get-EncryptedAnsibleVault -Value $plaintext -Password $password
            $actual2 = Get-EncryptedAnsibleVault -Value $plaintext -Password $password
            $actual | Should -Not -Be $plaintext
            $actual | Should -BeLike '$ANSIBLE_VAULT;1.1;AES256*'
            # verify we used a random salt and the output is different
            $actual | Should -Not -Be $actual2

            $actual = $plaintext | Get-EncryptedAnsibleVault -Password $password
            $actual2 = $plaintext | Get-EncryptedAnsibleVault -Password $password
            $actual | Should -Not -Be $plaintext
            $actual | Should -BeLike '$ANSIBLE_VAULT;1.1;AES256*'
            $actual | Should -Not -Be $actual2

            $actual = Get-EncryptedAnsibleVault -Path $path -Password $password
            $actual2 = Get-EncryptedAnsibleVault -Path $path -Password $password
            $actual | Should -Not -Be $plaintext
            $actual | Should -BeLike '$ANSIBLE_VAULT;1.1;AES256*'
            $actual | Should -Not -Be $actual2

            # we can't assert the vault text as it changes randomly, we can at
            # verify we can decrypt using the normal process which is tested
            # against known outputs
            if ($Vault -eq "unicode_1.1") {
                # The original plaintext file is known to be UTF-16, we need to
                # override the output encoding for this scenario only
                $dec_actual = $actual | Get-DecryptedAnsibleVault -Password $password -Encoding ([System.Text.Encoding]::Unicode)
            } else {
                $dec_actual = $actual | Get-DecryptedAnsibleVault -Password $password -Encoding ([System.Text.Encoding]::UTF8)
            }
            # because last actual was from file, the plaintext could have different newlines, just read the file again
            $dec_actual | Should -Be (Get-Content -Path $path -Raw)

            # now repeat the above and specify the ID
            $actual = Get-EncryptedAnsibleVault -Path $path -Password $password -Id Prod
            $actual2 = Get-EncryptedAnsibleVault -Path $path -Password $password -Id Prod
            $actual | Should -Not -Be $plaintext
            $actual | Should -BeLike '$ANSIBLE_VAULT;1.2;AES256;Prod*'
            $actual | Should -Not -Be $actual2

            $actual = Get-EncryptedAnsibleVault -Value $plaintext -Password $password -Id Prod
            $actual2 = Get-EncryptedAnsibleVault -Value $plaintext -Password $password -Id Prod
            $actual | Should -Not -Be $plaintext
            $actual | Should -BeLike '$ANSIBLE_VAULT;1.2;AES256;Prod*'
            # verify we used a random salt and the output is different
            $actual | Should -Not -Be $actual2

            $actual = $plaintext | Get-EncryptedAnsibleVault -Password $password -Id Prod
            $actual2 = $plaintext | Get-EncryptedAnsibleVault -Password $password -Id Prod
            $actual | Should -Not -Be $plaintext
            $actual | Should -BeLike '$ANSIBLE_VAULT;1.2;AES256;Prod*'
            $actual | Should -Not -Be $actual2

            $dec_actual = $actual | Get-DecryptedAnsibleVault -Password $password
            # last actual was the string we specified, we can assert with the actual string to make sure
            $dec_actual | Should -Be $plaintext
        }
    }
}
