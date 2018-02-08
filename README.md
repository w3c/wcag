# wcag21
WCAG 2.1 and support materials

The issues on the wcag 2.1 repo are currently reserved for success criteria proposals for wcag 2.1. Discussion of changes for understanding documents and techniques should take place on the list or in the wcag 2.0 repo issues.

## File Structure

The WCAG 2.1 repository contains source and auxiliary files for WCAG 2.1, Understanding WCAG 2.1, and eventually techniques, along with some content from WCAG 2.0 for context. It also contains auxiliary files that support automated formatting of the document. To facilitate multi-party editing, each success criterion is in a separate file, consisting of a HTML fragment that can be included into the main guidelines. Key files include:

* guidelines/index.html - the main guidelines file
* guidelines/sc/21/*.html - files for each success criterion
* guidelines/terms/21/*.html - files for each definition
* understanding/21/*.html - understanding files for each success criterion

## Review Links
 
Review links have been [put at the top of each issue](https://lists.w3.org/Archives/Public/w3c-wai-gl/2017JanMar/1200.html) tracking the success criterion proposal. The pattern for review links is:

* SC for viewing: https://rawgit.com/w3c/wcag21/{branchname}/guidelines/sc/21/{scfile}.html
* SC for editing: https://github.com/w3c/wcag21/blob/{branchname{/guidelines/sc/21/{scfile}.html
* Term for viewing: https://rawgit.com/w3c/wcag21/{branchname}/guidelines/terms/21/{termfile}.html 
* Term for editing: https://github.com/w3c/wcag21/blob/{branchname{/guidelines/terms/21/{termfile}.html
* SC in context of full guidelines: https://rawgit.com/w3c/wcag21/branchname/guidelines/#{scfile}

## Editing Draft Success Criteria

[Success Criteria Managers](https://www.w3.org/WAI/GL/wiki/SC_Managers_Phase1) will prepare candidate success criteria, ready for inclusion in the guidelines document. To prepare success criteria, follow these steps:

<!--1. [Fork this repository](https://help.github.com/articles/fork-a-repo/) or, if you have already forked it, [update your fork](https://help.github.com/articles/syncing-a-fork/). It is important to keep your fork up to date to avoid merge conflicts.-->
1. [Clone the repository](https://help.github.com/articles/cloning-a-repository/), using the URI https://github.com/w3c/wcag21.git to clone.
1. Switch to the working branch for the proposal, which is named for the shortname of the draft success criterion and the issue number, concatenated together.
1. Find the appropriate file for the success criterion in the guidelines/sc/21 folder, named the same as the start of the branch name, and open in an HTML-capable editor. Do the same with any definitions referenced by the success criterion, in the guidelines/terms/21 folder.
1. Open the guidelines/index.html file and remove comment marks around the lines that reference the success criterion and terms you have edited..
1. Follow the [success criteria format](#user-content-success-criteria-format) below to create the SC content.
1. Save the file and commit the change. NOTE: It is important to also add a suitable 'commit message'. In the comments, reference the issue number from which the proposal was developed starting with a hash, e.g., `#1`. 
1. When the success criterion is ready for Working Group review, inform the chairs. Once the proposal has been accepted by the Working Group, the editors will merge the working branch into the master branch, which puts it in the editors' draft and eventual Technical Report publication.

### Success Criteria Format

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

### Definitions

If you providing term definitions along with your SC, include them in the glossary. Position them in the appropriate alphabetical order with the rest of the terms and use the following format:

```html
<dt><dfn>{Term}</dfn></dt>
<dd>{Definition}</dd>
```

The ```dfn``` element tells the script that this is a term and causes special styling and linking features. To link to a term, use an `<a>` element without an `href` attribute; if the link text is the same as the term, the link will be correctly generated. For example, if there is a term `<dfn>web page</dfn>` on the page, a link in the form of `<a>web page</a>` will result in a proper link. If the link text has a different form from the canonical term, e.g., "web pages" (note the plural), you can provide a hint on the term definition with the `data-lt` attribute. In this example, modify the term to be `<dfn data-lt="web pages">web page</dfn>`. Multiple alternate names for the term can be separated with pipe characters, with no leading or trailing space, e.g., `<dfn data-lt="web pages|page|pages">web page</dfn>`.

## Editing Draft Understanding Content

There is one Understanding file per success criterion, plus an index:

* understanding/index.html - index page, need to uncomment or add a reference to individual Understanding pages as they are made available
* understanding/21/*.html - files for each understanding page, named the same as the success criterion file in the guidelines

Files are populated with a template that provides the expected structure. Leave the template structure in place, and add content as appropriate within the sections. Elements with class="instructions" provide guidance about what content to include in that section; you can remove those elements if you want but don't have to. The template for examples proposes either a bullet list or a series of sub-sections, choose one of those approaches and remove the other from the template. The template for techniques includes sub-sections for "situations", remove that wrapper section if not needed.

Understanding files are referenced from the relevant Success Criterion on the WCAG 2.1 page; these links are put in by the script.

The formal publication location for Understanding pages is https://www.w3.org/WAI/WCAG21/Understanding/. This content is updated as needed; and may be automated.

## Editing Techniques

Techniques are in the techniques folder, and grouped by technology into sub-folders. Each technique is a standalone file, which is in HTML format with a regular structure of elements, classes, and ids. Techniques previously published for WCAG 2.0 are currently have the assigned ID of the technique as the filename, but new techniques should use a filename that is derived from a shortened version of the technique title. 

For example, a technique "Using the alt attribute on the img element to provide short text alternatives" might use "img-alt-short-text-alternatives.html" as the filename.

### Create Techniques

* Determine a filename for the technique that is likely to be descriptive, unique, and short.
* Create a working branch named the same as the technique filename.
* Copy the techniques/technique-template.html file into the appropriate technology folder for the technique, and give it the chosen file name.
* Populate the template with appropriate content, using other techniques as examples for code formatting choices. Keep the existing structural sections from the template in place.
* When the technique is ready for review, ask the chairs to arrange WG review and merge.

### Associate Techniques with Success Criteria

PROPOSED: edit the [wcag21.json](wcag21.json) file to add a technique entry into each SC where appropriate. Entries can declare the technique to be sufficient, advisory, or failure on a per SC basis. The (proposed) generator will use this to provide links in the various places needed.

ALTERNATE: create a HTML-based data structure, which would be easier to read but harder to edit correctly.

ALTERNATE: link to techniques from Understanding as we have done before, but this allows inconsistencies and is harder to extract data from.

### Provide Working Examples of Techniques

@@