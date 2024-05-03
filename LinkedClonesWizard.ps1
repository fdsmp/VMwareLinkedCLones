################################################################
# Script de déploiement de clones liés en env VMware vSphere   #
# Auteur: Philippe PEREIRA                                     #
# Date: 03/05/2024                                             #
################################################################

##### Affichage d'une bannière de bienv

Write-Host " ______  _                                            _ " -ForegroundColor Green
Write-Host "(____  \(_)                                          | |" -ForegroundColor Green
Write-Host " ____)  )_  ____ ____ _   _ ____ ____  _   _  ____   | |" -ForegroundColor Green
Write-Host "|  __  (| |/ _  )  _ \ | | / _  )  _ \| | | |/ _  )  |_|" -ForegroundColor Green
Write-Host "| |__)  ) ( (/ /| | | \ V ( (/ /| | | | |_| ( (/ /    _ " -ForegroundColor Green
Write-Host "|______/|_|\____)_| |_|\_/ \____)_| |_|\____|\____)  |_|" -ForegroundColor Green
Write-Host "                                                         " -ForegroundColor Green

# Afficher un message d'accueil centré en vert gras
Write-Host "Script de déploiement de clones liés VMware." -ForegroundColor Green
Write-Host "Auteur: Philippe PEREIRA" -ForegroundColor Green
Write-Host ""
Write-Host "--- Configuration du déploiement ---" -ForegroundColor Yellow
Write-Host ""

# Appele des fonctions depuis le fichier fonctions.ps1
. ".\fonctions.ps1"

# Demander à l'utilisateur de saisir les valeurs pour les variables
PoserQuestion "Entrez le nom de la machine virtuelle source: "
$sourceVMName = Read-Host
PoserQuestion "Entrez le nom du pool de ressources: "
$resourcePoolName = Read-Host
PoserQuestion "Entrez le nom du datastore: "
$datastoreName = Read-Host
PoserQuestion "Entrez le nom du dossier: "
$folderName = Read-Host
PoserQuestion "Entrez le nom de base du clone: "
$cloneBaseName = Read-Host
# Vérifier que la saisie est bien un entier
do {
    PoserQuestion "Entrez le nombre de clones à créer: "
    $input = Read-Host
    if (-not $input -match '^\d+$') {
        Write-Host "Erreur : Veuillez saisir un nombre entier valide."
    }
} until ($input -match '^\d+$')

$numberOfClones = [int]$input
# Définir le chemin du fichier de sortie
$fichierSortie = "vars"

# Créer ou écraser le fichier de sortie avec les valeurs des variables
@"
`$SourceVMName = "$sourceVMName"
`$ResourcePoolName = "$resourcePoolName"
`$DatastoreName = "$datastoreName"
`$FolderName = "$folderName"
`$CloneBaseName = "$cloneBaseName"
`$NumberOfClones = "$numberOfClones"
"@ | Out-File -FilePath $fichierSortie -Encoding utf8

# Write-Host "Les valeurs des variables ont été écrites dans le fichier $fichierSortie."

# Récap de la saisie
Write-Host ""
Write-Host "Voici les paramètres de déploiement que vous avez saisis:" -ForegroundColor Green
Write-Host ""
Write-Host "* Template ................................" $sourceVMName
Write-Host "* Pool de ressources de destination ......." $resourcePoolName
Write-Host "* Datastore de destination ................" $datastoreName
Write-Host "* Dossier de destination .................." $folderName
Write-Host "* Nom de base des clones .................." $cloneBaseName
Write-Host "* Quantité de clones sohaitée ............." $numberOfClones
Write-Host ""

# Utilisation de la fonction pour poser la question et obtenir une réponse valide
$reponseUtilisateur = PoserQuestionOuiNon "Voulez-vous poursuivre le déploiement ?"
if ($reponseUtilisateur -eq "o") {
    .\deployment.ps1
} else {
    Write-Host ""
    Write-Host "Les données que vous avez fournies ont été enregistrées dans le fichier 'vars'." -ForegroundColor Yellow
    Write-Host ""
}
