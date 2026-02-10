# Perfect-Mail v2<br />Manuel

[toc]

## Présentation

Il s’agit de la seconde version de *Perfect-mail*, un utilitaire (`pmail`) permettant de produire des mails (presque) parfaits pour **tout gestionnaire de mails**, les pires compris (je veux parler bien entendu de *Outlook*), ainsi que pour **tout type d’appareil**, ordinateur de bureau, tablette ou smartphone grâce à MJML.

[Documentation officielle de MJML](https://documentation.mjml.io/#mj-text).

---

Cette section concerne uniquement le développement de l’application et donc les développeurs.

## Développement

*Balises et leur équivalence*

| Dans pmail   | Dans MJML                                 |                                                              |
| ------------ | ----------------------------------------- | ------------------------------------------------------------ |
|              | **Balises uniques (sans ambigüité)**      |                                                              |
| `title`      | mjml > mj-head > mj-title                 | Titre du mail                                                |
| `preview`    | mjml > mj-head > mj-preview               | Aperçu dans le listing des mails.                            |
| `font`       | mjml > mj-head > mj-font                  | [Définition d’une fonte](#define-font)                       |
| `all`        | mjml > mj-head > mj-attributes > mj-all   | Définition de l’[aspect général de tous les composants](#aspect-general-all). |
| `class`      | mjml > mj-head > mj-attributes > mj-class | Définition des [classes de paragraphe](#classes).            |
| `breakpoint` | mjml > mj-head > mj-breakpoint            | Définitely le « [point de rupture](#point-de-rupture) » pour passer d’un portable à un ordinateur. |
|              |                                           |                                                              |

<a name="define-font"></a>

### Définition d’une fonte

On définit une fonte n’importe où dans le document à l’aide de :

~~~pmail
font <name> <href>
~~~

Par exemple :

~~~pmail
font Raleway fonts.googleapis.com/css?family=Roboto
~~~

---

<a name="aspect-general-all"></a>

### Aspect général de tous les composants

~~~pmail
all prop:value;prop:value…;prop:value;
~~~

Les définitions s’appliqueront par défaut à tous les composants, qui pourront cependant être rectifiés au détail.

---

<a name="classes"></a>

### Définition des classes

~~~pmail
class <name> <prop:value;...;prop:value;>
~~~

Par exemple :

~~~pmail
class p1 size:14pt;color:blue;
class p2 style:italic;
~~~

On pourra ensuite l’appliquer à un paragraphe en faisant :

~~~pmail
section
	p1:p2: Le paragraphe trop stylé.
~~~





---

<a name="point-de-rupture"></a>

### Point de rupture

C'est le point qui va séparer un portable d'un ordinateur. Le mail considéra qu'en deça de cette valeur on a affaire à un portable et au-dessus à un ordinateur de bureau ou une tablette.

~~~pmail
breakpoint <valeur><unité>
~~~

Par exemple :

~~~~pmail
breakpoint 480px
~~~~



