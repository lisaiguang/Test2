package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.display.DisplayObject;
	
	public class MidLayer extends Sprite
	{
		static private var _layer:DisplayObjectContainer;
		
		public function MidLayer()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		protected function onAddToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			_layer = this;
		}
		
		static public function ShowWindow(cls:Class, zhezhao:Boolean = false):void
		{
			ShowWindowObj(cls,{});
		}
		
		static private var _dic:Dictionary = new Dictionary;
		static public function ShowWindowObj(cls:Class, obj:Object):void
		{
			if(HasWindow(cls))CloseWindow(cls);
			var view:DisplayObject;
			
			if(obj.params)
			{
				var params:Array = obj.params;
				switch(params.length)
				{
					case 0:
						view = new cls();
						break;
					case 1:
						view = new cls(params[0]);
						break;
					case 2:
						view = new cls(params[0],params[1]);
						break;
					case 3:
						view = new cls(params[0],params[1],params[2]);
						break;
					case 4:
						view = new cls(params[0],params[1],params[2],params[3]);
						break;
					default:
						throw new Error("params: can't support more than 4 params");
				}
			}
			else
			{
				view = new cls();
			}
			
			_layer.addChild(view);
			_dic[cls] = view;
		}
		
		static public function CloseWindow(cls:Class):void
		{
			if(HasWindow(cls))
			{
				var view:DisplayObject = _dic[cls];
				_layer.removeChild(view);
				delete _dic[cls];
			}
		}
		
		static public function HasWindow(cls:Class):Boolean
		{
			return _dic[cls]?true:false;
		}
	}
}