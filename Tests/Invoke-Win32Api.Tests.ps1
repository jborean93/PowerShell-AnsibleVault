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

        It 'fail when parameter count mismatch' {
            { Invoke-Win32Api -DllName a.dll -MethodName a -ReturnType bool -ParameterTypes @([int]) -Parameters @() } | Should -Throw "ParameterType Count 1 not equal to Parameter Count 0"
        }

        It 'invoke API that returns a handle' {
            $test_file_path = "$PSScriptRoot\Resources\test-deleteme.txt"
            if (-not (Test-Path -Path $test_file_path)) {
                New-Item -Path $test_file_path -ItemType File > $null
            }
            Set-Content -Path $test_file_path -Value "abc"

            try {
                $handle = Invoke-Win32Api -DllName kernel32.dll `
                    -MethodName CreateFileW `
                    -ReturnType Microsoft.Win32.SafeHandles.SafeFileHandle `
                    -ParameterTypes @([String], [System.Security.AccessControl.FileSystemRights], [System.IO.FileShare], [IntPtr], [System.IO.FileMode], [UInt32], [IntPtr]) `
                    -Parameters @(
                        "\\?\$test_file_path",
                        [System.Security.AccessControl.FileSystemRights]::Read,
                        [System.IO.FileShare]::ReadWrite,
                        [IntPtr]::Zero,
                        [System.IO.FileMode]::Open,
                        0,
                        [IntPtr]::Zero) `
                    -SetLastError $true `
                    -CharSet Unicode

                if ($handle.IsInvalid) {
                    $last_err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                    throw [System.ComponentModel.Win32Exception]$last_err
                }
                $fs = New-Object -TypeName System.IO.FileStream -ArgumentList $handle, ([System.IO.FileAccess]::Read)
                $sr = New-Object -TypeName System.IO.StreamReader -ArgumentList $fs
                $actual = $sr.ReadToEnd()
                $sr.Close()

                $actual | Should -Be "abc`r`n"
            } finally {
                Remove-Item -Path $test_file_path -Force > $null
            }
        }

        It 'invoke API with output strings' {
            $sid_string = "S-1-5-18"
            $sid = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $sid_string
            $sid_bytes = New-Object -TypeName byte[] -ArgumentList $sid.BinaryLength
            $sid.GetBinaryForm($sid_bytes, 0)

            $name = New-Object -TypeName System.Text.StringBuilder
            $name_length = 0
            $domain_name = New-Object -TypeName System.Text.StringBuilder
            $domain_name_length = 0

            $invoke_args = @{
                DllName = "Advapi32.dll"
                MethodName = "LookupAccountSidW"
                ReturnType = [bool]
                ParameterTypes = @([String], [byte[]], [System.Text.StringBuilder], [Ref], [System.Text.StringBuilder], [Ref], [Ref])
                Parameters = @(
                    $null,
                    $sid_bytes,
                    $name,
                    [Ref]$name_length,
                    $domain_name,
                    [Ref]$domain_name_length,
                    [Ref][IntPtr]::Zero
                )
                SetLastError = $true
                CharSet = "Unicode"
            }

            $res = Invoke-Win32Api @invoke_args
            $name.EnsureCapacity($name_length)
            $domain_name.EnsureCapacity($domain_name_length)
            $res = Invoke-Win32Api @invoke_args
            if (-not $res) {
                $last_err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                throw [System.ComponentModel.Win32Exception]$last_err
            }
            $name.ToString() | Should -Be "SYSTEM"
            $domain_name.ToString() | Should -Be "NT AUTHORITY"
        }
    }
}