WCAG (Web Content Accessibility Guidelines) 2
===

This repository is used to develop content for WCAG 2, as well as associated understanding documents and techniques.

See [Onboarding for working in Github](https://www.w3.org/WAI/GL/wiki/Onboarding_for_working_in_Github)

## Editorial style guide

@@To complete

* Avoid use of RFC2119 terms such as "must", "shall", or "may" in non-normative content, to avoid confusion with normative role.

See also: [WCAG 2 Style Guide](https://github.com/w3c/wcag/wiki/WCAG-2-style-guide)

## File Structure

Content for WCAG 2.1 and later is organized according to the file structure below. The WCAG repository contains source and auxiliary files for WCAG 2, Understanding WCAG 2, and eventually techniques. It also contains auxiliary files that support automated formatting of the document. To facilitate multi-party editing, each success criterion is in a separate file, consisting of a HTML fragment that can be included into the main guidelines. Key files include:

* `guidelines/index.html` - the main guidelines file
* `guidelines/sc/{version}/*.html` - files for each success criterion
* `guidelines/terms/{version}/*.html` - files for each definition
* `understanding/{version}/*.html` - understanding files for each success criterion

Where `{version}` is "20", content came from WCAG 2.0. "21" is used for content introduced in WCAG 2.1, "22" for WCAG 2.2, etc.

## Build System

The Techniques and Understanding documents are processed through a build system based on Eleventy and Liquid for templating and Cheerio for transformations.
More details, including instructions for previewing the output locally, can be found in the [build process README](11ty/README.md).

## Editing Draft Success Criteria

[Success Criteria Managers](https://www.w3.org/WAI/GL/wiki/SC_Managers_Phase1) will prepare candidate success criteria, ready for inclusion in the guidelines document. To prepare success criteria, follow these steps:

1. [Clone the repository](https://help.github.com/articles/cloning-a-repository/), using the URI https://github.com/w3c/wcag.git to clone.
1. Switch to the working branch for the proposal, which is named for the shortname of the draft success criterion and the issue number, concatenated together.
1. Find the appropriate file for the success criterion in the guidelines/sc/21 folder, named the same as the start of the branch name, and open in an HTML-capable editor. Do the same with any definitions referenced by the success criterion, in the guidelines/terms/21 folder.
1. Open the guidelines/index.html file and remove comment marks around the lines that reference the success criterion and terms you have edited..
1. Follow the [success criteria format](#user-content-success-criteria-format) below to create the SC content.
1. Save the file and commit the change. NOTE: It is important to also add a suitable 'commit message'. In the comments, reference the issue number from which the proposal was developed starting with a hash, e.g., `#1`. 
1. When the success criterion is ready for Working Group review, inform the chairs. Once the proposal has been accepted by the Working Group, the editors will merge the working branch into the main branch, which puts it in the editors' draft and eventual Technical Report publication.

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

Values you provide are described below. Refer to [Success Criterion 2.2.1](https://www.w3.org/TR/WCAG22/#timing-adjustable) for an example of each of these pieces of content.

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

If you are providing term definitions along with your SC, include them in the respective `guidelines/terms/{version}` directory, one-per-file, using the following format:

```html
<dt><dfn id="dfn-{shortname}">{Term}</dfn></dt>
<dd>{Definition}</dd>
```

The `dfn` element tells the script that this is a term and causes special styling and linking features. To link to a term, use an `<a>` element without an `href` attribute; if the link text is the same as the term, the link will be correctly generated. For example, if there is a term `<dfn>web page</dfn>` on the page, a link in the form of `<a>web page</a>` will result in a proper link.

If the link text has a different form from the canonical term, e.g., "web pages" (note the plural), you can provide a hint on the term definition with the `data-lt` attribute. In this example, modify the term to be `<dfn data-lt="web pages">web page</dfn>`. Multiple alternate names for the term can be separated with pipe characters, with no leading or trailing space, e.g., `<dfn data-lt="web pages|page|pages">web page</dfn>`.

## Editing Draft Understanding Content

There is one Understanding file per success criterion, plus an index:

* `understanding/index.html` - index page, need to uncomment or add a reference to individual Understanding pages as they are made available
* `understanding/{version}/*.html` - files for each understanding page, named the same as the success criterion file in the guidelines

Files are populated with a template that provides the expected structure. Leave the template structure in place, and add content as appropriate within the sections. Elements with class="instructions" provide guidance about what content to include in that section; you can remove those elements if you want but don't have to. The template for examples proposes either a bullet list or a series of sub-sections, choose one of those approaches and remove the other from the template.

Note that associated techniques are no longer defined within each understanding page; they are now defined in the `associatedTechniques` field in `understanding/understanding.11tydata.js`. See [Associated Techniques Data](11ty/README.md#associated-techniques-data) for more information.

Understanding files are referenced from the relevant Success Criterion on the WCAG specification; these links are put in by the script.

The formal publication location for Understanding pages is currently https://www.w3.org/WAI/WCAG22/Understanding/. This content is updated as needed; and may be automated.

## Editing Techniques

Techniques are in the techniques folder, and grouped by technology into sub-folders. Each technique is a standalone file, which is in HTML format with a regular structure of elements, classes, and ids.

### Technique File Structure

The [technique template](techniques/technique-template.html) shows the structure of techniques. Main sections are in top-level &lt;section> elements with specific IDs: meta, applicability, description, examples, tests, related, resources. The description and tests sections are required; the applicability and examples sections are recommended; the related and resources sections are optional. The meta section provides context for the technique during authoring but is removed for publication. The title of the technique is in the `<h1>` element. Elements with `class="instructions"` provide information about populating the template. They should be removed as the technique is developed but if not removed, will be ignored by the generator. **Do not copy `class="instructions"` on real content.**

Techniques can use a temporary style sheet to facilitate review of drafts. This style sheet is replaced by other style sheets and structure for formal publication. To use this style sheet, add `<link rel="stylesheet" type="text/css" href="../../css/editors.css"/>` to the head of the technique.

### Images, Examples, Cross References for Techniques

Techniques can include images. Place the image file in the `img` folder of the relevant technology - meaning all techniques for a technology share a common set of images. Use a relative link to load the image. Most images should be loaded with a `<figure>` element and labeled with a `<figcaption>` positioned at the bottom of the figure. `<figure>` elements must have an `id` attribute. Small inline images may be loaded with a `<img>` element with suitable `alt` text.

Techniques should include brief code examples to demonstrate how to author content that follows the technique. Code examples should be easy to read, and usually not complete content in themselves. More complete examples can be provided as [working examples](#user-content-provide-working-examples-of-techniques) (see below). Link to working examples at the bottom of each example, in a `<p class="working-example">` element, containing a relative link to `../../working-examples/{example-name}/`.

Cross references to other techniques may be provided where useful. Generally they should be provided in the "Related Techniques" section but can be provided elsewhere. Use a relative link to reference the technique, `{Technique ID}` if the same technology, or `../{Technology}/{Technique ID}` otherwise. If the technique is still under development and does not have a formal ID, reference the path to the development file. If the technique is under development in a different branch, use an absolute URI to the rawgit version of the technique.

Cross references to guidelines and success criteria should use a relative URI to the *Understanding* page for that item. Cross references to other parts of the guidelines should use an absolute URI to the guidelines as published on the W3C TR page, a URI beginning with `https://www.w3.org/TR/WCAG22/#`. Note that references to guidelines or success criteria to which techniques relate are added by the generator upon publication based on information in the Understanding documents, so redundant links to those is not normally needed or advised.

### Create Techniques

[General priorities and process to work on techniques are maintained in the wiki](https://www.w3.org/WAI/GL/wiki/Wcag21-techniques).

New techniques should use a filename that is derived from a shortened version of the technique title. Editors will assign the technique an ID and rename the file when it is accepted by the Working Group. For example, a technique "Using the alt attribute on the img element to provide short text alternatives" might use "img-alt-short-text-alternatives.html" as the filename. The editors will assign it a formal ID, and rename the file, when it is accepted by the Working Group.

Each new technique should be created in a new branch. Set-up of the branch and file is automated via the create-techniques.sh script, which can be run with bash. The command line is:

```
bash create-techniques.sh <technology> <filename> <type> "<title>"
```

* `<technology>` is the technology directory for the technique
* `<filename>` is the temporary filename (without extension) for the technique
* `<type>` is "technique" or "failure"
* `<title>` is the title of the technique, enclosed in quotes and escaping special characters with \\

This automates the following steps:

* Determine a filename for the technique that is likely to be descriptive, unique, and short.
* Create a working branch named the same as the technique filename.
* Copy the techniques/technique-template.html file into the appropriate technology folder for the technique, and give it the chosen file name.
* In the section element with id "meta", indicate to which guideline or success criterion the technique relates, and whether the technique is sufficient, advisory, or a failure for that item. Multiple applicability are allowed.

Once a technique branch and file is set up, populate the content and request review:

* Populate the template with appropriate content, using other techniques as examples for code formatting choices. Keep the existing structural sections from the template in place.
* When the technique is ready for review, make a pull request into the main branch.
* If you wish to reference the draft technique from an Understanding document, use the technique's rawgit URI.
* After a technique is approved, the chairs will assign it an ID and update links to it in the Understanding documents. 

### Formatting Techniques

Techniques in the repository are plain HTML files with minimal formatting. For publication to the editors' draft and W3C location, techniques are formatted by the Eleventy build process described above in the [Build System section](#build-system).

The generator compiles the techniques together as a suite with formatting and navigation. It enforces certain structures, such as ordering top-level sections described above and standardizing headings. It attempts to process cross reference links to make sure the URIs work upon publication. One of the most substantial roles is to populate the Applicability section with references to the guidelines or success criteria to which the technique relates. The information for this comes from the Understanding documents. Proper use of the technique template is important to enable this functionality, and mal-formed techniques may cause the generator to fail.

### Obsolete Techniques

Obsolete techniques should not be removed from the repository. Instead, they can be marked using YAML front-matter. For example:

```yaml
---
obsoleteSince: 22
obsoleteMessage: |
  This failure relates to 4.1.1: Parsing, which was removed as of WCAG 2.2.
---
```

* `obsoleteSince` indicates the earliest version of WCAG 2 when the technique became obsolete
  (this may be set to `20` if it should effectively be obsolete for all versions, e.g. for
  techniques involving deprecated HTML elements)
* `obsoleteMessage` indicates a message to be displayed within the About this Technique section

In cases where entire technologies are obsolete (e.g. Flash and Silverlight), these properties may also be specified at the technique subdirectory level, e.g. via `techniques/flash/flash.11tydata.json`.
Note that this case specifically requires JSON format, as this is consumed by both Eleventy and additional code in the build process used to assemble techniques data.

## Spell-checking

Both the normative and informative content is checked for spelling errors using [cspell](https://cspell.org/). This check runs on pull requests, and can be run locally via `npm run cspell` (requires [Node.js](https://nodejs.org/); remember to run `npm i` first if you haven't recently).

### Adding valid words

If a word is flagged that should be allowed anywhere it appears, add a line to the top-level `custom-words.txt` file, ideally under the appropriate section in alphabetical order.

If a word is flagged that should be allowed in a specific file, but should be considered incorrect elsewhere, add an entry to the `overrides` list in the top-level `cspell.yml` file. (Several examples already exist for reference.)

Note that both inline code and code blocks are ignored, so if you are using a term that pertains to a specific language/syntax, consider enclosing it in `<code>` or `<pre>` as appropriate.

## Version-specific Documentation

Informative documents are generated from the same source files for both WCAG 2.2 and 2.1,
as most of their content is consistent between them. (The guidelines themselves continue to be
maintained on separate branches e.g. `WCAG-2.1`, for purposes of maintaining separate Editors' Drafts.)

When building informative documents for older versions, the build system prunes success criteria that are
specific to newer versions, and in turn any techniques that are exclusively related to those criteria.

There are a few cases where content may need to cater to a specific version, explained in this section.

### Specifying Precise Version Number within Informative Documents

**Note:** This is _only_ applicable within `techniques` and `understanding` folders (_not_ `guidelines`).

In cases where the precise version number should be displayed within informative documents,
insert `{{ versionDecimal }}`. This will be replaced with the decimal-point-delimited version number,
e.g. 2.1 or 2.2.

### "New in {version}" Call-outs

In cases where a document pertaining to multiple versions warrants a specific call-out about an update in
a newer version, `class="wcagXY"` can be applied to an element surrounding the prose in question
(e.g. `class="wcag22"` for WCAG 2.2). This will result in the prose being omitted from earlier versions,
and displayed with the prefix "New in WCAG X.Y: " in applicable versions.

This class can also be applied alongside the `note` class, in which case " (New in WCAG X.Y)" will be
appended to the "Note" title in applicable versions, and the note will be hidden in earlier versions.

### Techniques Change Log

Data for the Techniques Change Log is now generated automatically by a script that reads git history;
see [Eleventy Usage](11ty/README.md#usage).

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
* Reference working examples from techniques using the rawgit URI to the example in its development branch, e.g., `https://rawgit.com/w3c/wcag/main/working-examples/alt-attribute/`. Editors will update links when examples are approved.
* When the example is complete and functional, submit a pull request into the main branch.

## Errata

The errata documents for WCAG 2.1 and 2.2 are now maintained in this repository.
See the [Errata README](errata/README.md) for authoring details.

**Note:** The errata for both versions are maintained on the `main` branch for use in builds.
Direct edits to the guidelines for WCAG 2.1 must be performed under `guidelines/` on the `WCAG-2.1` branch.

## Translations

WCAG 2.2 is ready for translation. To translate WCAG 2.2, follow instructions at [How to Translate WCAG 2](https://www.w3.org/WAI/about/translating/wcag/).
