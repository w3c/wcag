# Errata Editing Instructions

Errata are listed in reverse-chronological order, first sectioned by publish date,
then within each section based on when each erratum was added.

## Sections

The first top-level section under `<main>` corresponds to the latest version / unpinned URL;
subsequent sections correspond to previous versions / date-stamped URLs.

Each top-level section should be preceded by `trDate` and `trUrl` variable assignments.
These variables reduce the chance of copy-paste errors within individual errata.
For sections corresponding to previous versions, assignments should follow this pattern
(only `YYYY-MM-DD` should need to be replaced):

```
{%- assign trDate = "YYYY-MM-DD" -%}
{%- capture trUrl -%}
  https://www.w3.org/TR/{{ trDate | split: "-" | first }}/REC-WCAG{{ page.fileSlug }}-{{ trDate | replace: "-", "" }}/
{%- endcapture -%}
```

The level 2 heading in the top-level section for each previous version should use this code
(no replacements necessary, making use of the preceding variable reassignments):

```html
<h2>Errata since <a href="{{ trUrl }}">{{ trDate | date: "%d %B %Y" }} Publication</a></h2>
```

## Erratum format

Each erratum should be in the following format
(replacing `YYYY-MM-DD`, `Section Title`, `sectionid`, `details of changes`, and `#NNNN`):

```html
<li>
  YYYY-MM-DD:
  In <a href="{{ trUrl }}#sectionid">Section Title</a>,
  details of changes.
  ({% gh #NNNN %})
</li>
```

Adhering to this format is important, as any entries under the latest published version will also be
parsed for inclusion within Guideline/SC boxes and Key Terms definitions within Understanding pages.
(Newlines are insignificant and are suggested for source code readability.)

Each piece of this format is further explained in the subsections below.

### Section reference

When applicable, errata should begin with an indication of the section they relate to, including a link.

Example phrasing when linking to a section, e.g. a success criterion:

```html
In <a href="{{ trUrl }}#target-size-minimum">2.5.8 Target Size (Minimum)</a>
```

Example phrasing when linking to a term definition:

```html
In the definition for <a href="{{ trUrl }}#dfn-single-pointer">single pointer</a>
```

(Remember that term definition fragments always begin with `dfn-`.)

It is possible to reference multiple sections/terms from one erratum,
so long as all of the links remain front-loaded prior to the erratum's details.

### Details of changes

`details of what happened` should be expressed in present progressive tense
(e.g. "updating", "removing", "adding"), with the desired outcome listed first.
For example:

- updating the red threshold from ... to ...
- removing one note and adding two new notes, including ...
- removing a supernumerary "Note" indicator from the first note.
- correcting the word ... to ...

### GitHub PR or commit

When possible, provide a reference to one or more GitHub pull requests or commit hashes
at the end of each erratum, in the format `({% gh "..." %})`.

The format breaks down as follows:

- `{% gh "..." %}` is a custom shortcode, which accepts one of the following:
  - A PR number prefixed with `#`, e.g. `"#4080"` (this is the preferred option when available)
  - A commit hash of 7 or more characters, with no prefix, e.g. `"b043430"`
- The quotes around the parameter passed to the `gh` shortcode are necessary for template parsing
- The outer parentheses exist only for punctuation, and are directly output
