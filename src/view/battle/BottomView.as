package view.battle
{
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.battle.BottomUI;
	
	public class BottomView extends BottomUI
	{
		public function BottomView()
		{
			btnFire.addEventListener(MouseEvent.MOUSE_DOWN, onFireDown);
			btnUp.addEventListener(MouseEvent.MOUSE_DOWN, onUpDown);
			btnDown.addEventListener(MouseEvent.MOUSE_DOWN, onDownDown);
			btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, onLeftDown);
			btnRight.addEventListener(MouseEvent.MOUSE_DOWN, onRightDown);
		}
		
		public var isDownPressing:Boolean = false;
		
		protected function onDownDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onFireUp);
			isDownPressing = true;
		}
		
		public var isLeftPressing:Boolean = false;
		
		protected function onLeftDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onFireUp);
			isLeftPressing = true;
		}
		
		public var isRightPressing:Boolean = false;
		
		protected function onRightDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onFireUp);
			isRightPressing = true;
		}
		
		public var isUpPressing:Boolean = false;
		
		protected function onUpDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onFireUp);
			isUpPressing = true;
		}
		
		public var isFirePressing:Boolean = false;
		
		protected function onFireDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onFireUp);
			isFirePressing = true;
		}
		
		protected function onFireUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onFireUp);
			isDownPressing = isUpPressing = isRightPressing = isLeftPressing = isFirePressing = false;
		}
		
		public function InitPos():void
		{
			x = 10;
			y = StaticTable.STAGE_HEIGHT - height - 5;
		}
		
		public function printfDegree(degree:int):void
		{
			txtDegree.text = (degree < -90 ? degree + 180: -degree) + "°";
			mcPointer.rotation = degree;
		}
		
		public function printfForce(force:int):void
		{
			txtForce.text = force + "%";
			barForce.width = 486 * force * 0.01;
		}
	}
}