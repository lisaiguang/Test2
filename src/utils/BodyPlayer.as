package utils
{
	import com.urbansquall.ginger.AnimationPlayer;
	
	import data.staticObj.BodyDesc;
	import data.staticObj.EnumBodyType;
	import data.staticObj.ShipDesc;
	
	import message.EnumAction;
	
	public class BodyPlayer extends AnimationPlayer
	{
		public var bodyDesc:BodyDesc;
		
		public function BodyPlayer()
		{
			super();
		}
		
		public function get shipDesc():ShipDesc
		{
			return bodyDesc as ShipDesc;
		}
		
		public function collsin(bp:BodyPlayer):Boolean
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
	}
}