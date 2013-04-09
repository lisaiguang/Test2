package
{
	import com.adobe.ane.gameCenter.GameCenterController;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import data.MiniBuffer;
	import data.MiniSingals;
	import data.StaticTable;
	
	import message.PauseReq;
	
	import view.welcome.MiniMainMenuView;
	
	[SWF(frameRate="24",backgroundColor="0x000000")]
	public class CaiShenDao extends Sprite
	{
		private var _midLayer:MidLayer = new MidLayer;
		public static var GcController : GameCenterController = new GameCenterController();
		
		public function CaiShenDao()
		{
			TweenPlugin.activate([TransformAroundCenterPlugin]);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			StaticTable.Init();
			MiniBuffer.Init();
			
			addChild(_midLayer);
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.ACTIVATE, function (e:*):void { 
					NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
				});
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.DEACTIVATE, function (e:*):void {
					MiniSingals.OnPauseReq.dispatch(new PauseReq);
					NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
				});
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
			GcController.authenticate();
			MidLayer.ShowWindowObj(MiniMainMenuView,{params:[true]});
		}
	}
}