package data.staticObj
{
	public class BulletDesc
	{
		public static const CLEAR_CIRCLE:int = 0;
		public static const CLEAR_RECT:int = 1;
		
		public var id:int;
		public var bulletId:int;
		public var hurt:int;
		public var shootType:int;
		public var boundWidth:int;
		public var boundHeight:int;
		public var mass:int;
		public var clearParams:Vector.<int> = new Vector.<int>;
		public var name:String;
		public var desc:String;
		public var sold:int;
		
		public function BulletDesc()
		{
		}
		
		public function get range():int
		{
			if(clearParams[0] == CLEAR_CIRCLE)
			{
				return clearParams[1] * clearParams[1] * Math.PI;
			}
			else
			{
				return clearParams[1]  * clearParams[2]; 
			}
		}
	}
}