package utils
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class McSprite extends Sprite
	{
		
		private var m_bitmap:Bitmap;
		public function McSprite()
		{
			m_bitmap = new Bitmap( null, "never", false);
		}
	}
}