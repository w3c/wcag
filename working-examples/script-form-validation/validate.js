window.onload = initialise;
function initialise()
{
  // Ensure we're working with a relatively standards compliant user agent
  if (!document.getElementById || !document.createElement || !document.createTextNode)
    return;

  // Add an event handler for the number form
  var objForm = document.getElementById('numberform');
  objForm.onsubmit= function(){return validateNumbers(this);};
}

function validateNumbers(objForm)
{
  // Test whether fields are valid
  var bFirst = isNumber(document.getElementById('num1').value);
  var bSecond = isNumber(document.getElementById('num2').value);
  // If not valid, display errors
  if (!bFirst || !bSecond)
  {
    var objExisting = document.getElementById('validationerrors');
    var objNew = document.createElement('div');
    var objTitle = document.createElement('h2');
    var objParagraph = document.createElement('p');
    var objList = document.createElement('ol');
    var objAnchor = document.createElement('a');
    var strID = 'firsterror';
    var strError;
    // The heading element will contain a link so that screen readers
    // can use it to place focus - the destination for the link is 
    // the first error contained in a list
    objAnchor.appendChild(document.createTextNode('Errors in Submission'));
    objAnchor.setAttribute('href', '#firsterror');
    objTitle.appendChild(objAnchor);
    objParagraph.appendChild(document.createTextNode('Please review the following'));
    objNew.setAttribute('id', 'validationerrors');
    objNew.appendChild(objTitle);
    objNew.appendChild(objParagraph);
    // Add each error found to the list of errors
    if (!bFirst)
    {
      strError = 'Please provide a numeric value for the first number';
      objList.appendChild(addError(strError, '#num1', objForm, strID));
      strID = '';
    }
    if (!bSecond)
    {
      strError = 'Please provide a numeric value for the second number';
      objList.appendChild(addError(strError, '#num2', objForm, strID));
      strID = '';
    }
    // Add the list to the error information
    objNew.appendChild(objList);
    // If there were existing errors, replace them with the new lot,
    // otherwise add the new errors to the start of the form
    if (objExisting)
      objExisting.parentNode.replaceChild(objNew, objExisting);
    else
    {
      var objPosition = objForm.firstChild;
      objForm.insertBefore(objNew, objPosition);
    }
    // Place focus on the anchor in the heading to alert
    // screen readers that the submission is in error
    objAnchor.focus();
    // Do not submit the form
    objForm.submitAllowed = false;
    return false;
  }
  return true;
}

// Function to validate a number
function isNumber(strValue)
{
  return (!isNaN(strValue) && strValue.replace(/^\s+|\s+$/, '') !== '');
} 


// Function to create a list item containing a link describing the error
// that points to the appropriate form field
function addError(strError, strFragment, objForm, strID)
{
  var objAnchor = document.createElement('a');
  var objListItem = document.createElement('li');
  objAnchor.appendChild(document.createTextNode(strError));
  objAnchor.setAttribute('href', strFragment);
  objAnchor.onclick = function(event){return focusFormField(this, event, objForm);};
  objAnchor.onkeypress = function(event){return focusFormField(this, event, objForm);};
  // If strID has a value, this is the first error in the list
  if (strID.length > 0)
    objAnchor.setAttribute('id', strID);
  objListItem.appendChild(objAnchor);
  return objListItem;
}

// Function to place focus to the form field in error
function focusFormField(objAnchor, objEvent, objForm)
{
  // Allow keyboard navigation over links
  if (objEvent && objEvent.type == 'keypress')
    if (objEvent.keyCode != 13 && objEvent.keyCode != 32)
      return true;
  // set focus to the form control
  var strFormField = objAnchor.href.match(/[^#]\w*$/);
  objForm[strFormField].focus();
  return false;
}