Set-StrictMode -Version Latest

# Point de terminaison documente dans l'article (version beta de Microsoft Graph).
$script:UsageUri = "https://graph.microsoft.com/beta/reports/getMicrosoft365CopilotUsageUserDetail(period='D30')"

function Get-CopilotModelAudience {
    <#
    .SYNOPSIS
        Liste les utilisateurs ayant une activite Microsoft Copilot sur les 30 derniers jours.

    .DESCRIPTION
        Telecharge le rapport getMicrosoft365CopilotUsageUserDetail(period='D30') de Microsoft Graph
        dans un fichier CSV puis renvoie chaque ligne sous forme d'objet PowerShell. Chaque ligne
        correspond a un utilisateur licencie avec ses dernieres dates d'activite Copilot.
        Les colonnes sont renvoyees telles que fournies par Microsoft Graph.

        La fonction est en lecture seule : elle ne modifie aucune configuration du locataire.
        Les seuls fichiers ecrits sont le CSV et, sur demande, un rapport HTML local.

        Le point de terminaison est en version beta au 3 novembre 2026 : son format peut changer.

    .PARAMETER OutputFolder
        Dossier existant ou enregistrer le CSV et le rapport HTML. Par defaut, le dossier
        temporaire de l'utilisateur.

    .PARAMETER SkipConnect
        N'appelle pas Connect-MgGraph. A utiliser quand une session Microsoft Graph avec la
        permission Reports.Read.All est deja ouverte.

    .PARAMETER HtmlReport
        Produit aussi un rapport HTML simple a cote du CSV, avec le meme nom de base.

    .EXAMPLE
        Get-CopilotModelAudience -InformationAction Continue

        Se connecte a Microsoft Graph avec Reports.Read.All, telecharge le rapport des 30 derniers
        jours et renvoie les lignes.

    .EXAMPLE
        Get-CopilotModelAudience -OutputFolder 'C:\Rapports' -HtmlReport

        Enregistre le CSV et un rapport HTML dans C:\Rapports.

    .EXAMPLE
        Connect-MgGraph -Scopes 'Reports.Read.All' -NoWelcome
        Get-CopilotModelAudience -SkipConnect | Select-Object -First 10 | Format-Table -AutoSize

        Reutilise une session existante et affiche les 10 premieres lignes.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Module requis : Microsoft.Graph (Connect-MgGraph et Invoke-MgGraphRequest).
        Permission minimale : Reports.Read.All (role Lecteur de rapports ou equivalent).
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFolder = [System.IO.Path]::GetTempPath(),

        [Parameter()]
        [switch]$SkipConnect,

        [Parameter()]
        [switch]$HtmlReport
    )

    if (-not (Get-Command -Name 'Invoke-MgGraphRequest' -ErrorAction SilentlyContinue)) {
        throw 'Le module Microsoft.Graph est introuvable. Installez-le avec : Install-Module Microsoft.Graph -Scope CurrentUser'
    }

    if (-not (Test-Path -Path $OutputFolder -PathType Container)) {
        throw "Le dossier de sortie est introuvable : $OutputFolder"
    }

    if (-not $SkipConnect) {
        Write-Verbose 'Connexion a Microsoft Graph avec la permission Reports.Read.All.'
        Connect-MgGraph -Scopes 'Reports.Read.All' -NoWelcome -ErrorAction Stop
    }

    $horodatage = Get-Date -Format 'yyyyMMdd-HHmmss'
    $csvPath = Join-Path -Path $OutputFolder -ChildPath "copilot-usage-D30-$horodatage.csv"

    Write-Verbose "Lecture du rapport : $script:UsageUri"
    Invoke-MgGraphRequest -Method GET -Uri $script:UsageUri -OutputFilePath $csvPath -ErrorAction Stop
    Write-Information -MessageData "Rapport CSV enregistre : $csvPath"

    $lignes = @(Import-Csv -Path $csvPath)
    Write-Information -MessageData "Lignes dans le rapport : $($lignes.Count)"

    if ($HtmlReport) {
        $htmlPath = [System.IO.Path]::ChangeExtension($csvPath, '.html')
        $genereLe = Get-Date -Format 'yyyy-MM-dd HH:mm'
        $head = '<meta charset="utf-8"><title>Activite Microsoft Copilot (D30)</title>' +
            '<style>body{font-family:Segoe UI,Arial,sans-serif;margin:24px}' +
            'table{border-collapse:collapse}th,td{border:1px solid #ccc;padding:4px 8px;font-size:13px}' +
            'th{background:#f0f0f0}</style>'
        $intro = '<h1>Activite Microsoft Copilot sur 30 jours</h1>' +
            "<p>Genere le $genereLe. Lignes : $($lignes.Count).</p>" +
            '<p>Source : point de terminaison beta de Microsoft Graph. Le format peut changer.</p>'

        $lignes | ConvertTo-Html -Head $head -PreContent $intro |
            Out-File -FilePath $htmlPath -Encoding utf8
        Write-Information -MessageData "Rapport HTML enregistre : $htmlPath"
    }

    $lignes
}

