var speed=50        // speed of scroller
var step=3          // smoothness of movement
var StartActionText= "Scroll"  // Text for start link
var StopActionText = "Pause"   // Text for stop link

var x, scroll, divW, sText=""

function onclickIE(idAttr,handler,call){
  if ((document.all)&&(document.getElementById)){idAttr[handler]="Javascript:"+call}
}

function addLink(id,call,txt){
  var e=document.createElement('a')
  e.setAttribute('href',call)
  var linktext=document.createTextNode(txt)
  e.appendChild(linktext)
  document.getElementById(id).appendChild(e)
}

function getElementStyle() {
    var elem = document.getElementById('scroller');
    if (elem.currentStyle) {
        return elem.currentStyle.overflow;
    } else if (window.getComputedStyle) {
        var compStyle = window.getComputedStyle(elem, '');
        return compStyle.getPropertyValue("overflow");
    }
    return "";
}

function addControls(){

// test for CSS support first 
// test for the overlow property value set in style element or external file

if (getElementStyle()=="hidden") {
  var f=document.createElement('div');
  f.setAttribute('id','controls');
  document.getElementById('scroller').parentNode.appendChild(f);
  addLink('controls','Javascript:clickAction(0)',StopActionText);
  onclickIE(document.getElementById('controls').childNodes[0],"href",'clickAction(0)');
  document.getElementById('controls').style.display='block';
  }
}

function stopScroller(){clearTimeout(scroll)}

function setAction(callvalue,txt){
  var c=document.getElementById('controls')
  c.childNodes[0].setAttribute('href','Javascript:clickAction('+callvalue+')')
  onclickIE(document.getElementById('controls').childNodes[0],"href",'clickAction('+callvalue+')')
  c.childNodes[0].firstChild.nodeValue=txt
}

function clickAction(no){
  switch(no) {
    case 0:
      stopScroller();
      setAction(1,StartActionText);
      break;
    case 1:
      startScroller();
      setAction(0,StopActionText);
  }
}



function startScroller(){
  document.getElementById('tag').style.whiteSpace='nowrap'
  var p=document.createElement('p')
  p.id='testP'
  p.style.fontSize='25%' //fix for mozilla. multiply by 4 before using
  x-=step
  if (document.getElementById('tag').className) p.className=document.getElementById('tag').className
  p.appendChild(document.createTextNode(sText))
  document.body.appendChild(p)
  pw=p.offsetWidth
  document.body.removeChild(p)
  if (x<(pw*4)*-1){x=divW}
  document.getElementById('tag').style.left=x+'px'
  scroll=setTimeout('startScroller()',speed)
}

function initScroller(){
  if (document.getElementById && document.createElement && document.body.appendChild) {
    addControls();
    divW=document.getElementById('scroller').offsetWidth;
    x=divW;
    document.getElementById('tag').style.position='relative';
    document.getElementById('tag').style.left=divW+'px';
    var ss=document.getElementById('tag').childNodes;
    for (i=0;i<ss.length;i++) {sText+=ss[i].nodeValue+" "};
    scroll=setTimeout('startScroller()',speed);
  }
}


function addLoadEvent(func) {
  if (!document.getElementById | !document.getElementsByTagName) return
  var oldonload = window.onload
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      oldonload()
      func()
    }
  }
}

addLoadEvent(initScroller)