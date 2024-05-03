
function PoserQuestionOuiNon {
    param([string]$message)

    # Boucle jusqu'à obtenir une réponse valide
    do {
        $reponse = Read-Host "$message (o/n)"
        $reponse = $reponse.ToLower().Trim()

        # Vérifier si la réponse est valide
        if ([string]::IsNullOrEmpty($reponse)) {
            Write-Host "Veuillez saisir une réponse."
        } elseif ($reponse -eq "o" -or $reponse -eq "n") {
            return $reponse
        } else {
            Write-Host "Réponse invalide. Veuillez répondre 'o' pour Oui ou 'n' pour Non."
        }
    } until ($true)
}

function PoserQuestion {
    param([string]$message)
    Write-Host $message -NoNewline
}


