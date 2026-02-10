# Perfect-Mail<br />Manuel

[toc]

## Présentation

*Perfect-mail* est un utilitaire (`pmail`) permettant de produire des mails (presque) parfaits pour **tout gestionnaire de mails**, les pires compris (je veux parler bien entendu d’Outlook), ainsi que pour **tout type d’appareil**, ordinateur de bureau, tablette ou smartphone grâce à MJML.

[Documentation officielle de MJML](https://documentation.mjml.io/#mj-text).

## Production du mail

* Ouvrir un Terminal au dossier de l’application,
* y jouer le code `pmail -c /path/to/your-pmail-file.pmail`
* et le code est **mis directement dans le presse-papier** et consigné dans le fichier **.html** portant la même racine que le fichier `.pmail` original.

## Fonctionnement

On crée un fichier `.pmail`, en code brut, bien formaté et on le donne à l’application. Il fournit alors un fichier `.html` qu’il suffit d’envoyer comme mail (par exemple, avec Brevo, en collant le code html dans l’éditeur).

## Construction du mail

Le fichier `.pmail` le plus rudimentaire contient ce « code » :

~~~pmail 
section
	Ceci est le texte du message.
~~~

Il produira le premier code adapté à tout gestionnaire de mails, avec le texte « Ceci est le texte du message » qui sera bien placé dans la page.

Le terme **`section`** est un terme réservé qui dit à *Perfect Mail* que nous initions une nouvelle section, une nouvelle *partie* du mail.

### Avant que tout fonctionne…

Tout n’est pas encore opérationnel et de nombreuses inscriptions manquent encore pour produire des mails adéquats.

Voici des moyens de contourner certaines limites.

#### Espacement entre les sections

Pour régler cet espacement, on peut jouer sur la propriété `padding-top`. Plus la valeur sera élevée et plus il y aura d’écart entre les deux sections.

~~~pmail
section
	Premier paragraphe.
	
section | padding-top:100px;
	Deuxième paragraphe qui sera très éloigné.
~~~

#### Liens dans les textes

Pour le moment, tous les liens (`http://....`) sont supprimés dans le texte. Pour en inscrire quand même dans le mail, il suffit d’utiliser les variables à remplacer.

On écrit dans le mail :

~~~pmail
section
	column
		Mon texte avec un LIEN1 qui fonctionnera.
~~~

… et dans le fichier `remplacements.rb` au même niveau que le fichier `.pmail` :

~~~ruby
# Dans remplacements.rb
REMPLACEMENTS = {
  'LIEN1' => '<a href="....">...</a>',
  # ...
  }
~~~



### Colonnes et styles

#### Les colonnes

La puissance de *Perfect-Mail* apparait lorsqu’on utilise les *colonnes* et les *styles*. Ils permettent alors de définir très simplement une grande richesse de messages.

Il faut comprendre à la base que *Perfect-mail* travaille avec **une, deux ou trois colonnes**. Pas plus, ça mettrait trop en péril la mise en page sur les mobiles par exemple, sauf cas ponctuel très particulier.

Définir les colonnes est aussi simple que :

~~~pmail
section
	column
		Le texte de la première colonne.
	column
		Le texte de la seconde colonne.
~~~

Ici, **`column`** est aussi un terme réservé (signifie « colonne », bien entendu) qui permet de définir les colonnes du mail.

> Noter que ces colonnes apparaitront comme telles sur un ordinateur de bureau mais seront présentées l’une au-dessous des autres sur un smartphone.

Vous commencez peut-être aussi à comprendre pourquoi on définit des **`section`**(s). C’est tout simplement pour pouvoir varier le nombre de colonnes, chaque section pouvant avoir sa propre configuration, pour amener de la variété dans le message.

Vous remarquerez que la mise en forme ici se fait par *identation*. Mais en vérité, cette indentation ne sert qu’à mieux visualiser les parties finales du message. Vous pourriez avec tout autant d’efficacité écrire le mail sans aucune indentation : 

~~~
section
colonne
Le texte de la première colonne.
colonne
Le texte de la seconde colonne.
~~~

*(ce qui est tout de même moins clair).*

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
it: color:purple; font-style:italic;
// Notez bien les ";" à la fin de chaque définition
// Ne pas utiliser 'style' pour 'font-style'

section
	colonne
		gr: Un paragraphe dans le style gr.
	colonne
		pg: Un paragraphe dans le style pg.
	colonne
		gr:it: Ce paragraphe aura deux styles. le premier et il sera mis en italique aussi.
~~~

> Insistons sur ce commentaire : bien que nous ayons cherché à réduire absolument les noms des attributs, il n’es pas possible d’utiliser `style` à la place de `font-style`. Pour définir le style de la font, il faut expressément utiliser `font-style`.

Remarquez comme il est simple d’empiler les styles. Notez un point important : **c’est toujours le dernier style qui a raison**. Comment cela joue-t-il ? Vous remarquez que les deux styles `gr` et `it` définissent la couleur du texte. Puisque nous avons écrit `gr:it:`, c’est le dernier qui imposera sa couleur, donc le style `it:`. Le texte sera pourpre (`purple`). Si nous voulons que le texte reste rouge, nous devons utiliser l’ordre `it:gr:`. C’est toujours le dernier qui l’emporte ! (contrairement au 100 m nage libre !).

### Alignement des textes

Notez que pour aligner les textes, il ne faut pas penser aux colonnes ou aux sections, mais aux styles qui seront appliqués aux textes. Par exemple, pour avoir des textes justifiés, il faut définir un style avec cette propriété :

~~~pmail
styles
	pj: size:14pt; align:justify;

section
	column
		pj: Ce texte sera justifié sur toute la colonne.

section
	column
		pc: Ce texte sera centré dans la première colonne.
	column
		pc: Ce texte sera centré dans la deuxième colonne.
~~~

### Les images

Un mail sans image, c’est quand même moins beau.

Pour insérer une image, on utilise la balise **`img:`** suivi de l’URL du fichier sans `http://`. Par exemple :

~~~pmail
section
	column
		img:www.icare-edition.fr/img/mon_livre.jpg
		
~~~

> Noter que les petites images seront directement insérées en code en dur dans le message, pour une plus grand rapidement d’affichage.

Comme pour les autres éléments, on peut préciser les styles après une barre droite :

~~~pmail
img:www.monsite.fr/img/limage.png | width:100px;
~~~



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
