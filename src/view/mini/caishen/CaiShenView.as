package view.mini.caishen
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
	import flash.utils.getTimer;
	
	import data.MiniBuffer;
	import data.StaticTable;
	import data.staticObj.BodyBoxDesc;
	import data.staticObj.EnumAction;
	import data.staticObj.EnumBody;
	
	import lsg.BtnPause;
	import lsg.BtnPlay;
	import lsg.BtnShake;
	import lsg.bmp.MiniBack;
	
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
	
	import utils.JinDuTiao;
	import utils.LHelp;
	import utils.LazySprite;
	import utils.MyMath;
	
	public class CaiShenView extends LazySprite
	{
		public var _isPaused:Boolean = false;
		public const _isDebug:Boolean = false;
		
		private var _ybWaitBodys:Vector.<Body> = new Vector.<Body>;
		private var _baowuIds:Array = [EnumBody.TONGQIAN, EnumBody.YINZI, EnumBody.YUANBAO];
		public function CaiShenView()
		{
			for(var i:int = 0; i < 30; i++)
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
		}
		
		override protected function init():void
		{
			InitScence();
			InitSpace();
			InitHeadUp();
			InitShake();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		private var lastShake:Number = 0;
		private var shakeWait:Number = 500;
		private var acc:Accelerometer;
		private function InitShake():void
		{
			acc = new Accelerometer();
			acc.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);
		}
		
		private var _shakeTimer:int, _shakeMaxTime:int=1500, _shakeYbCount:int = 0, _shakeYbMaxCount:int = 15;
		private function onAccUpdate(e:AccelerometerEvent):void
		{
			if(!_shakeTimer)
			{
				if(getTimer() - lastShake > shakeWait && (e.accelerationX >= 1.5 || e.accelerationY >= 1.5 || e.accelerationZ >= 1.5))
				{
					lastShake = getTimer();
				}
			}
		}
		
		private function shakeAction():void
		{
			if(_shakeTimer)
			{
				_shakeTimer -= CaiShenDao.ELAPSED;
				if(_shakeTimer < 0) _shakeTimer = 0;
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
			goBmp.parent.removeChild(goBmp);
			_cs.play(EnumAction.CS_YB);
			_canMove = true;
		}
		
		private function GoStart(beginBmp:DisplayObject):void
		{
			beginBmp.parent.removeChild(beginBmp);
			var goBmp:Bitmap = StaticTable.GetBmp("go", false);
			goBmp.x = (StaticTable.STAGE_WIDTH - goBmp.width) * .5;
			goBmp.y = (StaticTable.STAGE_HEIGHT - goBmp.height) * .5;
			addChild(goBmp);
			TweenLite.delayedCall(0.5, GoComplete, [goBmp]);
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
			_cs.play(EnumAction.CS_READY);
			_cs.x = StaticTable.STAGE_WIDTH * .5;
			_cs.y = 10 + _cs.height * .5;
			addChild(_cs);
			
			_qiang = new Bitmap(new MiniBack);
			_qiang.y = 70;
			addChild(_qiang);
		}
		
		private var _goldTxt:TextField;
		private var _bestTxt:TextField;
		private var _btnShake:BtnShake;
		private var _btnPause:BtnPause, _btnPlay:BtnPlay;
		private var _jdt:JinDuTiao, _zsOccurMaxCount:int = 5;
		private function InitHeadUp():void
		{
			_jdt = new JinDuTiao(200, 20, 2, 0x00ff00);
			_jdt.x = (StaticTable.STAGE_WIDTH - 200) * .5;
			_jdt.y = 20;
			_jdt.setBlood(0,_zsOccurMaxCount);
			
			var beginBmp:Bitmap = StaticTable.GetBmp("ready", false);
			beginBmp.x = (StaticTable.STAGE_WIDTH - beginBmp.width) * .5;
			beginBmp.y = (StaticTable.STAGE_HEIGHT - beginBmp.height) * .5;
			addChild(beginBmp);
			TweenLite.from(beginBmp, 1, {transformAroundCenter:{scaleX:0, scaleY:0}, ease:Back.easeOut});
			TweenLite.delayedCall(2.6, GoStart, [beginBmp]);
			
			var goldBmp:Bitmap = StaticTable.GetBmp("miniGold", false);
			goldBmp.x = 10;
			goldBmp.y = 10;
			addChild(goldBmp);
			
			var format:TextFormat = new TextFormat("impact", 38, 0xffcc00, true);
			_goldTxt = new TextField();
			_goldTxt.defaultTextFormat = format;
			_goldTxt.text = "0两";
			_goldTxt.selectable = false;
			_goldTxt.autoSize = TextFieldAutoSize.LEFT;
			_goldTxt.x = goldBmp.x + goldBmp.width + 10;
			_goldTxt.y = goldBmp.y;
			_goldTxt.cacheAsBitmap = true;
			addChild(_goldTxt);
			
			var bestBmp:Bitmap = StaticTable.GetBmp("miniBest", false);
			bestBmp.x = 10;
			bestBmp.y = 10 + goldBmp.height;
			addChild(bestBmp);
			
			format = new TextFormat("impact", 26, 0xffcc00, true);
			_bestTxt = new TextField;
			_bestTxt.defaultTextFormat = format;
			_bestTxt.text = MiniBuffer.scores.data.best + "两";
			_bestTxt.selectable = false;
			_bestTxt.autoSize = TextFieldAutoSize.LEFT;
			_bestTxt.x = bestBmp.x + bestBmp.width + 10;
			_bestTxt.y = bestBmp.y;
			_bestTxt.cacheAsBitmap = true;
			addChild(_bestTxt);
			
			_btnShake = new BtnShake;
			_btnShake.x = _jdt.x + _jdt.width + 10;
			_btnShake.y = 0;
			
			_btnPause = new BtnPause;
			_btnPause.x= 540;
			_btnPause.addEventListener(MouseEvent.CLICK, onBtnPause);
			addChild(_btnPause);
			
			_btnPlay = new BtnPlay;
			_btnPlay.x = (StaticTable.STAGE_WIDTH - _btnPlay.width)*.5;
			_btnPlay.y = (StaticTable.STAGE_HEIGHT - _btnPlay.height)*.5;
			_btnPlay.addEventListener(MouseEvent.CLICK, onBtnPlay);
		}
		
		protected function onBtnPlay(event:MouseEvent = null):void
		{
			_isPaused = false;
			_btnPause.visible = true;
			removeChild(_btnPlay);
		}
		
		protected function onBtnPause(event:MouseEvent = null):void
		{
			_isPaused = true;
			_btnPause.visible = false;
			addChild(_btnPlay);
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
			
			_myRoleAni = StaticTable.GetAniBmpByName(_myRoleDesc.name);
			_myRoleAni.play(EnumAction.CS_READY);
			addChild(_myRoleAni);
			
			var poly:Polygon = new Polygon(Polygon.box(_myRoleDesc.width, _myRoleDesc.height, true));
			poly.filter.collisionGroup = GROUP_ROLE;
			poly.filter.collisionMask = ~(GROUP_ROLE);
			
			var role:Body = new Body(BodyType.DYNAMIC);
			role.allowRotation = false;
			role.shapes.add(poly);
			role.cbTypes.add(ROLES);
			role.position.setxy(StaticTable.STAGE_WIDTH*.5, StaticTable.STAGE_HEIGHT - _myRoleDesc.height * .5);
			role.space = _space;
			
			_myRole = role;
			_target = new Vec2(role.position.x, role.position.y);
		}
		
		private var BORDER:CbType = new CbType;
		public static const BORDER_PADDING:int = 20;
		private function createBorder():void
		{
			var border:Body = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(-200, StaticTable.STAGE_HEIGHT + BORDER_PADDING, StaticTable.STAGE_WIDTH + 400, 1)));
			border.space = _space;
			border.cbTypes.add(BORDER);
		}
		
		private static const SPEED:Number = 1280/1000;
		private var _spaceXs:Number = 0.001;
		protected function onFrameIn(event:Event):void
		{
			if(_isPaused)
			{
				return;
			}
			_space.step(CaiShenDao.ELAPSED * _spaceXs);
			shakeAction();
			myRoleAciton();
			ybAction();
			logicAction();
			renderUI();
		}
		
		private var _logicLevelIntev:int = 12000, _logicLevelTimer:int = 0, _logicMaxLevel:int = 88, _logicCurLevel:int;
		private function logicAction():void
		{
			_logicLevelTimer += CaiShenDao.ELAPSED;
			if(_logicLevelTimer >= _logicLevelIntev && _logicCurLevel < _logicMaxLevel)
			{
				_logicLevelTimer = 0;
				_logicCurLevel++;
				_djRates[0] += 0.01;
			}
		}
		
		private static const GROUP_YUANBAO:int = 4;
		private var YUANBAOS:CbType = new CbType;
		private var _ybs:Vector.<Body> = new Vector.<Body>, _lastCsFrameIndex:int=0;
		private var _ybMaxCount:Number = 5, _ybCurCount:int, _ybThrowMax:int = 1;
		private var _djRates:Array = [0.12,0.0,0.1];
		private var _djIds:Array = [EnumBody.ZHADAN, EnumBody.ZHUANSHI, EnumBody.JUBAOPEN];
		private var _jubaopengTimer:int, _jubaopengMaxTime:int=10000, _jubaopengIntev:int = 100, _jubaopengIntevTimer:int;
		private var _jubaopengCurCount:int, _jubaopengCurMaxCount:int = 1;
		private var _zsCurCount:int, _zsCurMaxCount:int = 1;
		private function ybAction():void
		{
			if(_shakeYbCount > 0)
			{
				_shakeYbCount--;
				yb = createYuanBao(_cs.x + Math.random() * StaticTable.STAGE_WIDTH * (Math.random()<.5?-.45:.45), 200 - Math.random() * 60);
				ybAni = yb.userData.animation;
				ybAni.play(EnumAction.EFFECT);
				addChild(ybAni);
				
				ybDesc = yb.userData.desc;
				var direction:Vec2 = Vec2.get(1,0);
				direction.angle = .5*-Math.PI;
				yb.applyImpulse(direction.muleq(0.3632 * ybDesc.width * ybDesc.height));
				direction.dispose();
				
				_ybs.push(yb);
			}
			
			if(_jubaopengTimer > 0)
			{
				_jubaopengTimer -= CaiShenDao.ELAPSED;
				
				if(_jubaopengTimer<0)
				{
					_jubaopengTimer=0;
				}
				else
				{
					_jubaopengIntevTimer += CaiShenDao.ELAPSED;
					if(_jubaopengIntevTimer > _jubaopengIntev)
					{
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
				var rand:Number = Math.random();
				for(i = 0; i < _djRates.length; i++)
				{
					if(_djIds[i] == EnumBody.JUBAOPEN && (_jubaopengTimer || _jubaopengCurCount >= _jubaopengCurMaxCount)) 
					{
						continue;
					}
					if(_djIds[i] == EnumBody.ZHUANSHI && (_zsCurCount >= _zsCurMaxCount))
					{
						continue;
					}
					rand -= _djRates[i];
					if(rand < 0)
					{
						id = _djIds[i];
						if(id == EnumBody.JUBAOPEN)
						{
							_jubaopengCurCount++;
						}
						else if(id == EnumBody.ZHUANSHI)
						{
							_zsCurCount++;
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
				
				direction = Vec2.get(1,0);
				direction.angle = (.35 + Math.random() * .301)*-Math.PI;
				ybDesc = yb.userData.desc;
				yb.applyImpulse(direction.muleq(0.3632 * ybDesc.width * ybDesc.height));
				direction.dispose();
				
				ybAni = yb.userData.animation;
				ybAni.play(EnumAction.EFFECT);
				addChild(ybAni);
				
				_ybs.push(yb);
			}
			
			if(_cs.currentAnimationID == EnumAction.CS_YB && _cs.currentFrameIndex == 2 && _cs.currentFrameIndex != _lastCsFrameIndex)
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
					}
					else if(ybDesc.id == EnumBody.ZHADAN)
					{
						_cs.play(EnumAction.CS_READY);
						_myRole.space = null;
						_jubaopengTimer = 0;
						MiniBuffer.scores.flush();
						MidLayer.ShowWindowObj(CaiShenFinishView, {});
					}
					else if(ybDesc.id == EnumBody.ZHUANSHI)
					{
						_jdt.setBlood(_jdt.cur + 1, _jdt.max);
					}
					else if(ybDesc.id == EnumBody.JUBAOPEN)
					{
						_jubaopengTimer = _jubaopengMaxTime;
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
					else if(ybDesc.id == EnumBody.ZHUANSHI)
					{
						_zsCurCount --;
					}
					
					if(!yb.userData.isDaoJu)
					{
						yb.userData.isDel = false;
						yb.userData.occur = false;
						yb.velocity.setxy(0,0);
						_ybWaitBodys.unshift(yb);
					}
				}
				else
				{
					if(_jubaopengTimer)
					{
						if(ybDesc.id == EnumBody.YUANBAO || ybDesc.id == EnumBody.TONGQIAN || ybDesc.id == EnumBody.YINZI)
						{
							var motion:Vec2 = Vec2.get(_myRole.position.x - yb.position.x, _myRole.position.y - yb.position.y).normalise();
							yb.applyImpulse(motion.muleq(500));
							motion.dispose();
						}
					}
					ybAni.x = yb.position.x;
					ybAni.y = yb.position.y;
					ybAni.update(CaiShenDao.ELAPSED);
				}
			}
		}
		
		private function createDaoJu(id:int, px:Number, py:Number):Body
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
			_myRoleAni.y = _myRole.position.y + (_myRoleDesc.height - _myRoleAni.height) * .5 - BORDER_PADDING;
			_myRoleAni.update(Test2.ELAPSED);
		}
		
		private var _curScore:int;
		private var _bestScore:int;
		private function renderUI():void
		{
			_cs.update(CaiShenDao.ELAPSED);
			_tk.update(CaiShenDao.ELAPSED);
			
			if(_isDebug)
			{
				_debug.clear();
				_debug.draw(_space);
				_debug.flush();
			}
			
			_goldTxt.text = _curScore + "两";
			if(_curScore >  MiniBuffer.scores.data.best) 
			{
				MiniBuffer.scores.data.best = _curScore;
			}
			_bestTxt.text =  MiniBuffer.scores.data.best + "两";
		}
		
	}
}