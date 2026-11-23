# CopilotModelAudienceReport

Module PowerShell en lecture seule qui répond à deux questions avant de décider quels modèles laisser actifs dans Microsoft Copilot (anciennement Microsoft 365 Copilot) :

- Qui utilise réellement Copilot dans le locataire depuis 30 jours ?
- Quels réglages des sous-traitants IA faut-il vérifier dans le Centre d'administration Microsoft 365 ?

Le module ne modifie rien dans le locataire. Il lit le rapport d'utilisation de Copilot par Microsoft Graph et produit une liste de vérification fondée sur la documentation Microsoft.

## Pourquoi maintenant

Microsoft a annoncé le 22 septembre 2026 le déploiement de Claude Opus 5.5 (Anthropic) et de GPT-6 Sol (OpenAI) dans Microsoft Copilot à travers Word, Excel, PowerPoint, Copilot Chat, Cowork et Copilot Studio. La disponibilité varie selon la licence, l'accès et la région.

Selon la page Microsoft Learn sur les sous-traitants IA (mise à jour le 18 septembre 2026), Microsoft active les modèles Anthropic par défaut pour la plupart des clients du cloud commercial, en excluant l'UE, l'AELE et le Royaume-Uni. Un locataire canadien est donc concerné par défaut. Ces modèles sont aussi exclus de la frontière des données de l'UE et, le cas échéant, des engagements de traitement dans le pays.

Savoir qui utilise déjà Copilot donne la vraie liste des personnes touchées par l'arrivée des nouveaux modèles.

## Contenu

- `Get-CopilotModelAudience` : télécharge le rapport `getMicrosoft365CopilotUsageUserDetail(period='D30')` en CSV puis renvoie chaque ligne sous forme d'objet PowerShell. Un rapport HTML simple est produit sur demande.
- `Get-CopilotSubprocessorChecklist` : renvoie, sous forme d'objets, les réglages et les points de vigilance documentés par Microsoft au sujet des sous-traitants IA. Aucune connexion n'est requise.

## Prérequis

- Windows PowerShell 5.1 ou PowerShell 7.
- Module Microsoft.Graph (cmdlets `Connect-MgGraph` et `Invoke-MgGraphRequest`).
- Permission Microsoft Graph déléguée minimale : `Reports.Read.All`.
- Rôle : Lecteur de rapports ou équivalent pour lire le rapport d'utilisation.
- Pour consulter ou modifier les réglages des sous-traitants IA dans le Centre d'administration : rôle Administrateur IA (AI Administrator) ou Administrateur général.

## Installation

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
git clone https://github.com/<votre-compte>/CopilotModelAudienceReport.git
Import-Module ./CopilotModelAudienceReport/CopilotModelAudienceReport/CopilotModelAudienceReport.psd1
```

Remplacez `<votre-compte>` par l'emplacement réel du dépôt.

## Exemples d'utilisation

Lire le rapport des 30 derniers jours et afficher les messages d'information :

```powershell
Get-CopilotModelAudience -InformationAction Continue
```

Enregistrer le CSV dans un dossier précis et produire un rapport HTML :

```powershell
Get-CopilotModelAudience -OutputFolder 'C:\Rapports' -HtmlReport -InformationAction Continue
```

Réutiliser une session Microsoft Graph déjà ouverte avec `Reports.Read.All` :

```powershell
Connect-MgGraph -Scopes 'Reports.Read.All' -NoWelcome
Get-CopilotModelAudience -SkipConnect | Select-Object -First 10 | Format-Table -AutoSize
```

Afficher la liste de vérification des sous-traitants IA :

```powershell
Get-CopilotSubprocessorChecklist | Format-List
```

## Exemple de sortie (fictif)

L'exemple ci-dessous est fictif. Il illustre seulement la forme des messages. Les colonnes du rapport d'utilisation sont celles fournies par Microsoft Graph et le module les renvoie telles quelles.

```text
Rapport CSV enregistre : C:\Rapports\copilot-usage-D30-20261103-091500.csv
Lignes dans le rapport : 42
Rapport HTML enregistre : C:\Rapports\copilot-usage-D30-20261103-091500.html
```

Extrait fictif de `Get-CopilotSubprocessorChecklist | Format-List` :

```text
Reglage                : Anthropic models with Data Retention
Emplacement            : Centre d'administration Microsoft 365 > Copilot > Parametres
EtatParDefautDocumente : Desactive par defaut
RoleRequis             : AI Administrator ou Global Administrator
Recommandation         : Laisser desactive : non couvert par les Product Terms ni par le DPA. Anthropic peut conserver les donnees jusqu'a 30 jours.
Source                 : https://learn.microsoft.com/fr-fr/microsoft-365/copilot/connect-to-ai-subprocessor
VerifieLe              : 2026-10-06
```

## Pourquoi il n'y a pas de paramètre -Apply

Le module est entièrement en lecture seule. Aucune API documentée dans les sources de l'article ne permet de lire ou de modifier le réglage « AI providers operating as Microsoft subprocessors ». Ce réglage se vérifie donc à la main dans le Centre d'administration Microsoft 365 sous Copilot > Paramètres. Les seuls fichiers écrits sont les rapports locaux CSV et HTML.

## Limites connues

- Le point de terminaison du rapport d'utilisation existe seulement dans la version beta de Microsoft Graph au 3 novembre 2026. Son format peut changer sans préavis.
- Seule la période D30 est prise en charge.
- Le module ne lit pas l'état réel des réglages des sous-traitants IA. La liste de vérification reprend la documentation Microsoft vérifiée autour du 6 octobre 2026 : revérifiez les pages Learn le jour de votre analyse.
- Le rapport ne dit pas quel modèle chaque personne a utilisé. Il indique seulement l'activité Copilot.
- Le CSV et le rapport HTML contiennent des renseignements personnels. Conservez-les dans un endroit protégé et supprimez-les quand ils ne servent plus.

## Article

Le réglage des sous-traitants IA de Copilot après l'arrivée de Claude Opus 5.5 :
https://trivium365.com/blog/claude-opus-5-5-gpt-6-sol-copilot-sous-traitants-ia/

## Sources Microsoft

- More Models, One Copilot (Microsoft Copilot Blog) : https://techcommunity.microsoft.com/blog/microsoft-copilot-blog/more-models-one-copilot/4559035
- Sous-traitants IA : https://learn.microsoft.com/fr-fr/microsoft-365/copilot/connect-to-ai-subprocessor
- Offres de résidence des données pour Copilot : https://learn.microsoft.com/fr-fr/microsoft-365/enterprise/m365-dr-service-copilot-offerings
- Confidentialité de Copilot : https://learn.microsoft.com/fr-fr/copilot/microsoft-365/microsoft-365-copilot-privacy

## Licence

MIT. Voir le fichier LICENSE.


## Démonstration en vidéo

https://www.youtube.com/watch?v=Rz59kBdfuus
