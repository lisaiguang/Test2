package view.mini.welcome
{
	import flash.events.MouseEvent;
	
	import lsg.MiniWelcomeUI;
	
	public class MiniWelcomeView extends MiniWelcomeUI
	{
		public function MiniWelcomeView()
		{
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onClick(event:MouseEvent):void
		{
			MidLayer.CloseWindow(MiniWelcomeView);
			MidLayer.ShowWindow(MiniMainMenuView);
		}
	}
}