package view.battle
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	import data.obj.BattleBeginAck;
	import data.obj.BattleFinishAck;
	import data.obj.BattlePlayer;
	import data.obj.BulletDesc;
	import data.obj.EnumDirection;
	import data.obj.PlayerFallAck;
	import data.obj.PlayerFallReq;
	import data.obj.PlayerHurtAck;
	import data.obj.PlayerHurtReq;
	import data.obj.PlayerRoundAck;
	import data.obj.PlayerRoundReq;
	import data.obj.RoleDesc;
	
	import lsg.battle.LoseUI;
	import lsg.battle.RoundBeginUI;
	import lsg.battle.WinUI;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.AABB;
	import nape.geom.Geom;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	
	import phys.Terrain;
	
	import starling.utils.Color;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	import utils.LHelp;
	import utils.LazySprite;
	import utils.McSprite;
	
	//wait to be improve role's motion by role.velocity and angle!
	
	public class BattleView extends LazySprite
	{
		public static const isDebug:Boolean = false;
		
		private var _bba:BattleBeginAck;
		public function BattleView(bba:BattleBeginAck)
		{
			_bba = bba;
		}
		
		override protected function init():void
		{
			setUp();
			addHeadUp();
			InitPos();
			initSignals();
			
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			Test2.Delay(1500, onPlayerRoundBegin, [_bba.firstRound, true]);
		}
		
		private var _isDrag:Boolean = false;
		private var _dragRect:Rectangle;
		
		protected function onMouseDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if(!isDebug)
			{
				if(!_dragRect)_dragRect = new Rectangle(StaticTable.STAGE_WIDTH - _release.width, StaticTable.STAGE_HEIGHT - _release.height, _release.width - StaticTable.STAGE_WIDTH, _release.height - StaticTable.STAGE_HEIGHT);
				_release.startDrag(false, _dragRect);
			}
			_isDrag = true;
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if(!isDebug)
			{
				_release.stopDrag();
			}
			_isDrag = false;
		}
		
		private var _space:Space;
		private var _debug:Debug;
		private var _release:Sprite;
		private var _terrain:Terrain;
		private var BORDER:CbType = new CbType;
		public static const BORDER_PADDING:int = 40;
		
		private function setUp():void
		{
			var gravity:Vec2 = Vec2.weak(0, 600);
			_space = new Space(gravity);
			
			var bd:BitmapData = StaticTable.GetMapBmd(_bba.mapId);
			_terrain = new Terrain(_space, bd, new Vec2(0,0), 80, 8);
			
			var border:Body = new Body(BodyType.STATIC);
			border.shapes.add(new Polygon(Polygon.rect(-BORDER_PADDING, -BORDER_PADDING, bd.width + BORDER_PADDING*2, 1)));
			border.shapes.add(new Polygon(Polygon.rect(-BORDER_PADDING, bd.height + BORDER_PADDING, bd.width + BORDER_PADDING*2, 1)));
			border.shapes.add(new Polygon(Polygon.rect(-BORDER_PADDING, -BORDER_PADDING, 1, bd.height + BORDER_PADDING*2)));
			border.shapes.add(new Polygon(Polygon.rect(bd.width + BORDER_PADDING, -BORDER_PADDING, 1, bd.height + BORDER_PADDING*2)));
			border.space = _space;
			border.cbTypes.add(BORDER);
			
			for(var i:int = 0; i < _bba.players.length; i++)
			{
				var bp:BattlePlayer = _bba.players[i];
				createRole(bp);
			}
			
			createNapeListeners();
			
			if(isDebug)
			{
				_debug = new BitmapDebug(bd.width, bd.height, stage.color);
				_debug.drawBodyDetail = true;
				addChild(_debug.display);
			}
			else
			{
				_release = new Sprite;
				addChild(_release);
				var bmp:Bitmap = new Bitmap(bd);
				_release.addChild(bmp);
			}
		}
		
		private function get map():DisplayObject
		{
			if(isDebug)
			{
				return _debug.display;
			}
			else
			{
				return _release;
			}
		}
		
		private var _roles:Vector.<Body>;
		private var _myRole:Body;
		private static const GROUP_ROLE:int = 2;
		private var ROLES:CbType = new CbType;
		
		private function createRole(player:BattlePlayer):void
		{	
			var rs:RoleDesc = StaticTable.GetRoleDesc(player.role);
			
			var poly:Polygon = new Polygon(Polygon.box(rs.boundWidth, rs.boundHeight, true));
			poly.filter.collisionGroup = GROUP_ROLE;
			poly.filter.collisionMask = ~(GROUP_ROLE);
			
			var role:Body = new Body(BodyType.DYNAMIC);
			role.shapes.add(poly);
			role.cbTypes.add(ROLES);
			role.position.setxy(player.x, player.y);
			role.space = _space;
			role.userData.battleplayer = player;
			role.userData.rs = rs;
			
			if(!_roles)_roles= new Vector.<Body>;
			_roles.push(role);
			
			if(player.id == Buffer.mainPlayer.id)
			{
				_myRole = role;
			}
		}
		
		private function role2RoleDesc(role:Body):RoleDesc
		{
			return role.userData.rs;
		}
		
		private function  role2BattlePlayer(role:Body):BattlePlayer
		{
			return role.userData.battleplayer;
		}
		
		private function PlayerId2Role(id:Number):Body
		{
			for each(var role:Body in _roles)
			{
				if(role2BattlePlayer(role).id == id)
				{
					return role;
				}
			}
			return null;
		}
		
		private function createNapeListeners():void
		{
			var landDetect4:InteractionListener =  new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, BULLETS, _terrain.GRAND, onBullets2GrandBegin);
			_space.listeners.add(landDetect4);
			
			landDetect4 =  new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, BULLETS, BORDER, onBullets2Border);
			_space.listeners.add(landDetect4);
			
			landDetect4 =  new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, ROLES, BORDER, onRoles2Border);
			_space.listeners.add(landDetect4);
		}
		
		private function onRoles2Border(cb:InteractionCallback):void
		{
			var role:Body = cb.int1.castBody;
			var bp:BattlePlayer = role2BattlePlayer(role);
			MySignals.Socket_Send.dispatch(new PlayerFallReq);
		}
		
		private function onBullets2Border(cb:InteractionCallback):void
		{
			var bullet:Body = cb.int1.castBody;
			bullet.space = null;
			_bullets.splice(_bullets.indexOf(bullet),1);
			
			if(bullet.userData.graphic)
			{
				_release.removeChild(bullet.userData.graphic);
			}
			
			MySignals.Socket_Send.dispatch(new PlayerRoundReq);
		}
		
		private function onBullets2GrandBegin(cb:InteractionCallback):void
		{
			var bullet:Body = cb.int1.castBody;
			
			if(bullet.userData.graphic && bullet.userData.graphic.parent)
			{
				_release.removeChild(bullet.userData.graphic);
			}
			
			var bs:BulletDesc = bulletBody2bulletDesc(bullet);
			explosion(bullet.position, bs.id);
			bullet.space = null;
			_bullets.splice(_bullets.indexOf(bullet),1);
			
			MySignals.Socket_Send.dispatch(new PlayerRoundReq);
		}
		
		private var _justExplosin:Boolean =false;
		private function explosion(pos:Vec2, bid:int):void 
		{
			var bomb:Sprite = StaticTable.GetBulletClear(bid);
			
			var rect:Rectangle = bomb.getBounds(bomb);
			rect.x += pos.x;
			rect.y += pos.y;
			var region:AABB = AABB.fromRect(rect);
			_terrain.bd.draw(bomb, new Matrix(1, 0, 0, 1, pos.x, pos.y), null, BlendMode.ERASE);
			_terrain.invalidate(region);
			
			var pids:Vector.<Number>;
			var distances:Vector.<Number>;
			for each(var role:Body in _roles)
			{
				if(rect.contains(role.position.x, role.position.y))
				{
					if(!pids)
					{
						pids = new Vector.<Number>;
						distances = new Vector.<Number>;
					}
					var bp:BattlePlayer = role2BattlePlayer(role);
					pids.push(bp.id);
					var dis:Number = LHelp.distance(role.position.x, role.position.y, rect.x + rect.width * .5, rect.y + rect.height * .5);
					distances.push(dis);
				}
			}
			
			if(pids)
			{
				var phr:PlayerHurtReq = new PlayerHurtReq;
				phr.bid = bid;
				phr.distances = distances;
				phr.pids = pids;
				MySignals.Socket_Send.dispatch(phr);
			}
			
			_justExplosin = true;
		}
				
		private var _shootView:ShootView;
		private var _smallMap:SmallMapView;
		private var _bottomView:BottomView;
		private var _adjustView:AdjustView;
		
		private function addHeadUp():void
		{
			stage.addChild(_shootView = new ShootView);
			stage.addChild(_smallMap = new SmallMapView);
			_smallMap.SetMap(_terrain.bd);
			stage.addChild(_bottomView = new BottomView);
			
			if(!isDebug)
			{
				_release.addChild(_adjustView = new AdjustView);
				_adjustView.visible = false;
			}
		}
		
		private function InitPos():void
		{
			_shootView.InitPos();
			_smallMap.InitPos();
			_bottomView.InitPos();
		}
		
		private function initSignals():void
		{
			listen(MySignals.onPlayerRoundAck, onPlayerRoundBegin);
			listen(MySignals.onPlayerHurtAck, onPlayerHurtAck);
			listen(MySignals.onBattleFinishAck, onBattleFinishAck);
			listen(MySignals.onPlayerFallAck, onPlayerFallAck); 
			_shootView.SHOOT.add(onShootReady);
		}
		
		private function onPlayerFallAck(pfa:PlayerFallAck):void
		{
			var role:Body = PlayerId2Role(pfa.playerId);
			var bp:BattlePlayer = role2BattlePlayer(role);
			bp.curBlood = 0;
			playerDead(role, bp);
		}
		
		private function onBattleFinishAck(bfa:BattleFinishAck):void
		{
			var bp:BattlePlayer = playerid2BattlePlayer(Buffer.mainPlayer.id);
			if(bp && bp.group == bfa.winGroup)
			{
				var winUI:DisplayObject = new WinUI;
			}
			else
			{
				winUI = new LoseUI;
			}
			winUI.x = StaticTable.STAGE_WIDTH;
			winUI.y = (StaticTable.STAGE_HEIGHT-winUI.height)*.5;
			stage.addChild(winUI);
			var tl:TimelineLite = new TimelineLite({onComplete:onBattleFinish, onCompleteParams:[winUI]});
			tl.append(new TweenLite(winUI, 0.4, {x:(StaticTable.STAGE_WIDTH-winUI.width)*.5}));
			tl.append(new TweenLite(winUI, 0.4, {x:-winUI.width, delay:1}));
			tl.play();
		}
		
		private function onBattleFinish(ui:DisplayObject):void
		{
			LHelp.RemoveFromParent(ui);
		}
		
		private function playerid2BattlePlayer(id:Number):BattlePlayer
		{
			for each(var bp:BattlePlayer in _bba.players)
			{
				if(bp.id == id)
				{
					return bp;
				}
			}
			return null;
		}
		
		private function onPlayerHurtAck(pha:PlayerHurtAck):void
		{
			for(var i:int = 0; i < pha.pids.length; i++)
			{
				var role:Body = PlayerId2Role(pha.pids[i]);
				var bp:BattlePlayer = role2BattlePlayer(role);
				bp.curBlood -= pha.hurts[i];
				playeBloodHurt(role.position, pha.hurts[i]);
				if(bp.curBlood <= 0)
				{
					playerDead(role, bp);
				}
			}
		}
		
		private function playerDead(role:Body,bp:BattlePlayer):void
		{
			var spt:DisplayObject = roleBody2Graphic(role);
			if(spt)
			{
				LHelp.DisGrey(spt);
			}
		}
		
		private function playeBloodHurt(position:Vec2, hurt:uint):void
		{
			if(!isDebug)
			{
				var tf:TextField = new TextField();
				tf.textColor = Color.RED;
				tf.text = hurt + "";
				tf.x = position.x;
				tf.y = position.y;
				tf.alpha = 0.3;
				_release.addChild(tf);
				TweenLite.to(tf, 2, {y:tf.y - 50, alpha:1, scaleX:3, scaleY:3, onComplete:LHelp.RemoveFromParent, onCompleteParams:[tf]});
			}
		}
		
		private var _prb:PlayerRoundAck;
		private var _isMyTurn:Boolean;
		private var _roundBeginUI:RoundBeginUI = new RoundBeginUI;
		private var tl:TimelineLite;
		
		private function onPlayerRoundBegin(prb:PlayerRoundAck, tween:Boolean = true):void
		{
			_prb = prb;
			_isMyTurn = _prb.playerId == Buffer.mainPlayer.id;
			
			var bp:BattlePlayer = controlBattlePlayer();
			_shootView.printfBullets(bp.curBulletIds);
			_bottomView.printfDegree(bp.rotationDeg);
			_bottomView.printfForce(bp.force);
			
			if(_release)mouseEnabled = mouseChildren = false;
			_roundBeginUI.txtContent.text = bp.name + "'s Round!";
			_roundBeginUI.x = StaticTable.STAGE_WIDTH;
			_roundBeginUI.y = (StaticTable.STAGE_HEIGHT - _roundBeginUI.height)*.5;
			if(!_roundBeginUI.parent)stage.addChild(_roundBeginUI);
			
			if(!tl) 
			{
				tl = new TimelineLite({onComplete:onPlayerRoundBeginMotionFinish});
				tl.append(new TweenLite(_roundBeginUI, 0.4, {x:(StaticTable.STAGE_WIDTH-_roundBeginUI.width)*.5}));
				tl.append(new TweenLite(_roundBeginUI, 0.4, {x:-_roundBeginUI.width, delay:1}));
				tl.play();
			}
			else
			{
				tl.restart();
			}
		}
		
		private function onPlayerRoundBeginMotionFinish():void
		{
			LHelp.RemoveFromParent(_roundBeginUI);
			var role:Body = controlRoleBody();
			focusMap(role.position.x, role.position.y, true);
			mouseEnabled = mouseChildren = true;
		}
		
		private function focusMap(x:Number, y:Number, tween:Boolean = false):void
		{
			MapLeftTop(StaticTable.STAGE_WIDTH * 0.5 - x, StaticTable.STAGE_HEIGHT * 0.5 - y, tween);
		}
		
		private function MapLeftTop(x:Number, y:Number, tween:Boolean = false):void
		{
			var minX:int = StaticTable.STAGE_WIDTH - _terrain.bd.width;
			var minY:int = StaticTable.STAGE_HEIGHT - _terrain.bd.height;
			
			if(x < minX)
			{
				x = minX;
			}
			else if(x > 0)
			{
				x = 0;
			}
			
			if(y < minY)
			{
				y = minY;
			}
			else if(y > 0)
			{
				y = 0;
			}
			
			if(tween)
			{
				var distance:Number=LHelp.distance(x,y,map.x,map.y) / 250;
				if(distance < 0.2)
				{
					map.x = x;
					map.y = y;
				}
				else
				{
					TweenLite.to(map,  distance, {x:x, y:y});
				}
			}
			else
			{
				map.x = x;
				map.y = y;
			}
			
			_smallMap.SetMapTopLeft(x, y);
		}
		
		private function controlRoleBody():Body
		{
			return PlayerId2Role(_prb.playerId);
		}
		
		private function controlBattlePlayer():BattlePlayer
		{
			return PlayerId2Role(_prb.playerId).userData.battleplayer;
		}
		
		private var _bid:int;
		private function onShootReady(bid:int):void{
			if(_bid){
				_shootView.printfBulletUnReady(bid);
				_bid = 0;
			}else{
				_shootView.printfBulletReady(bid);
				_bid = bid;
			}
		}
		
		private var _bullets:Vector.<Body>;
		private var BULLETS:CbType = new CbType;
		private static const GROUP_BULLET:int = 4;
		
		private function onShoot(bid:int):void
		{
			if(!_bullets)_bullets = new Vector.<Body>;
			
			var bp:BattlePlayer = controlBattlePlayer();
			if(bid == 0) bid = bp.curBulletIds[0];
			
			var _bs:BulletDesc = StaticTable.GetBulletDesc(bid);
			
			var poly:Polygon = new Polygon(Polygon.box(_bs.boundWidth, _bs.boundHeight, true));
			poly.filter.collisionGroup = GROUP_BULLET;
			poly.filter.collisionMask = ~(GROUP_BULLET|GROUP_ROLE);
			poly.material.density = _bs.mass / (_bs.boundWidth*_bs.boundHeight);
			
			var bullet:Body = new Body(BodyType.DYNAMIC);
			bullet.isBullet = true;
			bullet.shapes.add(poly);
			bullet.userData.bullet = _bs;
			bullet.cbTypes.add(BULLETS);
			bullet.space = _space;
			_bullets.push(bullet);
			
			var role:Body = controlRoleBody();
			bullet.position.x = role.position.x;
			bullet.position.y = role.position.y - role.bounds.height * 0.5;
			
			bullet.rotation = deg2rad(bp.rotationDeg);
			var target:Vec2 = Vec2.get(bullet.position.x + Math.cos(bullet.rotation), bullet.position.y + Math.sin(bullet.rotation));
			var force:Vec2 = target.sub(bullet.position, true).muleq(bp.force * 0.2);
			bullet.applyImpulse(force,null, true);
			target.dispose();
			
			_bid = 0;
		}
		
		private function bulletBody2bulletDesc(body:Body):BulletDesc
		{
			return body.userData.bullet;
		}
		
		private function bulletId2bulletBody(id:int):Body
		{
			for each(var body:Body in _bullets)
			{
				if(body.userData.bullet.id == id) return body;
			}
			return null;
		}
		
		private var _interactingBodies:BodyList = new BodyList;
		private var motion:int;
		private static const ROTATION_LIMT:Number = Math.PI / 2.5;
		private static const FORCE_STEP:Number = 0.75;//high is fast
		private static const DEGREE_STEP:Number = 0.75;
		
		protected function onFrameIn(event:Event):void
		{
			_space.step(Test2.ELAPSED / 1000);
			drawSpace();
			
			if(_isDrag)
			{
				if(!isDebug)_smallMap.SetMapTopLeft(map.x, map.y);
			}
			
			for each(var bullet:Body in _bullets)
			{
				bullet.rotation = bullet.velocity.angle;
			}
			
			for each(var role:Body in _roles)
			{
				_interactingBodies.clear();
				role.interactingBodies(InteractionType.COLLISION, 1, _interactingBodies);
				
				if(_justExplosin)
				{
					_justExplosin = false;
				}
				else if(_interactingBodies.length > 0)
				{
					if(role.velocity.x <= 0.01 && role.velocity.y <= 0.01 && role.angularVel <= 0.01)
					{
						if(!role.allowRotation)
						{
							role.allowRotation = true;
						}
						if(role.rotation >= ROTATION_LIMT || role.rotation <= -ROTATION_LIMT)
						{
							role.rotation = 0;
						}
					}
					else
					{
						if(role.rotation >= Math.PI / 3)
						{
							if(role.rotation >= ROTATION_LIMT)
							{
								role.angularVel = -3.14 * 3;
							}
							else if(role.angularVel >= 1)
							{
								role.angularVel -= 3.14 * 3;
							}
						}
						else if(role.rotation <= -Math.PI / 3)
						{
							if(role.rotation <= -ROTATION_LIMT)
							{
								role.angularVel = 3.14 * 3;
							}
							else if(role.angularVel <= -1)
							{
								role.angularVel += 3.14 * 3;
							}
						}
					}
				}
				else
				{
					if(role.allowRotation)
					{
						role.allowRotation = false;
					}
					
					if(role.rotation != 0)
					{
						role.rotation = 0;
						role.angularVel = 0;
					}
				}
				
				var bp:BattlePlayer = role2BattlePlayer(role);
				_smallMap.SetRoleXY(bp.id, role.position.x, role.position.y);
				
				if(_prb && bp.id == _prb.playerId)
				{
					if(_interactingBodies.length > 0)
					{	
						if(_bottomView.isLeftPressing)
						{
							role.position.x -= 1;
							bp.direction = EnumDirection.LEFT;
						}
						
						if(_bottomView.isRightPressing)
						{
							role.position.x += 1;
							bp.direction = EnumDirection.RIGHT;
						}
						
						var refuse:Boolean = false;
						
						if(motion >= 1)
						{
							motion = 0;
							refuse = true;
						}
						else if(role.rotation >= ROTATION_LIMT && bp.direction == EnumDirection.LEFT)
						{
							refuse = true;
						}
						else if(role.rotation <= -ROTATION_LIMT && bp.direction == EnumDirection.RIGHT)
						{
							refuse = true;
						}
						else
						{
							var closestA:Vec2 = Vec2.get();
							var closestB:Vec2 = Vec2.get();
							for(var i:int = 0; i < _interactingBodies.length; i++)
							{
								var iBody:Body = _interactingBodies.at(i);
								var distance:Number = Geom.distanceBody(role, iBody,closestA, closestB);
								if(distance < -1)
								{
									refuse = true;
									break;
								}
							}
							closestA.dispose();
							closestB.dispose();
						}
						
						if(refuse)
						{
							if(_bottomView.isLeftPressing)
							{
								role.position.x += 1;
							}
							
							if(_bottomView.isRightPressing)
							{
								role.position.x -= 1;
							}
						}
						else
						{
							motion+= 0.5;
						}
					}
					
					if(_bottomView.isUpPressing)
					{
						if(bp.degree >= 90)
						{
							bp.degree = 90;
						}
						else
						{
							bp.degree += DEGREE_STEP;
						}
						_bottomView.printfDegree(bp.rotationDeg);
					}
					
					if(_bottomView.isDownPressing)
					{
						if(bp.degree <= 0)
						{
							bp.degree = 0;
						}
						else
						{
							bp.degree -= DEGREE_STEP;
						}
						_bottomView.printfDegree(bp.rotationDeg);
					}
					
					if(_bottomView.isFirePressing)
					{
						bp.force = bp.force >= 100 ? 100 : bp.force + FORCE_STEP;
						_bottomView.printfForce(bp.force);
					}
					else if(bp.force > 0)
					{
						onShoot(_bid);
						bp.force = 0;
						_bottomView.printfForce(bp.force);
					}
					
					if(!isDebug)
					{
						_adjustView.x = role.position.x;
						_adjustView.y = role.position.y;
						_adjustView.printfDegree(bp.rotationDeg);
						if(!_adjustView.visible)_adjustView.visible = true;
					}
				}
			}
		}
		
		private function drawSpace():void
		{
			if(isDebug)
			{
				_debug.clear();
				_debug.draw(_space);
				_debug.flush()
			}
			else
			{
				for each(var role:Body in _roles)
				{
					var bp:BattlePlayer = role2BattlePlayer(role);
					var roleMc:McSprite = role.userData.graphic;
					
					if(!roleMc)
					{
						roleMc = StaticTable.GetRoleMcSprite(bp.role);
						role.userData.graphic = roleMc;
						_release.addChild(roleMc);
					}
					
					if(bp.direction == EnumDirection.LEFT)
					{
						roleMc.rotationY = 180;
					}
					else
					{
						roleMc.rotationY = 0;
					}
					
					roleMc.x = role.position.x;
					roleMc.y = role.position.y;
					roleMc.rotation = rad2deg(role.rotation);
				}
				
				var focusBullet:Boolean = true;
				for each(var bullet:Body in _bullets)
				{
					var bulletMc:McSprite = bullet.userData.graphic;
					var bs:BulletDesc = bulletBody2bulletDesc(bullet);
					
					if(!bulletMc)
					{
						bulletMc = StaticTable.GetBulletMcSprite(bs.id);
						bullet.userData.graphic = bulletMc;
						_release.addChild(bulletMc);
					}
					bulletMc.x = bullet.position.x;
					bulletMc.y = bullet.position.y;
					bulletMc.rotation = rad2deg(bullet.rotation);
					
					if(focusBullet)
					{
						focusBullet = false;
						if(!pointInView(bulletMc.x, bulletMc.y))
						{
							var cx:Number = -map.x + StaticTable.STAGE_WIDTH * 0.5;
							var cy:Number = -map.y + StaticTable.STAGE_HEIGHT * 0.5;
							cx += bullet.position.x < cx ? -bulletMc.width : bulletMc.width ;
							cy += bullet.position.y < cy ? -bulletMc.height : bulletMc.height ;
							focusMap(cx, cy);
						}
					}
				}
			}
		}
		
		private function roleBody2Graphic(role:Body):DisplayObject
		{
			return isDebug?null:role.userData.graphic;
		}
		
		private function shiftView(sx:Number, sy:Number):void
		{
			sx += map.x + StaticTable.STAGE_WIDTH * 0.5;
			sy += map.y + StaticTable.STAGE_HEIGHT * 0.5;
			focusMap(sx, sy);
		}
		
		private function pointInView(px:Number, py:Number):Boolean
		{
			var tx:Number = px + map.x;
			var ty:Number = py + map.y;
			return (tx >= 0 && tx <= StaticTable.STAGE_WIDTH && ty >= 0 && ty <= StaticTable.STAGE_HEIGHT);
		}
	}
}