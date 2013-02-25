package view
{
	import flash.events.MouseEvent;
	
	import lsg.Welcome;
	
	import utils.LazySprite;
	
	import view.island.IslandView;
	
	public class WelcomeView extends LazySprite
	{
		private var _view:Welcome;
		
		public function WelcomeView()
		{
			addChild(_view = new Welcome);
			_view.addEventListener(MouseEvent.CLICK, onStart);
		}
		
		protected function onStart(event:MouseEvent = null):void
		{
			MidLayer.CloseWindow(WelcomeView);
			MidLayer.ShowWindow(IslandView); 
		}
	}
}