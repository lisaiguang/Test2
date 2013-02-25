package utils
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class SCheckers
	{
		public static const EFFECT_GLOW:String = "glow";
		private var _args:Array;
		private var _vars:Object;
		
		private var selecter:Sprite;
		
		public function SCheckers(args:Array, vars:Object = null) 
		{
			_args = args;
			_vars = vars;
			
			for (var i:int = 0; i < args.length; i++)
			{
				var mc:Sprite = args[i] as Sprite;
				mc.mouseChildren = false;
				
				if (mc)
				{
					mc.addEventListener(MouseEvent.CLICK, onClick);
				}
				
				if (vars && mc == vars.check)
				{
					selecter = mc;
					addEffect(mc);
				}
			}
		}
		
		private function onClick(e:MouseEvent):void 
		{	
			var mc:Sprite = e.currentTarget as Sprite;
			
			if(selecter)
			{
				removeEffect(selecter);
			}
			
			selecter = mc;
			addEffect(mc);
			
			if (_vars && _vars.click is Function)
			{
				_vars.click.apply(null, _vars.clickParams);
			}
		}
		
		private function addEffect(sp:Sprite):void
		{
			if(_vars.effect)
			{
				if(_vars.effect == EFFECT_GLOW)
				{
					LHelp.AddGlow(sp);
				}
			}
		}
		
		public function removeEffect(sp:Sprite):void
		{
			if(_vars.effect)
			{
				if(_vars.effect == EFFECT_GLOW)
				{
					LHelp.RemoveGlow(sp);
				}
			}
		}
		
		public function getCheck(index:int = -1):Sprite
		{
			if(index == -1)
			{
				return selecter;
			}
			else
			{
				return _args[index];
			}
		}
		
		public function getCheckers():Array
		{
			return _args;
		}
		
		public function getCheckIndex():int 
		{
			var p:int = 0;
			
			for each(var m:Sprite in _args)
			{
				if (m == selecter)
					return p ;
				
				p++;
			}
			
			return -1;
		}
		
		public function SetCheck(lb:Sprite):void 
		{
			if(selecter)
			{
				removeEffect(selecter);
			}
			selecter = lb;
			if(lb)
			{
				addEffect(lb);
			}
		}
	}
}