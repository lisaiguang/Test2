package view.battle
{
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.battle.BottomUI;
	
	public class BottomView extends BottomUI
	{
		public function BottomView()
		{
			/*btnFire.addEventListener(MouseEvent.MOUSE_DOWN, onFireDown);
			btnUp.addEventListener(MouseEvent.MOUSE_DOWN, onUpDown);
			btnDown.addEventListener(MouseEvent.MOUSE_DOWN, onDownDown);
			btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, onLeftDown);
			btnRight.addEventListener(MouseEvent.MOUSE_DOWN, onRightDown);*/
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			switch(event.target.name)
			{
				case "btnFire":
					isFirePressing = true;
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					break;
				case "btnUp":
					isUpPressing = true;
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					break;
				case "btnDown":
					isDownPressing = true;
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					break;
				case "btnLeft":
					isLeftPressing = true;
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					break;
				case "btnRight":
					isRightPressing = true;
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					break;
			}
		}
		
		public var isDownPressing:Boolean = false;
		
		protected function onDownDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			isDownPressing = true;
		}
		
		public var isLeftPressing:Boolean = false;
		
		protected function onLeftDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			isLeftPressing = true;
		}
		
		public var isRightPressing:Boolean = false;
		
		protected function onRightDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			isRightPressing = true;
		}
		
		public var isUpPressing:Boolean = false;
		
		protected function onUpDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			isUpPressing = true;
		}
		
		public var isFirePressing:Boolean = false;
		
		protected function onFireDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			isFirePressing = true;
		}
		
		protected function onStageMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
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
			barForce.width = 440 * force * 0.01;
		}
	}
}