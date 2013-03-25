package mybodys
{
	import flash.display.DisplayObject;
	
	import data.staticObj.BodyDesc;
	import data.staticObj.EnumBodyType;
	
	import utils.LHelp;

	public class MyBody
	{
		protected var bodyDesc:BodyDesc;
		protected var animation:DisplayObject;
		
		public function MyBody(bd:BodyDesc)
		{
			bodyDesc = bd;
		}
		
		public function get x():Number
		{
			return animation.x;
		}
		
		public function set x(val:Number):void
		{
			animation.x = val
		}
		
		public function get y():Number
		{
			return animation.y;
		}
		
		public function set y(val:Number):void
		{
			animation.y = val
		}
		
		public function collsin(bp:*):Boolean
		{
			if(bodyDesc.type == EnumBodyType.CIRCLE)
			{
				if(LHelp.pointInRound(bp.x,bp.y, (animation.x + bp.x)*.5,(animation.y + bp.y)*.5,(bodyDesc.raidus + bp.bodyDesc.raidus) * .5))
				{
					return true;
				}
			}
			else if(bodyDesc.type == EnumBodyType.RECT)
			{
				if(LHelp.pointInRect(bp.x,bp.y,animation.x,animation.y,bodyDesc.width / 2, bodyDesc.height / 2))
				{
					return true;
				}
			}
			return false;
		}
	}
}