var version="22";

function titleToPathFrag (title) {
	return title.toLowerCase().replace(/[\s,]+/g, "-").replace(/[\(\)]/g, "");
}

function findHeading(el) {
	return el.querySelector('h1, h2, h3, h4, h5, h6');
}

function textNoDescendant(el) {
	var textContent = "";
	el.childNodes.forEach(function(node) {
		if (node.nodeType == 3) textContent += node.textContent;
	})
	return textContent;
}

function linkUnderstanding() {
	var understandingBaseURI;
	if (respecConfig.specStatus == "ED") understandingBaseURI = "../../understanding/";
	else understandingBaseURI = "https://www.w3.org/WAI/WCAG" + version + "/Understanding/";
	document.querySelectorAll('.sc,.guideline').forEach(function(node){
		var heading = textNoDescendant(findHeading(node));
		var pathFrag = titleToPathFrag(heading);
		if (node.id == "parsing") pathFrag = "parsing"; // special case parsing
		var el = document.createElement("div");
		el.setAttribute("class", "doclinks");
		el.innerHTML = "<a href=\"" + understandingBaseURI + pathFrag + ".html\">Understanding " + heading + "</a> <span class=\"screenreader\">|</span> <br /><a href=\"https://www.w3.org/WAI/WCAG" + version + "/quickref/#" + pathFrag + "\">How to Meet " + heading + "</a>";
		if (node.className = "sc") node.insertBefore(el, node.children[2]);
		if (node.className = "guideline") node.insertBefore(el, node.children[1]);
	})
}

function addTextSemantics() {
	// put brackets around the change marker
	document.querySelectorAll('p.change').forEach(function(node){
		var change = node.textContent;
		node.textContent = "[" + change + "]";
	})
	// put level before and parentheses around the conformance level marker
	document.querySelectorAll('p.conformance-level').forEach(function(node){
		var level = node.textContent;
		node.textContent = "(Level " + level + ")";
	})
	// put principle in principle headings
	document.querySelectorAll('section.sc h2 bdi.secno').forEach(function(node){
		var num = node.textContent;
		node.textContent = "Principle " + num;
	})
	// put guideline in GL headings
	document.querySelectorAll('section.guideline h3 bdi.secno').forEach(function(node){
		var num = node.textContent;
		node.textContent = "Guideline " + num;
	})
	// put success criterion in SC headings
	document.querySelectorAll('section.sc h4 bdi.secno').forEach(function(node){
		var num = node.textContent;
		node.textContent = "Success Criterion " + num;
	})
}

function markConformanceLevel() {
}

function swapInDefinitions() {
	if (new URLSearchParams(window.location.search).get("defs") != null) document.querySelectorAll('.internalDFN').forEach(function(node){
		node.title = node.textContent;
		node.textContent = findDef(document.querySelector(node.href.substring(node.href.indexOf('#'))).parentNode.nextElementSibling.firstElementChild).textContent;
	})
	function findDef(el){
		if (el.hasAttribute('class')) return findDef(el.nextElementSibling);
		else return el;
	}
}

function termTitles() {
	// put definitions into title attributes of term references
	document.querySelectorAll('.internalDFN').forEach(function(node){
		var dfn = document.querySelector(node.href.substring(node.href.indexOf('#')));
		if (dfn.parentNode.nodeName == "DT") node.title = dfn.parentNode.nextElementSibling.firstElementChild.textContent.trim().replace(/\s+/g,' ');
		else if (dfn.title) node.title=dfn.title;
	});	
}

// number notes if there are multiple per section
function numberNotes() {
	var sectionsWithNotes = new Array();
	document.querySelectorAll(".note").forEach(function(note) {
		var container = note.closest("dd");
		if (container == null) container = note.closest("section");
		sectionsWithNotes.push(container);
	});
	
	sectionsWithNotes.forEach(function(sec) {
		if (sec.noteprocessed) return;
		var notes = sec.querySelectorAll('.note');
		// no notes, shouldn't happen
		if (notes.length == 0) return;
		// one note, leave alone
		if (notes.length == 1) return;
		// more than one note, number them
		if (notes.length > 1) {
			var count = 1;
			sec.querySelectorAll(".note").forEach(function(note) {
				var span = note.querySelector(".note-title span");
				span.textContent = "Note " + count;
				count++;
			});
		}
		sec.noteprocessed = true;
	});
}

// change the numbering of examples to remove number from lone examples in a section, and restart numbering for multiple in each section
function renumberExamples() {
	var sectionsWithExamples = new Array();
	document.querySelectorAll(".example").forEach(function(example) {
		var container = example.closest("dd"); // use dd container if present
		if (container == null) container = example.closest("section"); // otherwise section
		sectionsWithExamples.push(container);
	});
	
	sectionsWithExamples.forEach(function(sec) {
		if (sec.exprocessed) return;
		var examples = sec.querySelectorAll(".example");
		// no examples, shouldn't happen
		if (examples.length == 0) return;
		// one example, remove the numbering
		// more than one example, number them
		else {
			var count = 1;
			var rmOrAdd = examples.length == 1 ? "rm" : "add";
			sec.querySelectorAll(".example").forEach(function(example) {
				var marker = example.querySelector(".marker");
				if (rmOrAdd == "rm") marker.textContent = "Example";
				else marker.textContent = "Example " + count;
				count++;
			});
		}
		sec.exprocessed = true;
	});
}

// scripts after Respec has run
function postRespec() {
	addTextSemantics();
	swapInDefinitions();
	termTitles();
	linkUnderstanding();
	numberNotes();
	renumberExamples();
}
