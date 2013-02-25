package utils
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class MCheckers
	{
		private var _args:Array;
		private var _vars:Object;
		
		private var outFrame:int = 1;
		private var selectFrame:int = 2;
		private var selecter:MovieClip;
		
		public function MCheckers(args:Array, vars:Object = null) 
		{
			_args = args;
			_vars = vars;
			
			if (_vars && _vars.out)
				outFrame = _vars.out;
			if (_vars && _vars.select)
				selectFrame = _vars.select;
			
			for (var i:int = 0; i < args.length; i++)
			{
				var mc:MovieClip = args[i] as MovieClip;
				mc.mouseChildren = false;
				
				if (mc)
				{
					mc.addEventListener(MouseEvent.CLICK, onClick);
				}
				
				if (vars && mc == vars.check)
				{
					mc.gotoAndStop(selectFrame);
					selecter = mc;
				}
				else
				{
					mc.gotoAndStop(outFrame);
				}
			}
		}
		
		private function onClick(e:MouseEvent):void 
		{	
			var mc:MovieClip = e.currentTarget as MovieClip;
			
			if (mc == selecter)
			{
				return;
			}
			
			var ck:MovieClip = getCheck();
			
			if (ck)
			{
				ck.gotoAndStop(outFrame);
			}
			
			selecter = mc;
			mc.gotoAndStop(selectFrame);
			
			
			if (_vars && _vars.click is Function)
			{
				_vars.click.apply(null, _vars.clickParams);
			}
		}
		
		public function getCheck():MovieClip
		{
			return selecter;
		}
		
		public function getCheckers():Array
		{
			return _args;
		}
		
		public function getCheckIndex():int 
		{
			var p:int = 0;
			
			for each(var m:MovieClip in _args)
			{
				if (m == selecter)
					return p ;
				
				p++;
			}
			
			return -1;
		}
		
		public function SetCheck(lb:MovieClip):void 
		{
			for (var i:int = 0; i < _args.length; i++)
			{
				var mc:MovieClip = _args[i] as MovieClip;
				
				if (mc == lb)
				{
					mc.gotoAndStop(selectFrame);
				}
				else
				{
					mc.gotoAndStop(outFrame);
				}
			}
			selecter = lb;
		}
	}
}