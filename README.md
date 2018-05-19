# PowerShell-AnsibleVault

[![Build status](https://ci.appveyor.com/api/projects/status/1jf9wurhryafa47o?svg=true)](https://ci.appveyor.com/project/jborean93/powershell-ansiblevault)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/AnsibleVault.svg)](https://www.powershellgallery.com/packages/AnsibleVault)

PowerShell module that allows you to encrypt and decrypt Ansible Vault files
natively in Windows.

## Info

This PowerShell module contains 2 PowerShell cmdlets that are used to encrypt
and decrypt and Ansible Vault files without having Ansible installed. The two
cmdlets that are added are

* `Get-DecryptedAnsibleVault`
* `Get-EncryptedAnsibleVault`

### Get-DecryptedAnsibleVault

Decrypt an Ansible Vault string and return the plaintext.

#### Syntax

```
# By Value/String
Get-DecryptedAnsibleVault
    -Value <String>
    -Password <SecureString>
    [[-Encoding] <System.Text.Encoding>]

# From path
Get-DecryptedAnsibleVault
    -Path <String>
    -Password <SecureString>
    [[-Encoding] <System.Text.Encoding>]

# With pipeline input
"`$ANSIBLE_VAULT;1.1;AES256;`n00010203040506070809" | Get-DecryptedAnsibleVault
    -Password <SecureString>
    [[-Encoding] <System.Text.Encoding>]
```

#### Parameters

* `Value`: <String> The Ansible Vault text as a string to decrypt, this is mutually exclusive to the `Path` parameter
* `Path`: <String> The path to a vault file whose contents will be decrypted, this is mutually exclusive to the `Value` parameter
* `Password`: <SecureString> The password to use when decrypting the contents

#### Optional Parameters

* `Encoding`: <System.Text.Encoding> The string encoding of the decrypted bytes. By default will be `UTF8` but if the original plaintext was encrypted with a different encoding type, this can override the output to what is needed

#### Input

* `<String>`: A string can be passed as a pipeline input as the `Value` parameter

#### Output

* `<String>`: The decrypted vault contents as a string

### Get-EncryptedAnsibleVault

Create an encrypted string that is compatible with Ansible Vault.

#### Syntax

```
# By Value/String
Get-EncryptedAnsibleVault
    -Value <String>
    -Password <SecureString>
    [[-Id] <String>]

# From Path
Get-EncryptedAnsibleVault
    -Path <String>
    -Password <SecureString>
    [[-Id] <String>]

# With pipeline input
"plaintext" | Get-EncryptedAnsibleVault
    -Password <SecureString>
    [[-Id] <String>]
```

#### Parameters

* `Value`: <String> The string to encrypt, this is mutually exclusive to the `Path` parameter
* `Path`: <String> The path to a file whose contents will be encrypted, this is mutually exclusive to the `Value` parameter
* `Password`: <SecureString> The password to use when encrypting the contents

#### Optional Parameters

* `Id`: <String> If specified, the vault will be encrypted and this ID will be set in the header

#### Input

* `<String>`: A string can be passed as a pipeling input as the `Value` parameter

#### Output

* `<String>`: The encrypted vault contents as a string


## Requirements

These cmdlets have the following requirements

* PowerShell v3.0 or newer
* Windows PowerShell (not PowerShell Core)
* Windows Server 2008 R2/Windows 7 or newer


## Installing

TODO: fill out this information, once uploaded to the PowerShell gallery


## Examples

Here are some examples that imitate the existing `ansible-vault` commands;

```
# store the password as a secure string
$password = Read-Host -Prompt "Enter the vault password" -AsSecureString

# ansible-vault encrypt
Get-EncryptedAnsibleVault -Path vault.yml -Password $password | Set-Content -Path vault.yml

# ansible-vault encrypt_string --stdin-name 'vault_variable'
$vault_text = Read-Host -Prompt "Enter string to encrypt" | Get-EncryptedAnsibleVault -Password $password
Write-Output -InputObject "vault_variable: !vault |`n        $($vault_text.Replace("`n", "`n        "))"

# ansible-vault decrypt
Get-DecryptedAnsibleVault -Path vault.yml -Password $password | Set-Content -Path vault.yml

# ansible-vault view
Get-DecryptedAnsibleVault -Path vault.yml -Password $password

# ansible-vault rekey
$old_pass = Read-Host -Prompt "Enter the original vault password" -AsSecureString
$new_pass = Read-Host -Prompt "Enter the new vault password" -AsSecureString

Get-DecryptedAnsibleVault -Path vault.yml -Password $old_pass | Get-EncryptedAnsibleVault -Password $new_pass | Set-Content -Path vault.yml

# ansible-vault encrypt --vault-id dev@prompt
Get-EncryptedAnsibleVault -Value "some secret" -Id dev -Password (Read-Host -Prompt "Enter the password" -AsSecureString)
```

You are not limited to the above, you can store the outputs in variables and
call these cmdlets in whatever way.

## Contributing

Contributing is quite easy, fork this repo and submit a pull request with the
changes. To test out your changes locally you can just run `.\build.ps1` in
PowerShell. This script will ensure all dependencies are installed before
running the test suite.

_Note: this requires PowerShellGet or WMF 5 to be installed_


## Backlog

* See if it is possible to integrate with vim or some other cli editor if it is installed (`ansible-vault create/edit`)
* Look at using [Rfc2898DeriveBytes](https://msdn.microsoft.com/en-us/library/system.security.cryptography.rfc2898derivebytes(v=vs.110).aspx) if it is available on the host to add support for PowerShell Core
