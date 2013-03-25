package mybodys
{
	import com.urbansquall.ginger.AnimationPlayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	
	import data.staticObj.BodyDesc;
	import data.staticObj.EnumAction;
	import data.staticObj.EnumBodyType;
	import data.staticObj.ShipDesc;
	
	import utils.LHelp;
	
	public class ShipPlayer extends AnimationPlayer
	{
		public var bodyDesc:BodyDesc;
		public var shootItev:int;
		
		override public function update(a_ms:Number):void
		{
			super.update(a_ms);
			shootItev += a_ms;
		}
		
		public function get allowShoot():Boolean
		{
			return shootItev * shipDesc.shootSpeed >= 1;
		}
		
		public function ShipPlayer()
		{
			super();
		}
		
		public function get curBlood():int
		{
			return _curBlood;
		}

		public function get maxBlood():int
		{
			return _maxBlood;
		}

		public function get shipDesc():ShipDesc
		{
			return bodyDesc as ShipDesc;
		}
		
		public function collsin(bp:*):Boolean
		{
			if(bodyDesc.type == EnumBodyType.CIRCLE)
			{
				if(LHelp.pointInRound(bp.x,bp.y, (x + bp.x)*.5,(y + bp.y)*.5,(bodyDesc.raidus + bp.bodyDesc.raidus) * .5))
				{
					return true;
				}
			}
			else if(bodyDesc.type == EnumBodyType.RECT)
			{
				if(LHelp.pointInRect(bp.x,bp.y,x,y,bodyDesc.width / 2, bodyDesc.height / 2))
				{
					return true;
				}
			}
			return false;
		}
		
		public function setRadius(angle:Number):void
		{
			if(angle > -Math.PI / 4 && angle <= Math.PI / 4)
			{
				if(currentAnimationID != EnumAction.SHIP_LEFT)  
				{
					play(EnumAction.SHIP_LEFT);
				}
			}
			else if(angle > Math.PI / 4 && angle <= 3 * Math.PI / 4)
			{
				if(currentAnimationID != EnumAction.SHIP_DOWN) play(EnumAction.SHIP_DOWN);
			}
			else if(angle > -3 * Math.PI / 4 && angle <= -Math.PI / 4)
			{
				if(currentAnimationID != EnumAction.SHIP_UP) play(EnumAction.SHIP_UP);
			}
			else if(angle > 3 * Math.PI / 4 || -3 * Math.PI / 4)
			{
				if(currentAnimationID != EnumAction.SHIP_RIGHT) play(EnumAction.SHIP_RIGHT);
			}
		}
		
		private var maxShape:Bitmap, curShape:Bitmap;
		private var _curBlood:int,_maxBlood:int;
		public function setBlood(curBlood:Number, maxBlood:Number, color=0xff0000):void
		{
			_curBlood = curBlood < 0?0:curBlood>maxBlood?maxBlood:curBlood;
			_maxBlood = maxBlood;
			if(!maxShape)
			{
				var shape:Shape = new Shape;
				shape.graphics.beginFill(0x000000);
				shape.graphics.drawRect(0,0,98, 6);
				shape.graphics.endFill();
				var bd:BitmapData = new BitmapData(98, 6, false);
				bd.draw(shape);
				maxShape = new Bitmap(bd);
				maxShape.x = -maxShape.width * .5;
				maxShape.y = -height * .7;
				addChild(maxShape);
			}
			if(!maxShape.parent)
			{
				addChild(maxShape);
			}
			if(!curShape)
			{
				shape = new Shape;
				shape.graphics.beginFill(color);
				shape.graphics.drawRect(0,0, 1, 4);
				shape.graphics.endFill();
				bd = new BitmapData(1, 4, false);
				bd.draw(shape);
				curShape = new Bitmap(bd);
				curShape.x = maxShape.x + 1;
				curShape.y = maxShape.y + 1;
			}
			if(!curShape.parent)
			{
				addChild(curShape);
			}
			//curShape.scaleX = _curBlood / _maxBlood;
			curShape.width = 96 * _curBlood / _maxBlood;
		}
		
		public function clearBlood(isDelete:Boolean = false):void
		{
			removeChild(curShape);
			removeChild(maxShape);
			if(isDelete)
			{
				curShape = maxShape = null;
			}
		}
	}
}