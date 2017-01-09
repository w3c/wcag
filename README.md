# wcag21
WCAG 2.1 and support materials

The issues on the wcag 2.1 repo are currently reserved for success criteria proposals for wcag 2.1. Discussion of changes for understanding documents and techniques should take place on the list or in the wcag 2.0 repo issues.

## Adding Success Criteria

[Success Criteria Managers](https://www.w3.org/WAI/GL/wiki/SC_Managers_Phase1) will submit pull requests for candidate success criteria, ready for inclusion in the guidelines document. To prepare success criteria, follow these steps:

1. [Fork this repository](https://help.github.com/articles/fork-a-repo/) or, if you have already forked it, [update your fork](https://help.github.com/articles/syncing-a-fork/). It is important to keep your fork up to date to avoid merge conflicts.
1. Switch to the `master` branch, then create a new branch for the success criterion proposal. Name the branch for the issue in which the SC proposal has been worked out, e.g., `ISSUE-1`.
1. Open the guidelines/index.html file in an HTML-capable editor.
1. Select the guideline into which you will add the SC, and add it after all the existing SC in the guideline, *regardless of the conformance level and expected number of the proposed SC*.
1. Follow the [success criteria format](#user-content-success-criteria-format) below to create the SC content.
1. Save the file and commit the change. NOTE: It is important to also add a suitable 'commit message'. In the comments, reference the issue number from which the proposal was developed starting with a hash, e.g., `#1`. 
1. Submit a [pull request](https://help.github.com/articles/using-pull-requests/) to make the proposal available for WG review.
1. When ready, the editors will accept the pull request and then merge it into master. You can delete the branch in your fork after the pull request has been accepted.

## Success Criteria Format

Success criteria use a simple structure of HTML elements, with a few class attribute values, to ensure consistency. Enhancement scripts and style key off this structure. Content you provide is indicated in braces. Items after comments are optional.

```html
<section class="sc">
	<h4>{SC Handle}</h4>
	<p class="conformance-level">{Level}</p>
	<p class="change">{Change}</p>
	<p>{Main SC Text}</p>
	<!-- if SC has sub-points -->
	<dl>
		<dt>{Point Handle}</dt>
		<dd>{Point Text}</dd>
	</dl>
	<!-- if SC has notes -->
	<p class="note">{Note}</p>
</section>
```

Note you do not provide the SC number. Numbers will be assigned, and most likely automatically generated, later.

Values you provide are described below. Refer to [Success Criterion 2.2.1](https://www.w3.org/TR/WCAG20/#time-limits-required-behaviors) for an example of each of these pieces of content.

<dl>
	<dt>{SC Handle}</dt>
	<dd>The short name of the SC. In SC 2.2.1 this is "Timing Adjustable".</dd>
	<dt>{Level}</dt>
	<dd>The conformance level of the SC. Values can be "A", "AA", or "AAA". Do not include the word "Level".</dd>
	<dt>{Change}</dt>
	<dd>Indicate whether the SC is unchanged from WCAG 2.0, changed, or new. Values can be "Unchanged", "Changed", or "New".</dd>
	<dt>{Main SC Text}</dt>
	<dd>The main text of the SC, or the starting paragraph. In SC 2.2.1 this is the content that begins "For each time limit...".</dd>
	<dt>{Point Handle}</dt>
	<dd>If the SC has bullets, each bullet has a handle. In SC 2.2.1 the first bullet point handle is "Turn off".</dd>
	<dt>{Point Text}</dt>
	<dd>The content of the bullet. In SC 2.2.1 the first bullet point text begins "The user is allowed...".</dd>
	<dt>{Note}</dt>
	<dd>If there is a note to the SC, provide it after the other content (without the starter "Note"). In SC 2.2.1, this is the content that begins "This success criterion...". If there is more than one note, multiple `<p class="note">`elements may be provided.</dd>
</dl>

## Definitions

If you providing term definitions along with your SC, include them in the glossary. Position them in the appropriate alphabetical order with the rest of the terms and use the following format:

```html
<dt><dfn>{Term}</dfn></dt>
<dd>{Definition}</dd>
```

The ```dfn``` element tells the script that this is a term and causes special styling and linking features. To link to a term, use an `<a>` element without an `href` attribute; if the link text is the same as the term, the link will be correctly generated. For example, if there is a term `<dfn>web page</dfn>` on the page, a link in the form of `<a>web page</a>` will result in a proper link. If the link text has a different form from the canonical term, e.g., "web pages" (note the plural), you can provide a hint on the term definition with the `data-lt` attribute. In this example, modify the term to be `<dfn data-lt="web pages">web page</dfn>`. Multiple alternate names for the term can be separated with pipe characters, with no leading or trailing space, e.g., `<dfn data-lt="web pages|page|pages">web page</dfn>`.

The issues on the wcag 2.1 repo are currently reserved for success criteria proposals for wcag 2.1. Discussion of changes for understanding documents and techniques should take place on the list or is the wcag 2.0 repo issues.
