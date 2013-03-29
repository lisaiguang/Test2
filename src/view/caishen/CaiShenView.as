package view.caishen
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.urbansquall.ginger.AnimationBmp;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import data.StaticTable;
	import data.staticObj.BodyBoxDesc;
	import data.staticObj.EnumAction;
	import data.staticObj.EnumBody;
	
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
	
	import utils.LazySprite;
	import utils.MyMath;
	
	public class CaiShenView extends LazySprite
	{
		public var _isPaused:Boolean = false;
		public function CaiShenView()
		{
		}
		
		override protected function init():void
		{
			InitSpace();
			addHeadUp();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(Event.ENTER_FRAME, onFrameIn);
		}
		
		override protected function destoryed():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			_isMove = false;
			_target.x = event.stageX;
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			if(_isMove)
				_target.x = event.stageX;
		}
		
		private var _isMove:Boolean = false;
		protected function onMouseDown(event:MouseEvent):void
		{
			_isMove= true;
			_target.x = event.stageX;
		}
		
		private function GoComplete(goBmp:DisplayObject):void
		{
			goBmp.parent.removeChild(goBmp);
			_ybSeed = 500;
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
		
		private var _cs:AnimationBmp;
		private var _goldTxt:TextField;
		private var _bestTxt:TextField;
		private function addHeadUp():void
		{
			_cs = StaticTable.GetAniBmpByName("caishen");
			_cs.play(EnumAction.CS_READY);
			_cs.x = StaticTable.STAGE_WIDTH * .5;
			_cs.y = 10 + _cs.height * .5;
			addChild(_cs);
			
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
			_bestTxt.text = "0两";
			_bestTxt.selectable = false;
			_bestTxt.autoSize = TextFieldAutoSize.LEFT;
			_bestTxt.x = bestBmp.x + bestBmp.width + 10;
			_bestTxt.y = bestBmp.y;
			_bestTxt.cacheAsBitmap = true;
			addChild(_bestTxt);
		}
		
		private var _space:Space;
		private var _debug:Debug;
		private function InitSpace():void
		{
			var gravity:Vec2 = Vec2.weak(0, 700);
			_space = new Space(gravity);
			
			_debug = new BitmapDebug(StaticTable.STAGE_WIDTH, StaticTable.STAGE_HEIGHT, stage.color);
			_debug.drawBodyDetail = true;
			addChild(_debug.display);
			
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
		public static const BORDER_PADDING:int = 0;
		private function createBorder():void
		{
			var border:Body = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(-100, StaticTable.STAGE_HEIGHT + BORDER_PADDING, StaticTable.STAGE_WIDTH + 200, 1)));
			border.space = _space;
			border.cbTypes.add(BORDER);
		}
		
		private static const SPEED:Number = 1280/1000;
		protected function onFrameIn(event:Event):void
		{
			if(_isPaused)
			{
				return;
			}
			_space.step(CaiShenDao.ELAPSED/1000);
			myRoleAciton();
			ybAction();
			renderUI();
		}
		
		private static const GROUP_YUANBAO:int = 4;
		private var YUANBAOS:CbType = new CbType;
		private var _ybs:Vector.<Body> = new Vector.<Body>;
		private var _ybSeed:int = int.MAX_VALUE, _ybTimer:int, _ybMaxCount:int = 3, _ybCurCount:int, _ybThrowIntev:int = 1000/10, _ybThrowTimer:int;
		private var _zdRate:Number = 0.2, _zsRate:Number = 0.1;
		private function ybAction():void
		{
			_ybThrowTimer += CaiShenDao.ELAPSED;
			if(_ybThrowTimer >= _ybThrowIntev)
			{
				_ybThrowTimer = 0;
				if(_ybCurCount > 0)
				{
					_ybCurCount--;
					var id:int = EnumBody.YUANBAO;
					var rand:Number = Math.random();
					if(rand < _zdRate)
					{
						id = EnumBody.ZHADAN;
					}
					else
					{
						rand -= _zdRate;
						if(rand < _zsRate)
						{
							id = EnumBody.ZHUANSHI;
						}
					}
					rand -= _zsRate;
					var ybDesc:BodyBoxDesc = StaticTable.GetBodyBoxDescById(id);
					
					var ybAni:AnimationBmp = StaticTable.GetAniBmpByName(ybDesc.name);
					ybAni.play(EnumAction.EFFECT);
					addChild(ybAni);
					
					var poly:Polygon = new Polygon(Polygon.box(ybDesc.width, ybDesc.height, true));
					poly.filter.collisionGroup = GROUP_YUANBAO;
					poly.filter.collisionMask = ~(GROUP_YUANBAO);
					
					var yb:Body = new Body(BodyType.DYNAMIC);
					yb.allowRotation = false;
					yb.shapes.add(poly);
					yb.cbTypes.add(YUANBAOS);
					yb.position.setxy(_cs.x, _cs.y);
					yb.space = _space;
					yb.userData.animation = ybAni;
					yb.userData.isDel = false;
					yb.userData.occur = false;
					yb.userData.desc = ybDesc;
					_ybs.push(yb);
					
					var direction:Vec2 = Vec2.get(1,0);
					direction.angle = (.35 + Math.random() * .301)*-Math.PI;
					yb.applyImpulse(direction.muleq(0.3632 * ybDesc.width * ybDesc.height));
					direction.dispose();
				}
			}
			
			_ybTimer += CaiShenDao.ELAPSED;
			if(_ybTimer >= _ybSeed)
			{
				_ybTimer = 0;
				_ybCurCount += Math.random() * _ybMaxCount;
			}
			
			for(var i:int = 0; i < _ybs.length; i++)
			{
				yb = _ybs[i];
				ybAni = yb.userData.animation;
				ybDesc = yb.userData.desc;
				
				if(yb.userData.occur)
				{
					if(ybDesc.id == EnumBody.YUANBAO)
					{
						_curScore += 1;
					}
					else if(ybDesc.id == EnumBody.ZHADAN)
					{
						_myRole.space = null;
						_ybSeed = int.MAX_VALUE;
						MidLayer.ShowWindowObj(CaiShenFinishView, {});
					}
				}
				
				if(yb.userData.isDel)
				{
					removeChild(ybAni);
					yb.space = null;
					_ybs.splice(i,1);
					i--;
				}
				else
				{
					ybAni.x = yb.position.x;
					ybAni.y = yb.position.y;
				}
			}
		}
		
		private function myRoleAciton():void
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
			
			_myRoleAni.x = _myRole.position.x;
			_myRoleAni.y = _myRole.position.y;
			_myRoleAni.update(Test2.ELAPSED);
		}
		
		private var _curScore:int;
		private function renderUI():void
		{
			_cs.update(Test2.ELAPSED);
			_debug.clear();
			_debug.draw(_space);
			_debug.flush();
			
			_goldTxt.text = _curScore + "两";
			_bestTxt.text = _curScore + "两";
		}
		
		private function onOverBmpFinish(overBmp:Bitmap):void
		{
		}
	}
}