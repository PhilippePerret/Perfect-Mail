# Perfect-Mail

## Overview

This command-line application takes a text like:

```txt
section

  p: My first email paragraph in a single column

section |background-color:whitegrey;

  column
    p: In this first column, a short text.

  column |width:30px
    img: myimage.jpg

  column
    p: The paragraph of the *third* column, a bit longer.

```

…and generates HTML code for an email that adapts to all mail clients on smartphones, tablets, and desktop computers.

## Usage

* Install the app with `brew install perfect-mail`,
* Write your message and save it with the `.pmail` extension (for example `myMail.pmail`),
* Open a Terminal and type `perfect-mail -c path/to/myMail.pmail`,
* => the email code is generated and copied to the clipboard,
* Paste it into your mailing list manager, for example.


---
*(french version)*

## Présentation

Cette application en ligne de commande permet, à partir d'un texte ressemblant à : 

~~~txt
section

  p: Mon premier paragraphe de mail dans une unique colonne

section |background-color:whitegrey;

  column
    p: Dans cette première colonne, un petit texte.

  column |width:30px
    img: monimage.jpg

  column
    p: Le paragraphe de la *troisième* colonne, un peu plus long.

~~~

… de produire le code HTML d'un mail qui s'adaptera à tous les gestionnaires de mail sur smartphone, tablette ou ordinateur de bureau.

## Utilisation

* Chargez l'application avec `brew install perfect-mail`,
* Rédigez votre message en lui donnant l'extension `.pmail` (par exemple `monMail.pmail`),
* ouvrez un Terminal et tapez `perfect-mail -c path/to/monMail.pmail`
* => le code du mail est produit et mis dans le presse-papier
* collez-le dans votre gestionnaire de mailing-list par exemple.

---

## Mode d’emploi

Un mail définit plusieurs sections avec le mot-clé `section`.



### Définition des styles

On peut définir les styles généraux au début du mail par la balise `styles` :

~~~txt
styles
	p: color:blue; size=18pt; 
	psmall: size:11pt;
	
~~~

### Séparateurs d’attributs

Les attributs sont toujours séparés par des « ; » (commen en CSS) et leur empreinte est `property=value;`

On peut indifféremment utiliser le « `:` » ou le « `=` » pour affecter la valeur. Ces deux expressions sont similaires :

~~~
size=12px;

size:12px;
~~~



### Commentaires

On peut placer des commentaires dans le texte  à l’aide de la marque `//` ou `/* */` (comme en JavaScript).

## Options de commande

| Option          | Description                                                  | Note |
| --------------- | ------------------------------------------------------------ | ---- |
| `-m/--minified` | Minifie le code pour obtenir le code le plus condensé possible. |      |
|                 |                                                              |      |
|                 |                                                              |      |

