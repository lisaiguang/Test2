package view.yaodaye
{
	import com.urbansquall.ginger.AnimationBmp;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.sensors.Accelerometer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import data.MiniBuffer;
	import data.StaticTable;
	import data.staticObj.BodyBoxDesc;
	import data.staticObj.EnumAction;
	import data.staticObj.EnumBody;
	
	import lsg.BtnReturn;
	import lsg.bmp.MiniLiang;
	import lsg.bmp.ShakeBeginTip;
	import lsg.bmp.mini1;
	import lsg.bmp.mini2;
	import lsg.bmp.mini3;
	import lsg.bmp.mini4;
	import lsg.bmp.mini5;
	import lsg.bmp.mini6;
	import lsg.bmp.mini7;
	import lsg.bmp.mini8;
	import lsg.bmp.mini9;
	import lsg.bmp.miniBest;
	import lsg.bmp.miniGold;
	import lsg.bmp.miniGoldBg;
	import lsg.bmp.miniOver;
	import lsg.bmp.yao1;
	import lsg.bmp.yao2;
	import lsg.bmp.yao3;
	import lsg.bmp.yao4;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import utils.LazySprite;
	
	import view.welcome.MiniMainMenuView;
	
	public class ShakeView extends LazySprite
	{
		private var _bmp:Bitmap;
		private var _bmps:Vector.<BitmapData> = new Vector.<BitmapData>;
		private var _xunxu:Array = [1,0,0,0,1,2,3,3,3,3,2,1], _currentFrame:int;
		private var _turnCount:int, _turnIntevs:Array = [];
		
		private var _ybWaitBodys:Vector.<Body> = new Vector.<Body>;
		private var _baowuIds:Array = [EnumBody.TONGQIAN, EnumBody.YINZI, EnumBody.YUANBAO];
		private static const GROUP_YUANBAO:int = 4;
		private var YUANBAOS:CbType = new CbType;
		
		public function ShakeView()
		{
			for(var i:int = 0; i < 36; i++)
			{
				var id:int = _baowuIds[i % _baowuIds.length];
				var ybDesc:BodyBoxDesc = StaticTable.GetBodyBoxDescById(id);
				var ybAni:AnimationBmp = StaticTable.GetAniBmpByName(ybDesc.name);
				
				var poly:Polygon = new Polygon(Polygon.box(ybDesc.width, ybDesc.height, true));
				poly.filter.collisionGroup = GROUP_YUANBAO;
				poly.filter.collisionMask = ~(GROUP_YUANBAO);
				
				var yb:Body = new Body(BodyType.DYNAMIC);
				yb.allowRotation = false;
				yb.shapes.add(poly);
				yb.cbTypes.add(YUANBAOS);
				yb.userData.isDel = false;
				yb.userData.occur = false;
				yb.userData.animation = ybAni;
				yb.userData.desc = ybDesc;
				_ybWaitBodys.push(yb);
			}
			
			_bmp = new Bitmap();
			addChild(_bmp);
			var bmpClass:Array = [yao1,yao2,yao3,yao4];
			for(i = 0; i<bmpClass.length; i++)
			{
				_bmps.push(new bmpClass[i]);
			}
			_bmp.bitmapData = _bmps[_xunxu[_currentFrame]];
			
			initAcc();
			initSpace();
			initHeadUp();
			addEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		private var _space:Space;
		private function initSpace():void
		{
			var gravity:Vec2 = Vec2.weak(0, 850);
			_space = new Space(gravity);
			
			createBorder();
			createNapeListeners();
		}
		
		private function createNapeListeners():void
		{
			var landDetect:InteractionListener =  new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, YUANBAOS, BORDER, onYuanbao2Border);
			_space.listeners.add(landDetect);
		}
		
		private function onYuanbao2Border(cb:InteractionCallback):void
		{
			var yb:Body = cb.int1.castBody;
			yb.userData.isDel = true;
		}
		
		private var BORDER:CbType = new CbType;
		public static const BORDER_PADDING:int = 20;
		private function createBorder():void
		{
			var border:Body = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(-2500, StaticTable.STAGE_HEIGHT + BORDER_PADDING, StaticTable.STAGE_WIDTH + 5000, 1)));
			border.space = _space;
			border.cbTypes.add(BORDER);
		}
		
		private var _goldTxt:TextField, _bestTxt:TextField;
		private var _liangAniBmp:Bitmap, _curGoldBgBmp:Bitmap, _maxGoldBgBmp:Bitmap;
		private var _bestScore:int;
		private var _btnBack:BtnReturn;
		private var _shakeBeginBmp:Bitmap, _shakeFinishBmp:Bitmap;
		private function initHeadUp():void
		{
			var goldBmp:Bitmap = new Bitmap(new miniGold);
			goldBmp.x = 10;
			goldBmp.y = 10;
			addChild(goldBmp);
			
			var format:TextFormat = new TextFormat("impact", 40, 0xffffff, true);
			_goldTxt = new TextField();
			_goldTxt.defaultTextFormat = format;
			_goldTxt.text = "0";
			_goldTxt.selectable = false;
			_goldTxt.autoSize = TextFieldAutoSize.LEFT;
			_goldTxt.x = goldBmp.x + goldBmp.width;
			_goldTxt.y = goldBmp.y + (goldBmp.height - _goldTxt.height) * .5;
			_goldTxt.cacheAsBitmap = true;
			
			_curGoldBgBmp = new Bitmap(new miniGoldBg);
			_curGoldBgBmp.x = goldBmp.x + goldBmp.width;
			_curGoldBgBmp.y = goldBmp.y + (goldBmp.height - _curGoldBgBmp.height) * .5;
			_curGoldBgBmp.width = _goldTxt.width;
			addChild(_curGoldBgBmp);
			addChild(_goldTxt);
			
			_liangAniBmp = new Bitmap(new MiniLiang);
			_liangAniBmp.x = _curGoldBgBmp.x + _curGoldBgBmp.width;
			_liangAniBmp.y = goldBmp.y + (goldBmp.height - _liangAniBmp.height) * .5;
			addChild(_liangAniBmp);
			
			var bestBmp:Bitmap = new Bitmap(new miniBest);
			bestBmp.x = 10;
			bestBmp.y = 10 + goldBmp.height;
			addChild(bestBmp);
			
			_bestScore = MiniBuffer.cookies.data.yaoba;
			format = new TextFormat("impact", 28, 0xffffff, true);
			_bestTxt = new TextField;
			_bestTxt.defaultTextFormat = format;
			_bestTxt.text = _bestScore + "两";
			_bestTxt.selectable = false;
			_bestTxt.autoSize = TextFieldAutoSize.LEFT;
			_bestTxt.x = bestBmp.x + bestBmp.width;
			_bestTxt.y = bestBmp.y + (bestBmp.height - _bestTxt.height) * .5;
			_bestTxt.cacheAsBitmap = true;
			
			_maxGoldBgBmp = new Bitmap(new miniGoldBg);
			_maxGoldBgBmp.width = _bestTxt.width;
			_maxGoldBgBmp.height = _bestTxt.height;
			_maxGoldBgBmp.x = bestBmp.x + bestBmp.width;
			_maxGoldBgBmp.y = bestBmp.y + (bestBmp.height - _maxGoldBgBmp.height) * .5;
			addChild(_maxGoldBgBmp);
			addChild(_bestTxt);
			
			_btnBack = new BtnReturn;
			_btnBack.scaleX = _btnBack.scaleY = 0.75;
			_btnBack.x = StaticTable.STAGE_WIDTH - _btnBack.width;
			_btnBack.y = StaticTable.STAGE_HEIGHT - _btnBack.height;
			addChild(_btnBack);
			_btnBack.addEventListener(MouseEvent.CLICK, onMenu);
			
			_position=[StaticTable.STAGE_WIDTH * .5, StaticTable.STAGE_HEIGHT * .5, StaticTable.STAGE_WIDTH * .25, StaticTable.STAGE_HEIGHT * .7, StaticTable.STAGE_WIDTH * .75, StaticTable.STAGE_HEIGHT * .6];
			
			_shakeBeginBmp = new Bitmap(new ShakeBeginTip);
			_shakeBeginBmp.x = (StaticTable.STAGE_WIDTH - _shakeBeginBmp.width)*.5;
			_shakeBeginBmp.y = (StaticTable.STAGE_HEIGHT - _shakeBeginBmp.height)*.5;
			addChild(_shakeBeginBmp);
			
			_shakeFinishBmp = new Bitmap(new miniOver);
			_shakeFinishBmp.x = (StaticTable.STAGE_WIDTH - _shakeFinishBmp.width)*.5;
			_shakeFinishBmp.y = (StaticTable.STAGE_HEIGHT - _shakeFinishBmp.height)*.5;
			
			var cls:Array = [mini9, mini8, mini7, mini6, mini5,mini4,mini3,mini2,mini1];
			for(var i:int=0;i<cls.length;i++)
			{
				var bmp:Bitmap = new Bitmap(new cls[i]);
				bmp.x = (StaticTable.STAGE_WIDTH - bmp.width)*.5;
				bmp.y = (StaticTable.STAGE_HEIGHT - bmp.height)*.5;
				_djs.push(bmp);
			}
		}
		
		protected function onMenu(event:MouseEvent):void
		{
			MidLayer.CloseWindow(ShakeView);
			MidLayer.ShowWindow(MiniMainMenuView);
		}
		
		private var _ybs:Vector.<Body> = new Vector.<Body>;
		private var _frameTimer:int, _frameTimerIntev:int = 0;
		private var _position:Array;
		private var _ybTimer:int, _ybTimerIntev:int;
		protected function onFrameIn(event:Event):void
		{
			DjsAction();
			_space.step(CaiShenDao.ELAPSED * .001);
			
			if(isFinished)
			{
				addChild(_shakeFinishBmp);
				MiniBuffer.cookies.data.yaoba = _bestScore;
				CaiShenDao.GcController.submitScore(_bestScore, "4");
			}
			
			if(_turnCount)
			{
				_frameTimer+=CaiShenDao.ELAPSED;
				if(_frameTimer >= _frameTimerIntev)
				{
					_frameTimer = 0;
					_currentFrame++;
					
					if(_currentFrame >= _xunxu.length)
					{
						_currentFrame = 0;
						_turnCount--;
						_ybTimerIntev = _turnIntevs.pop();
					}
					
					_bmp.bitmapData = _bmps[_xunxu[_currentFrame]];
				}
				
				_ybTimer+=CaiShenDao.ELAPSED;
				if(_ybTimer >= _ybTimerIntev)
				{
					_ybTimer=0;
					var index:int = Math.random() * 3;
					var yb:Body = createYuanBao(_position[index*2], _position[index*2 + 1]);
					
					if(yb)
					{
						var ybAni:AnimationBmp = yb.userData.animation;
						ybAni.play(EnumAction.EFFECT);
						addChildAt(ybAni, numChildren - 1);
						
						var ybDesc:BodyBoxDesc = yb.userData.desc;
						_ybs.push(yb);
						
						var direction:Vec2 = Vec2.get(1,0);
						var angle:Number = (.35 + Math.random() * .301)*-Math.PI;
						direction.angle = angle;
						yb.applyImpulse(direction.muleq(0.3632 * ybDesc.width * ybDesc.height));
						direction.dispose();
					}
				}
			}
			
			for(var i:int = 0; i < _ybs.length; i++)
			{
				yb = _ybs[i];
				ybAni = yb.userData.animation;
				ybDesc = yb.userData.desc;
				if(yb.userData.isDel)
				{
					removeChild(ybAni);
					yb.space = null;
					_ybs.splice(i,1);
					i--;
					yb.userData.isDel = false;
					yb.userData.occur = false;
					yb.velocity.setxy(0,0);
					_ybWaitBodys.unshift(yb);
					_curScore += 1;
					_curChanged = true;
				}
				else
				{
					ybAni.x = yb.position.x;
					ybAni.y = yb.position.y;
					ybAni.update(CaiShenDao.ELAPSED);
				}
			}
			renderUI();
		}
		
		private var _curScore:int, _curChanged:Boolean;
		private function renderUI():void
		{
			if(_curChanged)
			{
				_curChanged= false;
				_goldTxt.text = _curScore + "";
				_liangAniBmp.x = _goldTxt.x + _goldTxt.width;
				_curGoldBgBmp.width = _goldTxt.width;
				if(_curScore >  _bestScore)
				{
					_bestScore = _curScore;
					_bestTxt.text =  _bestScore + "两";
					_maxGoldBgBmp.width = _bestTxt.width;
				}
			}
		}
		
		private function createYuanBao(px:Number, py:Number):Body
		{
			if(_ybWaitBodys.length == 0) return null;
			var yb:Body = _ybWaitBodys.pop();
			yb.position.setxy(px,py);
			yb.space = _space;
			return yb;
		}
		
		private var acc:Accelerometer;
		private function initAcc():void
		{
			acc = new Accelerometer();
			acc.setRequestedUpdateInterval(40);
			acc.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);
		}
		
		private function get isFinished():Boolean
		{
			return _isDjsFinished && (_turnCount <= 0) && getTimer() - lastShake >= 1000;
		}
		
		private var lastShake:Number = 0,  shakeWait:Number = 500,  _isDjsFinished:Boolean;
		private function onAccUpdate(e:AccelerometerEvent):void
		{
			if(isFinished)return;
			if(getTimer() - lastShake > shakeWait)
			{
				if(e.accelerationX >= 1.5 || e.accelerationY >= 1.5 || e.accelerationZ >= 1.5)
				{
					var intev:int  = 100 - Math.max(e.accelerationX,e.accelerationY,e.accelerationZ) * 30;
					intev = Math.max(0, intev);
					_turnIntevs.unshift(intev);
					_turnCount++;
					if(_shakeBeginBmp.parent)
					{
						removeChild(_shakeBeginBmp);
						PlayDaoJiShi();
					}
					lastShake = getTimer();
				}
			}
		}
		
		private function DjsAction():void
		{
			if(_currentDjsFrame > -1)
			{
				_djsTimer+=CaiShenDao.ELAPSED;
				if(_djsTimer >= _djsTimerIntev)
				{
					_djsTimer=0;
					removeChild(_djs[_currentDjsFrame]);
					_currentDjsFrame++;
					if(_currentDjsFrame >= _djs.length)
					{
						_currentDjsFrame=-1;
						_isDjsFinished=true;
					}
					else
					{
						addChild(_djs[_currentDjsFrame]);
					}
				}
			}
		}
		
		private var _djs:Array=[], _currentDjsFrame:int = -1, _djsTimer:int, _djsTimerIntev:int=1000;
		private function PlayDaoJiShi():void
		{
			_djsTimer=_currentDjsFrame=0;
			addChild(_djs[_currentDjsFrame]);
		}
	}
}