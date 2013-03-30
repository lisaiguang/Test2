package data
{
	import flash.net.SharedObject;
	
	public class MiniBuffer
	{
		public static var scores:SharedObject;
		
		public static function Init():void
		{
			scores = SharedObject.getLocal("scores");
			if(!scores.data.best)scores.data.best=0;
		}
	}
}