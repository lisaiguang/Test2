package data.staticObj
{
	public class MapDesc
	{
		public var id:int;
		public var name:String;
		public var width:Number;
		public var cols:Number;
		public var rows:Number;
		public var blockWidth:Number;
		public var blockHeight:Number;
		public var height:Number;
		public var citys:Vector.<MapCityDesc> = new Vector.<MapCityDesc>;
		public function MapDesc()
		{
		}
	}
}