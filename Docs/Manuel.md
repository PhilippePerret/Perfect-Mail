# Perfect-Mail<br />Manuel

[toc]

## Présentation

*Perfect-mail* est un utilitaire permettant de produire des mails (presque) parfaits pour **tout gestionnaire de mails**, les pire compris (je veux parler bien entendu d’Outlook), ainsi que pour **tout type d’appareil**, ordinateur de bureau, tablette ou smartphone.

## Fonctionnement

On crée un fichier `.pmail` bien formaté et on le donne à l’application. Il fournit alors un fichier `.html` qu’il suffit d’envoyer comme mail (par exemple, avec Brevo, en collant le code html dans l’éditeur).

## Construction du mail

Le fichier `.pmail` le plus rudimentaire contient ce « code » :

~~~pmail 
section:
	Ceci est le texte du message.
~~~

Il produira le premier code adapté à tout gestionnaire de mails.

### Colonnes et styles

#### Les colonnes

Mais la puissance de *Perfect-Mail* vient quand on utilise les colonnes et les styles. Ils permettent de définir très simplement une grande richesse de documents.

Il faut comprendre à la base que *perfect-mail* travaille avec **une, deux ou trois colonnes**. Pas plus, ça mettrait trop en péril la mise en page sur les mobiles par exemple.

Définir les colonnes est aussi simple que :

~~~pmail
section
	colonne
		Le texte de la première colonne.
	colonne
		Le texte de la seconde colonne.
~~~

Vous commencez certainement à comprendre pourquoi on définit des **`section`**(s). C’est tout simple pour pouvoir varier le nombre de colonnes.

Vous pourriez remarquer que la mise en forme se fait par *identation*. Mais en vérité, cette indentation ne sert qu’à mieux présenter la forme du message. Vous pourriez avec tout autant d’efficacité écrire le mail avec : 

~~~
section
colonne
Le texte de la première colonne.
colonne
Le texte de la seconde colonne.
~~~

(ce qui est tout de même moins clair).

Comme nous le détaillerons plus tard, nous pouvons mettre en forme chaque colonne, lui définir un alignement, une couleur de fond, une image de fond même, une taille de police, etc. Pour le moment, définissons juste l’alignement d’une section de trois colonnes :



~~~
section
	column
		Contenu de la première colonne.
	column
		Contenu de la deuxième colonne.
// Ici la nouvelle section <- un commentaire

section
	column | align:left;
		Du texte qui sera aligné à gauche (left)
	column | align:center;
		Du texte qui sera aligné au centre (center)
	column | align:right;
		Du texte qui sera aligné à droite (right)

~~~

Comme vous pouvez le voir, nous avons fait une troisième colonne avec trois alignements différents. Nous aurions pu aussi utiliser l’alignement `justify` pour *justifier* le texte, c’est-à-dire le faire adopter une colonne bien construite sans air autour.

#### Les styles

Les styles, c’est l’autre puissance de *Perfect-Mail*, qui permet de donner un aspect cohérent à tout le message, et à le modifier très rapidement et très sûrement sans avoir à modifier tout.

Un *style* se définit dans une rubrique… `styles`. Si possible au-dessus du fichier `.pmail`. Créons par exemple deux styles de paragraphe qui vont définir la couleur et la taille du texte.

~~~pmail
styles
	grandrouge: size:32pt; color:red;
	petitvert: size:8pt; color:#00FF00;
~~~

C’est la définition on-ne-peut-plus simple de nos deux styles. Appliquons-les maintenant à nos paragraphes.

> Vous remarquerez que nous avons changé les noms avant qu’ils prennent moins de place dans le code du mail. Et nous en avons créé un troisième pour montrer toute la puissance de ces styles.

~~~pmail
styles
gr: size:32pt; color:red;
pg: size:8pt; color:#00FF00;
it: color:purple; style:italic;
// Notez bien les ";" à la fin de chaque définition

section
	colonne
		gr: Un paragraphe dans le style gr.
	colonne
		pg: Un paragraphe dans le style pg.
	colonne
		gr:it: Ce paragraphe aura deux styles. le premier et il sera mis en italique aussi.
~~~

Remarquez comme il est simple d’empiler les styles. Notez un point important : **c’est toujours le dernier style qui a raison**. Comment cela joue-t-il ? Vous remarquez que les deux styles `gr` et `it` définissent la couleur du texte. Puisque nous avons écrit `gr:it:`, c’est le dernier qui imposera sa couleur, donc le style `it:`. Le texte sera pourpre (`purple`). Si nous voulons que le texte reste rouge, nous devons utiliser l’ordre `it:gr:`. C’est toujours le dernier qui l’emporte ! (contrairement au 100 m nage libre !).



### Les images

Un mail sans image, c’est quand même moins beau.

### Les fontes

On peut définir des fontes précises pour le mail, qui seront utilisées pour une mise en page parfaite.

La seule contrainte concernant ces fontes est la suivante : la fonte doit être accessible depuis le web afin que votre destinataire puisse l’utiliser (il n’y verra rien, mais son gestionnaire devra la charger). Si vous utilisez les polices que Google met en libre accès, vous n’aurez aucun problème : 

~~~pmail
fonts
	Rale: fonts.googleapis.com/css?family=Raleway
	Cha: www.atelier-icare/fonts/Charter/Charter Regular

styles
	nr: font:Rale; size:15pt;
	cr: font:Cha; size:13pt; color:blue;
~~~

Notez comme il est simple ici encore de définir la donnée : il suffit d’indiquer le nom qu’on utilisera pour cette fonte (au sein du fichier `pmail`), deux points, puis l’url de la fonte que vous pouvez obtenir très facilement en rejoignant le site des fontes google.
