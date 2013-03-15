package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class JinDuTiao extends Sprite
	{
		private var maxShape:Bitmap, curShape:Bitmap;
		private var _cur:int,_max:int=int.MAX_VALUE, _cw:Number;
		
		public function JinDuTiao(w:Number, h:Number, bolder:Number = 1, color=0xff0000)
		{
			_cw = w - bolder*2;
			var shape:Shape = new Shape;
			shape.graphics.beginFill(0x000000);
			shape.graphics.drawRect(0,0, w, h);
			shape.graphics.endFill();
			var bd:BitmapData = new BitmapData(w, h, false);
			bd.draw(shape);
			maxShape = new Bitmap(bd);
			addChild(maxShape);
			
			shape = new Shape;
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(0,0, 1, h - bolder * 2);
			shape.graphics.endFill();
			bd = new BitmapData(1, h - bolder * 2, false);
			bd.draw(shape);
			curShape = new Bitmap(bd);
			curShape.x = maxShape.x + bolder;
			curShape.y = maxShape.y + bolder;
			addChild(curShape);
		}
		public function setBlood(curBlood:Number, maxBlood:Number):void
		{
			_cur = curBlood < 0?0:curBlood;
			_max = maxBlood;
			curShape.width = _cw * (_cur / _max);
		}
	}
}