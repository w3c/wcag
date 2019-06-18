/* shared.js */

function HarmonizeEvent(evt)
{
	if (!evt.target)
	{
		evt.target = evt.srcElement;
		if ('mouseover' == evt.type)
		{
			evt.relatedTarget = evt.fromElement;
		}
		else if ('mouseout' == evt.type)
		{
			evt.relatedTarget = evt.toElement;
		}
		evt.preventDefault = function() { this.returnValue = false; }
		evt.stopPropagation = function() { this.cancelBubble = true; }
	}
}

function PositionElement(el,src,right,bottom)
{
	var top = 0;
	var left = 0;
	if (right)
	{
		left += src.offsetWidth;
	}
	if (bottom)
	{
		top += src.offsetHeight;
	}
	while (src)
	{
		top += src.offsetTop;
		left += src.offsetLeft;
		src = src.offsetParent;
	}
	el.style.top = top + "px";
	el.style.left = left + "px";
}

// Mozilla equivalency

if (!document.all)
{
	// swapNode()
	if ('function' != Node.prototype.swapNode)
	{
		Node.prototype.swapNode = function (node) 
		{
			var nextSibling = this.nextSibling;
			var parentNode = this.parentNode;
			node.parentNode.replaceChild(this, node);
			parentNode.insertBefore(node, nextSibling); 	
		};
	}

	// click() 
	if ('function' != HTMLElement.prototype.click)
	{
		HTMLElement.prototype.click = function()
		{
			var e = document.createEvent("MouseEvents");
			e.initEvent("click",true,true);
			var blnRet = this.dispatchEvent(e);
		};
	}
	
	// contains() 
	if ('function' != HTMLElement.prototype.contains)
	{
		HTMLElement.prototype.contains = function (el) 
		{	
			while (el!=null && el!=this)
			{
				el = el.parentElement;
			}
			return (el!=null)
		};
	}

}