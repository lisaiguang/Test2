package view.battle
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import data.StaticTable;
	
	import starling.utils.Color;
	
	public class SmallMapView extends Sprite
	{
		public function InitPos():void
		{
			x = StaticTable.STAGE_WIDTH - width;
			y = 0;
		}
		
		public function SmallMapView()
		{
		}
		
		private var _bmp:Bitmap;
		private var _scaleFactor:Number;
		private var top:Sprite;
		
		public function SetMap(bd:BitmapData):void
		{
			_scaleFactor = StaticTable.STAGE_WIDTH / 5 / bd.width;
			
			if(_bmp)removeChild(_bmp);
			_bmp = new Bitmap(bd, "auto", true);
			_bmp.width = bd.width * _scaleFactor;
			_bmp.height = bd.height * _scaleFactor;
			addChild(_bmp);
			
			if(top)removeChild(top);
			top = new Sprite;
			top.x = 0;
			top.y = 0;
			top.graphics.beginFill(0xdd0000, 0.4);
			top.graphics.drawRect(0,0,StaticTable.STAGE_WIDTH * _scaleFactor, StaticTable.STAGE_HEIGHT * _scaleFactor);
			top.graphics.endFill();
			addChild(top);
		}
		
		public function SetMapTopLeft(mx:Number, my:Number):void
		{
			top.x = -mx * _scaleFactor;
			top.y = -my * _scaleFactor;
		}
		
		private var _dic:Dictionary = new Dictionary;
		public function SetRoleXY(rid:int, rx:Number, ry:Number):void
		{
			var role:Shape = _dic[rid];
			
			if(!role)
			{
				var color:uint = rid == 1?Color.RED:Color.BLUE;
				role = new Shape;
				role.graphics.beginFill(color, 0.6);
				role.graphics.drawCircle(3, 3, 3);
				role.graphics.endFill();
				addChild(role);
				_dic[rid] = role;
			}
			
			role.x = rx * _scaleFactor - 3;
			role.y = ry * _scaleFactor - 3;
			
			if(role.x < _bmp.x || role.y < _bmp.y || role.x > _bmp.x + _bmp.width || role.y > _bmp.y + _bmp.height )
			{
				if(role.parent)removeChild(role);
			}
			else
			{
				if(!role.parent)addChild(role);
			}
		}
	}
}