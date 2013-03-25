package mybodys
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import data.staticObj.ShenFuDesc;
	
	public class ShenFuPlayer extends Bitmap
	{
		public var sfDesc:ShenFuDesc;
		public var remains:Number;
		
		public function ShenFuPlayer(sf:ShenFuDesc, bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			sfDesc = sf;
			super(bitmapData, pixelSnapping, smoothing);
		}
	}
}