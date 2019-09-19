# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function New-VaultKey {
    <#
    .SYNOPSIS
    Generates the various keys required for vault encryption/decryption.

    .DESCRIPTION
    Generates the Cipher, HMAC, and AES CTR Nonce used as part of the Vault
    operations.

    .PARAMETER Password
    [SecureString] The password used to derive the key.

    .PARAMETER Salt
    [byte[]] The salt used to derive the key.

    .OUTPUTS
    [byte[]] The key used in the AES cipher.

    [byte[]] The used as part of the HMAC calculation.

    [byte[]] The nonce/counter used in the AES CTR cipher.

    .EXAMPLE
    $salt = New-Object -TypeName byte[] -ArgumentList 32
    $random_gen = New-Object -TypeName System.Security.Cryptography.RNGCryptoServiceProvider
    $random_gen.GetBytes($salt)
    New-VaultKeys -Password $sec_string -Salt $salt

    .NOTES
    On decryption, the salt is stored in the cipher bytes whiile the salt must
    be randomly generated when creating a vault.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Does not adjust system state, creates a new key that is in memory")]
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(Mandatory=$true)] [SecureString]$Password,
        [Parameter(Mandatory=$true)] [byte[]]$Salt
    )
    $derived_key = New-PBKDF2Key -Algorithm SHA256 -Password $password -Salt $Salt -Length 80 -Iterations 10000
    $cipher_key = $derived_key[0..31]
    $hmac_key = $derived_key[32..63]
    $nonce = $derived_key[64..79]

    return $cipher_key, $hmac_key, $nonce
}