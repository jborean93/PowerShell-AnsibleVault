# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-DecryptedAnsibleVault {
    <#
    .SYNOPSIS
    Decrypt an Ansible Vault string and return the plaintext as a string.

    .DESCRIPTION
    This cmdlet will take in a Ansible Vault string and return the decrypted
    value.

    .PARAMETER Path
    [String] The path to a file whose contents will be decrypted. This is
    mutually exclusive to the Value parameter.

    .PARAMETER Value
    [String] The string value to decrypt. This is mutually exclusive to the
    Path parameter.

    .PARAMETER Password
    [SecureString] The password used to decrypt the value with

    .PARAMETER Encoding
    [System.Text.Encoding] The string encoding of the decrypted bytes returned
    by this cmdlet. By default will be UTF8 but if the original plaintext was
    read as a different encoding type then this can override the encoding to
    what is needed.

    .INPUTS
    [String] You can pipe the encrypted vault string to decrypt.

    .OUTPUTS
    [String] The decrypted vault string.

    .EXAMPLE
    # Create the secure string that stores the vault password
    $password = Read-Host -AsSecureString

    # get the decrypted vault string from file contents
    Get-DecryptedAnsibleVault -Path C:\temp\vault.txt -Password $password

    # create a vault string from a string
    Get-DecryptedAnsibleVault -Value $vault_text -Password $password

    # send the string to encrypt as a pipeline input
    $vault_Text | Get-DecryptedAnsibleVault -Password $password

    # decrypt vault that had the original plaintext encoded as UTF-16
    Get-DecryptedAnsibleVault -Value $vault_text -Password $password -Encoding ([System.Text.Encoding]::Unicode)

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
        [Parameter()] [System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8
    )

    $vault_text = switch ($PSCmdlet.ParameterSetName) {
        ByPath {
            $pwd_path = Join-Path -Path $pwd -ChildPath $Path
            if (Test-Path -Path $pwd_path -PathType Leaf) {
                [System.IO.File]::ReadAllText($pwd_path)
            } else {
                [System.IO.File]::ReadAllText($Path)
            }
        }
        ByValue { $Value }
    }

    if ($null -eq $vault_text) {
        throw [System.ArgumentException]"Failed to get vault text to decrypt"
    }
    if (-not $vault_text.StartsWith('$ANSIBLE_VAULT;')) {
        throw [System.ArgumentException]"Vault text does not start with the header `$ANSIBLE_VAULT;"
    }

    $version, $cipher, $id, $cipher_bytes = Get-VaultHeader -Value $vault_text

    # The salt, hmac and encrypted bytes value are split by \n, we need to
    # split by that char to get the actual values
    $salt, $hmac, $encrypted_bytes = Split-Byte -Value $cipher_bytes -Char ([char]"`n") -MaxSplit 2

    $salt = Convert-HexToByte -Value ([System.Text.Encoding]::UTF8.GetString($salt))
    $expected_hmac = [System.Text.Encoding]::UTF8.GetString($hmac)
    $encrypted_bytes = Convert-HexToByte -Value ([System.Text.Encoding]::UTF8.GetString($encrypted_bytes))

    $cipher_key, $hmac_key, $nonce = New-VaultKey -Password $password -Salt $salt

    $actual_hmac = Get-HMACValue -Value $encrypted_bytes -Key $hmac_key
    if ($actual_hmac -ne $expected_hmac) {
        throw [System.ArgumentException]"HMAC verification failed, was the wrong password entered?"
    }

    $decrypted_bytes = Invoke-AESCTRCycle -Value $encrypted_bytes -Key $cipher_key -Nonce $nonce

    # Need to manually remove the padding as AES CTR has no concept of padding
    # it is a stream mode
    $unpadded_bytes = Remove-Pkcs7Padding -Value $decrypted_bytes -BlockSize 128
    $decrypted_string = $Encoding.GetString($unpadded_bytes)

    return $decrypted_string
}
