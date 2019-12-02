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

        It 'should return correct split for split char <Char> with bytes <Value> with MaxSplit <MaxSplit>' -TestCases @(
            @{
                Char = [char]"a"
                MaxSplit = $null
                Value = [byte[]]@(1, 1, 97, 1, 97, 1)
                Expected = @(
                    [byte[]]@(1, 1),
                    [byte[]]@(1),
                    [byte[]]@(1)
                )
            }
            @{
                Char = [char]"a"
                MaxSplit = $null
                Value = [byte[]]@(1, 1, 97, 1, 97, 1, 97)
                Expected = @(
                    [byte[]]@(1, 1),
                    [byte[]]@(1),
                    [byte[]]@(1)
                )
            }
            @{
                Char = [char]"a"
                MaxSplit = 1
                Value = [byte[]]@(1, 1, 97, 1, 97, 1, 97)
                Expected = @(
                    [byte[]]@(1, 1),
                    [byte[]]@(1, 97, 1, 97)
                )
            }
            @{
                Char = [char]"a"
                MaxSplit = 2
                Value = [byte[]]@(1, 1, 97, 1, 97, 1, 97)
                Expected = @(
                    [byte[]]@(1, 1),
                    [byte[]]@(1),
                    [byte[]]@(1, 97)
                )
            }
            @{
                Char = [char]"a"
                MaxSplit = $null
                Value = [byte[]]@(1, 1, 97, 97, 1, 97, 1)
                Expected = @(
                    [byte[]]@(1, 1),
                    [byte[]]@(1),
                    [byte[]]@(1)
                )
            }
        ){
            param($Char, $MaxSplit, $Value, $Expected)

            $invoke_args = @{}
            if ($MaxSplit) {
                $invoke_args.MaxSplit = $MaxSplit
            }

            $actual = Split-Byte -Value $Value -Char $Char @invoke_args
            $actual.Count | Should -Be $Expected.Count

            for ($i = 0; $i -lt $actual.Count; $i++) {
                $actual[$i].Count | Should -Be $Expected[$i].Count
                for ($j = 0; $j -lt $actual[$i].Count; $j++) {
                    $actual[$i][$j] | Should -Be $Expected[$i][$j]
                }
            }
        }
    }
}