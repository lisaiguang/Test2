package view.battle
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	
	import phys.Terrain;
	
	import utils.StaticTable;
	
	public class BattleView extends Sprite
	{
		private var _space:Space;
		private var _debug:Debug;
		
		public function BattleView()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAdd2Stage);
		}
		
		protected function onAdd2Stage(event:Event):void
		{
			var gravity:Vec2 = Vec2.weak(0, 600);
			_space = new Space(gravity);
			
			_debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, stage.color);
			addChild(_debug.display);
			
			setUp();
			
			this.addEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		private function setUp():void
		{
			var bd:BitmapData = StaticTable.GetBattleBackground(1);
			var tr:Terrain = new Terrain(_space, bd, new Vec2(0,0), 160, 8);
			//this.addChild(new Bitmap(bd));
		}
		
		protected function onFrameIn(event:Event):void
		{
			_space.step(1 / stage.frameRate);
			
			_debug.clear();
			_debug.draw(_space);
			_debug.flush();
		}
	}
}