package utils
{
	import flash.display.BitmapData;
	
	import lsg.battle.bg1;

	public class StaticTable
	{
		public static const STAGE_WIDTH:int  = 640;
		public static const STAGE_HEIGHT:int = 960;
		
		public static function GetBattleBackground(id:int):BitmapData
		{
			var bd:BitmapData = new bg1;
			return bd;
		}
	}
}