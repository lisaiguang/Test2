package view.battle
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.shoot.IconBg;
	
	import org.osflash.signals.Signal;
	
	import utils.LHelp;
	
	public class ShootView extends Sprite
	{
		private var spts:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>;
		
		public function ShootView()
		{
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
				spt.y = i * spt.height;
				addChild(spt);
				spts.push(spt);
				spt.addEventListener(MouseEvent.CLICK, onSptClick);
				
				var icon:Bitmap = new Bitmap(StaticTable.GetBulletIcon(bid));
				icon.x = spt.width *.5 - icon.width*.5;
				icon.y = spt.height *.5 - icon.height*.5;
				spt.addChild(icon);
			}
			
			InitPos();
		}
		
		private function Spt2Bid(spt:DisplayObjectContainer):int
		{
			return _bulletIds[spts.indexOf(spt)];
		}
		
		private function Bid2Spt(bid:int):IconBg
		{
			return getChildByName("b" + bid) as IconBg;
		}
		
		public var SHOOT:Signal = new Signal(int);
		
		protected function onSptClick(event:MouseEvent):void
		{
			var bid:int = Spt2Bid(event.currentTarget as DisplayObjectContainer);
			SHOOT.dispatch(bid);
		}
		
		public function InitPos():void
		{
			x = StaticTable.STAGE_WIDTH - width;
			y = StaticTable.STAGE_HEIGHT - height - 240;
		}
		
		public function printfBulletReady(bid:int):void
		{
			var spt:IconBg = Bid2Spt(bid);
			LHelp.DisGrey(spt);
		}
		
		public function printfBulletUnReady(bid:int):void
		{
			var spt:IconBg = Bid2Spt(bid);
			spt.filters = [];
		}
	}
}