package view.caishen
{
	import flash.events.MouseEvent;
	
	import data.MiniBuffer;
	import data.StaticTable;
	
	import lsg.MiniOverUI;
	
	import view.more.GouMaiVeiw;
	import view.welcome.MiniMainMenuView;
	import view.yaodaye.ShakeView;
	
	public class CaiShenFinishView extends MiniOverUI
	{
		public function CaiShenFinishView()
		{
			btnRetry.addEventListener(MouseEvent.CLICK, onReTry);
			btnMenu.addEventListener(MouseEvent.CLICK, onMenu);
			btnShake.addEventListener(MouseEvent.CLICK, onShake);
			InitPos();
		}
		
		protected function onShake(event:MouseEvent):void
		{
			if(MiniBuffer.cookies.data.purchased)
			{
				MidLayer.CloseWindow(CaiShenFinishView);
				MidLayer.CloseWindow(CaiShenView);
				MidLayer.ShowWindow(ShakeView);
			}
			else
			{
				MidLayer.ShowWindow(GouMaiVeiw);
			}
		}
		
		private function InitPos():void
		{
			x = (StaticTable.STAGE_WIDTH - width)*0.5;
			y = (StaticTable.STAGE_HEIGHT - height)*0.5;
		}
		
		protected function onMenu(event:MouseEvent):void
		{
			MidLayer.CloseWindow(CaiShenFinishView);
			MidLayer.CloseWindow(CaiShenView);
			MidLayer.ShowWindow(MiniMainMenuView);
		}
		
		protected function onReTry(event:MouseEvent):void
		{
			MidLayer.CloseWindow(CaiShenFinishView);
			MidLayer.CloseWindow(CaiShenView);
			MidLayer.ShowWindow(CaiShenView);
		}
	}
}