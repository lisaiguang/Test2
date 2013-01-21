package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	import net.hires.debug.Stats;
	
	import utils.StaticTable;
	
	import view.WelcomeView;
	
	public class Test2 extends Sprite
	{	
		/*private var mStarling:Starling;*/
		private var _midLayer:MidLayer = new MidLayer;
		
		public function Test2()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var stageWidth:int   = StaticTable.STAGE_WIDTH
			var stageHeight:int  = StaticTable.STAGE_HEIGHT;
			var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
			
			this.addChild(_midLayer);
			this.addChild(new Stats);
			/*Starling.multitouchEnabled = true;
			Starling.handleLostContext = !iOS; 
			
			var viewPort:Rectangle = RectangleUtil.fit(
				new Rectangle(0, 0, stageWidth, stageHeight), 
				new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), true);
			
			var scaleFactor:int = viewPort.width < 480 ? 1 : 2; // midway between 320 and 640
			var appDir:File = File.applicationDirectory;
			
			mStarling = new Starling(StarlingLayer, stage, viewPort);
			mStarling.stage.stageWidth  = stageWidth;  // <- same size on all devices!
			mStarling.stage.stageHeight = stageHeight; // <- same size on all devices!
			mStarling.simulateMultitouch  = false;
			mStarling.enableErrorChecking = Capabilities.isDebugger;
			
			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, 
				function onRootCreated(event:Object, app:StarlingLayer):void
				{
					mStarling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
					mStarling.start();
				});*/
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.ACTIVATE, function (e:*):void { /*mStarling.start();*/ });
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.DEACTIVATE, function (e:*):void { /*mStarling.stop();*/ });
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.addEventListener(Event.ENTER_FRAME, onFrameIn);
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
			this.removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddToStage);
			MidLayer.ShowWindow(view.WelcomeView);
		}
	}
}