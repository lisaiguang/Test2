package view.caishen
{
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.MiniOverUI;
	
	public class CaiShenFinishView extends MiniOverUI
	{
		public function CaiShenFinishView()
		{
			btnRetry.addEventListener(MouseEvent.CLICK, onReTry);
			btnMenu.addEventListener(MouseEvent.CLICK, onMenu);
			InitPos();
		}
		
		private function InitPos():void
		{
			x = (StaticTable.STAGE_WIDTH - width)*0.5;
			y = (StaticTable.STAGE_HEIGHT - height)*0.5;
		}
		
		protected function onMenu(event:MouseEvent):void
		{
		}
		
		protected function onReTry(event:MouseEvent):void
		{
			MidLayer.CloseWindow(CaiShenFinishView);
			MidLayer.CloseWindow(CaiShenView);
			MidLayer.ShowWindow(CaiShenView);
		}
	}
}