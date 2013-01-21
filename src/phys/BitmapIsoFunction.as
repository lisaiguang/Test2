package phys
{
	import flash.display.BitmapData;
	import nape.geom.IsoFunction;
	
	public class BitmapIsoFunction implements IsoFunction
	{
		private var _bd:BitmapData;
		
		public function BitmapIsoFunction(bd:BitmapData):void
		{
			this._bd = bd;
		}
		
		public function iso(x:Number, y:Number):Number
		{
			var ix:int = int(x); if(ix<0) ix = 0; else if(ix>=_bd.width)  ix = _bd.width -1;
			var iy:int = int(y); if(iy<0) iy = 0; else if(iy>=_bd.height) iy = _bd.height-1;
			var fx:Number = x - ix; if(fx<0) fx = 0; else if(fx>1) fx = 1;
			var fy:Number = y - iy; if(fy<0) fy = 0; else if(fy>1) fy = 1;
			var gx:Number = 1-fx;
			var gy:Number = 1-fy;
			
			var a00:int = _bd.getPixel32(ix,iy)>>>24;
			var a01:int = _bd.getPixel32(ix,iy+1)>>>24;
			var a10:int = _bd.getPixel32(ix+1,iy)>>>24;
			var a11:int = _bd.getPixel32(ix+1,iy+1)>>>24;
			
			var ret:Number = gx*gy*a00 + fx*gy*a10 + gx*fy*a01 + fx*fy*a11;
			
			return 0x80-ret;
		}
	}
}