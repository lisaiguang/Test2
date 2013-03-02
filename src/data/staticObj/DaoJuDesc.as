package data.staticObj
{
	public class DaoJuDesc
	{
		public var itemId:int;
		public var name:String;
		public var desc:String;
		public var type:int;
		public var sold:int;
		public var extra:int;
		public function DaoJuDesc()
		{
		}
		
		public function get level():int
		{
			return extra;
		}
		
		public function get tz():int
		{
			return extra;
		}
		
		public function get bs():int
		{
			return extra;
		}
	}
}