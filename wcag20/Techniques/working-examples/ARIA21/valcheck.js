function logincheck() { // For form-alert.htm: using JS alert 
if(document.getElementById("lname").value == ""){
alert("You forgot to enter your last name!");
return false;
}
if(document.getElementById("usrname").value == ""){
alert("Please enter your login name");
return false;
}
if(document.getElementById("pwd").value == ""){
alert("Please enter your password");
return false;
}
alert("Sorry cannot login: login and password mismatch. Please try again.");
return true;
} // end of logincheck function

function showTooltip( tooltip_id ) { 
document.getElementById( tooltip_id ).style.display = "inline"; 
} 
function hideTooltip( tooltip_id ) { 
document.getElementById( tooltip_id ).style.display = "none"; 
} 
function keydownTooltip( event, tooltip_id ) {
var e = window.event || event;
if( e.keyCode == 27 ) {
document.getElementById( tooltip_id ).style.display = "none";
return browser.stopPropagation( e );
} else {
return true;
}}  // end of function

function errorAlert () { // For form-alert1.htm: using innerHTML for 1 alert at a time 
if(document.getElementById("lname").value == ""){
document.getElementById("errlist").innerHTML  = "<li role='alert'>You forgot to enter your last name!</li>";
return false;
}
if(document.getElementById("usrname").value == ""){
document.getElementById("errlist").innerHTML = "<li role='alert'>Please enter your login name</li>";
return false;
}
if(document.getElementById("pwd").value == ""){
document.getElementById("errlist").innerHTML = "<li role='alert'>Please enter your password</li>";
return false;
}
document.getElementById("errlist").innerHTML = "<li role='alert'>Sorry cannot login: Login name and password mismatch.   Please try again.</li>";
return false; // with innerHTML this too has to be 'false'
} // end of errorAlert function

function errorAlert1 () {//  For form-alert2.htm: using DOM to add error text   
// remove error messages already displayed: 
var liTag = document.getElementById("errlist") ; 
while (liTag.firstChild) {
liTag.removeChild(liTag.firstChild);
}
// done with removing messages
// Next line removes error icons
var myImg = "images/iconError.gif" ;
$('label').find('img').remove() ;
// remove aria-describedby from form controls:
$("input").removeAttr("aria-describedby");

// Define arrays
var fields = new Array() ;  // holds id of form controls sequentially
fields[0] = "lname"; fields[1] = "usrname"; fields[2] = "pwd";

var messages = new Array() ; // Holds error messages  
messages[0] = "You forgot to enter your last name!";
messages[1] = "Please enter your login name";
messages[2] = "Please enter your password"; 

var errText = new Array() ;  // holds actual errors to be listed 
var errId = new Array() ; // holds id of list items  
var i = 0; var j = 0;  errText[i] = ""; 
// i can range from 0 to 2 i.e. 1 to 3 error fields
while(j<=2) {
var thisFld = document.getElementById(fields[j]);
if(thisFld.value == ""){
errText[i] = messages[j] ; 
errId[i] = String(i) ;
// Set aria-described for form control:
thisFld.setAttribute("aria-describedby", "list_" +errId[i] ) ;
// Create error icon:
newIcon = document.createElement( "img" );
$(newIcon).attr({
src: "images/iconError.gif",
alt: "Error " + String(parseInt(i) +1),
id: "img_" + String(i)
});

// place error icon within corresponding label element - same as index j.
$(document.getElementsByTagName("LABEL")[j]).append(newIcon);

// prependImage(fields[j],lbl, errId[i] );
i++;
} j++;
} // end of while

if(errText[0] != "") { // means at least one error is present
var j = 0;
while(j < i) {
var liTag = document.createElement("li");
var node=document.createTextNode(errText[j]); 
liTag.appendChild(node);
liTag.setAttribute("id", "list_" + errId[j]); j++;
document.getElementById("errlist").appendChild(liTag); 
} // end of while
document.getElementById("errlist").focus() 
return false;
} // end of if for errText[0] not blank i.e. errors present
$(document.getElementById("errlist")).html("<li>Sorry cannot login: Login name and password mismatch.   Please try again.</li>");
return false; 
} // end of errorAlert1 function

function prependImage(elementId, strId) {
var image = new Image();
  // Set path and alt properties
image.src = "images/iconError.gif";
image.alt = "Error " + String(parseInt(strId) +1);
image.id = "img_" + strId;
  // Add it to the DOM
// This adds image before the label: 
$(document.getElementById(elementId)).parent().prepend(image);
  // If all went well, return false so navigation can 
  // be cancelled based on function outcome
return false;
}

