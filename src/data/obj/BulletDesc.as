package data.obj
{
	public class BulletDesc
	{
		public static const CLEAR_CIRCLE:int = 0;
		public static const CLEAR_RECT:int = 1;
		
		public var id:int;
		public var boundWidth:int;
		public var boundHeight:int;
		public var mass:int;
		public var clearParams:Vector.<int> = new Vector.<int>;
		
		public function BulletDesc()
		{
		}
	}
}