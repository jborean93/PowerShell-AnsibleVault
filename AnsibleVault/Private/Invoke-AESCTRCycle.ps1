# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Invoke-AESCTRCycle {
    <#
    .SYNOPSIS
    Uses AES in CTR mode to encrypt/decrypt a byte array.

    .DESCRIPTION
    Uses the AES encryption mechanism in CTR block mode to transform input
    bytes. This function can be used to encrypt and decrypt the bytes in the
    Ansible Vault with relative ease. Because AES in CTR mode is a stream
    cipher, the input bytes does not have to be the same as the AES block size.

    .PARAMETER Value
    [byte[]] The input bytes to transform.

    .PARAMETER Key
    [byte[]] The key used to increment the nonce/counter used as part of the
    byte transformation process.

    .PARAMETER Nonce
    [byte[]] The nonce/counter used to XOR the input bytes and transform it to
    the output bytes

    .OUTPUTS
    [byte[]] The encrypted/decrypted bytes after running through a cycle.

    .NOTES
    The .NET class AesCryptoServiceProvider does not have a native
    CTR mode so this must be done manually. Thanks to Hans Wolff at
    https://gist.github.com/hanswolff/8809275, I've been able to use that code
    as a reference and create a PowerShell function to do the same.
    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory=$true)] [byte[]]$Value,
        [Parameter(Mandatory=$true)] [byte[]]$Key,
        [Parameter(Mandatory=$true)] [byte[]]$Nonce
    )

    $counter_cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $counter_cipher.Mode = [System.Security.Cryptography.CipherMode]::ECB
    $counter_cipher.Padding = [System.Security.Cryptography.PaddingMode]::None
    $counter_encryptor = $counter_cipher.CreateEncryptor($Key, (New-Object -TypeName byte[] -ArgumentList($counter_cipher.BlockSize / 8)))

    $xor_mask = New-Object -TypeName System.Collections.Queue
    $output = New-Object -TypeName byte[] -ArgumentList $Value.Length
    for ($i = 0; $i -lt $Value.Length; $i++) {
        if ($xor_mask.Count -eq 0) {
            $counter_mode_block = New-Object -TypeName byte[] -ArgumentList ($counter_cipher.BlockSize / 8)
            $counter_encryptor.TransformBlock($Nonce, 0, $Nonce.Length, $counter_mode_block, 0) > $null

            for ($j = $Nonce.Length - 1; $j -ge 0; $j--) {
                $current_nonce_value = $Nonce[$j]
                if ($current_nonce_value -eq 255) {
                    $Nonce[$j] = 0
                } else {
                    $Nonce[$j] += 1
                }

                if ($Nonce[$j] -ne 0) {
                    break
                }
            }

            foreach ($counter_byte in $counter_mode_block) {
                $xor_mask.Enqueue($counter_byte)
            }
        }

        $current_mask = $xor_mask.Dequeue()
        $output[$i] = [byte]($Value[$i] -bxor $current_mask)
    }

    return [byte[]]$output
}