package view.paihang
{
	import flash.events.MouseEvent;
	
	import data.MiniBuffer;
	
	import lsg.PaiHangBangUI;
	
	import view.welcome.MiniMainMenuView;
	
	public class PaiHangView extends PaiHangBangUI
	{
		public function PaiHangView()
		{
			txtFuHao.text = MiniBuffer.cookies.data.fuhao + "两";
			txtTiGan.text = MiniBuffer.cookies.data.bestTiGan + "两";
			txtShouZhi.text = MiniBuffer.cookies.data.bestFinger + "两";
			txtYaoBa.text = MiniBuffer.cookies.data.yaoba + "两";
			
			btnFuHao.addEventListener(MouseEvent.CLICK, onFuHao);
			btnTiGan.addEventListener(MouseEvent.CLICK, onTiGan);
			btnShouZhi.addEventListener(MouseEvent.CLICK, onShouZhi);
			btnYaoBa.addEventListener(MouseEvent.CLICK, onYaoBa);
			btnReturn.addEventListener(MouseEvent.CLICK, onReturn);
		}
		
		protected function onReturn(event:MouseEvent):void
		{
			MidLayer.CloseWindow(PaiHangView);
			MidLayer.ShowWindow(MiniMainMenuView);
		}
		
		protected function onYaoBa(event:MouseEvent):void
		{
			CaiShenDao.GcController.showLeaderboardView("4");
		}
		
		protected function onShouZhi(event:MouseEvent):void
		{
			CaiShenDao.GcController.showLeaderboardView("3");
		}
		
		protected function onTiGan(event:MouseEvent):void
		{
			CaiShenDao.GcController.showLeaderboardView("2");
		}
		
		protected function onFuHao(event:MouseEvent):void
		{
			CaiShenDao.GcController.showLeaderboardView("1");
		}
	}
}