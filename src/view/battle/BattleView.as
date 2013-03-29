package view.battle
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.urbansquall.ginger.AnimationPlayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	import data.staticObj.RoleBulletDesc;
	import data.staticObj.EnumBaoShi;
	import data.staticObj.RoleDesc;
	
	import lsg.battle.LoseUI;
	import lsg.battle.RoundBeginUI;
	import lsg.battle.WinUI;
	
	import message.BattleBeginAck;
	import message.BattleFinishAck;
	import message.BattlePlayer;
	import data.staticObj.EnumAction;
	import message.EnumDirection;
	import message.PlayerDisjustAck;
	import message.PlayerDisjustReq;
	import message.PlayerFallAck;
	import message.PlayerFallReq;
	import message.PlayerHurtAck;
	import message.PlayerHurtReq;
	import message.PlayerMoveAck;
	import message.PlayerMoveReq;
	import message.PlayerRoundAck;
	import message.PlayerRoundReq;
	import message.PlayerShootAck;
	import message.PlayerShootReq;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.dynamics.Arbiter;
	import nape.geom.AABB;
	import nape.geom.Geom;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	
	import phys.Terrain;
	
	import starling.utils.Color;
	import starling.utils.rad2deg;
	
	import utils.LHelp;
	import utils.LazySprite;
	import utils.McSprite;
	import utils.MyMath;
	
	import view.city.CityView;
	
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
			listenSignals();
			
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			map.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			TweenLite.delayedCall(1.5, onPlayerRoundBegin, [_bba.firstRound, true]);
		}
		
		private var _isDrag:Boolean = false;
		private var _dragRect:Rectangle;
		protected function onMouseDown(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if(!_dragRect)_dragRect = new Rectangle(StaticTable.STAGE_WIDTH - map.width, StaticTable.STAGE_HEIGHT - map.height, map.width - StaticTable.STAGE_WIDTH, map.height - StaticTable.STAGE_HEIGHT);
			map.startDrag(false, _dragRect);
			_isDrag = true;
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			map.stopDrag();
			_isDrag = false;
		}
		
		private var _space:Space;
		private var _debug:Debug;
		private var map:Sprite;
		private var _terrain:Terrain;
		private var BORDER:CbType = new CbType;
		public static const BORDER_PADDING:int = 40;
		
		private function setUp():void
		{
			var gravity:Vec2 = Vec2.weak(0, 600);
			_space = new Space(gravity);
			
			var bd:BitmapData = StaticTable.GetMapBmd(_bba.mapId);
			_terrain = new Terrain(_space, bd, new Vec2(0,0), 42, 6);
			
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
			map = new Sprite;
			addChild(map);
			
			if(isDebug)
			{
				_debug = new BitmapDebug(bd.width, bd.height, stage.color);
				_debug.drawBodyDetail = true;
				map.addChild(_debug.display);
			}
			else
			{
				var bmp:Bitmap = new Bitmap(bd);
				map.addChild(bmp);
			}
		}
		
		
		private var _roles:Vector.<Body>;
		private var _myRole:Body;
		private static const GROUP_ROLE:int = 2;
		private var ROLES:CbType = new CbType;
		private function createRole(player:BattlePlayer):void
		{	
			var rs:RoleDesc = StaticTable.GetRoleDesc(player.role);
			
			var poly:Circle = new Circle(rs.boundWidth / 2);
			poly.filter.collisionGroup = GROUP_ROLE;
			poly.filter.collisionMask = ~(GROUP_ROLE);
			
			var role:Body = new Body(BodyType.DYNAMIC);
			role.allowRotation = false;
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
			var pfr:PlayerFallReq = new PlayerFallReq;
			pfr.playerId = bp.id;
			MySignals.Socket_Send.dispatch(pfr);
		}
		
		private function onBullets2Border(cb:InteractionCallback):void
		{
			var bullet:Body = cb.int1.castBody;
			var position:Number = _bullets.indexOf(bullet);
			if(position == -1)
			{
				return;
			}
			else
			{
				_bullets.splice(position,1);
			}
			if(bullet.userData.graphic)
			{
				map.removeChild(bullet.userData.graphic);
			}
			bullet.space = null;
			
			if(_bullets.length == 0 && _hasLastBullet)
			{
				MySignals.Socket_Send.dispatch(new PlayerRoundReq);
			}
		}
		
		private function onBullets2GrandBegin(cb:InteractionCallback):void
		{
			var bullet:Body = cb.int1.castBody;
			var position:Number = _bullets.indexOf(bullet);
			if(position == -1)
			{
				return;
			}
			else
			{
				_bullets.splice(position,1);
			}
			
			if(bullet.userData.graphic)
			{
				map.removeChild(bullet.userData.graphic);
			}
			bullet.space = null;
			
			var bs:RoleBulletDesc = bulletBody2bulletDesc(bullet);
			if(bs.isNormal)
			{
				explosion(bullet.position, bs);
				
				if(_bullets.length == 0 && _hasLastBullet)
				{
					MySignals.Socket_Send.dispatch(new PlayerRoundReq);
				}
			}
			else
			{
				controlRoleBody().position.setxy(bullet.position.x, bullet.position.y);
				MySignals.Socket_Send.dispatch(new PlayerRoundReq);
			}
		}
		
		private function explosion(pos:Vec2, bs:RoleBulletDesc):void 
		{
			var ts:int = getTimer();
			var bomb:Shape = bs.clearShape;
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
				phr.bid = bs.id;
				phr.distances = distances;
				phr.pids = pids;
				MySignals.Socket_Send.dispatch(phr);
			}
			trace("time:" + (getTimer() - ts));
		}
		
		private var _shootView:ShootView;
		private var _smallMap:SmallMapView;
		private var _bottomView:BottomView;
		private var _adjustView:AdjustView;
		
		private function addHeadUp():void
		{
			addChild(_shootView = new ShootView);
			addChild(_smallMap = new SmallMapView);
			_smallMap.SetMap(_terrain.bd);
			addChild(_bottomView = new BottomView);
			map.addChild(_adjustView = new AdjustView);
		}
		
		private function InitPos():void
		{
			_shootView.InitPos();
			_smallMap.InitPos();
			_bottomView.InitPos();
		}
		
		private function listenSignals():void
		{
			listen(MySignals.onPlayerRoundAck, onPlayerRoundBegin);
			listen(MySignals.onPlayerHurtAck, onPlayerHurtAck);
			listen(MySignals.onBattleFinishAck, onBattleFinishAck);
			listen(MySignals.onPlayerFallAck, onPlayerFallAck); 
			listen(MySignals.onPlayerShootAck, onPlayerShootAck);
			listen(MySignals.onPlayerMoveAck, onPlayerMoveAck);
			listen(MySignals.onPlayerDisjustAck, onPlayerDisjustAck);
		}
		
		private function onPlayerDisjustAck(pda:PlayerDisjustAck):void
		{
			var bp:BattlePlayer = playerid2BattlePlayer(pda.pid);
			if(bp.degree != pda.degree)
			{
				bp.degree = pda.degree;
				_bottomView.printfDegree(bp.rotationDeg, bp.direction);
				_adjustView.printfDegree(bp.rotationDeg);
			}
			if(pda.action == 1)
			{
				_playerDisjustAck = pda;
			}
			else
			{
				_playerDisjustAck = null;
			}
		}
		
		private function onPlayerMoveAck(pma:PlayerMoveAck):void
		{
			var role:Body = PlayerId2Role(pma.pid);
			role.position.setxy(pma.x, pma.y);
			var bp:BattlePlayer = role2BattlePlayer(role);
			bp.direction = pma.direction;
			if(pma.action == 1)
			{
				_playerMoveAck = pma;
				bp.action = EnumAction.ROLE_MOVING;
			}
			else
			{
				_playerMoveAck = null;
				bp.action = EnumAction.ROLE_WAITING;
			}
		}
		
		private function onPlayerShootAck(psa:PlayerShootAck):void
		{
			onShoot(psa.pid, psa.bid, psa.rad, psa.force * 0.2);
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
			addChild(winUI);
			var tl:TimelineLite = new TimelineLite({onComplete:onBattleFinish, onCompleteParams:[winUI]});
			tl.append(new TweenLite(winUI, 0.4, {x:(StaticTable.STAGE_WIDTH-winUI.width)*.5}));
			tl.play();
		}
		
		private function onBattleFinish(ui:DisplayObject):void
		{
			TweenLite.delayedCall(3, onClose);
		}
		
		private function onClose():void
		{
			MidLayer.CloseWindow(BattleView);
			MidLayer.ShowWindow(CityView);
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
				LHelp.AddGrey(spt);
			}
		}
		
		private var _format:TextFormat = new TextFormat(null, 24, Color.RED);
		private function playeBloodHurt(position:Vec2, hurt:uint):void
		{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = _format;
			tf.text = hurt + "";
			tf.x = position.x;
			tf.y = position.y;
			map.addChild(tf);
			TweenLite.to(tf, 2, {y:tf.y - 80, onComplete:LHelp.RemoveFromParent, onCompleteParams:[tf]});
		}
		
		private var _prb:PlayerRoundAck;
		private var _isMyTurn:Boolean;
		private var _roundBeginUI:RoundBeginUI = new RoundBeginUI;
		private var tl:TimelineLite;
		
		private function onPlayerRoundBegin(prb:PlayerRoundAck, tween:Boolean = true):void
		{
			_hasLastBullet = _shooted = false;
			_prb = prb;
			_isMyTurn = _prb.playerId == Buffer.mainPlayer.id;
			
			var bp:BattlePlayer = controlBattlePlayer();
			
			_adjustView.visible = _isMyTurn;
			if(_isMyTurn)
			{
				_adjustView.x = bp.x;
				_adjustView.y = bp.y;
				_adjustView.printfDegree(bp.rotationDeg);
				_shootView.printfBullets(bp.curBulletIds);
				_bottomView.printfForce(bp.force, bp.lastForce);
				_bottomView.printfDegree(bp.rotationDeg, bp.direction);
			}
			
			if(map)mouseEnabled = mouseChildren = false;
			_roundBeginUI.txtContent.text = bp.name + "'s Round!";
			_roundBeginUI.x = StaticTable.STAGE_WIDTH;
			_roundBeginUI.y = (StaticTable.STAGE_HEIGHT - _roundBeginUI.height)*.5;
			if(!_roundBeginUI.parent)stage.addChild(_roundBeginUI);
			
			if(!tl) 
			{
				tl = new TimelineLite({onComplete:onPlayerRoundBeginTipFinish});
				tl.append(new TweenLite(_roundBeginUI, 0.4, {x:(StaticTable.STAGE_WIDTH-_roundBeginUI.width)*.5}));
				tl.append(new TweenLite(_roundBeginUI, 0.4, {x:-_roundBeginUI.width, delay:1}));
				tl.play();
			}
			else
			{
				tl.restart();
			}
		}
		
		private function onPlayerRoundBeginTipFinish():void
		{
			LHelp.RemoveFromParent(_roundBeginUI);
			var role:Body = controlRoleBody();
			focusMap(role.position.x, role.position.y, 2.5);
			mouseEnabled = mouseChildren = true;
		}
		
		private function focusMap(x:Number, y:Number, tween:Number = 0):void
		{
			MapLeftTop(StaticTable.STAGE_WIDTH * 0.5 - x, StaticTable.STAGE_HEIGHT * 0.5 - y, tween);
		}
		
		private function MapLeftTop(x:Number, y:Number, tween:Number = 0):void
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
				if(distance / tween < 0.05)
				{
					map.x = x;
					map.y = y;
				}
				else
				{
					TweenLite.to(map,  distance / tween, {x:x, y:y});
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
		
		private var _bullets:Vector.<Body>;
		private var BULLETS:CbType = new CbType;
		private static const GROUP_BULLET:int = 4;
		private var _shooted:Boolean = false;
		
		private function onShoot(pid, bid:int, rad:Number, force:Number):void
		{
			_shooted = true;
			if(!_bullets)_bullets = new Vector.<Body>;
			if(bid == 0) bid = 1;
			
			var _bs:RoleBulletDesc = StaticTable.GetBulletDesc(bid);
			trace(_bs, _bs.baoshi);
			if(_bs.baoshi == EnumBaoShi.NONE)
			{
				shootAbullet(pid, _bs, rad, force);
			}
			else if(_bs.baoshi == EnumBaoShi.LIAN_SHE)
			{
				shootAbullet(pid, _bs, rad, force, false);
				TweenLite.delayedCall(0.5, shootAbullet, [pid, _bs, rad, force, false]);
				TweenLite.delayedCall(1.0, shootAbullet, [pid, _bs, rad, force, true]);
			}
			else if(_bs.baoshi == EnumBaoShi.SAN_SHE)
			{
				shootAbullet(pid, _bs, rad, force);
				shootAbullet(pid, _bs, rad - Math.PI / 16, force);
				shootAbullet(pid, _bs, rad + Math.PI / 16, force);
			}
		}
		
		private var _hasLastBullet:Boolean = false;
		private function shootAbullet(pid:Number, _bs:RoleBulletDesc, rotationRad:Number, forceFactor:Number, lastBullet:Boolean = true):void
		{
			_hasLastBullet = lastBullet;
			var poly:Polygon = new Polygon(Polygon.box(_bs.tuzhi.width, _bs.tuzhi.height, true));
			poly.filter.collisionGroup = GROUP_BULLET;
			poly.filter.collisionMask = ~(GROUP_BULLET|GROUP_ROLE);
			poly.material.density = _bs.tuzhi.mass / (_bs.tuzhi.width*_bs.tuzhi.height);
			
			var bullet:Body = new Body(BodyType.DYNAMIC);
			bullet.shapes.add(poly);
			bullet.userData.bullet = _bs;
			bullet.cbTypes.add(BULLETS);
			bullet.space = _space;
			_bullets.push(bullet);
			
			var role:Body = PlayerId2Role(pid);
			bullet.position.x = role.position.x;
			bullet.position.y = role.position.y - role.bounds.height * 0.5;
			
			bullet.rotation = rotationRad;
			var target:Vec2 = Vec2.get(bullet.position.x + Math.cos(bullet.rotation), bullet.position.y + Math.sin(bullet.rotation));
			var force:Vec2 = target.sub(bullet.position, true).muleq(forceFactor);
			bullet.applyImpulse(force,null, true);
			target.dispose();
		}
		
		private function bulletBody2bulletDesc(body:Body):RoleBulletDesc
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
		private static const ROTATION_LIMT:Number = Math.PI / 2.5;
		private static const FORCE_STEP:Number = 0.75;//high is fast
		private static const DEGREE_STEP:Number = 0.6;
		private static const MOVE_STEP:Number = 1;
		private var _bid:int;
		private var _playerMoveAck:PlayerMoveAck;
		private var _playerDisjustAck:PlayerDisjustAck;
		
		protected function onFrameIn(event:Event):void
		{
			_space.step(Test2.ELAPSED / 1000);
			
			if(_isDrag)
			{
				_smallMap.SetMapTopLeft(map.x, map.y);
			}
			
			for each(var bullet:Body in _bullets)
			{
				bullet.rotation = bullet.velocity.angle;
			}
			
			for each(var role:Body in _roles)
			{
				var bp:BattlePlayer = role2BattlePlayer(role);
				var isControlBp:Boolean = _prb && bp.id == _prb.playerId;
				
				bp.moved = bp.x != role.position.x || bp.y != role.position.y;
				if(bp.moved)
				{
					bp.x = role.position.x;
					bp.y = role.position.y;
					_smallMap.SetRoleXY(bp.id, bp.x, bp.y);
					
					var thred:Number = ROTATION_LIMT;
					for(var i:int = 0; i < role.arbiters.length; i++)
					{
						var arb:Arbiter = role.arbiters.at(i);
						if (!arb.isCollisionArbiter())
						{
							continue;
						}
						var angle:Number = arb.collisionArbiter.normal.angle;
						if(angle < 0)
						{
							angle += Math.PI;
						}
						angle -= MyMath.HALF_PI;
						var thred2:Number = Math.abs(angle);
						if(thred2 < thred)
						{
							bp.rotation = angle;
							thred = thred2;
						}
					}
					
					if(bp.id == Buffer.mainPlayer.id)
					{
						if(_isMyTurn)
						{
							_adjustView.x = bp.x;
							_adjustView.y = bp.y;
							
						}
						_bottomView.printfDegree(bp.rotationDeg, bp.direction);
						_adjustView.printfDegree(bp.rotationDeg);
					}
				}
				
				if(isControlBp && _isMyTurn)
				{					
					if(!_playerMoveAck)
					{
						if(_bottomView.isLeftPressing)
						{
							var pmr:PlayerMoveReq = createPlayerMoveReq(bp, EnumDirection.LEFT, 1);
						}
						else if(_bottomView.isRightPressing)
						{
							pmr = createPlayerMoveReq(bp, EnumDirection.RIGHT, 1);
						}
						if(pmr) MySignals.Socket_Send.dispatch(pmr);
					}
					else
					{
						if(_playerMoveAck.direction == EnumDirection.LEFT && !_bottomView.isLeftPressing)
						{
							pmr = createPlayerMoveReq(bp, EnumDirection.LEFT, 0);
						}
						else if(_playerMoveAck.direction == EnumDirection.RIGHT && !_bottomView.isRightPressing)
						{
							pmr = createPlayerMoveReq(bp, EnumDirection.RIGHT, 0);
						}
						if(pmr) MySignals.Socket_Send.dispatch(pmr);
					}
					
					if(!_playerDisjustAck)
					{
						if(_bottomView.isUpPressing)
						{
							var pdr:PlayerDisjustReq = createPlayerDisjustReq(bp, EnumDirection.UP, 1);
						}
						else if(_bottomView.isDownPressing)
						{
							pdr = createPlayerDisjustReq(bp, EnumDirection.DOWN, 1);
						}
						if(pdr) MySignals.Socket_Send.dispatch(pdr);
					}
					else
					{
						if(_playerDisjustAck.direction == EnumDirection.UP && !_bottomView.isUpPressing)
						{
							pdr = createPlayerDisjustReq(bp, EnumDirection.UP, 0);
						}
						else if(_playerDisjustAck.direction == EnumDirection.DOWN && !_bottomView.isDownPressing)
						{
							pdr = createPlayerDisjustReq(bp, EnumDirection.DOWN, 0);
						}
						if(pdr) MySignals.Socket_Send.dispatch(pdr);
					}
					
					if(!_shooted)
					{
						if(_shootView.bulletPress)
						{
							_bid = _shootView.bulletPress;
							bp.force = bp.force >= 100 ? 100 : bp.force + FORCE_STEP;
							_bottomView.printfForce(bp.force, 0);
						}
						else if(bp.force > 0)
						{
							var _playerShootReq:PlayerShootReq = new PlayerShootReq;
							_playerShootReq.pid = bp.id;
							_playerShootReq.bid = _bid;
							_playerShootReq.force = bp.force;
							_playerShootReq.rad = bp.rotationRad;
							MySignals.Socket_Send.dispatch(_playerShootReq);
							bp.lastForce = bp.force;
							_bid = bp.force = 0;
							_bottomView.printfForce(bp.force, bp.lastForce);
						}
					}
				}
				
				if(_playerDisjustAck && _playerDisjustAck.pid == bp.id)
				{
					if(_playerDisjustAck.direction == EnumDirection.UP)
					{
						bp.degree += DEGREE_STEP;
						if(bp.degree >= 90)
						{
							bp.degree = 90;
						}
					}
					else
					{
						bp.degree -= DEGREE_STEP;
						if(bp.degree <= 0)
						{
							bp.degree = 0;
						}
					}
					_bottomView.printfDegree(bp.rotationDeg, bp.direction);
					_adjustView.printfDegree(bp.rotationDeg);
				}
				
				if(_playerMoveAck && _playerMoveAck.pid == bp.id)
				{
					if(_playerMoveAck.direction == EnumDirection.LEFT)
					{
						role.position.x -= MOVE_STEP;
					}
					else
					{
						role.position.x += MOVE_STEP;
					}
					
					var refuse:Boolean = false;
					if(role.rotation >= ROTATION_LIMT && bp.direction == EnumDirection.LEFT)
					{
						refuse = true;
					}
					else if(role.rotation <= -ROTATION_LIMT && bp.direction == EnumDirection.RIGHT)
					{
						refuse = true;
					}
					else
					{
						_interactingBodies.clear();
						role.interactingBodies(InteractionType.COLLISION, 1, _interactingBodies);
						var closestA:Vec2 = Vec2.get();
						var closestB:Vec2 = Vec2.get();
						for(i = 0; i < _interactingBodies.length; i++)
						{
							var iBody:Body = _interactingBodies.at(i);
							var distance:Number = Geom.distanceBody(role, iBody,closestA, closestB);
							if(distance <= -1)
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
						if(_playerMoveAck.direction == EnumDirection.LEFT)
						{
							role.position.x += MOVE_STEP;
						}
						else
						{
							role.position.x -= MOVE_STEP;
						}
					}
				}
			}
			drawSpace();
		}
		
		private function createPlayerMoveReq(bp:BattlePlayer, direction:int, action:int):PlayerMoveReq
		{
			var pmr:PlayerMoveReq = new PlayerMoveReq;
			pmr.pid = bp.id;
			pmr.x = bp.x;
			pmr.y = bp.y;
			pmr.rotation = bp.rotation;
			pmr.direction = direction;
			pmr.action = action;
			return pmr;
		}
		
		private function createPlayerDisjustReq(bp:BattlePlayer, direction:int, action:int):PlayerDisjustReq
		{
			var pdr:PlayerDisjustReq = new PlayerDisjustReq;
			pdr.pid = bp.id;
			pdr.degree = bp.degree;
			pdr.action = action;
			pdr.direction = direction;
			return pdr;
		}
		
		private function drawSpace():void
		{
			if(isDebug)
			{
				_debug.clear();
				_debug.draw(_space);
				_debug.flush()
			}
			
			for each(var role:Body in _roles)
			{
				var bp:BattlePlayer = role2BattlePlayer(role);
				var roleMc:AnimationPlayer = role.userData.graphic;
				
				if(!roleMc)
				{
					roleMc = StaticTable.GetRoleAniPlayer(bp.role);
					roleMc.rotationY = bp.direction == EnumDirection.LEFT ? 0:180;
					role.userData.graphic = roleMc;
					map.addChild(roleMc);
				}
				else
				{
					roleMc.update(Test2.ELAPSED);
				}
				
				if(bp.direction == EnumDirection.LEFT)
				{
					if(roleMc.rotationY != 0)
						roleMc.rotationY = 0;
				}
				else
				{
					if(roleMc.rotationY != 180)
						roleMc.rotationY = 180;
				}
				
				if(bp.moved)
				{
					roleMc.x = bp.x;
					roleMc.y = bp.y;
					roleMc.rotation = rad2deg(bp.rotation);
				}
				
				if(roleMc.currentAnimationID != bp.action)
				{
					roleMc.play(bp.action);
				}
			}
			
			var focusBullet:Boolean = true;
			for each(var bullet:Body in _bullets)
			{
				var bulletMc:McSprite = bullet.userData.graphic;
				var bs:RoleBulletDesc = bulletBody2bulletDesc(bullet);
				if(!bulletMc)
				{
					bulletMc = StaticTable.GetBulletMcSprite(bs.tuzhi.id);
					bullet.userData.graphic = bulletMc;
					map.addChild(bulletMc);
				}
				bulletMc.x = bullet.position.x;
				bulletMc.y = bullet.position.y;
				bulletMc.rotation = rad2deg(bullet.rotation);
				
				if(focusBullet)
				{
					focusBullet = false;
					if(!pointInView(bulletMc.x, bulletMc.y, bs.tuzhi.width * 1.5))
					{
						focusMap(bulletMc.x, bulletMc.y, 50);
					}
				}
			}
		}
		
		private function roleBody2Graphic(role:Body):DisplayObject
		{
			return role.userData.graphic;
		}
		
		private function pointInView(px:Number, py:Number, radius:Number):Boolean
		{
			var tx:Number = px + map.x;
			var ty:Number = py + map.y;
			return (tx - radius >= 0 && tx + radius <= StaticTable.STAGE_WIDTH && ty - radius >= 0 && ty + radius <= StaticTable.STAGE_HEIGHT);
		}
	}
}