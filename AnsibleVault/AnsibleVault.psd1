# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

@{
    RootModule = 'AnsibleVault.psm1'
    ModuleVersion = '0.3.0'
    GUID = '718e9512-c750-40f3-b00e-c94b20910ecb'
    Author = 'Jordan Borean'
    Copyright = 'Copyright (c) 2018 by Jordan Borean, Red Hat, licensed under MIT.'
    Description = "Adds cmdlets that can be used to encrypt and decrypt and Ansible Vault in PowerShell.`nSee https://github.com/jborean93/PowerShell-AnsibleVault for more info"
    PowerShellVersion = '3.0'
    FunctionsToExport = @(
        'Get-DecryptedAnsibleVault',
        'Get-EncryptedAnsibleVault'
    )
    PrivateData = @{
        PSData = @{
            Tags = @(
                "Automation",
                "DevOps",
                "Windows",
                "Ansible",
                "Vault"
            )
            LicenseUri = 'https://github.com/jborean93/PowerShell-AnsibleVault/blob/master/LICENSE'
            ProjectUri = 'https://github.com/jborean93/PowerShell-AnsibleVault'
            ReleaseNotes = 'See https://github.com/jborean93/PowerShell-AnsibleVault/blob/master/CHANGELOG.md'
        }
    }
}
