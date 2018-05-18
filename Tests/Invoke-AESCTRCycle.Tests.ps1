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

        It 'AES CTR cycle for key <Key> and counter <Counter> from input <InputHex> should get <OutputHex>' -TestCases @(
            # These test cases are from https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38a.pdf
            # F.5.1 CTR-AES127.Encrypt
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
                InputHex = "6bc1bee22e409f96e93d7e117393172a"
                OutputHex = "874d6191b620e3261bef6864990db6ce"
            }
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff00"
                InputHex = "ae2d8a571e03ac9c9eb76fac45af8e51"
                OutputHex = "9806f66b7970fdff8617187bb9fffdff"
            }
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff01"
                InputHex = "30c81c46a35ce411e5fbc1191a0a52ef"
                OutputHex = "5ae4df3edbd5d35e5b4f09020db03eab"
            }
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff02"
                InputHex = "f69f2445df4f9b17ad2b417be66c3710"
                OutputHex = "1e031dda2fbe03d1792170a0f3009cee"
            }
            # F.5.2 CTR-AES127.Encrypt
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
                InputHex = "874d6191b620e3261bef6864990db6ce"
                OutputHex = "6bc1bee22e409f96e93d7e117393172a"
            }
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff00"
                InputHex = "9806f66b7970fdff8617187bb9fffdff"
                OutputHex = "ae2d8a571e03ac9c9eb76fac45af8e51"
            }
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff01"
                InputHex = "5ae4df3edbd5d35e5b4f09020db03eab"
                OutputHex = "30c81c46a35ce411e5fbc1191a0a52ef"
            }
            @{
                Key = "2b7e151628aed2a6abf7158809cf4f3c"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff02"
                InputHex = "1e031dda2fbe03d1792170a0f3009cee"
                OutputHex = "f69f2445df4f9b17ad2b417be66c3710"
            }
            # F.5.3 CTR-AES192.Encrypt
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
                InputHex = "6bc1bee22e409f96e93d7e117393172a"
                OutputHex = "1abc932417521ca24f2b0459fe7e6e0b"
            }
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff00"
                InputHex = "ae2d8a571e03ac9c9eb76fac45af8e51"
                OutputHex = "090339ec0aa6faefd5ccc2c6f4ce8e94"
            }
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff01"
                InputHex = "30c81c46a35ce411e5fbc1191a0a52ef"
                OutputHex = "1e36b26bd1ebc670d1bd1d665620abf7"
            }
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff02"
                InputHex = "f69f2445df4f9b17ad2b417be66c3710"
                OutputHex = "4f78a7f6d29809585a97daec58c6b050"
            }
            # F.5.4 CTR-AES192.Decrypt
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
                InputHex = "1abc932417521ca24f2b0459fe7e6e0b"
                OutputHex = "6bc1bee22e409f96e93d7e117393172a"
            }
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff00"
                InputHex = "090339ec0aa6faefd5ccc2c6f4ce8e94"
                OutputHex = "ae2d8a571e03ac9c9eb76fac45af8e51"
            }
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff01"
                InputHex = "1e36b26bd1ebc670d1bd1d665620abf7"
                OutputHex = "30c81c46a35ce411e5fbc1191a0a52ef"
            }
            @{
                Key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff02"
                InputHex = "4f78a7f6d29809585a97daec58c6b050"
                OutputHex = "f69f2445df4f9b17ad2b417be66c3710"
            }
            # F.5.5 CTR-AES256.Encrypt
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
                InputHex = "6bc1bee22e409f96e93d7e117393172a"
                OutputHex = "601ec313775789a5b7a7f504bbf3d228"
            }
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff00"
                InputHex = "ae2d8a571e03ac9c9eb76fac45af8e51"
                OutputHex = "f443e3ca4d62b59aca84e990cacaf5c5"
            }
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff01"
                InputHex = "30c81c46a35ce411e5fbc1191a0a52ef"
                OutputHex = "2b0930daa23de94ce87017ba2d84988d"
            }
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff02"
                InputHex = "f69f2445df4f9b17ad2b417be66c3710"
                OutputHex = "dfc9c58db67aada613c2dd08457941a6"
            }
            # F.5.6 CTR-AES256.Decrypt
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"
                InputHex = "601ec313775789a5b7a7f504bbf3d228"
                OutputHex = "6bc1bee22e409f96e93d7e117393172a"
            }
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff00"
                InputHex = "f443e3ca4d62b59aca84e990cacaf5c5"
                OutputHex = "ae2d8a571e03ac9c9eb76fac45af8e51"
            }
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff01"
                InputHex = "2b0930daa23de94ce87017ba2d84988d"
                OutputHex = "30c81c46a35ce411e5fbc1191a0a52ef"
            }
            @{
                Key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
                Counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdff02"
                InputHex = "dfc9c58db67aada613c2dd08457941a6"
                OutputHex = "f69f2445df4f9b17ad2b417be66c3710"
            }
        ) {
            param($Key, $Counter, $InputHex, $OutputHex)
            $expected = Convert-HexToByte -Value $OutputHex
            $actual = Invoke-AESCTRCycle -Value (Convert-HexToByte -Value $InputHex) `
                -Nonce (Convert-HexToByte -Value $Counter) `
                -Key (Convert-HexToByte -Value $Key)
            
            $actual | Should -Be $expected
        }
    }
}