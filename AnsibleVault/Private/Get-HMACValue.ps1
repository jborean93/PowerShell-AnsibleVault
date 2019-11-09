# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-HMACValue {
    <#
    .SYNOPSIS
    Generates the HMAC hex string of a byte array.

    .DESCRIPTION
    Generates the HMAC hex string of a byte array using the SHA256 algorithm
    and the Key specified.

    .PARAMETER Value
    [byte[]] The byte array to compute the hash from.

    .PARAMETER Key
    [byte[]] The key to use as part of the HMAC function.

    .OUTPUTS
    [String] The hex string of the HMAC output.

    .EXAMPLE
    Get-HMACValue -Value $bytes -Key $key

    .NOTES
    This is locked in to use the SHA256 algorithm, in the future this may
    change and be configurable but right now Ansible Vault only uses this.
    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory=$true)] [byte[]]$Value,
        [Parameter(Mandatory=$true)] [byte[]]$Key
    )
    $hmac_sha256 = New-Object -TypeName System.Security.Cryptography.HMACSHA256 -ArgumentList @(,$Key)
    $actual_hmac = $hmac_sha256.ComputeHash($Value)
    $actual_hmac_hex = Convert-ByteToHex -Value $actual_hmac

    return $actual_hmac_hex
}