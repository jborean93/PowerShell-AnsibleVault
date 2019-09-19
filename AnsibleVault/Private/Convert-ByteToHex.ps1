# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Convert-ByteToHex {
    <#
    .SYNOPSIS
    Converts a byte array to a string of hex characters.

    .DESCRIPTION
    Takes in a byte array and returns the hex string representation of each
    byte.

    .PARAMETER Value
    [byte[]] The byte array to create the hex string from.

    .RETURNS HexString
    [String] The hex string of the byte array.

    .EXAMPLE
    Convert-BytesToHex -Value [byte[]]@(72, 101, 108, 108, 111)

    .NOTES
    No special notes.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true)] [byte[]]$Value
    )
    $hex_string = New-Object -TypeName System.Text.StringBuilder -ArgumentList ($Value.Length * 2)
    foreach ($byte in $Value) {
        $hex_string.AppendFormat("{0:x2}", $byte) > $null
    }

    return $hex_string.ToString()
}