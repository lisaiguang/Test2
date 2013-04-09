package view.caishen
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.urbansquall.ginger.AnimationBmp;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.sensors.Accelerometer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import data.MiniBuffer;
	import data.MiniSingals;
	import data.StaticTable;
	import data.staticObj.BodyBoxDesc;
	import data.staticObj.EnumAction;
	import data.staticObj.EnumBody;
	import data.staticObj.EnumMusic;
	
	import lsg.BtnBack;
	import lsg.BtnPause;
	import lsg.BtnPlay;
	import lsg.bmp.MiniBack;
	import lsg.bmp.MiniLiang;
	import lsg.bmp.mini1;
	import lsg.bmp.mini2;
	import lsg.bmp.mini3;
	import lsg.bmp.miniBest;
	import lsg.bmp.miniGo;
	import lsg.bmp.miniGold;
	import lsg.bmp.miniGoldBg;
	import lsg.bmp.miniReady;
	
	import message.PauseReq;
	
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
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	
	import utils.LHelp;
	import utils.LazySprite;
	import utils.MyMath;
	
	import view.welcome.MiniMainMenuView;
	
	public class CaiShenView extends LazySprite
	{
		private var _isPause:Boolean;
		public function get isPaused():Boolean
		{
			return _isPause;
		}
		
		public function set isPaused(value:Boolean):void
		{ 
			if(value)
			{
				flushScore();
				if(_btnPause.parent)removeChild(_btnPause);
				addChild(_btnPlay);
				addChild(_btnBack);
				addChild(_txtPauseTip);
				_isPause = value;
			}
			else
			{
				addChild(_btnPause);
				removeChild(_btnPlay);
				removeChild(_btnBack);
				removeChild(_txtPauseTip);
				PlayDaoJiShi();
			}
		}
		
		private var _djs:Array, _currentDjsFrame:int = -1, _djsTimer:int, _djsTimerIntev:int=800;
		private function PlayDaoJiShi():void
		{
			if(!_djs)
			{
				_djs=[];
				var bmp:Bitmap = new Bitmap(new mini3);
				bmp.x = (StaticTable.STAGE_WIDTH - bmp.width)*.5;
				bmp.y = (StaticTable.STAGE_HEIGHT - bmp.height)*.5;
				_djs.push(bmp);
				bmp = new Bitmap(new mini2);
				bmp.x = (StaticTable.STAGE_WIDTH - bmp.width)*.5;
				bmp.y = (StaticTable.STAGE_HEIGHT - bmp.height)*.5;
				_djs.push(bmp);
				bmp = new Bitmap(new mini1);
				bmp.x = (StaticTable.STAGE_WIDTH - bmp.width)*.5;
				bmp.y = (StaticTable.STAGE_HEIGHT - bmp.height)*.5;
				_djs.push(bmp);
			}
			_djsTimer=_currentDjsFrame=0;
			addChild(_djs[_currentDjsFrame]);
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
						_isPause = false;
					}
					else
					{
						addChild(_djs[_currentDjsFrame]);
					}
				}
			}
		}
		
		public const _isDebug:Boolean = false;
		
		private var _ybWaitBodys:Vector.<Body> = new Vector.<Body>;
		private var _baowuIds:Array = [EnumBody.TONGQIAN, EnumBody.YINZI, EnumBody.YUANBAO];
		private var _zdWaitBodys:Vector.<Body> = new Vector.<Body>;
		private var _djRates:Array;
		private var _djIds:Array = [EnumBody.ZHADAN, EnumBody.JUBAOPEN, EnumBody.SHALOU];
		private var _jubaopengIntevBegin:Number, _jubaopengImpulseBegin:Number; 
		public function CaiShenView()
		{
			_djRates = [0.0,0.1,0.35];
			_jubaopengIntev = _jubaopengIntevBegin = 80;
			_jubaopengImpluse = _jubaopengImpulseBegin = 350;
			
			for(var i:int = 0; i < 28; i++)
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
			
			for(i = 0; i < 12; i++)
			{
				id = EnumBody.ZHADAN;
				ybDesc = StaticTable.GetBodyBoxDescById(id);
				ybAni = StaticTable.GetAniBmpByName(ybDesc.name);
				
				poly = new Polygon(Polygon.box(ybDesc.width, ybDesc.height, true));
				poly.filter.collisionGroup = GROUP_YUANBAO;
				poly.filter.collisionMask = ~(GROUP_YUANBAO);
				
				yb = new Body(BodyType.DYNAMIC);
				yb.allowRotation = false;
				yb.shapes.add(poly);
				yb.cbTypes.add(YUANBAOS);
				yb.userData.isDel = false;
				yb.userData.occur = false;
				yb.userData.animation = ybAni;
				yb.userData.desc = ybDesc;
				_zdWaitBodys.push(yb);
			}
		}
		
		override protected function init():void
		{
			InitScence();
			InitSpace();
			InitHeadUp();
			if(MiniBuffer.model == 1)
			{
				InitAcc();
			}
			else if(MiniBuffer.model == 0)
			{
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			listen(MiniSingals.OnPauseReq, OnPauseReq);
		}
		
		override protected function destoryed():void
		{
			if(hasEventListener(Event.ENTER_FRAME))
			{
				removeEventListener(Event.ENTER_FRAME, onFrameIn);
			}
			if(hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		private function OnPauseReq(pr:PauseReq):void
		{
			isPaused = true;
		}
		
		private var acc:Accelerometer;
		private function InitAcc():void
		{
			acc = new Accelerometer();
			acc.setRequestedUpdateInterval(50);
			acc.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);
		}
		
		private var _lastAccX:Number = 0;
		private const FACTOR:Number = 0.3;
		private function onAccUpdate(e:AccelerometerEvent):void
		{
			var ax:Number = (e.accelerationX * FACTOR) + (_lastAccX * (1 - FACTOR)); 
			if(Math.abs(ax - _lastAccX) > .004 && !_isMove)
			{
				_target.x = StaticTable.STAGE_WIDTH * .5 - ax * StaticTable.STAGE_WIDTH * .5 * 4;
				if(_target.x < 0)_target.x = 0;
				if(_target.x > StaticTable.STAGE_WIDTH)_target.x = StaticTable.STAGE_WIDTH;
				_lastAccX = ax;
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			_isMove = false;
			_target.x = event.stageX;
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			if(_isMove)
				_target.x = event.stageX;
		}
		
		private var _isMove:Boolean = false;
		protected function onMouseDown(event:MouseEvent):void
		{
			var target:DisplayObject = LHelp.FindParentByClass(event.target as DisplayObject, MovieClip);
			if(!target)
			{
				_isMove= true;
				_target.x = event.stageX;
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}
		
		private function GoComplete(goBmp:DisplayObject):void
		{
			_btnPause.visible = true;
			goBmp.parent.removeChild(goBmp);
		}
		
		private function GoStart(beginBmp:DisplayObject):void
		{
			beginBmp.parent.removeChild(beginBmp);
			var goBmp:Bitmap = new Bitmap(new miniGo);
			goBmp.x = (StaticTable.STAGE_WIDTH - goBmp.width) * .5;
			goBmp.y = (StaticTable.STAGE_HEIGHT - goBmp.height) * .5;
			addChild(goBmp);
			TweenLite.delayedCall(0.5, GoComplete, [goBmp]);
			_canMove = true;
			addEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		private var _qiang:Bitmap;
		private var _tk:AnimationBmp;
		private var _cs:AnimationBmp;
		private function InitScence():void
		{
			_tk = StaticTable.GetAniBmpByName("MiniTk");
			_tk.play(EnumAction.EFFECT);
			addChild(_tk);
			
			_cs = StaticTable.GetAniBmpByName("MiniCs");
			_cs.play(EnumAction.REN_YUAN_BAO);
			_cs.x = StaticTable.STAGE_WIDTH * .5;
			_cs.y = 10 + _cs.height * .5;
			addChild(_cs);
			
			_qiang = new Bitmap(new MiniBack);
			_qiang.y = 70;
			addChild(_qiang);
		}
		
		private var _goldTxt:TextField, _bestTxt:TextField;
		private var _btnPause:BtnPause, _btnPlay:BtnPlay, _btnBack:BtnBack, _txtPauseTip:TextField;
		private var _zsOccurMaxCount:int = 5;
		private var _boomAni:AnimationBmp;
		private var _liangAniBmp:Bitmap, _curGoldBgBmp:Bitmap, _maxGoldBgBmp:Bitmap;
		private function InitHeadUp():void
		{
			var beginBmp:Bitmap = new Bitmap(new miniReady);
			beginBmp.x = (StaticTable.STAGE_WIDTH - beginBmp.width) * .5;
			beginBmp.y = (StaticTable.STAGE_HEIGHT - beginBmp.height) * .5;
			addChild(beginBmp);
			TweenLite.delayedCall(3, GoStart, [beginBmp]);
			
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
			
			_bestScore = MiniBuffer.model == 0? MiniBuffer.cookies.data.bestFinger : MiniBuffer.cookies.data.bestTiGan;
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
			
			_btnPause = new BtnPause;
			_btnPause.visible = false;
			_btnPause.x= 540;
			_btnPause.addEventListener(MouseEvent.CLICK, onBtnPause);
			addChild(_btnPause);
			
			_btnPlay = new BtnPlay;
			_btnPlay.x = (StaticTable.STAGE_WIDTH - _btnPlay.width)*.5 - _btnPlay.width * .7;
			_btnPlay.y = (StaticTable.STAGE_HEIGHT - _btnPlay.height)*.5;
			_btnPlay.addEventListener(MouseEvent.CLICK, onBtnPlay);
			
			_btnBack = new BtnBack;
			_btnBack.x = (StaticTable.STAGE_WIDTH - _btnPlay.width)*.5 + _btnBack.width * .7;
			_btnBack.y = (StaticTable.STAGE_HEIGHT - _btnPlay.height)*.5;
			_btnBack.addEventListener(MouseEvent.CLICK, onBtnBack);
			
			format = new TextFormat("impact", 40, 0xffffff, true);
			_txtPauseTip = new TextField;
			_txtPauseTip.defaultTextFormat = format;
			_txtPauseTip.text = MiniBuffer.model == 0?"手指模式":"体感模式";
			_txtPauseTip.selectable = false;
			_txtPauseTip.autoSize = TextFieldAutoSize.LEFT;
			_txtPauseTip.x = (StaticTable.STAGE_WIDTH - _txtPauseTip.width)*.5 ;
			_txtPauseTip.y = _btnPlay.y - _txtPauseTip.height - 5;
			_txtPauseTip.cacheAsBitmap = true;
			
			_boomAni = StaticTable.GetAniBmpByName("MiniBoom");
			_boomAni.play(EnumAction.EFFECT);
		}
		
		protected function onBtnBack(event:MouseEvent):void
		{
			MidLayer.CloseWindow(CaiShenView);
			MidLayer.ShowWindow(MiniMainMenuView);
		}
		
		protected function onBtnPlay(event:MouseEvent = null):void
		{
			isPaused = false;
			event.stopPropagation();
		}
		
		protected function onBtnPause(event:MouseEvent = null):void
		{
			isPaused = true;
			event.stopPropagation();
		}
		
		private var _space:Space;
		private var _debug:Debug;
		private function InitSpace():void
		{
			var gravity:Vec2 = Vec2.weak(0, 850);
			_space = new Space(gravity);
			
			if(_isDebug)
			{
				_debug = new BitmapDebug(StaticTable.STAGE_WIDTH, StaticTable.STAGE_HEIGHT, stage.color);
				_debug.drawBodyDetail = true;
				addChild(_debug.display);
			}
			
			createBorder();
			addRoleBox();
			createNapeListeners();
		}
		
		private function createNapeListeners():void
		{
			var landDetect:InteractionListener =  new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, YUANBAOS, BORDER, onYuanbao2Border);
			_space.listeners.add(landDetect);
			landDetect = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, YUANBAOS, ROLES, onYuanbao2ROLE);
			_space.listeners.add(landDetect);
		}
		
		private function onYuanbao2ROLE(cb:InteractionCallback):void
		{
			var yb:Body = cb.int1.castBody;
			yb.userData.isDel = true;
			yb.userData.occur = true;
		}
		
		private function onYuanbao2Border(cb:InteractionCallback):void
		{
			var yb:Body = cb.int1.castBody;
			yb.userData.isDel = true;
		}
		
		private var _myRoleAni:AnimationBmp
		private var _myRole:Body;
		private var _myRoleDesc:BodyBoxDesc;
		private var _target:Vec2;
		private static const GROUP_ROLE:int = 2;
		private var ROLES:CbType = new CbType;
		private function addRoleBox():void
		{
			_myRoleDesc = StaticTable.GetBodyBoxDescById(EnumBody.ROLE);
			
			var poly:Polygon = new Polygon(Polygon.box(_myRoleDesc.width, _myRoleDesc.height, true));
			poly.filter.collisionGroup = GROUP_ROLE;
			poly.filter.collisionMask = ~(GROUP_ROLE);
			
			var role:Body = new Body(BodyType.DYNAMIC);
			role.allowRotation = false;
			role.shapes.add(poly);
			role.cbTypes.add(ROLES);
			role.position.setxy(StaticTable.STAGE_WIDTH*.5, StaticTable.STAGE_HEIGHT - _myRoleDesc.height * .5 + BORDER_PADDING);
			role.space = _space;
			
			_myRole = role;
			_target = new Vec2(role.position.x, role.position.y);
			
			_myRoleAni = StaticTable.GetAniBmpByName(_myRoleDesc.name);
			_myRoleAni.x = StaticTable.STAGE_WIDTH*.5;
			_myRoleAni.y = StaticTable.STAGE_HEIGHT - _myRoleAni.height * .5;
			_myRoleAni.play(EnumAction.MOVE);
			addChild(_myRoleAni);
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
		
		private static const SPEED:Number = 1280/1000;
		private var _spaceXs:Number = 0.001;
		protected function onFrameIn(event:Event):void
		{
			DjsAction();
			
			if(isPaused)
			{
				return;
			}
			
			_space.step(CaiShenDao.ELAPSED * _spaceXs);
			myRoleAciton();
			ybAction();
			logicAction();
			renderUI();
		}
		
		private var _logicLevelIntev:int = 7000, _logicLevelTimer:int = 0, _logicMaxLevel:int = 48, _logicCurLevel:int;
		private function logicAction():void
		{
			_logicLevelTimer += CaiShenDao.ELAPSED;
			if(_logicLevelTimer >= _logicLevelIntev && _logicCurLevel < _logicMaxLevel)
			{
				_logicLevelTimer = 0;
				_logicCurLevel++;
				_djRates[0] += 0.01;
				_csUpdateXsBegin += 0.01;
				if(_csUpdateXs < _csUpdateXsBegin)_csUpdateXs=_csUpdateXsBegin;
			}
		}
		
		private static const GROUP_YUANBAO:int = 4;
		private var YUANBAOS:CbType = new CbType;
		private var _ybs:Vector.<Body> = new Vector.<Body>, _lastCsFrameIndex:int=0;
		private var _ybMaxCount:Number = 5, _ybCurCount:int, _ybThrowMax:int = 1;
		private var _jubaopengTimer:int, _jubaopengMaxTime:int=10000, _jubaopengIntev:int, _jubaopengIntevTimer:int, _jubaopengImpluse:Number = 500;
		private var _jubaopengCurCount:int, _jubaopengCurMaxCount:int = 1, _slCurCount:int, _slCurMaxCount:int = 0;
		private var _djAngs:Number = 0; 
		private const MIN_ANG:Number = .04 * Math.PI;
		private function ybAction():void
		{			
			if(_jubaopengTimer > 0)
			{
				_jubaopengTimer -= CaiShenDao.ELAPSED;
				if(_jubaopengTimer<=0)
				{
					_jubaopengTimer=0;
					_csUpdateXs =_csUpdateXsBegin;
					_jubaopengIntev = _jubaopengIntevBegin;
					_jubaopengImpluse = _jubaopengImpulseBegin;
				}
				else
				{
					_jubaopengIntevTimer += CaiShenDao.ELAPSED;
					if(_jubaopengIntevTimer > _jubaopengIntev)
					{
						_jubaopengIntevTimer = 0;
						yb = createYuanBao(_cs.x + Math.random() * StaticTable.STAGE_WIDTH * (Math.random()<.5?-.4:.4), 200);
						ybAni = yb.userData.animation;
						ybAni.play(EnumAction.EFFECT);
						addChild(ybAni);
						_ybs.push(yb);
					}
				}
			}
			
			var curThrow:int = 0;
			while(_ybCurCount > 0 && curThrow < _ybThrowMax)
			{
				curThrow++;
				_ybCurCount--;
				var id:int;
				if(_ybCurCount > 0)
				{
					var rand:Number = Math.random();
					for(i = 0; i < _djRates.length; i++)
					{
						if(_djIds[i] == EnumBody.JUBAOPEN) 
						{
							if(_jubaopengTimer || _jubaopengCurCount >= _jubaopengCurMaxCount)
							{
								continue;
							}
						}
						else if(_djIds[i] == EnumBody.SHALOU)
						{
							if(_jubaopengTimer <= 0 || _slCurCount >= _slCurMaxCount)
							{
								continue;
							}
						}
						else if(_djIds[i] == EnumBody.ZHADAN)
						{
							if(_csUpdateXs > _csUpdateXsBegin)
							{
								rand += _djRates[i] * .9;
							}
						}
						
						rand -= _djRates[i];
						if(rand < 0)
						{
							id = _djIds[i];
							if(_djIds[i] == EnumBody.JUBAOPEN) 
							{
								_jubaopengCurCount++;
							}
							else if(_djIds[i] == EnumBody.SHALOU)
							{
								_slCurCount++;
							}
							break;
						}
					}
					
					if(rand >= 0)
					{
						yb = createYuanBao(_cs.x, 200);
					}
					else
					{
						yb = createDaoJu(id, _cs.x, 200);
					}
				}
				else
				{
					id = EnumBody.ZHADAN;
					yb = createDaoJu(id, _cs.x, 200);
				}
				
				ybDesc = yb.userData.desc;
				var direction:Vec2 = Vec2.get(1,0);
				var angle:Number = (.35 + Math.random() * .301)*-Math.PI;
				if(id == EnumBody.ZHADAN || id == EnumBody.JUBAOPEN || id == EnumBody.SHALOU)
				{
					var oa:Number = _djAngs;
					if(angle < oa && angle > oa - MIN_ANG)
					{
						if(angle >= .65 * -Math.PI + MIN_ANG)
						{
							angle -= MIN_ANG;
						}
						else
						{
							angle += MIN_ANG * 2;
						}
					}
					else if(angle > oa && angle < oa + MIN_ANG)
					{
						if(angle <= .35 * -Math.PI - MIN_ANG)
						{
							angle += MIN_ANG;
						}
						else
						{
							angle -= MIN_ANG * 2;
						}
					}
					_djAngs = angle;
				}
				direction.angle = angle;
				yb.applyImpulse(direction.muleq(0.3632 * ybDesc.width * ybDesc.height));
				direction.dispose();
				
				ybAni = yb.userData.animation;
				ybAni.play(EnumAction.EFFECT);
				addChild(ybAni);
				
				_ybs.push(yb);
			}
			
			if(_cs.currentAnimationID == EnumAction.REN_YUAN_BAO && _cs.currentFrameIndex == 2 && _cs.currentFrameIndex != _lastCsFrameIndex)
			{
				_ybCurCount += (1 + Math.random()) * _ybMaxCount * .501;
			}
			_lastCsFrameIndex = _cs.currentFrameIndex;
			
			for(var i:int = 0; i < _ybs.length; i++)
			{
				var yb:Body = _ybs[i];
				var ybAni:AnimationBmp = yb.userData.animation;
				var ybDesc:BodyBoxDesc = yb.userData.desc;
				if(yb.userData.occur)
				{
					if(ybDesc.id == EnumBody.YUANBAO || ybDesc.id == EnumBody.TONGQIAN || ybDesc.id == EnumBody.YINZI)
					{
						_curScore += 1;
						_curChanged = true;
					}
					else if(ybDesc.id == EnumBody.ZHADAN)
					{
						for(var j:int = 0; j < _ybs.length; j++)
						{
							var tyb:Body = _ybs[j];
							if(tyb != yb)
							{
								tyb.velocity.setxy(0,0);
								direction = Vec2.get(tyb.position.x - yb.position.x, tyb.position.y - yb.position.y);
								var len:Number = Math.max(20, direction.length / 10);
								tyb.applyImpulse(direction.normalise().muleq(150000 / len));
								direction.dispose();
							}
						}
						
						_myRole.space = null;
						_jubaopengTimer = 0;
						_csUpdateXs = 1;
						_canMove = false;
						
						_myRoleAni.play(EnumAction.ZHA);
						_cs.play(EnumAction.READY);
						_boomAni.x = yb.position.x - 5*100;
						_boomAni.y = yb.position.y - 5*100;
						_boomAni.scaleX = 5;
						_boomAni.scaleY = 5;
						addChild(_boomAni);
						flushScore();
					}
					else if(ybDesc.id == EnumBody.JUBAOPEN)
					{
						_jubaopengTimer = _jubaopengMaxTime;
						_slCurMaxCount = 1;
					}
					else if(ybDesc.id == EnumBody.SHALOU)
					{
						_csUpdateXs = _csUpdateXsBegin * 1.67;
						_jubaopengIntev = _jubaopengIntevBegin / 2;
						_jubaopengImpluse = _jubaopengImpulseBegin * 2;
						_slCurMaxCount = 0;
					}
				}
				
				if(yb.userData.isDel)
				{
					removeChild(ybAni);
					yb.space = null;
					_ybs.splice(i,1);
					i--;
					
					if(ybDesc.id == EnumBody.JUBAOPEN)
					{
						_jubaopengCurCount --;
					}
					else if(ybDesc.id == EnumBody.SHALOU)
					{
						_slCurCount --;
					}
					
					if(!yb.userData.isDaoJu)
					{
						yb.userData.isDel = false;
						yb.userData.occur = false;
						yb.velocity.setxy(0,0);
						if(ybDesc.id == EnumBody.ZHADAN)
						{
							_zdWaitBodys.unshift(yb);
						}
						else
						{
							_ybWaitBodys.unshift(yb);
						}
					}
				}
				else
				{
					if(_jubaopengTimer > 0)
					{
						if(ybDesc.id == EnumBody.YUANBAO || ybDesc.id == EnumBody.TONGQIAN || ybDesc.id == EnumBody.YINZI)
						{
							var motion:Vec2 = Vec2.get(_myRole.position.x - yb.position.x, _myRole.position.y - yb.position.y).normalise();
							yb.applyImpulse(motion.muleq(_jubaopengImpluse));
							motion.dispose();
						}
					}
					ybAni.x = yb.position.x;
					ybAni.y = yb.position.y;
					ybAni.update(CaiShenDao.ELAPSED);
				}
			}
		}
		
		private function flushScore():void
		{
			if(MiniBuffer.model == 0) 
			{
				MiniBuffer.cookies.data.bestFinger = _bestScore;
				CaiShenDao.GcController.submitScore(_bestScore, "3");
			}
			else if(MiniBuffer.model == 1) 
			{
				MiniBuffer.cookies.data.bestTiGan = _bestScore;
				CaiShenDao.GcController.submitScore(_bestScore, "2");
			}
			MiniBuffer.cookies.data.fuhao += _curScore;
			CaiShenDao.GcController.submitScore(MiniBuffer.cookies.data.fuhao, "1");
			MiniBuffer.cookies.flush();
		}
		
		private function createDaoJu(id:int, px:Number, py:Number):Body
		{
			if(id == EnumBody.ZHADAN)
			{
				yb = _zdWaitBodys.pop();
				yb.position.setxy(px,py);
				yb.space = _space;
			}
			else
			{
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
				yb.userData.isDaoJu = true;
				yb.userData.animation = ybAni;
				yb.userData.desc = ybDesc;
				yb.space = _space;
				yb.position.setxy(px, py);
			}
			return yb;
		}
		
		private function createYuanBao(px:Number, py:Number):Body
		{
			var yb:Body = _ybWaitBodys.pop();
			yb.position.setxy(px,py);
			yb.space = _space;
			return yb;
		}
		
		public var _canMove:Boolean = false;
		private function myRoleAciton():void
		{
			if(_canMove)
			{
				var motion:Vec2 = Vec2.get(_target.x - _myRole.position.x, _target.y - _myRole.position.y);
				if(motion.length > 0)
				{
					motion.normalise().muleq(SPEED * CaiShenDao.ELAPSED);
					if(motion.angle < MyMath.HALF_PI && motion.angle > -MyMath.HALF_PI)
					{
						_myRole.position.x +=  Math.min(motion.x, _target.x - _myRole.position.x);
					}
					else
					{
						_myRole.position.x += Math.max(motion.x, _target.x - _myRole.position.x);
					}
				}
				motion.dispose();
			}
			_myRoleAni.x = _myRole.position.x;
		}
		
		private var _curScore:int, _curChanged:Boolean;
		private var _bestScore:int;
		private var _csUpdateXs:Number = 1, _csUpdateXsBegin:Number = 1;
		private function renderUI():void
		{
			_cs.update(CaiShenDao.ELAPSED * _csUpdateXs);
			_tk.update(CaiShenDao.ELAPSED * _csUpdateXs);
			
			if(_isDebug)
			{
				_debug.clear();
				_debug.draw(_space);
				_debug.flush();
			}
			
			if(_boomAni && _boomAni.parent)
			{
				if(!_boomAni.isPlaying())
				{
					_boomAni.parent.removeChild(_boomAni);
					MidLayer.ShowWindow(CaiShenFinishView);
				}
				_boomAni.update(CaiShenDao.ELAPSED);
			}
			
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
		
	}
}