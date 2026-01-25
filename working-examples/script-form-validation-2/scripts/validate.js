window.onload = initialise;

function initialise()
{
	var objForms = document.getElementsByTagName('form');
	var iCounter;

	// Attach an event handler for each form
	for (iCounter=0; iCounter<objForms.length; iCounter++)
	{
		objForms[iCounter].onsubmit = function(){return validateForm(this);};
	}
}


// Event handler for the form
function validateForm(objForm)
{
	var arClass = [];
	var iErrors = 0;
	var objField = objForm.getElementsByTagName('input');
	var objLabel = objForm.getElementsByTagName('label');
	var objList = document.createElement('ol');
	var objError, objExisting, objNew, objTitle, objParagraph, objAnchor, objPosition;
	var strLinkID, iFieldCounter, iClassCounter, iCounter;

	// Get the id or name of the form, to make a unique
	// fragment identifier
	if (objForm.id)
	{
		strLinkID = objForm.id + 'ErrorID';
	}
	else
	{
		strLinkID = objForm.name + 'ErrorID';
	}

	// Iterate through input form controls, looking for validation classes
	for (iFieldCounter=0; iFieldCounter<objField.length; iFieldCounter++)
	{
		// Get the class for the field, and look for the appropriate class
		arClass = objField[iFieldCounter].className.split(' ');
		for (iClassCounter=0; iClassCounter<arClass.length; iClassCounter++)
		{
			switch (arClass[iClassCounter])
			{
				case 'string':
					if (!isString(objField[iFieldCounter].value, arClass))
					{
						if (iErrors === 0)
						{
							logError(objField[iFieldCounter], objLabel, objList, strLinkID);
						}
						else
						{
							logError(objField[iFieldCounter], objLabel, objList, '');
						}
						iErrors++;
					}
					break;
				case 'number':
					if (!isNumber(objField[iFieldCounter].value, arClass))
					{
						if (iErrors === 0)
						{
							logError(objField[iFieldCounter], objLabel, objList, strLinkID);
						}
						else
						{
							logError(objField[iFieldCounter], objLabel, objList, '');
						}
						iErrors++;
					}
					break;

				case 'email' :
					if (!isEmail(objField[iFieldCounter].value, arClass))
					{
						if (iErrors === 0)
						{
							logError(objField[iFieldCounter], objLabel, objList, strLinkID);
						}
						else
						{
							logError(objField[iFieldCounter], objLabel, objList, '');
						}
						iErrors++;
					}
					break;
			}
		}
	}

	if (iErrors > 0)
	{
		// If not valid, display error messages
		objError = objForm.getElementsByTagName('div');
		
		// Look for existing errors
		for (iCounter=0; iCounter<objError.length; iCounter++)
		{
			if (objError[iCounter].className == 'validationerrors')
			{
				objExisting = objError[iCounter];
			}
		}

		objNew = document.createElement('div');
		objTitle = document.createElement('h2');
		objParagraph = document.createElement('p');
		objAnchor = document.createElement('a');

		if (iErrors == 1)
		{
			objAnchor.appendChild(document.createTextNode('1 Error in Submission'));
		}
		else
		{
			objAnchor.appendChild(document.createTextNode(iErrors + ' Errors in Submission'));
		}
		objAnchor.href = '#' + strLinkID;
		objAnchor.className = 'submissionerror';

		objTitle.appendChild(objAnchor);
		objParagraph.appendChild(document.createTextNode('Please review the following'));
		objNew.className = 'validationerrors';

		objNew.appendChild(objTitle);
		objNew.appendChild(objParagraph);
		objNew.appendChild(objList);
		
		// If there were existing error, replace them with the new lot,
		// otherwise add the new errors to the start of the form
		if (objExisting)
		{
			objExisting.parentNode.replaceChild(objNew, objExisting);
		}
		else
		{
			objPosition = objForm.firstChild;
			objForm.insertBefore(objNew, objPosition);
		}

		// Allow for latency
		setTimeout(function() { objAnchor.focus(); }, 50);
		
		// Don't submit the form
		objForm.submitAllowed = false;
		return false;
	}

	// Submit the form
	return true;
}

// Function to add a link in a list item that points to problematic field control
function addError(objList, strError, strID, strErrorID)
{
	var objListItem = document.createElement('li');
	var objAnchor = document.createElement('a');
	
	// Fragment identifier to the form control
	objAnchor.href='#' + strID;

	// Make this the target for the error heading
	if (strErrorID.length > 0)
	{
		objAnchor.id = strErrorID;
	}

	// Use the label prompt for the error message
	objAnchor.appendChild(document.createTextNode(strError));
	// Add keyboard and mouse events to set focus to the form control
	objAnchor.onclick = function(event){return focusFormField(this, event);};
	objAnchor.onkeypress = function(event){return focusFormField(this, event);};
	objListItem.appendChild(objAnchor);
	objList.appendChild(objListItem);
}

function focusFormField(objAnchor, objEvent)
{
	var strFormField, objForm;

	// Allow keyboard navigation over links
	if (objEvent && objEvent.type == 'keypress')
	{
		if (objEvent.keyCode != 13 && objEvent.keyCode != 32)
		{
			return true;
		}
	}

	// set focus to the form control
	strFormField = objAnchor.href.match(/[^#]\w*$/);
	objForm = getForm(strFormField);
	objForm[strFormField].focus();
	return false;
}

// Function to return the form element from a given form field name
function getForm(strField)
{
	var objElement = document.getElementById(strField);

	// Find the appropriate form
	do
	{
		objElement = objElement.parentNode;
	} while (!objElement.tagName.match(/form/i) && objElement.parentNode);

	return objElement;
}

// Function to log the error in a list
function logError(objField, objLabel, objList, strErrorID)
{
	var iCounter, strError;

	// Search the label for the error prompt
	for (iCounter=0; iCounter<objLabel.length; iCounter++)
	{
		if (objLabel[iCounter].htmlFor == objField.id)
		{
			strError = objLabel[iCounter].firstChild.nodeValue;
		}
	}

	addError(objList, strError, objField.id, strErrorID);
}

// Validation routines - add as required

function isString(strValue, arClass)
{
	var bValid = (typeof strValue == 'string' && strValue.replace(/^\s*|\s*$/g, '') !== '' && isNaN(strValue));

	return checkOptional(bValid, strValue, arClass);
}

function isEmail(strValue, arClass)
{
	var objRE = /^[\w-\.\']{1,}\@([\da-zA-Z\-]{1,}\.){1,}[\da-zA-Z\-]{2,}$/;
	var bValid = objRE.test(strValue);

	return checkOptional(bValid, strValue, arClass);
}

function isNumber(strValue, arClass)
{
	var bValid = (!isNaN(strValue) && strValue.replace(/^\s*|\s*$/g, '') !== '');

	return checkOptional(bValid, strValue, arClass);
}

function checkOptional(bValid, strValue, arClass)
{
	var bOptional = false;
	var iCounter;

	// Check if optional
	for (iCounter=0; iCounter<arClass.length; iCounter++)
	{
		if (arClass[iCounter] == 'optional')
		{
			bOptional = true;
		}
	}

	if (bOptional && strValue.replace(/^\s*|\s*$/g, '') === '')
	{
		return true;
	}

	return bValid;
}

