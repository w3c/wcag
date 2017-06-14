function titleToPathFrag (title) {
	return title.toLowerCase().replace(/[\s,]+/g, "-").replace(/[\(\)]/g, "");
}

function linkUnderstanding() {
	var understandingBaseURI;
	if (respecConfig.specStatus == "ED") understandingBaseURI = "../understanding/21/";
	else understandingBaseURI = "https://www.w3.org/WAI/WCAG21/Understanding/";
	document.querySelectorAll('.sc.new,.sc.proposed').forEach(function(node){
		var heading = node.firstElementChild.textContent;
		var el = document.createElement("div");
		el.setAttribute("class", "doclinks");
		el.innerHTML = "<a href=\"" + understandingBaseURI + titleToPathFrag(heading) + ".html\">Understanding " + heading + "</a>";
		node.insertBefore(el, node.children[1]);
	})
}

require(["core/pubsubhub"], function(respecEvents) {
    "use strict";
    respecEvents.sub('end', function(message) {
    	if (message === 'core/link-to-dfn') {
    		linkUnderstanding();
    	}
	})
})

// Fix the scroll-to-fragID problem:
require(["core/pubsubhub"], function (respecEvents) {
    "use strict";
    respecEvents.sub("end-all", function () {
        if(window.location.hash) {
            window.location = window.location.hash;
        }
    });
});
