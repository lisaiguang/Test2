package utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class LazySprite extends Sprite
	{
		public function LazySprite()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdd2Stage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private var sigs:Vector.<Signal>;
		private var funs:Vector.<Function>;
		
		protected function listen(signal:Signal, func:Function):void
		{
			if(sigs == null){sigs = new Vector.<Signal>;funs = new Vector.<Function>}
			signal.add(func);
			sigs.push(signal);
			funs.push(func);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			if(sigs)
			{
				for(var i:int = 0; i < sigs.length; i++)
				{
					sigs[i].remove(funs[i]);
				}
				sigs = null;
				funs = null;
			}
			destoryed();
		}
		
		protected function destoryed():void
		{
			
		}
		
		private function onAdd2Stage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdd2Stage);
			init();
		}
		
		protected function init():void
		{
		}
	}
}