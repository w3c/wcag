// trigger and popup inside the same link

var parent = document.getElementById('parent');

parent.onmouseover = function() {
    document.getElementById('popup').style.display = 'block';
}

parent.onmouseout = function() {
    document.getElementById('popup').style.display = 'none';
}

parent.onfocus = function() {
    document.getElementById('popup').style.display = 'block';
}

parent.onblur = function() {
    document.getElementById('popup').style.display = 'none';
}

// hide when ESC is pressed

document.addEventListener('keydown', (e) => {
  if ((e.keyCode || e.which) === 27)
       document.getElementById('popup').style.display = 'none';
});