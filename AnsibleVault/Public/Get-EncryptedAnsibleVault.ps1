# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-EncryptedAnsibleVault {
    <#
    .SYNOPSIS
    Create an encrypted string the is compatible with Ansible Vault.

    .DESCRIPTION
    This cmdlet will take in a string or path to a file to encrypt and then
    return the encrypted Ansible Vault text.

    .PARAMETER Path
    [String] The path to a file whose contents will be encrypted. This is
    mutually exclusive to the Value parameter.

    .PARAMETER Value
    [String] The string value to encrypt. This is mutually exclusive to the
    Path parameter.

    .PARAMETER Password
    [SecureString] The password used to encrypt the value with

    .PARAMETER Id
    [String] The ID to specify for the created vault. If not specified then no
    ID will be applied. This is only supported in Ansible since the 2.4
    version.

    .INPUTS
    [String] You can pipe a string to encrypt to this cmdlet.

    .OUTPUTS
    [String] The encrypted vault string.

    .EXAMPLE
    # Create the secure string that stores the vault password
    $password = Read-Host -AsSecureString

    # create a vault string from a file
    Get-EncryptedAnsibleVault -Path C:\temp\vault.txt -Password $password

    # create a vault string from a string
    Get-EncryptedAnsibleVault -Value "variable: abc`nvariable2: def" -Password $password

    # send the string to encrypt as a pipeline input
    "variable: abc`nvariable2: def" | Get-EncryptedAnsibleVault -Password $password

    # create a vault string with a specific ID
    Get-EncryptedAnsibleVault -Value "variable: abc`nvariable2: def" -Password $password -Id Prod

    .NOTES
    This only supports the vault versions 1.1 and 1.2. These version are mostly
    identical but 1.2 is used when the Id parameter is specified. This should
    be interoperable with the ansible-vault code used by Ansible itself.
    #>
    [CmdletBinding(DefaultParameterSetName="ByPath")]
    [OutputType([String])]
    param(
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="ByPath")] [String]$Path,
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="ByValue", ValueFromPipeline, ValueFromPipelineByPropertyName)] [String]$Value,
        [Parameter(Position=1, Mandatory=$true)] [SecureString]$Password,
        [Parameter()] [String]$Id
    )

    $bytes_to_encrypt = switch($PSCmdlet.ParameterSetName) {
        ByPath {
            $pwd_path = Join-Path -Path $pwd -ChildPath $Path
            if (Test-Path -Path $pwd_path -PathType Leaf) {
                [System.IO.File]::ReadAllBytes($pwd_path)
            } else {
                [System.IO.File]::ReadAllBytes($Path)
            }
        }
        ByValue { [System.Text.Encoding]::UTF8.GetBytes($Value) }
    }
    if ($null -eq $bytes_to_encrypt) {
        throw [System.ArgumentException]"Failed to get bytes for vault to encrypt"
    }

    # Generate a secure random salt value
    $salt = New-Object -TypeName byte[] -ArgumentList 32
    $random_gen = New-Object -TypeName System.Security.Cryptography.RNGCryptoServiceProvider
    $random_gen.GetBytes($salt)

    $cipher_key, $hmac_key, $nonce = New-VaultKey -Password $Password -Salt $salt

    # While AES CTR is a stream mode, Ansible still pads the bytes we we need
    # to do that here
    $padded_bytes = Add-Pkcs7Padding -Value $bytes_to_encrypt -BlockSize 128
    $encrypted_bytes = Invoke-AESCTRCycle -Value $padded_bytes -Key $cipher_key -Nonce $nonce
    $actual_hmac = Get-HMACValue -Value $encrypted_bytes -Key $hmac_key

    $cipher_text = @((Convert-ByteToHex -Value $salt), $actual_hmac, (Convert-ByteToHex -Value $encrypted_bytes)) -join "`n"

    # Yes the vault cipher text is hexlified twice when it shouldn't be
    # necessary
    $cipher_text = Convert-ByteToHex -Value ([System.Text.Encoding]::UTF8.GetBytes($cipher_text))

    # now we need to add a newline every 80 chars
    $cipher_text = $cipher_text -replace ".{80}", "$&`n"

    # Finally build the header and cipher text and return the string
    $version = "1.1"
    $id_suffix = ""
    if ($Id) {
        $version = "1.2"
        $id_suffix = ";$Id"
    }
    $header = "`$ANSIBLE_VAULT;$version;AES256$id_suffix"
    $vault_string = "$header`n$cipher_text"

    return $vault_string
}
