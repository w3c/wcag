WCAG (Web Content Accessibility Guidelines) - Gałąź do produkcji wersji przeglądowych z sierpnia 2016 r.
===

W serwisie W3C ta gałąź wykorzystywana była w żądaniach scalenia do 10 lipca 2016 r.

To repozytorium służy do opracowywania treści dla WCAG 2, a także powiązanych dokumentów i technik zrozumienia.

## Przewodnik po stylu redakcyjnym

@@Do dokończenia

* Unikaj używania terminów RFC2119, takich jak „musi”, „powinien” lub „może” w treściach nienormatywnych, aby uniknąć pomyłki z rolą normatywną.

## Struktura plików

WCAG 2.0 utrzymywany był w innej strukturze plików niż kolejne wersje WCAG. Pliki źródłowe dla WCAG 2.0 znajdują się w folderze wcag20 i służą głównie do celów archiwalnych. Nie edytuj zawartości tego folderu.

Treść dla WCAG 2.1 i nowszych jest zorganizowana zgodnie z poniższą strukturą plików. Repozytorium WCAG zawiera pliki źródłowe i pomocnicze dla WCAG 2, Zrozumienie WCAG 2 i ewentualnie techniki. Zawiera również pliki pomocnicze, które obsługują automatyczne formatowanie dokumentu. Aby ułatwić edycję wielostronną, każde kryterium sukcesu znajduje się w osobnym pliku, składającym się z fragmentu HTML, który można włączyć do głównych wytycznych. Kluczowe pliki obejmują:

