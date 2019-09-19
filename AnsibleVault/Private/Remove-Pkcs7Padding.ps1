# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Remove-Pkcs7Padding {
    <#
    .SYNOPSIS
    Removes PKCS7 padding on a paddded byte array.

    .DESCRIPTION
    Will remove any PKCS7 padding on a byte array. This can be run multiple
    times and the result will always be the same.

    .PARAMETER Value
    [byte[]] The bytes to add the remove from.

    .PARAMETER BlockSize
    [int] The size of the block in bits.

    .OUTPUTS
    [byte[]] The input byte array that has been unpadded.

    .EXAMPLE
    Remove-Pkcs7Padding -Bytes [byte[]]@(1, 2, 3, 5, 5, 5, 5 ,5) -BlockSize 64

    .NOTES
    Usually this is done as part of a crypto provider but because we use
    Invoke-AESCTRCycle (AES in CTR mode/stream cipher) we need to manually
    unpad the bytes as this is done in the Ansible Vault implementation.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Does not adjust system state, removes the padding in a byte array")]
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory=$true)] [byte[]]$Value,
        [Parameter(Mandatory=$true)] [int]$BlockSize
    )

    $last_byte = [int]$Value[$Value.Length - 1]
    if ($last_byte -gt ($BlockSize / 8)) {
        return $Value
    } elseif ($Value.Length -eq 1) {
        return $Value
    }

    for ($i = $Value.Length - 1; $i -ge $Value.Length - $last_byte; $i--) {
        if ([int]$Value[$i] -ne $last_byte) {
            return $Value
        }
    }

    $unpadded_size = $Value.Length - $last_byte
    $unpadded_bytes = New-Object -TypeName byte[] -ArgumentList $unpadded_size
    [System.Buffer]::BlockCopy($Value, 0, $unpadded_bytes, 0, $unpadded_size)
    return [byte[]]$unpadded_bytes
}