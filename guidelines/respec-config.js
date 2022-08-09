var respecConfig = {
	// embed RDFa data in the output
	trace:  true,
	useExperimentalStyles: true,
	doRDFa: '1.1',
	includePermalinks: true,
	permalinkEdge:     true,
	permalinkHide:     false,
	tocIntroductory: true,
	// specification status (e.g., WD, LC, NOTE, etc.). If in doubt use ED.
	specStatus:           "ED",
	//crEnd:                "2012-04-30",
	//perEnd:               "2013-07-23",
	//publishDate:          "2013-08-22",
	diffTool:             "http://www.aptest.com/standards/htmldiff/htmldiff.pl",
	
	// the specifications short name, as in https://www.w3.org/TR/short-name/
	shortName:            "WCAG22",
	
	
	// if you wish the publication date to be other than today, set this
	//publishDate:  "2014-12-11",
	copyrightStart:  "2020",
	license: "document",
	
	// if there is a previously published draft, uncomment this and set its YYYY-MM-DD date
	// and its maturity status
	//previousPublishDate:  "2014-06-12",
	//previousMaturity:  "WD",
	prevRecURI: "https://www.w3.org/TR/WCAG/",
	//previousDiffURI: "https://www.w3.org/TR/2014/REC-wai-aria-20140320/",
	
	// if there a publicly available Editors Draft, this is the link
	edDraftURI: "https://w3c.github.io/wcag/guidelines/22/",
	
	// if this is a LCWD, uncomment and set the end of its review period
	// lcEnd: "2012-02-21",
	
	// editors, add as many as you like
	// only "name" is required
	editors: [
		{
			name: "Chuck Adams",
			//url: "https://www.oracle.com/",
			mailto: "charles.adams@oracle.com",
			company: "Oracle",
			companyURI: "https://www.oracle.com/",
			w3cid: 104852
		},
		{
			name: "Alastair Campbell",
			//url: "https://www.nomensa.com/",
			mailto: "acampbell@nomensa.com",
			company: "Nomensa",
			companyURI: "https://www.nomensa.com/",
			w3cid: 44689
		},
		{
			name: "Rachael Montgomery",
			mailto: "rachael@accessiblecommunity.org",
			company: "Invited Expert",
			w3cid: 90310
		},
		{
			name: "Michael Cooper",
			url: 'https://www.w3.org/People/cooper',
			//mailto: "cooper@w3.org",
			company: "W3C",
			companyURI: "https://www.w3.org",
			w3cid: 34017
		},
		{
			name: "Andrew Kirkpatrick",
			//url: "http://www.adobe.com/",
			mailto: "akirkpat@adobe.com",
			company: "Adobe",
			companyURI: "http://www.adobe.com/",
			w3cid: 39770
		}
	],
	/* 
	formerEditors: [
		{
			name: "Ben Caldwell",
			company: "Trace R&D Center, University of Wisconsin-Madison",
			w3cid: 33602
		},
		{
			name: "Loretta Guarino Reid",
			company: "Google, Inc.",
			w3cid: 35436
		},
		{
			name: "Gregg Vanderheiden",
			company: "Trace R&D Center, University of Wisconsin-Madison",
			w3cid: 3442
		},
		{
			name: "Wendy Chisholm",
			company: "W3C",
			w3cid: 4099
		},
		{
			name: "John Slatin",
			company: "Accessibility Institute, University of Texas at Austin",
			w3cid: 35537
		},
		{
			name: "Jason White",
			company: "University of Melbourne",
			w3cid: 74028
		},
		{
			name: "Joshue O Connor",
			company: "Invited Expert, InterAccess",
			w3cid: 41218
		}
	],
	*/
	
	// authors, add as many as you like.
	// This is optional, uncomment if you have authors as well as editors.
	// only "name" is required. Same format as editors.
	
	//authors:  [
	//    { name: "Your Name", url: "http://example.org/",
	//      company: "Your Company", companyURI: "http://example.com/" },
	//],
	
	/*
	alternateFormats: [
		{ uri: 'wcag21-diff.html', label: "Diff from Previous Recommendation" } ,
		{ uri: 'wcag21.ps', label: "PostScript version" },
		{ uri: 'wcag21.pdf', label: "PDF version" }
	],
	*/
	
	// errata: 'https://www.w3.org/2010/02/rdfa/errata.html',
	
	// name of the WG
	group:           "ag",
	github: "w3c/wcag",

	maxTocLevel: 4,
	
	postProcess: [postRespec]
	
};
