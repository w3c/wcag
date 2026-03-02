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
	publishDate:          "2024-12-12",
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
	prevRecURI: "https://www.w3.org/TR/WCAG21/",
	//previousDiffURI: "https://www.w3.org/TR/2014/REC-wai-aria-20140320/",
	
	// if there a publicly available Editors Draft, this is the link
	edDraftURI: "https://w3c.github.io/wcag/guidelines/22/",
	
	// if this is a LCWD, uncomment and set the end of its review period
	// lcEnd: "2012-02-21",
	
	// editors, add as many as you like
	// only "name" is required
	editors: [
		{
			name: "Alastair Campbell",
			//url: "https://www.nomensa.com/",
			mailto: "acampbell@nomensa.com",
			company: "Nomensa",
			companyURI: "https://www.nomensa.com/",
			w3cid: 44689
		},
		{
			name: "Chuck Adams",
			//url: "https://www.oracle.com/",
			mailto: "charles.adams@oracle.com",
			company: "Oracle",
			companyURI: "https://www.oracle.com/",
			w3cid: 104852
		},
		{
			name: "Rachael Bradley Montgomery",
			mailto: "rachael@accessiblecommunity.org",
			company: "Library of Congress",
			companyURI: "https://loc.gov/",
			w3cid: 90310
		},
    {
			name: "Michael Cooper",
			url: 'https://www.w3.org/People/cooper',
			company: "W3C",
			companyURI: "https://www.w3.org",
			w3cid: 34017,
			retiredDate: "2023-07-31"
		},
		{
			name: "Andrew Kirkpatrick",
			company: "Adobe",
			companyURI: "http://www.adobe.com/",
			w3cid: 39770,
			retiredDate: "2020-03-04"
		}
  ],
	
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
	
	errata: 'https://www.w3.org/WAI/WCAG22/errata/',
  implementationReportURI: 'https://www.w3.org/WAI/WCAG22/implementation-report/',
	
	// name of the WG
	group:  "ag",
	github: "w3c/wcag",

	maxTocLevel: 4,
	
	postProcess: [postRespec]
	
};
