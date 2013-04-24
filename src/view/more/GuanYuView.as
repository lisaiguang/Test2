package view.more
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import lsg.ZhiZuoRenUI;
	
	public class GuanYuView extends ZhiZuoRenUI
	{
		public function GuanYuView()
		{
			super();
			btnReturn.addEventListener(MouseEvent.CLICK, onReturn);
			btnXiaZai.addEventListener(MouseEvent.CLICK, onXiaZai);
			CONFIG::android
				{
					btnXiaZai.visible = false;
				}
		}
		
		protected function onXiaZai(event:MouseEvent):void
		{
			CONFIG::ios
				{
					navigateToURL(new URLRequest("https://itunes.apple.com/us/app/wa-hong-shu/id639476618"));
				}
		}
		
		protected function onReturn(event:MouseEvent):void
		{
			MidLayer.CloseWindow(GuanYuView);
		}
	}
}