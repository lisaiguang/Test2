package view.mini.welcome
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.MiniMainMenuUI;
	
	public class MiniMainMenuView extends MiniMainMenuUI
	{
		private var _mainbtns:Array;
		private var _newgamebtns:Array;
		
		public function MiniMainMenuView()
		{
			_mainbtns = [btnNewGame, btnPaiHang, btnEWai];
			_newgamebtns = [btnFinger, btnTiGan];
			
			showMainBtns();
			btnNewGame.addEventListener(MouseEvent.CLICK, onNewGameClick);
			btnReturn.addEventListener(MouseEvent.CLICK, onReturnClick);
		}
		
		protected function onReturnClick(event:MouseEvent):void
		{
			if(_status == 1)
			{
				_status = 0;
				btnReturn.visible = false;
				
				for(var i:int = 0; i < _newgamebtns.length; i++)
				{
					var d:DisplayObject = _newgamebtns[i];
					TweenLite.to(d, 0.5, {delay:i*Delay, x:StaticTable.STAGE_WIDTH});
				}
				
				for(i = 0; i < _mainbtns.length; i++)
				{
					d = _mainbtns[i];
					TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5});
				}
			}
		}
		
		private const Delay:Number = .1;
		private function showMainBtns():void
		{
			btnReturn.visible = false;
			
			for(var i:int = 0; i < _newgamebtns.length; i++)
			{
				var d:DisplayObject = _newgamebtns[i];
				d.x = StaticTable.STAGE_WIDTH;
			}
			
			for(i = 0; i < _mainbtns.length; i++)
			{
				d = _mainbtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5});
			}
		}
		
		protected function onNewGameClick(event:MouseEvent):void
		{
			showNewGameMenu();
		}
		
		private var _status:int;
		private function showNewGameMenu():void
		{
			_status = 1;
			
			for(var i:int = 0; i < _mainbtns.length; i++)
			{
				var d:DisplayObject = _mainbtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:-d.width, y:d.y});
			}
			
			for(i = 0; i < _newgamebtns.length; i++)
			{
				d = _newgamebtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5, y:d.y});
			}
			
			TweenLite.delayedCall(.5 + i*Delay, returnVisible);
		}
		
		private function returnVisible():void
		{
			btnReturn.visible = true;
		}
	}
}