package view.city
{
	import flash.events.MouseEvent;
	
	import data.MySignals;
	import data.StaticTable;
	
	import lsg.IslandUI;
	import lsg.MenuBarUI;
	
	import message.BattleBeginAck;
	import message.BattleBeginReq;
	
	import utils.LazySprite;
	
	import view.battle.BattleView;
	import view.gangkou.GangKouView;
	import view.paodan.PaoDanView;
	import view.paodanfactory.PaoDanFactoryView;
	import view.shendian.ShenDianView;
	
	public class CityView extends LazySprite
	{
		private var _ui:IslandUI = new IslandUI;
		private var _menuUI:lsg.MenuBarUI = new MenuBarUI;
		
		public function CityView(id:int = 1)
		{
			addChild(_ui);
			_ui.mcJinJi.addEventListener(MouseEvent.CLICK, onJinJiClick);
			_ui.mcPaoDan.addEventListener(MouseEvent.CLICK, onPaoDanFactoryClick);
			_ui.mcGangKou.addEventListener(MouseEvent.CLICK, onGangKouClick);
			
			addChild(_menuUI);
			_menuUI.btnDaoJu.addEventListener(MouseEvent.CLICK, onDaoJuClick);
			_menuUI.btnPao.addEventListener(MouseEvent.CLICK, onPaoDanClick);
		}
		
		protected function onGangKouClick(event:MouseEvent):void
		{
			MidLayer.CloseWindow(CityView);
			MidLayer.ShowWindowObj(GangKouView, {zhezhao:true});
		}
		
		protected function onPaoDanFactoryClick(event:MouseEvent):void
		{
			MidLayer.ShowWindowObj(PaoDanFactoryView, {zhezhao:true});
		}
		
		protected function onDaoJuClick(event:MouseEvent):void
		{
			MidLayer.ShowWindowObj(ShenDianView, {zhezhao:true});
		}
		
		protected function onPaoDanClick(event:MouseEvent):void
		{
			MidLayer.ShowWindowObj(PaoDanView, {zhezhao:true});
		}
		
		protected function onJinJiClick(event:MouseEvent):void
		{
			MySignals.Socket_Send.dispatch(new BattleBeginReq);
		}
		
		override protected function init():void
		{
			listen(MySignals.onBattleBeginAck, onBattleBeginAck);
			InitPos();
		}
		
		private function onBattleBeginAck(bba:BattleBeginAck):void
		{
			if(bba.error == 0)
			{
				MidLayer.CloseWindow(CityView);
				MidLayer.ShowWindowObj(BattleView,{zhezhao:true, params:[bba]});
			}
		}
		
		public function InitPos():void
		{
			_ui.x = 0;
			_ui.y = 0;
			_menuUI.x = (StaticTable.STAGE_WIDTH - _menuUI.width)*.5;
			_menuUI.y = StaticTable.STAGE_HEIGHT - _menuUI.height - 5;
		}
	}
}