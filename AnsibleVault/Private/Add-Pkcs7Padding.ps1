# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Add-Pkcs7Padding {
    <#
    .SYNOPSIS
    Add padding to the byte array based on the PKCS7 padding spec.

    .DESCRIPTION
    Will add PKCS7 padding to a byte array. This will always add the padding
    even if it has already been padded as there is no real way to determine
    if the padding has already been applied.

    .PARAMETER Value
    [byte[]] The bytes to add the padding to.

    .PARAMETER BlockSize
    [int] The size of the block in bits.

    .OUTPUTS
    [byte[]] The input bytes after being padded to the BlockSize.

    .EXAMPLE
    Add-Pkcs7Padding -Value @([byte]1, [byte]2) -BlockSize 128

    .NOTES
    Usually this is done as part of a crypto provider but because we use
    Invoke-AESCTRCycle (AES in CTR mode/stream cipher) we need to manually
    pad the bytes as this is done in the Ansible Vault implementation.
    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory=$true)] [byte[]]$Value,
        [Parameter(Mandatory=$true)] [int]$BlockSize
    )
    $block_size_bytes = $BlockSize / 8
    $padding_length = $block_size_bytes - ($Value.Length % $block_size_bytes)

    if ($padding_length -eq 0) {
        $padding_length = $block_size_bytes
    }

    $padded_bytes = New-Object -TypeName byte[] -ArgumentList ($Value.Length + $padding_length)
    $Value.CopyTo($padded_bytes, 0)
    for ($i = $Value.Length; $i -lt $padded_bytes.Length; $i++) {
        $padded_bytes[$i] = [byte]$padding_length
    }
    return $padded_bytes
}