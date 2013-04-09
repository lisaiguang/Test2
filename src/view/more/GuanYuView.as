package view.more
{
	import flash.events.MouseEvent;
	
	import lsg.ZhiZuoRenUI;
	
	public class GuanYuView extends ZhiZuoRenUI
	{
		public function GuanYuView()
		{
			super();
			btnReturn.addEventListener(MouseEvent.CLICK, onReturn);
		}
		
		protected function onReturn(event:MouseEvent):void
		{
			MidLayer.CloseWindow(GuanYuView);
		}
	}
}