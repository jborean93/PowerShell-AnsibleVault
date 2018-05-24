# Changelog for AnsibleVault

## v0.2.0 - 2018-05-25

* Support getting a vault file based on the pwd when using the `-Path` parameter
* Set the default parameter to `-Path` to better replicate the `ansible-vault` commands


## v0.1.0 - 2018-05-19

* Initial version for the `AnsibleVault` module
* Adds the `New-EncryptedAnsibleVault` cmdlet to encrypt a string to the format expected by Ansible Vault
* Adds the `Get-DecryptedAnsibleVault` cmdlet to decrypt a vaulted string to plaintext
