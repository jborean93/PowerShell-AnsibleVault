# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Convert-HexToByte {
    <#
    .SYNOPSIS
    Converts a string of hex characters to a byte array.

    .DESCRIPTION
    Takes in a string of hex characters and returns the byte array that the
    hex represents.

    .PARAMETER Value
    [String] The hex string to convert.

    .OUTPUTS
    [byte[]] The byte array based on the converted hex string.

    .EXAMPLE
    Convert-HexToBytes -Value "48656c6c6f20576f726c64"

    .NOTES
    The hex string should have no spaces that separate each hex char.
    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory=$true)] [String]$Value
    )
    $bytes = New-Object -TypeName byte[] -ArgumentList ($Value.Length / 2)
    for ($i = 0; $i -lt $Value.Length; $i += 2) {
        $bytes[$i / 2] = [Convert]::ToByte($Value.Substring($i, 2), 16)
    }

    return [byte[]]$bytes
}