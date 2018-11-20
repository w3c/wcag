window.onload = init;

function init()
{
	var objForeground = document.getElementById('forelink');
	var objBackground = document.getElementById('backlink');
	var objForm = document.getElementById('colourpicker');

	// Set up event handlers for foreground and background colour picker links
	objForeground.onclick = function(){return selectColour(this);};
	objBackground.onclick = function(){return selectColour(this);};
	// Set up an event handler for when the form is submitted
	objForm.onsubmit = function(){return changeColour();};
}

// Function to build the colour picker
// objElement is the anchor used to activate the dialog 
function selectColour(objElement)
{
	var iInnerRed, iInnerGreen, iInnerBlue, strColour;
	var iCounter = 0;
	var objExisting = document.getElementById('cchoices');
	var objPicker = document.createElement('div');
	var objRow = document.createElement('div');
	var objAnchor, objCol, objImage;

	// If the colour picker dialog is already present, remove it
	if (objExisting)
	{
		objExisting.parentNode.removeChild(objExisting);
	}
	objPicker.setAttribute('id', 'cchoices');

	// Start to build the colour picker

	// Add a panel to contain the currently selected colour
	objCol = document.createElement('div');
	objCol.appendChild(document.createTextNode('#000'));
	objCol.setAttribute('id', 'tooltip');
	objRow.appendChild(objCol);
	objPicker.appendChild(objRow);
	objRow = document.createElement('div');

	// Iterate through all web-safe colours (e.g. #fc0) to build
	// a colour picker grid
	// Steps of 16 for red, green, and blue
	for (iInnerRed=0; iInnerRed<16; iInnerRed+=3)
	{
		for (iInnerGreen=0; iInnerGreen<16; iInnerGreen+=3)
		{
			for (iInnerBlue=0; iInnerBlue<16; iInnerBlue+=3)
			{
				iCounter++;

				// Add a colour cell for our grid
				objCol = document.createElement('span');
				// Convert our red, green, and blue values to hexadecimal to
				// create a short-hand hex triplet colour value
				strColour = '#' + iInnerRed.toString(16).toUpperCase() + iInnerGreen.toString(16).toUpperCase() + iInnerBlue.toString(16).toUpperCase();

				// Add an anchor and events to handle mouse and keyboard behaviour
				objAnchor = document.createElement('a');
				objAnchor.setAttribute('href', '#');
				objAnchor.setAttribute('id', 'cp' + iCounter);
				objAnchor.onclick = function(){return setColour(this, objElement);};
				objAnchor.onkeydown = function(event){return navigatePicker(this, event);};
				objAnchor.onfocus = function(){return updateTooltip(this);};
				objAnchor.onmouseover = function(){return updateTooltip(this);};

				// Add a transparent image with the alt text containing the colour value
				// and set the background property of the image using the colour value
				objImage = document.createElement('img');
				objImage.setAttribute('src', 'pot.gif');
				objImage.setAttribute('width', '10');
				objImage.setAttribute('height', '10');
				objImage.setAttribute('alt', strColour);
				objImage.style.backgroundColor = strColour;
				objAnchor.appendChild(objImage);
				objCol.appendChild(objAnchor);

				// Add the cell to the current row in our grid
				objRow.appendChild(objCol);

				// Limit each row to 12 cells
				if (iCounter%12 === 0)
				{
					objPicker.appendChild(objRow);
					objRow = document.createElement('div');
				}
			}
		}
	}
	// Add the picker to the document, and set focus on
	// the first cell in the grid
	document.body.appendChild(objPicker);
	document.getElementById('cp1').focus();

	return false;
}

// Function to update the panel with the currently selected colour
// in the colour picker dialog (either from mouse hover, or 
// keyboard focus)
//
// objElement is the anchor that is currently selected
function updateTooltip(objElement)
{
	// Get existing tooltip
	var objExisting = document.getElementById('tooltip');

	// Setup a new tooltip
	var objCol = document.createElement('div');
	var strColour = objElement.firstChild.getAttribute('alt');
	objCol.appendChild(document.createTextNode(strColour));
	objCol.setAttribute('id', 'tooltip');

	// Replace the old tooltip with the new tooltip
	objExisting.parentNode.replaceChild(objCol, objExisting);
}

