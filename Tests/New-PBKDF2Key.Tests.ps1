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
. $PSScriptRoot\..\AnsibleVault\Private\Convert-ByteToHex.ps1
. $PSScriptRoot\..\AnsibleVault\Private\Invoke-Win32Api.ps1


Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should get valid KDF output (Algorithm: <Algorithm>, Iterations: <Iterations>, Length: <Length>' -TestCases @(
            # PBKDF2 with SHA1 are from https://tools.ietf.org/html/rfc6070#section-2
            @{
                Algorithm = "SHA1"
                Secret = "password"
                Salt = "salt"
                Iterations = 1
                Length = 20
                Expected = "0c60c80f961f0e71f3a9b524af6012062fe037a6"
            }
            @{
                Algorithm = "SHA1"
                Secret = "password"
                Salt = "salt"
                Iterations = 2
                Length = 20
                Expected = "ea6c014dc72d6f8ccd1ed92ace1d41f0d8de8957"
            }
            @{
                Algorithm = "SHA1"
                Secret = "password"
                Salt = "salt"
                Iterations = 4096
                Length = 20
                Expected = "4b007901b765489abead49d926f721d065a429c1"
            }
            @{
                Algorithm = "SHA1"
                Secret = "password"
                Salt = "salt"
                Iterations = 16777216
                Length = 20
                Expected = "eefe3d61cd4da4e4e9945b3d6ba2158c2634e984"
            }
            @{
                Algorithm = "SHA1"
                Secret = "passwordPASSWORDpassword"
                Salt = "saltSALTsaltSALTsaltSALTsaltSALTsalt"
                Iterations = 4096
                Length = 25
                Expected = "3d2eec4fe41c849b80c8d83662c0e44a8b291a964cf2f07038"
            }
            @{
                Algorithm = "SHA1"
                Secret = "pass`0word"
                Salt = "sa`0lt"
                Iterations = 4096
                Length = 16
                Expected = "56fa6aa75548099dcc37d7f03425e0c3"
            }
            # PBKDF2 with SHA256 are from https://stackoverflow.com/questions/5130513/pbkdf2-hmac-sha2-test-vectors
            @{
                Algorithm = "SHA256"
                Secret = "password"
                Salt = "salt"
                Iterations = 1
                Length = 32
                Expected = "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b"
            }
            @{
                Algorithm = "SHA256"
                Secret = "password"
                Salt = "salt"
                Iterations = 2
                Length = 32
                Expected = "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43"
            }
            @{
                Algorithm = "SHA256"
                Secret = "password"
                Salt = "salt"
                Iterations = 4096
                Length = 32
                Expected = "c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a"
            }
            @{
                Algorithm = "SHA256"
                Secret = "password"
                Salt = "salt"
                Iterations = 16777216
                Length = 32
                Expected = "cf81c66fe8cfc04d1f31ecb65dab4089f7f179e89b3b0bcb17ad10e3ac6eba46"
            }
            @{
                Algorithm = "SHA256"
                Secret = "passwordPASSWORDpassword"
                Salt = "saltSALTsaltSALTsaltSALTsaltSALTsalt"
                Iterations = 4096
                Length = 40
                Expected = "348c89dbcbd32b2f32d814b8116e84cf2b17347ebc1800181c4e2a1fb8dd53e1c635518c7dac47e9"
            }
            @{
                Algorithm = "SHA256"
                Secret = "pass`0word"
                Salt = "sa`0lt"
                Iterations = 4096
                Length = 16
                Expected = "89b69d0516f829893c696226650a8687"
            }
        ){
            param($Algorithm, $Secret, $Salt, $Iterations, $Length, $Expected)

            $sec_pass = ConvertTo-SecureString -String $Secret -AsPlainText -Force
            $salt_bytes = [System.Text.Encoding]::UTF8.GetBytes($Salt)
            $actual = New-PBKDF2Key -Algorithm $Algorithm `
                -Password $sec_pass `
                -Salt $salt_bytes `
                -Length $Length `
                -Iterations $Iterations

            (Convert-ByteToHex -Value $actual) | Should -Be $Expected
        }

        It 'fail with invalid algorithm' {
            $sec_pass = ConvertTo-SecureString -String "a" -AsPlainText -Force
            { New-PBKDF2Key -Algorithm "fake" -Password $sec_pass -Salt ([byte[]]@(1)) -Length 1 -Iterations 0 } | Should -Throw "Failed to open algorithm provider with ID 'fake': The object was not found (STATUS_NOT_FOUND 0xC0000225)"
        }

        It 'failed to generate key with invalid parameters' {
            $sec_pass = ConvertTo-SecureString -String "a" -AsPlainText -Force
            { New-PBKDF2Key -Algorithm SHA256 -Password $sec_pass -Salt ([byte[]]@(1)) -Length 0 -Iterations 0 } | Should -Throw "Failed to derive key: An invalid parameter was passed to a service or function (STATUS_INVALID_PARAMETER 0xC0000000D)"
        }
    }
}
