package data.staticObj
{
	public class BodyDesc
	{
		public var id:int;
		public var type:int;
		public var animation:String;
		private var _params1:Number;
		private var _params2:Number;

		public function get width():Number
		{
			return _params1;
		}

		public function set width(value:Number):void
		{
			_params1 = value;
		}

		public function get height():Number
		{
			return _params2;
		}

		public function set height(value:Number):void
		{
			_params2 = value;
		}

		public function get raidus():Number
		{
			return _params1;
		}

		public function set raidus(value:Number):void
		{
			_params1 = value;
		}

	}
}