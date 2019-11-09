# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Get-VaultHeader {
    <#
    .SYNOPSIS
    Parses the vault text and get's the header information.

    .DESCRIPTION
    Takes in the full vault string and returns the header information as well
    as the byte array of the encrypted bytes.

    .PARAMETER Value
    [String] The Ansible vault contents as a string.

    .OUTPUTS
    [Version] The version of the vault.

    [String] The string identifying the cipher type.

    [String] The ID of the vault.

    [byte[]] The byte array of the encrypted vault contents.

    .EXAMPLE
    Get-VaultHeader -Value $vault_text

    .NOTES
    Currently only the 1.1 and 1.2 versions of Ansible Vault is supported,
    as of writting this, they are the latest and only supported versions in
    Ansible but that may change in the future.
    #>
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [Parameter(Mandatory = $true)] [String]$Value
    )
    $vault_lines = $Value -split "[\r\n]" | Where-Object {$_}
    $header = $vault_lines[0].Trim().Split(";")

    $version = [Version]$header[1].Trim()
    if ($version -lt [Version]"1.1" -or $version -gt [Version]"1.2") {
        throw [System.NotSupportedException]"Cannot parse vault version $version, currently only 1.1 and 1.2 is supported by this tool"
    }

    $cipher = $header[2].Trim()
    $id = $null
    if ($header.Length -ge 4) {
        $id = $header[3].Trim()
    }

    $cipher_text = $vault_lines[1..($vault_lines.Length - 1)] -join ""
    $cipher_bytes = Convert-HexToByte -Value $cipher_text

    return $version, $cipher, $id, $cipher_bytes
}