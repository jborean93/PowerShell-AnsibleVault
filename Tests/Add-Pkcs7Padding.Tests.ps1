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

        It 'should return correct padding length for block size <Size> with input <Value>' -TestCases @(
            @{ Size = 32; Value = [byte[]]@(1); Expected = [byte[]]@(1, 3, 3, 3) }
            @{ Size = 32; Value = [byte[]]@(1, 2); Expected = [byte[]]@(1, 2, 2, 2) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3); Expected = [byte[]]@(1, 2, 3, 1) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3, 4); Expected = [byte[]]@(1, 2, 3, 4, 4, 4, 4, 4) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3, 4, 5); Expected = [byte[]]@(1, 2, 3, 4, 5, 3, 3, 3) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3, 4, 5, 6); Expected = [byte[]]@(1, 2, 3, 4, 5, 6, 2, 2) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3, 4, 5, 6, 7); Expected = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 1) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8); Expected = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8, 4, 4, 4, 4) }
            @{ Size = 32; Value = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8, 9); Expected = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8, 9, 3, 3, 3) }
            @{ Size = 64; Value = [byte[]]@(1, 2, 3, 4); Expected = [byte[]]@(1, 2, 3, 4, 4, 4, 4, 4) }
            @{ Size = 64; Value = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8); Expected = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8) }
        ){
            param($Size, $Value, $Expected)
            $actual = Add-Pkcs7Padding -Value $Value -BlockSize $Size
            $actual.Length | Should -Be $Expected.Length

            for ($i = 0; $i -lt $actual.Length; $i++) {
                $actual[$i] | Should -Be $Expected[$i]
            }
        }
    }
}