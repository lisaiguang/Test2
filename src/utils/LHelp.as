package utils
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;

	public class LHelp
	{
		static public function distance(x:Number,y:Number,x1:Number,y1:Number):Number
		{
			return Math.sqrt((x1-x)*(x1-x) + (y1-y)*(y1-y));
		}
		
		public static function DisGrey(dis:DisplayObject):void
		{
			var colorMat:ColorMatrixFilter = new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0]);
			dis.filters = [colorMat];
		}
		
		public static function RemoveFromParent(dis:DisplayObject):void
		{
			if(dis.parent)dis.parent.removeChild(dis);
		}
	}
}