// Function to update the short-hand hex triplet colour in
// the form.
// 
// In this example, the form fields have id values
// of foreground and background. The href attribute of the links
// to activate the colour picker control also has target ids of 
// foreground and background.
//
// objAnchor is the anchor that was selected from the colour picker
// objInput is the anchor that was used to activate the colour picker
function setColour(objAnchor, objInput)
{
	// Extract the id from the href attribute
	var strID = objInput.href.substring(objInput.href.length - 10);
	var objColour = document.getElementById(strID);
	var objPicker = document.getElementById('cchoices');
	// Extract the colour value from the alt attribute
	var strColour = objAnchor.firstChild.getAttribute('alt');

	// Set the value attribute of the input form
	// Belts and braces because of a bug in Mozilla
	objColour.value = strColour;
	objColour.setAttribute('value', strColour);
	// Remove the colour picker dialog
	objPicker.parentNode.removeChild(objPicker);
	// Place focus in the input field
	objColour.focus();

	return false;
}

// Function to change the colours on the page when the form is submitted
function changeColour()
{
	var objHead = document.getElementsByTagName('head')[0];
	var objStyle = document.createElement('style');
	// Get foreground and background colours from form
	var strFore = document.getElementById('foreground').value;
	var strBack = document.getElementById('background').value;
	// Create a style block
	var strCSS = 'body, legend, a{ color: ' + strFore + '; background: ' + strBack + ';}';
	var objText = document.createTextNode(strCSS);

	// If we already have a style block, remove it
	var objExisting = document.getElementsByTagName('style')[0];

	if (objExisting)
	{
		objExisting.parentNode.removeChild(objExisting);
	}

	objStyle.setAttribute('type', 'text/css');

	// IE doesn't allow text to be appended to style elements,
	// so use the proprietary cssText property if it exists,
	// otherwise, append the style block
	if (objStyle.styleSheet)
	{
		objStyle.styleSheet.cssText = strCSS;
	}
	else
	{
		objStyle.appendChild(objText);
	}

	objHead.appendChild(objStyle);

	// Set cookie values so the values can persist on other pages
	setCookie('forecolour', strFore);
	setCookie('backcolour', strBack);

	return false;
}

// A function to improve keyboard access to the picker
// allowing users to navigate by column and row using
// the cursor keys
//
// objAnchor is the currently selected cell
// objEvent is the W3C object property
function navigatePicker(objAnchor, objEvent)
{
	var iKeyCode, strID, iCurID, iDestID, objPicker;

	// If W3C object property is undefined, use
	// IE's proprietary window.event property
	if (!objEvent)
	{
		objEvent = window.event;
	}
	
	iKeyCode = objEvent.keyCode;

	// If the ESC key is pressed, remove the colour picker
	if (iKeyCode == 27)
	{
		objPicker = document.getElementById('cchoices');

		objPicker.parentNode.removeChild(objPicker);
	}

	// if any key other than cursor keys are pressed,
	// pass control back to the colour picker
	if (iKeyCode < 37 || iKeyCode > 40) 
	{
		return true;
	}

	// Determine the number of the current cell
	// The id for each cell is cp1, cp2, and so on
	strID = objAnchor.getAttribute('id');
	iCurID = strID.substr(2, 4);

	// Find out which cursor key was pressed
	switch (iKeyCode)
	{
		case 37: // Left cursor key
			iDestID = iCurID - 1;
			break;
		case 38: // Up cursor key
			iDestID = iCurID - 12;
			break;
		case 39: // Right cursor key
			iDestID = parseInt(iCurID, 10) + 1;
			break;
		case 40: // Down cursor key
			iDestID = parseInt(iCurID, 10) + 12;
			break;
	}

	// If an id exists with the value, move focus
	// to the cell with that id
	if (document.getElementById('cp' + iDestID))
	{
		document.getElementById('cp' + iDestID).focus();
	}

	return false;
}

// A function to set a cookie
//
// strName is the name of the cookie
// strValue is the value for the cookie
function setCookie(strName, strValue)
{
    var dtExpires = new Date();

	// Set an expiry date of 1 year
    dtExpires.setTime(dtExpires.getTime() + (1000 * 60 * 60 * 24 * 365));

	// Write the cookie
    document.cookie = strName + '=' + strValue + '; expires=' + dtExpires.toGMTString() + '; path=/';
}
