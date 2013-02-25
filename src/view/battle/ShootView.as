package view.battle
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.shoot.IconBg;
	
	public class ShootView extends Sprite
	{
		private var spts:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>;
		
		public function ShootView()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public var bulletPress:int;
		protected function onMouseDown(event:MouseEvent):void
		{
			var tname:String = event.target.name;
			if(tname.charAt(0) == "b")
			{
				bulletPress = Spt2Bid(event.target as DisplayObject); 
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			}
		}
		
		protected function onStageMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			bulletPress = 0;
		}
		
		private var _bulletIds:Vector.<int>;
		public function printfBullets(bulletIds:Vector.<int>):void
		{
			_bulletIds = bulletIds;
			
			for each(var dc:DisplayObjectContainer in spts)
			{
				removeChild(dc);
			}
			
			spts = new Vector.<DisplayObjectContainer>;
			
			for(var i:int = 0; i < bulletIds.length; i++)
			{
				var bid:int = bulletIds[i];
				var spt:IconBg = new IconBg;
				spt.name = "b" + bid;
				spt.x = 0;
				spt.y = (bulletIds.length - i - 1) * (spt.height + 2);
				addChild(spt);
				spts.push(spt);
				
				var icon:Bitmap = StaticTable.GetBulletIcon(bid);
				icon.x = spt.width *.5 - icon.width*.5;
				icon.y = spt.height *.5 - icon.height*.5;
				spt.addChild(icon);
			}
			
			InitPos();
		}
		
		private function Spt2Bid(spt:DisplayObject):int
		{
			return int(spt.name.substr(1));
		}
		
		private function Bid2Spt(bid:int):IconBg
		{
			return getChildByName("b" + bid) as IconBg;
		}
		
		public function InitPos():void
		{
			x = StaticTable.STAGE_WIDTH - width;
			y = StaticTable.STAGE_HEIGHT - height - 220;
		}
	}
}