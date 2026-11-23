@{
    RootModule        = 'CopilotModelAudienceReport.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '7d3c2a9e-4b6f-4f1a-9c58-2e0b6a1d8f43'
    Author            = 'Charles Jenkins'
    Copyright         = '(c) 2026 Charles Jenkins. Licence MIT.'
    Description       = 'Lecture seule : liste les utilisateurs actifs dans Microsoft Copilot sur 30 jours et rappelle les reglages des sous-traitants IA a verifier.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-CopilotModelAudience'
        'Get-CopilotSubprocessorChecklist'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('Copilot', 'MicrosoftGraph', 'Microsoft365', 'Reports', 'Governance')
            ReleaseNotes = 'Version 1.0.0 : version initiale.'
        }
    }
}
