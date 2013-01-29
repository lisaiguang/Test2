package view.battle
{
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.battle.ControlUI;
	
	public class ControllerView extends ControlUI
	{	
		public function ControllerView()
		{
			btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, onForwardDown);
			btnRight.addEventListener(MouseEvent.MOUSE_DOWN, onBackDown);
		}
		
		public var isRight:Boolean = false;
		protected function onBackDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onBackUp);
			isRight= true;
		}
		
		protected function onBackUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onBackUp);
			isRight= false;
		}
		
		public var isLeft:Boolean = false;
		protected function onForwardDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onForwardUp);
			isLeft = true;
		}		
		
		protected function onForwardUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onForwardUp);
			isLeft = false;
		}
		
		public function InitPos():void
		{
			x = StaticTable.STAGE_WIDTH - width - 10;
			y = StaticTable.STAGE_HEIGHT - height - 10;
		}
	}
}