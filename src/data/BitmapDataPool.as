package data
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	public class BitmapDataPool
	{
		public function BitmapDataPool()
		{
		}
		
		private static var _dic:Dictionary = new Dictionary;
		public static function getBitmapData(cls:Class):BitmapData
		{
			if(!_dic[cls])
			{
				_dic[cls] = new cls;
			}
			return _dic[cls];
		}
		
		public static function destoryBitmapData(cls:Class):void
		{
			if(_dic[cls])
			{
				var bd:BitmapData = _dic[cls];
				bd.dispose();
				delete _dic[cls];
			}
		}
		
	}
}