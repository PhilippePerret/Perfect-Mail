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

**Perfect-Mail** (PMail) permet de définir un mail avec un code simplissime et de le mettre en forme avec **[MJML](https://mjml.io)** pour qu’il s’adapte à tous les gestionnaires de mail.

Au minimum, le code `pmail` peut ressembler à : 

~~~pmail
section
	Ceci est le corps du message qui s'affichera correctement quelque soit le gestionnaire de mails du destinataire, sur un mobile, une tablette ou un ordinateur de bureau.
~~~

Et au maximum, on pourra définir des styles de paragraphes, des colonnes, des images, des boutons, des accordéons et des kaléïdoscopes, tout ce que MJML permet de faire, et même plus.

Voici par exemple un code beaucoup plus complexe et, dessous, le mail qu’il produit dans le gestionnaire `Mail.app` d’un ordinateur de bureau Apple.

~~~pmail
fonts
	Charter: www.atelier-icare.net/fonts/Charter/Charter Regular.ttf
	
styles
	n: font:Charter; size:15pt;
	p: font:Charter; size:11pt;
	
section
	column
		n: Un paragraphe sur la première colonne, à gauche.
	column
		p: Un paragraphe écrit plus petit, sur la colonne du milieu. En cliquant sur l'image ci-contre, on rejoint l'atelier.
	column
		img: www.atelier-icare.net/img/logo.jpg | href=www.atelier-icare.net
		
section
	p: Une petite note tout en bas.
~~~



Un mail définit plusieurs sections avec le mot-clé `section`.


<a name="define-fonts"></a>

### Définir les fontes

Il faut bien considérer, pour commencer, que la fonte à utiliser doit se trouver sur le web, pas localement, sauf si elle est définie dans un fichier `.css` par un `@font-face`.

Les fontes se définissent alors dans la section `fonts` du fichier `.pmail` : 

~~~pmail
fonts
	// Ici la définition des fontes
~~~

Une fonte se définit alors tout simplement par son nom (celui qui sera utilisé ici, peu importe ce qu’il est) et l’URL de la police. Par exemple : 

~~~pmail
fonts
	Rale: https:fonts.googleapis.com/css?family=Raleway
~~~

> On peut omettre le ‘http:’ pour la brièveté.

Pour aller plus loin, voir [comment utiliser la fonte par le style](#use-font-in-style).

<a name="define-styles"></a>

### Définition des styles

On peut définir les styles généraux au début du mail par la balise `styles` :

~~~txt
styles
	p: color:blue; size=18pt; 
	psmall: size:11pt;
	
~~~

<a name="use-font-in-style"></a>

#### Utiliser une fonte par le style

Une fois que la [fonte est définie](#define-fonts), on peut l'utiliser dans le style défini :

~~~pmail
styles
	p: font:Rale; color:red;
~~~

<a name="images"></a>

## Les images

Le code PMAIL permet deux utilisations  « out of the box » :

* l’utilisation d’[images distantes](#images-distantes) (recommandé),
* l’utilisation d’[images locales](#images-locales) (si petites — logo, etc.,

<a name="images-distantes"></a>

### Images distantes

Les images distantes se définissent simplement par : 

~~~pmail
img: <URL de l'imge> | <attributs optionnels>
~~~

Par exemple : 

~~~pmail
img: www.monsite.net/images/limage.jpg | width: 120px;
~~~




<a name="images-locales"></a>

### Images locales

Pour les images locales, il vaut mieux qu’elles soient inférieures à 100 ko sous peine de trop alourdir le mail envoyé. Car pour fonctionner — le destinataire ne possédant pas cette image —, on doit la charger « en dur » à l’intérieur du mail.

Pour un mail plus alléger et rapide, déposer plutôt l’image quelque part sur la toile et préciser son URL en valeur.

### Rejoindre une cible en cliquant sur l’image

Pour pouvoir rejoindre une cible en cliquant sur l’image, il suffit d’ajouter en attributs l’attribut `href:` ou `href=` suivi de l’URL. Par exemple : 

~~~pmail
img: www.site.com/image.jpg | href=www.site.com
~~~

> Vous notez que le protocole (https) n’est pas nécessaire, il est ajouté automatiquement par Perfect-Mail.



---

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

