package phys
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import nape.phys.Body;

	public class Bullet extends Bitmap
	{
		private var _body:Body;
		
		public function Bullet(id:int)
		{
		}

		public function get body():Body
		{
			return _body;
		}
	}
}