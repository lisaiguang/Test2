package data.staticObj
{
	import flash.utils.Dictionary;

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
		public var islands:Vector.<MapIslandDesc> = new Vector.<MapIslandDesc>;
		public var blockDic:Dictionary = new Dictionary;
		
		public function MapDesc()
		{
		}
		
		public function getBlockName(col:Number,row:Number):String
		{
			return blockDic[col*1000+row]?blockDic[col*1000+row]:"sea1";
		}
	}
}