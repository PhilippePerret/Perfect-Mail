# Todo

- [ ] Revoir le `add_line` qui est mieux que la nouvelle méthode car la ligne doit être traitée différemment en fonction du container.
- [x] Revoir le parsing, il n'est pas bon du tout… Alors que c'est simple. Par exemple, dès qu'on est dans les lignes d'une section, soit on a une colonne, soit on a un identifier qui peut être :
  - une image (img:)
  - un text (par défaut ou txt:)
  - une table (tbl:)
  - voir les autres élément
  Cette ligne doit être analysée comme : 
    `<tag>:<contenu>|<styles propres>`
  Pour une image, `<contenu>` est le chemin d'accès à l'image, pour un texte, c'est le texte
  Et les attributs sont toujours les attributs.
  Basta, ça ne devrait pas être aussi compliqué.
- [ ] Définition des textes multilines
- [ ] Gérer l'importation de fontes.
- [ ] Gérer la possibilité d'importer du code MJML ou HTML
- [ ] Développer la possibilité d'écrire en markdown
- [ ] Prendre en compte tous les attributs, en "réduisant" ceux qu'on peut réduire
- [ ] Traitement des images
  - [ ] Possibilité de mettre les images en code en dur dans le mail
- [ ] Ajouter petit à petit tous les éléments de MJML.
- [x] produire le fichier MJML
- [x] produire le fichier HTML
- [x] Produire un mail pour Mail.app


## Tests à implémenter

- [ ] Affecter un style à un paragraphe (`sty: Mon paragraphe`) génère une alerte si le style n’existe pas.