package view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import view.battle.BattleView;
	
	import lsg.gas.Welcome;
	
	public class WelcomeView extends Sprite
	{
		private var _view:Welcome = new Welcome;
		
		public function WelcomeView()
		{
			addChild(_view);
			_view.btnStart.addEventListener(MouseEvent.CLICK, onStart);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		protected function onStart(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			MidLayer.CloseWindow(WelcomeView);
			MidLayer.ShowWindow(BattleView);
		}
		
		protected function onAdded(event:Event):void
		{
			// TODO Auto-generated method stub
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
	}
}