* guidelines/index.html - główny plik z wytycznymi
* guidelines/sc/<wersja>/*.html - pliki dla każdego kryterium sukcesu
* guidelines/terms/<wersja>/*.html - pliki dla każdej definicji słownkowej
* understanding/<wersja>/*.html - pliki objaśnień dla każdego kryterium sukcesu

Gdzie, jeżeli <wersja> to "20", treść pochodzi z WCAG 2.0., "21" treść pochodzi z WCAG 2.1, "22" dla WCAG 2.2,itd.

## Edytowanie kryteriów sukcesu wersji roboczej

[Opiekunowie kryteriów sukcesu](https://www.w3.org/WAI/GL/wiki/SC_Managers_Phase1) przygotują kryteria sukcesu kandydata, gotowe do włączenia do dokumentu z wytycznymi. Aby przygotować kryteria sukcesu, wykonaj następujące kroki:

1. [Sklonuj repozytorium](https://help.github.com/articles/cloning-a-repository/), za pomocą identyfikatora URI https://github.com/w3c/wcag.git.
1. Przełącz się do gałęzi roboczej dla propozycji, której nazwa pochodzi od skróconej nazwy kryterium powodzenia wersji roboczej i numeru wydania, połączonych razem.
1. Znajdź odpowiedni plik dla kryterium sukcesu w folderze wytyczne/sc/21 o takiej samej nazwie jak początek nazwy oddziału i otwórz go w edytorze obsługującym HTML. 
1. Otwórz plik wytyczne/index.html i usuń komentarze wokół wierszy odnoszących się do kryterium sukcesu i warunków, które edytowałeś.
1. Postępuj zgodnie z poniższym [poniższym formatem kryteriów sukcesu](#user-content-success-criteria-format), aby utworzyć zawartość KS.
1. Zapisz plik i zatwierdź zmianę. UWAGA: Ważne jest, aby dodać również odpowiedni „komunikat zatwierdzenia”. W komentarzach podaj numer wydania, na podstawie którego opracowano propozycję, zaczynając od krzyżyka, np. `#1`.
1. Kiedy kryterium sukcesu będzie gotowe do przeglądu przez Grupę Roboczą, poinformuj o tym przewodniczących. Gdy propozycja zostanie zaakceptowana przez Grupę Roboczą, redaktorzy połączą gałąź roboczą z gałęzią główną, co umieści ją w wersji roboczej redakcji i ostatecznej publikacji Raportu Technicznego.

### Format kryteriów sukcesu
Kryteria sukcesu wykorzystują prostą strukturę elementów HTML z kilkoma wartościami atrybutów klas, aby zapewnić spójność. Skrypty ulepszające i styl wyłączają tę strukturę. Dostarczona przez Ciebie treść jest oznaczona w nawiasach klamrowych. Pozycje po komentarzach są opcjonalne.

```html
<section class="sc">
	<h4>{Etykieta KS}</h4>
	<p class="conformance-level">{Poziom}</p>
	<p class="change">{Zmiana}</p>
	<p>{Główny tekst KS}</p>
	<!-- jeśli KS ma punkty -->
	<dl>
		<dt>{Etykieta punktu}</dt>
		<dd>{Tekst punktu}</dd>
	</dl>
	<!-- jeśli KS ma uwagi -->
	<p class="note">{Uwaga}</p>
</section>
```

Stosowane wartości elementów są opisane poniżej. Przykład każdego z tych fragmentów treści znajduje się w Kryterium sukcesu 2.2.1 .

<dl>
	<dt>{Etykieta KS}</dt>
	<dd>Krótka nazwa KS. W KS 2.2.1 jest to „Dostosowanie czasu”.</dd>
	<dt>{Poziom}</dt>
	<dd>Poziom zgodności KS. Wartościami mogą być „A”, „AA” lub „AAA”. Nie dołączaj słowa „Poziom”.</dd>
	<dt>{Zmiana}</dt>
	<dd>Wskaż, czy KS jest niezmieniony od WCAG 2.1, zmieniony czy nowy. Wartości mogą być „Niezmienione”, „Zmienione” lub „Nowe”.</dd>
	<dt>{Główny tekst KS}</dt>
	<dd>Główny tekst KS lub akapit początkowy. W KS 2.2.1 jest to treść, która zaczyna się od „Gdy czas korzystania z treści jest ograniczany…”.</dd>
	<dt>{Etykieta punktu}</dt>
	<dd>Jeśli KS ma punkty, każda punkt ma etykietę. W SC 2.2.1 pierwszą etykietą (uchwytem) punktu jest „Wyłączenie”.</dd>
	<dt>{Tekst punktu}</dt>
	<dd>W KS 2.2.1 tekst pierwszego punktu zaczyna się od „Użytkownik może wyłączyć limit czasowy…”..</dd>
	<dt>{Uwaga}</dt>
	<dd>Jeśli istnieje uwaga do KS, podaj ją po innej treści (bez etykiety „Uwaga”). W KS 2.2.1 jest to treść rozpoczynająca się od „To kryterium sukcesu ma na celu zapewnienie…”. Jeśli jest więcej niż jedna uwaga, może być wiele wpisów zaczynających się od `<p class="note">`</dd>
</dl>

### Definicje

Jeśli dostarczasz definicje terminów wraz z KS, dołącz je do słownika. Ułóż je w odpowiedniej kolejności alfabetycznej z pozostałymi terminami i użyj następującego formatu:

```html
<dt><dfn>{Termin}</dfn></dt>
<dd>{Definicja}</dd>
```

Element ```dfn``` mówi skryptowi, że jest to termin i wywołuje specjalne funkcje stylizacji i łączenia. Aby połączyć się z terminem, użyj elementu `<a>` bez atrybutu `href`; jeśli tekst linku jest taki sam jak termin, link zostanie wygenerowany poprawnie. Na przykład, jeśli na stronie znajduje się termin `<dfn>strona internetowa</dfn>`, link w postaci `<a>strona internetowa</a>` spowoduje utworzenie odpowiedniego łącza. Jeśli tekst linku ma inną formę niż termin kanoniczny, np. „strony internetowe” (zwróć uwagę na liczbę mnogą), możesz podać wskazówkę dotyczącą definicji terminu za pomocą atrybutu `data-lt`. W tym przykładzie zmodyfikuj termin na `<dfn data-lt="strony internetowe">strona internetowa</dfn>`. Wiele alternatywnych nazw terminu można oddzielić kreską, bez spacji na początku lub końcu, np. `<dfn data-lt="stron internetowych|strony internetowe">strona internetowa</dfn>`.


## Edycja wersji roboczej Zrozumienie (Objaśnienie) kryterium sukcesu

Na każde kryterium sukcesu przypada jeden plik z objaśnieniem oraz indeks:

* understanding/index.html - strona indeksu, należy odkomentować lub dodać odniesienie do poszczególnych stron Understanding w miarę ich udostępniania
* understanding/<wersja>/*.html - pliki dla każdej strony zrozumienia, nazwane tak samo jak plik kryterium sukcesu w wytycznych

Pliki są wypełniane szablonem, który zapewnia oczekiwaną strukturę. Pozostaw strukturę szablonu na swoim miejscu i dodaj odpowiednie treści w sekcjach. Elementy z `class="instructions"` dostarczają wskazówek dotyczących treści, które należy uwzględnić w tej sekcji; możesz usunąć te elementy, jeśli chcesz, ale nie musisz. Szablon przykładów proponuje listę wypunktowaną lub serię podsekcji, wybierz jedno z tych podejść i usuń drugie z szablonu. Szablon technik zawiera podsekcje dotyczące „sytuacji”, usuń tę sekcję, jeśli nie jest potrzebna.

Pliki objaśnień są przywoływane z odpowiedniego kryterium sukcesu w specyfikacji WCAG; te linki są wstawiane przez skrypt.

Oficjalna lokalizacja publikacji stron objaśnień to obecnie https://www.w3.org/WAI/WCAG21/Understanding/. TTa treść jest aktualizowana w razie potrzeby; i może być zautomatyzowana.


## Editing Techniques

Techniques are in the techniques folder, and grouped by technology into sub-folders. Each technique is a standalone file, which is in HTML format with a regular structure of elements, classes, and ids.

### Technique File Structure

The [technique template](techniques/technique-template.html) shows the structure of techniques. Main sections are in top-level &lt;section> elements with specific IDs: meta, applicability, description, examples, tests, related, resources. The description and tests sections are required; the applicability and examples sections are recommended; the related and resources sections are optional. The meta section provides context for the technique during authoring but is removed for publication. The title of the technique is in the `<h1>` element. Elements with `class="instructions"` provide information about populating the template. They should be removed as the technique is developed but if not removed, will be ignored by the generator. **Do not copy `class="instructions"` on real content.**

Techniques can use a temporary style sheet to facilitate review of drafts. This style sheet is replaced by other style sheets and structure for formal publication. To use this style sheet, add `<link rel="stylesheet" type="text/css" href="../../css/editors.css"/>` to the head of the technique.

The generator used to publish techniques uses XML processing, so techniques must be well-formed XML. Techniques use HTML 5 structure so are actually [HTML Polyglot](https://www.w3.org/TR/html-polyglot/).  

### Images, Examples, Cross References for Techniques

Techniques can include images. Place the image file in the `img` folder of the relevant technology - meaning all techniques for a technology share a common set of images. Use a relative link to load the image. Most images should be loaded with a `<figure>` element and labeled with a `<figcaption>` positioned at the bottom of the figure. `<figure>` elements must have an `id` attribute. Small inline images may be loaded with a `<img>` element with suitable `alt` text.

Techniques should include brief code examples to demonstrate how to author content that follows the technique. Code examples should be easy to read, and usually not complete content in themselves. More complete examples can be provided as [working examples](#user-content-provide-working-examples-of-techniques) (see below). Link to working examples at the bottom of each example, in a `<p class="working-example">` element, containing a relative link to `../../working-examples/{example-name}/`.

Cross references to other techniques may be provided where useful. Generally they should be provided in the "Related Techniques" section but can be provided elsewhere. Use a relative link to reference the technique, `{Technique ID}` if the same technology, or `../{Technology}/{Technique ID}` otherwise. If the technique is still under development and does not have a formal ID, reference the path to the development file. If the technique is under development in a different branch, use an absolute URI to the rawgit version of the technique.

Cross references to guidelines and success criteria should use a relative URI to the *Understanding* page for that item. Cross references to other parts of the guidelines should use an absolute URI to the guidelines as published on the W3C TR page, a URI beginning with `https://www.w3.org/TR/WCAG21/#`. Note that references to guidelines or success criteria to which techniques relate are added by the generator upon publication based on information in the Understanding documents, so redundant links to those is not normally needed or advised.

### Create Techniques

[General priorities and process to work on techniques are maintained in the wiki](https://www.w3.org/WAI/GL/wiki/Wcag21-techniques).

New techniques should use a filename that is derived from a shortened version of the technique title. Editors will assign the technique an ID and rename the file when it is accepted by the Working Group. For example, a technique "Using the alt attribute on the img element to provide short text alternatives" might use "img-alt-short-text-alternatives.html" as the filename. The editors will assign it a formal ID, and rename the file, when it is accepted by the Working Group.

Each new technique should be created in a new branch. Set-up of the branch and file is automated via the create-techniques.sh script, which can be run with bash. The command line is:

```Shell
bash create-techniques.sh <technology> <filename> <type> "<title>"
```
\<technology> is the technology directory for the technique
\<filename> is the temporary filename (without extension) for the technique
\<type> is "technique" or "failure"
\<title> is the title of the technique, enclosed in quotes and escaping special characters with \\

This automates the following steps:

* Determine a filename for the technique that is likely to be descriptive, unique, and short.
* Create a working branch named the same as the technique filename.
* Copy the techniques/technique-template.html file into the appropriate technology folder for the technique, and give it the chosen file name.
* In the section element with id "meta", indicate to which guideline or success criterion the technique relates, and whether the technique is sufficient, advisory, or a failure for that item. Multiple applicability are allowed.

Once a technique branch and file is set up, populate the content and request review:

* Populate the template with appropriate content, using other techniques as examples for code formatting choices. Keep the existing structural sections from the template in place.
* When the technique is ready for review, make a pull request into master.
* If you wish to reference the draft technique from an Understanding document, use the technique's rawgit URI.
* After a technique is approved, the chairs will assign it an ID and update links to it in the Undestanding documents. 

### Formatting Techniques

Techniques in the repository are plain HTML files with minimal formatting. For publication to the editors' draft and W3C location, techniques are formatted by an XSLT-based generator managed by Apache Ant running in Java. Most people do not need to worry about this, but relevant files are the [Ant build file](build.xml) and [XSLT files](xslt).

The generator compiles the techniques together as a suite with formatting and navigation. It enforces certain structures, such as ordering top-level sections described above and standardizing headings. It attempts to process cross reference links to make sure the URIs work upon publication. One of the most substantial roles is to populate the Applicability section with references to the guidelines or success criteria to which the technique relates. The information for this comes from the Understanding documents. Proper use of the technique template is important to enable this functionality, and mal-formed techniques may cause the generator to fail.

## Working Examples

Examples in techniques should be brief easy-to-consume code samples of how the technique is used in content. Therefore examples should focus on the specific features the technique describes, and not include related content such as style, script, surrounding web content, etc.

Often it is desirable to provide more comprehensive examples, which show the technique in action while not interfering with the main technique document. These examples also show the complete code required to make the technique operate, including full style and script files, images, page code, etc. Usually, these "working examples" are referenced at the bottom of the elided example which is included in the main technique.

Working examples are stored in the `working-examples` directory of the repository. Each example is in its own subdirectory, to contain the multiple files that may be necessary to make the example work. In some cases, multiple working examples will share common resources; these are stored in the appropriate sub-directory of the working-examples directory, e.g., `working-examples/css`, `working-examples/img`, `working-examples/script`. Reference these common resources when available; otherwise place resources in the working example directory, using subdirectories to organize when appropriate.

To create a working example:

* Identify the name for the example, e.g., "Using the alt attribute".
* Create a working branch for the example, whose name begins with the prefix `example-` and which otherwise semantically identifies the example, e.g., `example-alt-attribute`.
* Create a directory for the example inside the working examples directory, using the semantic name for the example minus the prefix used in the branch name, e.g., `working-examples/alt-attribute/`.
* If the primary example is HTML, name the file `index.html`. Otherwise, create a suitable file name.
* Refer to resources shared among multiple examples using relative links, e.g., `../css/example.css`. Place other resources in the same directory as the main example, e.g., `working-examples/alt-attribute/css/alt.css`.
* Reference working examples from techniques using the rawgit URI to the example in its development branch, e.g., `https://rawgit.com/w3c/wcag/master/working-examples/alt-attribute/`. Editors will update links when examples are approved.
* When the example is complete and functional, submit a pull request into the master branch.

## Translations

WCAG 2.1 jest gotowy do tłumaczenia. WCAG 2.2 jest wciąż w fazie rozwoju, więc nie powinien być jeszcze tłumaczony. Aby przetłumaczyć WCAG 2.1, upewnij się, że korzystasz z[GitHub](https://github.com/), a następnie:

* [Utwórz rozwidlenie (fork)](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo) repozytorium w3c/wcag.
* Przejdź do [gałęzi](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/about-branches) "WCAG-2.1".
* Utwórz nową gałąź z tej gałęzi.
* Przetłumacz całą treść zorientowaną na użytkownika w folderze „guidelines”, w tym podfoldery. Treści zorientowane na użytkownika obejmują tekst w elementach oraz atrybuty, takie jak „title” ​​i „alt”, które dostarczają treści użytkownikom. **Pozostałe znaczniki pozostaw bez zmian**.
* Załaduj dokument index.html do nowoczesnej przeglądarki i pozwól skryptowi skompilować zawartość i sformatować ją.
* Aktywuj link „Respec” w prawym górnym rogu i wybierz „Eksportuj…”, a następnie opcję „HTML”.
* Wyedytuj wynikowy plik, aby przetłumaczyć tekst wstawiony przez skrypt.
* Edytuj plik, aby spełnić wymagania procesu [Autoryzowanych Tłumaczeń W3C](https://www.w3.org/2005/02/TranslationPolicy). 

