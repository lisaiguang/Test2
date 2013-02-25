package view.battle
{
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	import message.EnumDirection;
	
	import lsg.battle.BottomUI;
	
	public class BottomView extends BottomUI
	{
		public function BottomView()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			switch(event.target.name)
			{
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
		
		protected function onStageMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			isDownPressing = isUpPressing = isRightPressing = isLeftPressing = false;
		}
		
		public function InitPos():void
		{
			x = 10;
			y = StaticTable.STAGE_HEIGHT - height - 10;
		}
		
		public function printfDegree(degree:Number, direction:int):void
		{
			txtDegree.text = int(direction == EnumDirection.LEFT? 180 + degree:-degree) + "°";
			mcPointer.rotation = degree;
		}
		
		public function printfForce(force:int, lastForce:int):void
		{
			txtForce.text = force + "%";
			barForce.width = 440 * force * 0.01;
		}
	}
}