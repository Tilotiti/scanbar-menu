# scanbar-menu

Application macOS menu bar pour afficher rapidement les codes-barres Code-128 à partir du texte copié dans le presse-papier.

## Fonctionnalités

- Tourne en arrière-plan avec une icône dans la barre de menu (en haut de l'écran)
- Surveille le presse-papier en temps réel
- Détecte automatiquement les codes-barres potentiels (texte < 48 caractères)
- Affiche une fenêtre flottante sous la barre de menu avec :
  - La valeur copiée
  - L'équivalent en code-barres Code-128
- Mise à jour automatique si un nouveau code est copié alors que la fenêtre est ouverte
- Fermeture facile : bouton X ou clic en dehors de la fenêtre

## Prérequis

- macOS 13.0 ou supérieur
- Xcode 15.0 ou supérieur (pour compiler)

## Installation

1. Cloner le dépôt
2. Ouvrir `ScanBarMenu.xcodeproj` dans Xcode
3. Compiler (Cmd+B) puis lancer (Cmd+R)
4. L'icône apparaît dans la barre de menu

## Utilisation

1. Copier un texte court (moins de 48 caractères) — par exemple un code produit
2. Une fenêtre s'affiche automatiquement sous la barre de menu avec le code-barres Code-128
3. Fermer en cliquant sur le X ou en cliquant ailleurs
4. Cliquer sur l'icône dans la barre de menu et « Quitter » pour fermer l'application