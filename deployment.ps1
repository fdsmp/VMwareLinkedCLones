# Récupération des varaibles
Invoke-Expression -Command (Get-Content "vars" | Out-String)

# Appele des fonctions depuis le fichier fonctions.ps1
. ".\fonctions.ps1"

Clear-Host
# Saisie du nom du serveur vcenter
PoserQuestion "Entrez le nom de votre serveur vCenter: "
$SourceVcenter = Read-Host

# Connexion à vcenter
Write-Host ""
Write-Host -ForegroundColor Cyan "Connexion au serveur $SourceVcenter"
#Write-Host ""

Connect-VIServer -Server $SourceVcenter 

Clear-Host

############ Vérification de l'existence des objets

# Vérification de l'existence de la VM source
$sourceVM = Get-VM -Name $sourceVMName
if ($sourceVM -eq $null) {
    Write-Host ""
    Write-Host "La machine virtuelle source '$sourceVMName' n'existe pas." -ForegroundColor Red
    Write-Host ""
    Disconnect-VIServer -Confirm:$false # Déconnexion de vCenter en cas d'erreur
    exit
}


# Vérification de l'existence du datastore
$datastore = Get-Datastore -Name $datastoreName
if ($datastore -eq $null) {
    Write-Host ""
    Write-Host "Le datastore '$datastoreName' n'existe pas." -ForegroundColor Red
    Write-Host ""
    Disconnect-VIServer -Confirm:$false
    exit
}

# Vérification de l'unicité du pool de ressources
$resourcePool = Get-ResourcePool -Name $resourcePoolName
if ($resourcePool -eq $null) {
    Write-Host ""
    Write-Host "Erreur : Assurez-vous que le pool de ressource '$resourcePoolName' existe et qu'il est unique au sein du cluster." -ForegroundColor Red
    Write-Host ""
    Disconnect-VIServer -Confirm:$false
    exit
}

# Vérification de l'unicité du dossier
$folder = Get-Folder -Name $folderName
if ($folder -eq $null) {
    Write-Host ""
    Write-Host "Erreur : Assurez-vous que le dossier '$folderName' existe et qu'il est unique au sein du cluster." -ForegroundColor Red
    Write-Host ""
    Disconnect-VIServer -Confirm:$false
    exit
}

# Résumé avant déploiement
Write-Host ""
Write-Host -ForegroundColor Cyan "<< CONFIGURATION DU DEPLOIEMENT >>"
$configurationTable = @{
    "VM Source" = $sourceVMName
    "Quantité de clones" = $numberOfClones
    "Nom de base des clones" = $cloneBaseName
    "Dossier de destination" = $folderName
    "Pool de destination" = $resourcePoolName
}
$configurationTable.GetEnumerator() | Format-Table -AutoSize

do {
    $reponse = Read-Host "La configuration est-elle correcte? (O/N)"
} while ($reponse -notin @("O", "N"))

if ($reponse -eq "N") {
    Disconnect-VIServer -Confirm:$false
    exit
} 

## Création d'un snapshot pour le déploiement de clones liés
$snapshotName = "Deployment Snapshot"

Write-Host ""
Write-Host -ForegroundColor Cyan "<< CREATION D'UN SNAPSHOTS >>"
Write-Host ""

# Récup des snapshots de la VM source
$snapshots = Get-Snapshot -VM $sourceVM

# Vérif si un snapshot nommé Deployment Snapshot existe déjà
if ($snapshots.Name -eq $snapshotName){
    Write-Host -ForegroundColor Red "Un snapshot nommé 'Deployment Snapshot' existe déjà."
    Write-Host -ForegroundColor Red "Vous devez le supprimer ou le renommer, puis relancer le script."
    Write-Host ""
    exit
}
# Vérifier et affichage s'il y a d'autres snapshots (non bloquant)
if ($snapshots.Count -gt 0) {
    Write-Host "La VM '$sourceVMName' possède déjà un ou plusieurs snapshots :"
    $snapshots | Format-Table -Property Name, Description, Created, SizeMB

    do {
        $reponse = Read-Host "Voulez-vous tout de même poursuivre le déploiement? (O/N)"
    } while ($reponse -notin @("O", "N"))

    if ($reponse -eq "N") {
        exit
    }
}

########### Ojbets valides, début déploiement

# Création du snapshot
New-Snapshot -VM $sourceVM -Name $snapshotName -Description "Snapshot for linked cloning" -Memory:$false -Quiesce:$true     

########### Déploiement des clones
for ($i = 1; $i -le $numberOfClones; $i++) {
    # Formater le numéro de séquence avec deux chiffres
    $sequenceNumber = $i.ToString().PadLeft(2, '0')
    
    # Créer le nom du clone avec le numéro de séquence formaté
    $cloneName = "$cloneBaseName-$sequenceNumber"
    
    # Créer le clone
    New-VM -VM $sourceVM -Name $cloneName -LinkedClone -ReferenceSnapshot $snapshotName -Datastore $datastore -Location $folder -ResourcePool $resourcePool
}
########### FIN de déploiement

# Message de fin de déploiment
$vmlist = Get-VM -Name $cloneBaseName* -Location $folderName

Write-Host ""
Write-Host -ForegroundColor Green "-- DEPLOIEMENT TERMINE --"
Write-Host ""

# Affichage de la liste des clones déployés
$vmlist | Format-Table -Property Name, PowerState

# Déconnexion de vcenter
Disconnect-VIServer -Confirm:$false 