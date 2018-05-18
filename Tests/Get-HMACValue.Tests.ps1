$verbose = @{}
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $verbose.Add("Verbose", $true)
}

$ps_version = $PSVersionTable.PSVersion.Major
$module_name = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module -Name $PSScriptRoot\..\AnsibleVault -Force
. $PSScriptRoot\..\AnsibleVault\Private\$module_name.ps1
. $PSScriptRoot\..\AnsibleVault\Private\Convert-HexToByte.ps1
. $PSScriptRoot\..\AnsibleVault\Private\Convert-ByteToHex.ps1

Describe "$module_name PS$ps_version tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should get valid HMAC256 result for value <Value> with key <Key>' -TestCases @(
            # Test vectors are from https://tools.ietf.org/html/rfc4231#section-4.1
            @{
                Key = "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"
                Value = "4869205468657265"
                Expected = "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7"
            }
            @{
                Key = "4a656665"
                Value = "7768617420646f2079612077616e7420666f72206e6f7468696e673f"
                Expected = "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843"
            }
            @{
                Key = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                Value = "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
                Expected = "773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe"
            }
            @{
                Key = "0102030405060708090a0b0c0d0e0f10111213141516171819"
                Value = "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd"
                Expected = "82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b"
            }
            @{
                Key = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                Value = "54657374205573696e67204c6172676572205468616e20426c6f636b2d53697a65204b6579202d2048617368204b6579204669727374"
                Expected = "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54"
            }
            @{
                Key = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                Value = "5468697320697320612074657374207573696e672061206c6172676572207468616e20626c6f636b2d73697a65206b657920616e642061206c6172676572207468616e20626c6f636b2d73697a6520646174612e20546865206b6579206e6565647320746f20626520686173686564206265666f7265206265696e6720757365642062792074686520484d414320616c676f726974686d2e"
                Expected = "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2"
            }
        ) {
            param($Key, $Value, $Expected)
            $actual = Get-HMACValue -Value (Convert-HexToByte -Value $Value) -Key (Convert-HexToByte -Value $Key)
            $actual | Should -Be $Expected
        }
    }
}