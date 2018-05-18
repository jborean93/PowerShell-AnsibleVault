# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

# get public and private function definition files.
$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# dot source the files
foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $public.Basename
