package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import lsg.gas.Welcome;
	import starling.core.Starling;
	
	public class Test2 extends Sprite
	{
		private var myStarling:Starling;
		
		public function Test2()
		{
			super();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Starling.multitouchEnabled = true;
			
			myStarling = new Starling(Game, stage);
			myStarling.antiAliasing = 1;
			myStarling.showStats = true;
			myStarling.start();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		protected function onAddToStage(event:Event):void
		{
			// TODO Auto-generated method stub
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.addChild(new lsg.gas.Welcome);
		}
	}
}