package
{
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import data.Buffer;
	import data.MySignals;
	import data.MySocket;
	import data.StaticTable;
	
	import message.MainPlayer;
	import net.hires.debug.Stats;
	import view.welcome.WelcomeView;
	
	import warn.WarnView;
	[SWF(frameRate="24")]
	public class Test2 extends Sprite
	{	
		/*private var mStarling:Starling;*/
		private var _midLayer:MidLayer = new MidLayer;
		
		public function Test2()
		{
			TweenPlugin.activate([TransformAroundCenterPlugin]);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//var stageWidth:int   = StaticTable.STAGE_WIDTH
			//var stageHeight:int  = StaticTable.STAGE_HEIGHT;
			//var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
			addChild(_midLayer);
			addChild(new Stats);
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
			StaticTable.Init();
			BufferInit();
			SocketInit();
			GlobalListen();
			MidLayer.ShowWindow(WelcomeView);
		}
		
		private function GlobalListen():void
		{
		}
		
		private var _buffer:Buffer = new Buffer;
		
		private function BufferInit():void
		{
			var player:MainPlayer = new MainPlayer;
			player.id = 1;
			player.name = "lsg";
			player.gold = 100;
			player.curCityId = 1;
			player.curMapId = 2;
			player.curShip = 1;
			player.curPaoDan = 1;
			for(var i:int=1; i<=5; i++)
			{
				player.sjs.push(StaticTable.GetSkillDescByTypeLevel(i,0));
			}
			for(; i<=11; i++)
			{
				player.sfs.push(StaticTable.GetShenFuByTypeLevel(i,0));
			}
			MySignals.onMainPlayer.dispatch(player);
			
			/*for(i = 1; i <= 100; i ++)
			{
				var dj:DaoJu = new DaoJu;
				dj.id = i;
				dj.itemId = i % 4 + 1;
				dj.count = 1;
				MySignals.onDaoJu.dispatch(dj);
			}
			
			for(i = 0; i < 4; i++)
			{
				var pd:PaoDan = new PaoDan;
				pd.id = i + 1;
				pd.bulletId = i % 4 + 1;
				pd.count = 1;
				pd.isEquiped = true;
				MySignals.onPaoDan.dispatch(pd);
			}*/
		}
		
		private var _socket:MySocket = new MySocket;
		
		private function SocketInit():void
		{
		}
		
		public static function Warn(content:String, okFun:Function = null, cancleFun:Function = null, okParams:Array = null, cancleParams:Array = null):void
		{
			MidLayer.ShowWindowObj(WarnView, {params:[{content:content, ok:okFun, cancle:cancleFun, okParams:okParams, cancleParams:cancleParams}]});
		}
		
		public static function Error(error:int):void
		{
			if(StaticTable.ERROR_DIC[error])
				Warn(StaticTable.ERROR_DIC[error]);
			else
				Warn("undefined error : "+error);
		}
	}
}