function Get-CopilotSubprocessorChecklist {
    <#
    .SYNOPSIS
        Renvoie la liste des reglages et points de vigilance documentes pour les sous-traitants IA de Copilot.

    .DESCRIPTION
        Renvoie des objets qui decrivent les reglages a verifier dans le Centre d'administration
        Microsoft 365 sous Copilot > Parametres ainsi que les points de residence et de traitement
        des donnees documentes par Microsoft. Aucune connexion n'est faite et rien n'est lu dans
        le locataire : l'etat reel doit etre verifie a la main.

        Le contenu reprend les pages Microsoft Learn verifiees autour du 6 octobre 2026.
        Ces pages changent souvent : revalidez-les le jour de votre analyse.

    .EXAMPLE
        Get-CopilotSubprocessorChecklist | Format-List

        Affiche chaque point de verification avec sa source.

    .EXAMPLE
        Get-CopilotSubprocessorChecklist | Export-Csv -Path .\checklist.csv -NoTypeInformation

        Exporte la liste pour la joindre a une note de decision.

    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param()

    $urlSousTraitants = 'https://learn.microsoft.com/fr-fr/microsoft-365/copilot/connect-to-ai-subprocessor'
    $urlResidence = 'https://learn.microsoft.com/fr-fr/microsoft-365/enterprise/m365-dr-service-copilot-offerings'
    $urlConfidentialite = 'https://learn.microsoft.com/fr-fr/copilot/microsoft-365/microsoft-365-copilot-privacy'
    $emplacement = "Centre d'administration Microsoft 365 > Copilot > Parametres"
    $roles = 'AI Administrator ou Global Administrator'
    $verifieLe = '2026-10-06'

    [pscustomobject]@{
        Reglage                = 'AI providers operating as Microsoft subprocessors'
        Emplacement            = $emplacement
        EtatParDefautDocumente = 'Modeles Anthropic actives par defaut pour la plupart des clients du cloud commercial (hors UE/AELE et Royaume-Uni)'
        RoleRequis             = $roles
        Recommandation         = "Verifier l'etat reel dans le locataire et documenter la decision."
        Source                 = $urlSousTraitants
        VerifieLe              = $verifieLe
    }

    [pscustomobject]@{
        Reglage                = 'Anthropic models with Data Retention'
        Emplacement            = $emplacement
        EtatParDefautDocumente = 'Desactive par defaut'
        RoleRequis             = $roles
        Recommandation         = "Laisser desactive : non couvert par les Product Terms ni par le DPA. Anthropic peut conserver les donnees jusqu'a 30 jours."
        Source                 = $urlSousTraitants
        VerifieLe              = $verifieLe
    }

    [pscustomobject]@{
        Reglage                = 'Traitement des requetes envoyees aux modeles Anthropic'
        Emplacement            = 'Aucun reglage : point a documenter'
        EtatParDefautDocumente = "Exclus de la frontiere des donnees de l'UE et, le cas echeant, des engagements de traitement dans le pays"
        RoleRequis             = 'Sans objet'
        Recommandation         = "Documenter ce point avant d'utiliser Copilot sur des renseignements personnels sensibles."
        Source                 = $urlSousTraitants
        VerifieLe              = $verifieLe
    }

    [pscustomobject]@{
        Reglage                = 'Stockage au repos et traitement du contenu Copilot (locataire inscrit au Canada)'
        Emplacement            = 'Aucun reglage : point a documenter'
        EtatParDefautDocumente = "Contenu des interactions et index semantique stockes au repos dans la geographie locale. Les clients hors UE peuvent voir leurs requetes traitees aux Etats-Unis, dans l'UE ou dans d'autres regions."
        RoleRequis             = 'Sans objet'
        Recommandation         = 'Ne pas confondre stockage au repos et lieu de traitement dans la documentation de conformite.'
        Source                 = "$urlResidence ; $urlConfidentialite"
        VerifieLe              = $verifieLe
    }
}

Export-ModuleMember -Function 'Get-CopilotModelAudience', 'Get-CopilotSubprocessorChecklist'
