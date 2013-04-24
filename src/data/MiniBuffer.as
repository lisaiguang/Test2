package data
{
	import flash.net.SharedObject;
	
	public class MiniBuffer
	{
		public static var model:int;
		public static var cookies:SharedObject;
		
		public static function Init():void
		{
			cookies = SharedObject.getLocal("scores");
			if(!cookies.data.bestFinger)cookies.data.bestFinger=0;
			if(!cookies.data.bestTiGan)cookies.data.bestTiGan=0;
			if(!cookies.data.fuhao)cookies.data.fuhao=0;
			if(!cookies.data.yaoba)cookies.data.yaoba=0;
			if(cookies.data.purchased)cookies.data.purchased=false;
		}
	}
}