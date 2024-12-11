# Errata Editing Instructions

Errata are listed in reverse-chronological order, first sectioned by publish date,
then within each section based on when each erratum was added.

The first top-level section under `<main>` corresponds to the latest version / unpinned URL;
subsequent sections correspond to previous versions / date-stamped URLs.

Each top-level section should be preceded by `trDate` and `trUrl` variable assignments.
These variables reduce the chance of copy-paste errors within individual errata.
For sections corresponding to previous versions, assignments should follow this pattern
(only `YYYY-MM-DD` should need to be replaced):

```
{%- assign trDate = "YYYY-MM-DD" -%}
{%- capture trUrl -%}
  https://www.w3.org/TR/{{ trDate | split: "-" | first }}/REC-WCAG21-{{ trDate | replace: "-", "" }}/
{%- endcapture -%}
```

The level 2 heading in the top-level section for each previous version should use this code
(no replacements necessary, making use of the preceding variable reassignments):

```html
<h2>Errata since <a href="{{ trUrl }}">{{ trDate | date: "%d %B %Y" }} Publication</a></h2>
```

Each erratum should be in the following format
(replacing `YYYY-MM-DD`, `Section Title`, and `details of what happened`):

```html
<li>YYYY-MM-DD: In <a href="{{ trUrl }}#sectionid">Section Title</a>, details of what happened.</li>
```

Adhering to this format is important, as any entries under the latest version will also be
parsed for inclusion within Guideline/SC boxes and Key Terms definitions within Understanding pages.
