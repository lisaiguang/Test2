package
{
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import data.MiniBuffer;
	import data.StaticTable;
	
	import net.hires.debug.Stats;
	
	import view.mini.welcome.MiniWelcomeView;

	[SWF(frameRate="30")]
	public class CaiShenDao extends Sprite
	{
		private var _midLayer:MidLayer = new MidLayer;
		
		public function CaiShenDao()
		{
			TweenPlugin.activate([TransformAroundCenterPlugin]);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			addChild(_midLayer);
			addChild(new Stats);
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			addEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		public static var ELAPSED:int;
		public static var TIMESTAMP:int;
		protected function onFrameIn(event:Event):void
		{
			var ts:int = getTimer();
			ELAPSED = ts - TIMESTAMP;
			TIMESTAMP = ts;
		}
		
		protected function onAddToStage(event:flash.events.Event):void
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddToStage);
			StaticTable.Init();
			MiniBuffer.Init();
			MidLayer.ShowWindow(MiniWelcomeView);
		}
	}
}