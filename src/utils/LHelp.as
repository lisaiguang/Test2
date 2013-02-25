package utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	
	import starling.utils.Color;

	public class LHelp
	{
		static public function distance(x:Number,y:Number,x1:Number,y1:Number):Number
		{
			return Math.sqrt((x1-x)*(x1-x) + (y1-y)*(y1-y));
		}
		
		public static function AddGlow(dis:DisplayObject):void
		{
			var gf:GlowFilter = new GlowFilter(Color.BLUE);
			dis.filters = [gf];
		}
		
		public static function RemoveGlow(dis:DisplayObject):void
		{
			dis.filters = null;
		}
		
		public static function AddGrey(dis:DisplayObject):void
		{
			var colorMat:ColorMatrixFilter = new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0]);
			dis.filters = [colorMat];
		}
		
		public static function RomoveGrey(dis:DisplayObject):void
		{
			var colorMat:ColorMatrixFilter = new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0]);
			dis.filters = null;
		}
		
		public static function RemoveFromParent(dis:DisplayObject):void
		{
			if(dis.parent)dis.parent.removeChild(dis);
		}
		
		static public function FindParentByName(target:DisplayObject, name:String):DisplayObject 
		{
			while (target.name != name && target.parent)
			{
				target = target.parent;
			}
			return target.name != name ? null:target;
		}
		
		static public function FindParentByClass(target:DisplayObject, tClass:Class):*
		{
			while (target.parent)
			{
				if (target is tClass)
				{
					return target;
				}
				else
				{
					target = target.parent;
				}
			}
			return null;
		}
		
		public static function Clear(_content:DisplayObjectContainer):void
		{
			while(_content.numChildren)
			{
				_content.removeChildAt(0);
			}
		}
	}
}