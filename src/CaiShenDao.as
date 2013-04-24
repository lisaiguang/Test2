package
{
	CONFIG::ios
	{	
		import com.adobe.ane.gameCenter.GameCenterController;
	}
	
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import data.MiniBuffer;
	import data.MiniSingals;
	import data.StaticTable;
	import data.message.ActiveReq;
	import data.message.PauseReq;
	
	CONFIG::android
	{
		import com.greensock.TweenLite;
		import lsg.bmp.Default;
	}
		
	import view.welcome.MiniMainMenuView;
	import data.staticObj.EnumMusic;
	import music.SoundPlayer;
	
	[SWF(frameRate="24",backgroundColor="0x000000")]
	public class CaiShenDao extends Sprite
	{
		private var _midLayer:MidLayer = new MidLayer;
		CONFIG::ios
		{
			public static var GcController : GameCenterController = new GameCenterController();
		}
		
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
					MiniSingals.OnActiveReq.dispatch(new ActiveReq);
					NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
					if(MiniBuffer.cookies.data.music)
					{
						var sp:SoundPlayer = StaticTable.GetSoundPlayer(EnumMusic.BG);
						if(!sp.isPlaying)sp.play(0,int.MAX_VALUE);
					}
				});
			
			NativeApplication.nativeApplication.addEventListener(
				flash.events.Event.DEACTIVATE, function (e:*):void {
					MiniSingals.OnPauseReq.dispatch(new PauseReq);
					NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
					if(MiniBuffer.cookies.data.music)
					{
						var sp:SoundPlayer = StaticTable.GetSoundPlayer(EnumMusic.BG);
						if(sp.isPlaying)sp.stop();
					}
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
		
		protected function onAddToStage(event:Event):void
		{
			_midLayer.scaleX = StaticTable.SCALE_X = stage.fullScreenWidth / StaticTable.STAGE_WIDTH;
			_midLayer.scaleY = StaticTable.SCALE_Y = stage.fullScreenHeight / StaticTable.STAGE_HEIGHT;
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddToStage);
			
			CONFIG::ios
			{
				GcController.authenticate();
				MidLayer.ShowWindowObj(MiniMainMenuView,{params:[true]});
			}
			
			CONFIG::android
			{
				var bmp:Bitmap = new Bitmap(new Default);
				bmp.scaleX = StaticTable.SCALE_X;
				bmp.scaleY = StaticTable.SCALE_Y;
				addChild(bmp);
				TweenLite.delayedCall(2.5, onStart, [bmp]);
			}
		}
		
		private function onStart(bmp:Bitmap):void
		{
			removeChild(bmp);
			bmp.bitmapData.dispose();
			MidLayer.ShowWindow(MiniMainMenuView);
		}
	}
}