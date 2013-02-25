package utils
{
	import com.greensock.BlitMask;
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class SlidePage
	{
		public var blitMask:BlitMask;
		public var mc:DisplayObject;
		public var bounds:Rectangle;
		
		public var enableScrollX:Boolean;
		public var enableScrollY:Boolean;
		
		public function SlidePage(mc:DisplayObject, blitMask:BlitMask)
		{
			this.mc = mc;
			this.blitMask = blitMask;
			this.bounds = new Rectangle(blitMask.x, blitMask.y, blitMask.width, blitMask.height);
			
			mc.parent.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private var t1:uint, t2:uint, y1:Number, y2:Number, x1:Number, x2:Number, xOverlap:Number, xOffset:Number, yOverlap:Number, yOffset:Number;
		private var _target:*, _func:Function, mx:Number, my:Number;
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			var area:Rectangle = blitMask.getRect(blitMask.stage);
			if(area.contains(e.stageX, e.stageY))
			{
				TweenLite.killTweensOf(mc);
				blitMask.enableBitmapMode();
				mx = mc.x;
				my = mc.y;
				
				if(enableScrollX)
				{
					x1 = x2 = mc.x;
					xOffset = mc.parent.mouseX - mc.x;
					xOverlap =  bounds.left - (totalPage - 1) * bounds.width;
				}
				if(enableScrollY)
				{
					y1 = y2 = mc.y;
					yOffset = mc.parent.mouseY - mc.y;
					yOverlap = bounds.top - (totalPage - 1) * bounds.height;
				}
				t1 = t2 = getTimer();
				
				_target = _func = null;
				for(var cls:Class in _dic)
				{
					var tg:* = LHelp.FindParentByClass(e.target as DisplayObject, cls)
					if(tg)
					{
						_target = tg;
						_func = _dic[cls];
						break;
					}
				}
				
				mc.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				mc.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			}
		}
		
		private function mouseMoveHandler(event:MouseEvent):void {
			if(enableScrollY)
			{
				var y:Number = mc.parent.mouseY - yOffset;
				if (y > bounds.top) {
					mc.y = (y + bounds.top) * 0.5;
				} else if (y < yOverlap) {
					mc.y = (y + yOverlap) * 0.5;
				} else {
					mc.y = y;
				}
			}
			if(enableScrollX)
			{
				var x:Number = mc.parent.mouseX - xOffset;
				if (x > bounds.left) {
					mc.x = (x + bounds.left) * 0.5;
				} else if (x < xOverlap) {
					mc.x = (x + xOverlap) * 0.5;
				} else {
					mc.x = x;
				}
			}
			blitMask.update();
			var t:uint = getTimer();
			if (t - t2 > 50) {
				x2 = x1;
				x1 = mc.x;
				y2 = y1;
				t2 = t1;
				y1 = mc.y;
				t1 = t;
			}
			event.updateAfterEvent();
		}
		
		private function mouseUpHandler(event:MouseEvent):void {
			blitMask.disableBitmapMode();
			mc.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			mc.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			if(mx - mc.x < 12 && mx - mc.x > -12 && my - mc.y < 12 && my - mc.y > -12)
			{
				mc.x = mx;
				mc.y = my;
				if(_target)
				{
					_func(_target);
				}
			}
			else
			{
				var time:Number = (getTimer() - t2) / 1000;
				var xVelocity:Number = (mc.x - x2) / time;
				var yVelocity:Number = (mc.y - y2) / time;
				
				var params:Object = {onUpdate:blitMask.update, ease:Strong.easeOut};
				if(enableScrollX)
					params["x"] = currentPageX(xVelocity);
				if(enableScrollY)
					params["y"] = currentPageY(yVelocity);
				TweenLite.to(mc, 0.3, params);
			}
		}
		
		private function currentPageX(velo:Number):Number
		{
			var pageFactor:Number = 0.5 + (velo / 1000 < 0 ? -Math.max(-0.5, velo / 1000):-Math.min(0.5, velo / 1000));
			var page:int = -(mc.x - bounds.left) / bounds.width + pageFactor;
			if(page > totalPage - 1)
			{
				page = totalPage - 1;
			}
			return -page * bounds.width + bounds.left;
		}
		
		private function get totalPage():int{
			var tp:int = mc.width / bounds.width + 0.99;
			return tp < 1?1:tp;
		}
		
		private function currentPageY(velo:Number):Number
		{
			var pageFactor:Number = 0.5 + (velo / 1000 < 0 ? -Math.max(-0.5, velo / 1000):-Math.min(0.5, velo / 1000));
			var page:int = -(mc.y - bounds.top) / bounds.height + pageFactor;
			var totalPage:int = mc.height / bounds.height + 0.51;
			if(page < 0)
			{
				page = 0;
			}
			else if(page > totalPage - 1)
			{
				page = totalPage - 1;
			}
			return -page * bounds.height + bounds.top;
		}
		
		public function set mcX(val:int):void
		{
			blitMask.x = bounds.x = mc.x = val;
		}
		
		public function set mcY(val:int):void
		{
			blitMask.y = bounds.y = mc.y = val;
		}
		
		private var _dic:Dictionary = new Dictionary;
		public function registerClick(cls:Class, func:Function):void
		{
			_dic[cls] = func;
		}
	}
}