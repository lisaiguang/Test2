package view.welcome
{
	import com.greensock.TweenLite;
	import com.urbansquall.ginger.AnimationBmp;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import data.MiniBuffer;
	import data.StaticTable;
	import data.staticObj.EnumMusic;
	
	import lsg.BtnMusicOff;
	import lsg.BtnMusicOn;
	import lsg.MiniMainMenuUI;
	import lsg.bmp.MainMenuBg;
	import lsg.bmp.MainMenuFg;
	import lsg.bmp.MainMenuTitle;
	
	import music.SoundPlayer;
	
	import view.caishen.CaiShenView;
	import view.more.GouMaiVeiw;
	import view.more.GuanYuView;
	import view.paihang.PaiHangView;
	
	public class MiniMainMenuView extends MiniMainMenuUI
	{
		private var _mainbtns:Array;
		private var _newgamebtns:Array, _morebtns:Array;
		private var _lightAni:AnimationBmp, _anis:Vector.<AnimationBmp>;
		private var _sp:SoundPlayer, _btnoff:BtnMusicOff, _btnon:BtnMusicOn;
		public function MiniMainMenuView(isInit:Boolean = false)
		{
			var bg:Bitmap = new Bitmap(new MainMenuBg);
			addChildAt(bg, 0);
			
			_lightAni = StaticTable.GetAniBmpByName("MiniTk3"); 
			addChildAt(_lightAni, 1);
			
			var fg:Bitmap = new Bitmap(new MainMenuFg);
			fg.y = 40;
			addChildAt(fg, 2);
			
			var title:Bitmap = new Bitmap(new MainMenuTitle);
			addChildAt(title, 3);
			
			_mainbtns = [btnNewGame, btnPaiHang, btnMore];
			_newgamebtns = [btnFinger, btnTiGan];
			_morebtns = [btnGY, btnYao];
			for(var i:int = 0; i < _mainbtns.length; i++)
			{
				var d:DisplayObject = _mainbtns[i];
				d.x = (StaticTable.STAGE_WIDTH-d.width)*.5;
			}
			showMainBtns();
			
			btnNewGame.addEventListener(MouseEvent.CLICK, onNewGameClick);
			btnReturn.addEventListener(MouseEvent.CLICK, onReturnClick);
			btnFinger.addEventListener(MouseEvent.CLICK, onFingerClick);
			btnTiGan.addEventListener(MouseEvent.CLICK, onTiGanClick);
			btnPaiHang.addEventListener(MouseEvent.CLICK, onPaiHang);
			btnMore.addEventListener(MouseEvent.CLICK, onMore);
			btnYao.addEventListener(MouseEvent.CLICK, onYao);
			btnGY.addEventListener(MouseEvent.CLICK, onGY);
			
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			if(isInit)
			{
				_anis=new Vector.<AnimationBmp>;
				var aniNames:Array = ["MiniBoom", "jubaopen", "shalou"];
				for(i = 0; i < aniNames.length; i++)
				{
					var ani:AnimationBmp = StaticTable.GetAniBmpByName(aniNames[i]);
					addChildAt(ani, 0);
					_anis.push(ani);
				}
			}
			
			_btnoff=new BtnMusicOff;
			_btnoff.x=StaticTable.STAGE_WIDTH - _btnoff.width;
			_btnoff.addEventListener(MouseEvent.CLICK, onMusicOff);
			_btnon=new BtnMusicOn;
			_btnon.x=StaticTable.STAGE_WIDTH - _btnon.width;
			_btnon.addEventListener(MouseEvent.CLICK, onMusicOn);
			_sp = StaticTable.GetSoundPlayer(EnumMusic.BG);
			if(MiniBuffer.cookies.data.music)
			{
				addChild(_btnon);
				if(!_sp.isPlaying)_sp.play(0,int.MAX_VALUE);
			}
			else
			{
				addChild(_btnoff);
				if(_sp.isPlaying)_sp.stop();
			}
		}
		
		protected function onMusicOn(event:MouseEvent):void
		{
			addChild(_btnoff);
			removeChild(_btnon);
			MiniBuffer.cookies.data.music = false;
			MiniBuffer.cookies.flush();
			if(_sp.isPlaying)_sp.stop();
		}
		
		protected function onMusicOff(event:MouseEvent):void
		{
			addChild(_btnon);
			removeChild(_btnoff);
			MiniBuffer.cookies.data.music = true;
			MiniBuffer.cookies.flush();
			if(!_sp.isPlaying)_sp.play(0,int.MAX_VALUE);
		}
		
		protected function onGY(event:MouseEvent):void
		{
			MidLayer.ShowWindow(GuanYuView);
		}
		
		protected function onYao(event:MouseEvent):void
		{
			MidLayer.ShowWindow(GouMaiVeiw);
		}
		
		protected function onMore(event:MouseEvent):void
		{
			for(var i:int = 0; i < _mainbtns.length; i++)
			{
				var d:DisplayObject = _mainbtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:-d.width, y:d.y});
			}
			for(i = 0; i < _morebtns.length; i++)
			{
				d = _morebtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5, y:d.y});
			}
			TweenLite.delayedCall(.5 + i*Delay, returnVisible);
		}
		
		protected function onPaiHang(event:MouseEvent):void
		{
			MidLayer.CloseWindow(MiniMainMenuView);
			MidLayer.ShowWindow(PaiHangView);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			removeEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		
		protected function onFrameIn(event:Event):void
		{
			_lightAni.update(CaiShenDao.ELAPSED);
			if(_anis)
			{
				for(var i:int = 0;i < _anis.length; i++)
				{
					_anis[i].update(CaiShenDao.ELAPSED);
				}
			}
		}
		
		protected function onTiGanClick(event:MouseEvent):void
		{
			MiniBuffer.model = 1;
			MidLayer.CloseWindow(MiniMainMenuView);
			MidLayer.ShowWindow(CaiShenView);
		}
		
		protected function onFingerClick(event:MouseEvent):void
		{
			MiniBuffer.model = 0;
			MidLayer.CloseWindow(MiniMainMenuView);
			MidLayer.ShowWindow(CaiShenView);
		}
		
		protected function onReturnClick(event:MouseEvent):void
		{
			btnReturn.visible = false;
			
			for(var i:int = 0; i < _newgamebtns.length; i++)
			{
				var d:DisplayObject = _newgamebtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:StaticTable.STAGE_WIDTH});
			}
			
			for(i = 0; i < _morebtns.length; i++)
			{
				d = _morebtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:StaticTable.STAGE_WIDTH});
			}
			
			for(i = 0; i < _mainbtns.length; i++)
			{
				d = _mainbtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5});
			}
		}
		
		private const Delay:Number = .1;
		private function showMainBtns():void
		{
			btnReturn.visible = false;
			
			for(var i:int = 0; i < _newgamebtns.length; i++)
			{
				var d:DisplayObject = _newgamebtns[i];
				d.x = StaticTable.STAGE_WIDTH;
			}
			
			for(i = 0; i < _morebtns.length; i++)
			{
				d = _morebtns[i];
				d.x = StaticTable.STAGE_WIDTH;
			}
			
			for(i = 0; i < _mainbtns.length; i++)
			{
				d = _mainbtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5});
			}
		}
		
		protected function onNewGameClick(event:MouseEvent):void
		{
			for(var i:int = 0; i < _mainbtns.length; i++)
			{
				var d:DisplayObject = _mainbtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:-d.width, y:d.y});
			}
			
			for(i = 0; i < _newgamebtns.length; i++)
			{
				d = _newgamebtns[i];
				TweenLite.to(d, 0.5, {delay:i*Delay, x:(StaticTable.STAGE_WIDTH-d.width)*.5, y:d.y});
			}
			
			TweenLite.delayedCall(.5 + i*Delay, returnVisible);
		}
		
		private function returnVisible():void
		{
			btnReturn.visible = true;
		}
	}
}