function errorAlert2 () {//  For form-alert3.htm: using DOM to add error text   

$("div.control span").remove(); // removes generic error message
// remove aria-describedby, aria-invalid and class from form controls:
$("div.control input").removeAttr("aria-describedby aria-invalid class");
// Define arrays
var fields = new Array() ;  // holds id of form controls sequentially
fields[0] = "pin4"; fields[1] = "email"; fields[2] = "lname"; fields[3] = "startDt";
var eFlag = 0; 
var i = 0; var j = 0;  
// i can range from 0 to 3 i.e. 1 to 4 error fields
while(j<=3) {
var thisFld = document.getElementById(fields[j]);
if(thisFld.value.length == 0){
if (j < 3) { // this is not  done for start date field
tieErrText(thisFld, i, "Error: Input data missing") ;
i++ ;
eFlag++;
}
if (j == 3)  { // means j=3 and date is empty
var dtString =formatDate() ;
$(thisFld).prop("value", dtString);
}
} // end of  check for no input data 
else if (j == 0 && ( (isNaN(thisFld.value)) || (thisFld.value.length != 4))) {
eFlag = addErrText(thisFld) ;
}  // end of if j == 0
else if (j == 1 ) { // checking email field
// Checks for syntax of an email:
/* This means that the input data must contain an @ sign and at least one dot (.). 
Also, the @ must not be the first character of the email address, and the last dot must be present after the @ sign, and minimum 2 characters before the end 
*/
var atpos = thisFld.value.indexOf("@");
var dotpos = thisFld.value.lastIndexOf(".");
if (atpos<1 || dotpos<atpos+2 || dotpos+2>= thisFld.value.length) {
eFlag = addErrText(thisFld) ;
}} // end of if j==1
else if (j == 2) { // check last name for non-alpha characters
if (!checkAlpha(thisFld.value)) {
eFlag = addErrText(thisFld) ;
}  } // end of j == 2 for last name check

else if (j == 3 ) { // checking non-empty policy start date field 
if(!ValidateDate(thisFld.value)) {
eFlag = addErrText(thisFld) ;
} 
else if (!dateLater(thisFld.value)) {
tieErrText(thisFld, i, "Error: Date has passed");
i++; eFlag++;
}
} // end of j == 3 for date check
j++;
} // end of while 
if (eFlag  > 0) {
$(document.getElementById("err_final")).text("Sorry cannot login: Please fix the errors and retry").focus();
return false; 
} 
$(document.getElementById("err_final")).html("Sorry cannot login: PIN / Email / Name mismatch. Please retry").focus();
return false; 
} // end of errorAlert2 function

function ValidateDate(dtValue) {
var dtRegex = new RegExp(/\b[01][0-9][\/-][0123][0-9][\/-][2][0]\d{2}\b/);
return dtRegex.test(dtValue);
 }

function checkAlpha(aWord) {
//regular expression defining aword with 2 or more alpha characters: 
var alphaRegex  = new RegExp(/^[a-zA-Z]{2,}$/) ; 
return alphaRegex.test(aWord);
 }


function dateLater(dtStr) { // compares input date string with current date
var yy = dtStr.substr(6) ;
var dd = dtStr.substr(3,2) ;
var mm = dtStr.substr(0,2) ;
var d1 = Date.parse(yy + "-" +mm + "-" + dd);
// var d1 = Date.parse("2013-12-25"); 
var dt = new Date() ;
yy =dt.getFullYear();
mm = dt.getMonth(); mm++;
dd = dt.getDate();
var d2 = Date.parse(yy + "-" +mm + "-" + dd);
if (d1>= d2) {
return true;
}
return false;
}

function tieErrText(errFld, k, errMsg) {
var errId = "err_" + String(k) ;
// A hidden field with id=spanval  is used to hold  content of span tag:
$(document.getElementById('spanval')).prop("value", '<span class="errtext" id="' +errId +'">' + errMsg + '</span>') ;
$(errFld).parent().append(document.getElementById('spanval').value);
// Set aria-described for form control:
errFld.setAttribute("aria-describedby", errId) ;
errFld.setAttribute("class", "error") ;
}

function addErrText(errFld) {
$(errFld).attr("aria-invalid", "true").attr("class", "error");
// Suffix error text: 
$(errFld).parent().append('<span class="errtext">Error: Incorrect data</span>');
return 1;
}

function formatDate() {
var dt1 = new Date();
var mm = dt1.getMonth();  mm++ ;
if (mm < 10) { mm ="0" + mm; }
var dd = dt1.getDate() ; 
if (dd < 10) { dd ="0" + dd; }
var dtStr = mm + "/" + dd +"/" + dt1.getFullYear();
return dtStr;
}
