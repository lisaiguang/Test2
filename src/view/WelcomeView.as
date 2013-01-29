package view
{
	import flash.events.MouseEvent;
	
	import data.MySignals;
	import data.obj.BattleBeginAck;
	import data.obj.BattleBeginReq;
	
	import lsg.gas.Welcome;
	
	import utils.LazySprite;
	
	import view.battle.BattleView;
	
	public class WelcomeView extends LazySprite
	{
		private var _view:Welcome;
		
		public function WelcomeView()
		{
			addChild(_view = new Welcome);
			_view.addEventListener(MouseEvent.CLICK, onStart);
		}
		
		override protected function init():void
		{
			listen(MySignals.onBattleBeginAck, onBattleBeginAck);
		}
		
		private function onBattleBeginAck(bba:BattleBeginAck):void
		{
			if(bba.error)
			{
				
			}
			else
			{
				MidLayer.CloseWindow(WelcomeView);
				MidLayer.ShowWindowObj(BattleView,{params:[bba]}); 
			}
		}
		
		protected function onStart(event:MouseEvent):void
		{
			MySignals.Socket_Send.dispatch(new BattleBeginReq);
		}
	}
}