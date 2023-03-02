## Uwaga

To repozytorium jest rozwidleniem repozytorium WCAG W3C. Zostało wykonane, aby wesprzeć organizację pracy nad przygotowaniem oficjalnego tłumaczenia WCAG 2.2 na język polski.

**Żadna treść widoczna w tym repozytorium nie jest oficjalnym, obowiązującym, zalecanym itd. stanowiskiem W3C. Nie powinna być wykorzystywana nigdzie, poza tym repozytorium i w pracach zespołu tłumaczy!**

## Udział w tłumaczeniu

Każdy może uczestniczyć w tłumaczeniu, zgłaszać swoje propozycje, uwagi, wątliwości.

W szczególności każdy może:

- zgłosić problem z aktualnym oficjalnym tłumaczeniem WCAG 2.1 na język polski, np. propozycję zmiany aktualnego tłumaczenia kryterium sukcesu lub terminu słownikowego, powiązań tłumaczenia ze słownikiem terminów, itp.
- przedstawić swoje sugestie, opinie, wątpliwości w dyskusjach nad każdym nowym w WCAG 2.2 kryterium sukcesu  
- przedstawić swoje sugestie, opinie, wątpliwości w dyskusjach nad każdym nowym w WCAG 2.2 terminem
- przedstawić swoje sugestie, opinie, wątpliwości w odniesieniu do tekstu wprowadzającego i opisującego WCAG 2.2

# Poniżej znajdują się robocze propozycje do dyskusji

## Tok pracy nad nowymi kryteriami sukcesu

### Dyskusja

Dla każdego nowego kryterium sukcesu, dla każdego nowego terminu oraz dla każdej z głównych części wprowadzenia do WCAG 2.2 zostanie założony wątek rozważań w obszarze Issues.
Dla ułatwienia:

- wątek każdego dyskutowanego kryterium sukcesu będzie zatytułowany przewidywanym numerem tego kryterium i roboczą nazwą tego kryterium,
- wątek każdego dyskutowanego nowego terminu będzie zatytułowany numerem przedrostkiem 2.2-Termin, a po nim, po spacji zostanie przytoczone robocze tłumaczenie terminu
- wątek każdej dyskutowanej części wprowadzenia będzie zatytułowany przedrostkiem 2.2-Wstęp, a po nim po spacji przytoczony zostanie nagłówek części wstępu. 

### Uzgadnianie wersji finalnej
Uzgadnianie tekstów tłumaczeń odbywa się w drodze konsensusu.
Dyskusję nad każdym nowym kryterium sukcesu i nad każdym terminem moderuje **redaktor - opiekun KS** lub **redaktor - opiekun terminu**.
Dyskusję nad tekstem wprowadzającym moderują **redaktorzy wydania WCAG 2.2**

Moderator:

- formułuje podsumowania dyskusji na kolejnych etapach
- określa kwestie do rozstrzygnięcia
- formułuje w poście otwierającym dyskusję nad kryterium sukcesu/terminem kolejne wersje proponowanego tłumaczenia
- inicjuje scalenie z tłumaczeniem roboczym wypracowanej wersji „kandydującej”

W szczególności moderator **czuwa** nad konsekwencjami, jakie niosą proponowane rozstrzygnięcia dla spójności tłumaczenia, w tym:
- jeżeli w tłumaczeniu KS stosowany jest termin słownikowy - spójnością zastosowanego znaczenia i sformułowania z defunicją terminu; w przypadku, gdy w definicji terminu nie ma formy gramatycznej użytej w tekście tłumaczenia, **moderator zgłasza propozycję uzupełnienia** w wątku dyskusji nad tym terminem   
 
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

Jeśli w KS użyty jest termin słownikowy, otacza się go znacznikiem, `a` według wzoru: `<a>termin słownikowy</a>`.
 
### Definicje

Jeśli redagujesz lub dyskutujesz definicje terminów, uwzględnij format definicji: 

```html
<dt><dfn>{Termin}</dfn></dt>
<dd>{Definicja}</dd>
```

Format rozszerzony, gdy termin używany jest w kilku formach gramatycznych

```html
<dt><dfn data-lt="<inna forma gramatyczna>|<inną formą gramatyczną>">{Termin}</dfn></dt>
<dd>{Definicja}</dd>
```

Element ```dfn``` mówi skryptowi, że jest to termin i wywołuje specjalne funkcje stylizacji i łączenia. Aby połączyć się z terminem, użyj elementu `<a>` bez atrybutu `href`; jeśli tekst linku jest taki sam jak termin, link zostanie wygenerowany poprawnie. Na przykład, jeśli na stronie znajduje się termin `<dfn>strona internetowa</dfn>`, link w postaci `<a>strona internetowa</a>` spowoduje utworzenie odpowiedniego łącza. Jeśli tekst linku ma inną formę niż termin kanoniczny, np. „strony internetowe” (zwróć uwagę na liczbę mnogą), możesz podać wskazówkę dotyczącą definicji terminu za pomocą atrybutu `data-lt`. W tym przykładzie zmodyfikuj termin na `<dfn data-lt="strony internetowe">strona internetowa</dfn>`. Wiele alternatywnych nazw terminu można oddzielić kreską, bez spacji na początku lub końcu, np. `<dfn data-lt="stron internetowych|strony internetowe">strona internetowa</dfn>`. 
 

## Problemy tłumaczenia WCAG 2.1
W związku z opracowaniem tłumaczenia WCAG 2.2 możliwe jest poprawienie, uzupełnienie, uściślenie tłumaczenia WCAG 2.1. 

### Co się stanie z propozycjami? 
- **Ulepszenia**: Zaproponowane zmiany, po zaakceptowaniu przez zespół redakcyjny, zostaną zastosowane w tłumaczeniu WCAG 2.2. 
- **Błędy**: Jeśli zostaną wykryte i zgłoszone błędy w tłumaczeniu WCAG 2.1, wówczas zostanie przygotwana także errata do oficjalnej wersji WCAG 2.1.  

### Zgłoszenia problemów dotyczących WCAG 2.1
Jeśli chcesz zgłosić propozycję zmian w oficjalnym tłumaczeniu WCAG 2.1 na język polski:

- utwórz nowe zgłoszenie problemu
- zatytułuj swoje zgłoszenie według schematu: `2.1-<KS X.X.X> problem` albo ` 2.1-<slownik>-<termin> problem` albo `2.1-Wstęp <Część> - problem`






