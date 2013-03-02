package data.staticObj
{
	import flash.display.Shape;

	public class BulletDesc
	{
		public static const CLEAR_CIRCLE:int = 0;
		public static const CLEAR_RECT:int = 1;
		
		public var id:int;
		public var tuzhi:TuZhiDesc;
		public var baoshi:int;
		public var hurt:int;
		public var clearShape:Shape;
		public var range:int;
		public var sold:int;
		private var _desc:String;
		public var level:int;
		
		public function BulletDesc()
		{
		}
		
		public function get desc():String
		{
			return _desc ? _desc:"";
		}

		public function set desc(value:String):void
		{
			_desc = value;
		}

		public function get isNormal():Boolean
		{
			return _desc == null;
		}
	}
}