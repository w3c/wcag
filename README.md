WCAG (Web Content Accessibility Guidelines)
===

Please do not submit any new pull requests against this branch - please look in the list of branches for the most current Working Branch and use that one.

This repository is used to develop content for WCAG 2, as well as associated understanding documents and techniques.

## File Structure

WCAG 2.0 was maintained in a different file structure than subsequent versions of WCAG. Source files for WCAG 2.0 are in the wcag20 folder and exists primarily for archival purposes. Do not edit content in that folder.

Content for WCAG 2.1 and later is organized accordign to the file structure below. The WCAG repository contains source and auxiliary files for WCAG 2, Understanding WCAG 2, and eventually techniques. It also contains auxiliary files that support automated formatting of the document. To facilitate multi-party editing, each success criterion is in a separate file, consisting of a HTML fragment that can be included into the main guidelines. Key files include:

* guidelines/index.html - the main guidelines file
* guidelines/sc/<version>/*.html - files for each success criterion
* guidelines/terms/<version>/*.html - files for each definition
* understanding/<version>/*.html - understanding files for each success criterion

Where <version> is "20", content came from WCAG 2.0. "21" is used for content introduced in WCAG 2.1, "22" for WCAG 2.2, etc.

## Editing Draft Success Criteria

[Success Criteria Managers](https://www.w3.org/WAI/GL/wiki/SC_Managers_Phase1) will prepare candidate success criteria, ready for inclusion in the guidelines document. To prepare success criteria, follow these steps:

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
* understanding/<version>/*.html - files for each understanding page, named the same as the success criterion file in the guidelines

Files are populated with a template that provides the expected structure. Leave the template structure in place, and add content as appropriate within the sections. Elements with class="instructions" provide guidance about what content to include in that section; you can remove those elements if you want but don't have to. The template for examples proposes either a bullet list or a series of sub-sections, choose one of those approaches and remove the other from the template. The template for techniques includes sub-sections for "situations", remove that wrapper section if not needed.

Understanding files are referenced from the relevant Success Criterion on the WCAG specification; these links are put in by the script.

The formal publication location for Understanding pages is currently https://www.w3.org/WAI/WCAG21/Understanding/. This content is updated as needed; and may be automated.

## Editing Techniques

Techniques are in the techniques folder, and grouped by technology into sub-folders. Each technique is a standalone file, which is in HTML format with a regular structure of elements, classes, and ids. Techniques previously published for WCAG 2.0 are currently have the assigned ID of the technique as the filename, but new techniques should use a filename that is derived from a shortened version of the technique title. 

For example, a technique "Using the alt attribute on the img element to provide short text alternatives" might use "img-alt-short-text-alternatives.html" as the filename.

### Create Techniques

* Determine a filename for the technique that is likely to be descriptive, unique, and short.
* Create a working branch named the same as the technique filename.
* Copy the techniques/technique-template.html file into the appropriate technology folder for the technique, and give it the chosen file name.
* In the section element with id "meta", indicate to which guideline or success criterion the technique relates, and whether the technique is sufficient, advisory, or a failure for that item. Multiple applicability are allowed.
* Populate the template with appropriate content, using other techniques as examples for code formatting choices. Keep the existing structural sections from the template in place.
* When the technique is ready for review, ask the chairs to arrange WG review and merge.
* If you wish to reference the draft technique from an Understanding document, use the technique's rawgit URI.
* After a technique is approved, the chairs will assign it an ID and update links to it in the Undestanding documents. 

### Provide Working Examples of Techniques

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
