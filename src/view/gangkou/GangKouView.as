package view.gangkou
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.urbansquall.ginger.AnimationBmp;
	import com.urbansquall.ginger.AnimationPlayer;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import bit101.Grid;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	import data.staticObj.EnumAction;
	import data.staticObj.EnumSkillType;
	import data.staticObj.HaiDaoGroupDesc;
	import data.staticObj.HaiDaoWaveDesc;
	import data.staticObj.HaiDaoWaveMemDesc;
	import data.staticObj.MapCityDesc;
	import data.staticObj.MapDesc;
	import data.staticObj.ShenFuDesc;
	import data.staticObj.ShenJiangDesc;
	
	import message.MainPlayerGoldReq;
	
	import mybodys.MyBody;
	import mybodys.PaoDanBody;
	import mybodys.ShenFuPlayer;
	import mybodys.ShipPlayer;
	
	import nape.geom.Vec2;
	
	import starling.utils.Color;
	import starling.utils.rad2deg;
	
	import utils.JinDuTiao;
	import utils.LHelp;
	import utils.LazySprite;
	import utils.TextPool;
	
	import view.city.CityView;
	
	public class GangKouView extends LazySprite
	{
		private var _mcDesc:MapCityDesc;
		private var _mapDesc:MapDesc;
		
		private var _pathGrid:Grid;
		private static const GRID_SIZE:int = 32;
		private static const GRID_SIZE_HALF:int = 16;
		
		private var _ship:ShipPlayer;
		private var _arranges:Vector.<DisplayObject> = new Vector.<DisplayObject>;
		private var _groupDesc:HaiDaoGroupDesc;
		
		public function GangKouView()
		{
			_mapDesc = StaticTable.GetSeaMapDesc(Buffer.mainPlayer.curMapId);
			_mcDesc = _mapDesc.citys[0]
			_pathGrid = StaticTable.GetSeaMapGrid(_mapDesc.id);
			drawMap();
			
			_mcAnchor = StaticTable.GetAniBmpByName("anchor");
			addChild(_mcAnchor);
			
			_groupDesc = StaticTable.GetHaoDaoGroup(1);
			for(var i:int = 0; i < _groupDesc.waves.length; i++)
			{
				_remains.push(_groupDesc.waves[i].remains);
			}
			/*for(var i:int = 0; i < _groupDesc.waves.length; i++)
			{
			var memDesc:HaiDaoWaveMemDesc = _groupDesc.waves[i];
			for(var j:int = 0; j < memDesc.count; j++)
			{
			var hd:ShipPlayer = StaticTable.GetShipBodyPlayer(memDesc.id);
			hd.mouseEnabled = hd.mouseChildren = false;
			hd.setBlood(hd.shipDesc.blood, hd.shipDesc.blood);
			hd.visible = false;
			addChild(hd);
			_hds.push(hd);
			_arranges.push(hd);
			if(hd.shipDesc.bulletId)
			{
			pd = StaticTable.GetPaoDanBody(hd.shipDesc.bulletId);
			_vpaodans.push(pd);
			}
			}
			}*/
			
			_ship = StaticTable.GetShipBodyPlayer(Buffer.mainPlayer.curShip);
			_ship.mouseEnabled = _ship.mouseChildren =false;
			_ship.x = _mcDesc.outX;
			_ship.y = _mcDesc.outY;
			_ship.setBlood(_ship.shipDesc.blood, _ship.shipDesc.blood);
			addChild(_ship);
			_arranges.push(_ship);
			focusMap(_ship.x, _ship.y);
			
			for(i = 0; i < 8; i++)
			{
				var pd:PaoDanBody = StaticTable.GetPaoDanBody(Buffer.mainPlayer.curPaoDan);
				_vpaodans.push(pd);
			}
			
			for(i = 0; i < 2; i++)
			{
				var effect:AnimationBmp = StaticTable.GetAniBmpByName("effect2");
				_veffect2s.push(effect);
			}
			
			drawCitys();
			_greenBar = new JinDuTiao(98,6,1,Color.GREEN);
			_greenBar.x = -_greenBar.width*.5;
			_greenBar.y = -_ship.height * .78;
			
			_greenText = new TextField();
			_greenText.defaultTextFormat = GREEN_FORMAT;
			_greenText.text = "";
			_greenText.selectable = false;
			_greenText.autoSize = TextFieldAutoSize.CENTER;
			_greenText.cacheAsBitmap = true;
			_greenText.y = -_ship.height * .78-_greenBar.height-30;
			_greenText.x = _greenText.width * -.5;
			
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private var _remains:Vector.<Number> = new Vector.<Number>;
		private function waveAction():void
		{
			for(var i:int = 0; i < _remains.length; i++)
			{
				if(_remains[i] <= 0)
				{
					continue;
				}
				_remains[i] -= Test2.ELAPSED;
				if(_remains[i] <= 0)
				{
					var wvDesc:HaiDaoWaveDesc = _groupDesc.waves[i];
					for(var j:int = 0; j < wvDesc.members.length; j++)
					{
						var memDesc:HaiDaoWaveMemDesc = wvDesc.members[j];
						for(var k:int = 0; k < memDesc.count; k++)
						{
							var pos:Number = wvDesc.npcPoses[int(Math.random() * wvDesc.npcPoses.length)];
							addHaiDao(memDesc.id, pos);
						}
					}
				}
			}
		}
		
		private var _hds:Vector.<ShipPlayer> = new Vector.<ShipPlayer>;
		private function addHaiDao(shipId:int, pos:Number):void
		{
			if(pos == 1)
			{
				var hy:Number = Math.random() * StaticTable.STAGE_HEIGHT * 0.5  + _ship.y;
				var hx:Number = _ship.x + StaticTable.STAGE_WIDTH * .6;
				if(hx < StaticTable.STAGE_WIDTH)hx = StaticTable.STAGE_WIDTH;
			}
			else if(pos == 2)
			{
				hy = _ship.y + StaticTable.STAGE_HEIGHT * .6;
				hx = Math.random() * StaticTable.STAGE_WIDTH * 0.5  + _ship.x;
				if(hy < StaticTable.STAGE_HEIGHT)hy = StaticTable.STAGE_HEIGHT;
			}
			else if(pos == 3)
			{
				hy = _ship.y + StaticTable.STAGE_HEIGHT * .6;
				hx = Math.random() * StaticTable.STAGE_WIDTH * -0.5  + _ship.x;
				if(hy < StaticTable.STAGE_HEIGHT)hy = StaticTable.STAGE_HEIGHT;
			}
			else if(pos == 4)
			{
				hy = Math.random() * StaticTable.STAGE_HEIGHT * 0.5  + _ship.y;
				hx = _ship.x + StaticTable.STAGE_WIDTH * -.6;
				if(hx > _mapDesc.width - StaticTable.STAGE_WIDTH)hx = _mapDesc.width - StaticTable.STAGE_WIDTH;
			}
			else if(pos == 5)
			{
				hy = Math.random() * StaticTable.STAGE_HEIGHT * -0.5  + _ship.y;
				hx = _ship.x + StaticTable.STAGE_WIDTH * -.6;
				if(hx > _mapDesc.width - StaticTable.STAGE_WIDTH)hx = _mapDesc.width - StaticTable.STAGE_WIDTH;
			}
			else if(pos == 6)
			{
				hy = _ship.y + StaticTable.STAGE_HEIGHT * -0.6;
				hx = Math.random() * StaticTable.STAGE_WIDTH * -0.5  + _ship.x;
				if(hy > _mapDesc.height - StaticTable.STAGE_HEIGHT)hy = _mapDesc.height - StaticTable.STAGE_HEIGHT;
			}
			else if(pos == 7)
			{
				hy = _ship.y + StaticTable.STAGE_HEIGHT * -.6;
				hx = Math.random() * StaticTable.STAGE_WIDTH * 0.5  + _ship.x;
				if(hy > _mapDesc.height - StaticTable.STAGE_HEIGHT)hy = _mapDesc.height - StaticTable.STAGE_HEIGHT;
			}
			else if(pos == 8)
			{
				hy = Math.random() * StaticTable.STAGE_HEIGHT * -0.5  + _ship.y;
				hx = _ship.x + StaticTable.STAGE_WIDTH * .6;
				if(hx < StaticTable.STAGE_WIDTH)hx = StaticTable.STAGE_WIDTH;
			}
			if(hx > 0 && hy > 0  && hx < _mapDesc.width && hy < _mapDesc.height && _pathGrid.getNode(hx/GRID_SIZE,hy/GRID_SIZE).walkable)
			{
				var hd:ShipPlayer = StaticTable.GetShipBodyPlayer(shipId);
				hd.x = hx;
				hd.y = hy;
				hd.mouseEnabled = hd.mouseChildren = false;
				hd.setBlood(hd.shipDesc.blood, hd.shipDesc.blood);
				addChild(hd);
				_hds.push(hd);
				_arranges.push(hd);
			}
		}
		
		private var _mcAnchor:AnimationBmp;
		protected function onMouseClick(e:MouseEvent):void
		{
			var ex:int = (e.stageX - x) / GRID_SIZE;
			var ey:int = (e.stageY - y) / GRID_SIZE;
			if(_pathGrid.getNode(ex, ey).walkable)
			{
				var sx:int = _ship.x / GRID_SIZE;
				var sy:int = _ship.y / GRID_SIZE;
				if(sx != ex || sy != ey)
				{
					_mcAnchor.x = e.stageX - x;
					_mcAnchor.y = e.stageY - y;
					_mcAnchor.play(EnumAction.EFFECT);
					_mcAnchor.visible = true;
					
					while(_directions.length > 0)
					{
						_directions.pop().dispose();
						_times.pop();
					}
					
					var direction:Vec2 = Vec2.get(_mcAnchor.x - _ship.x, _mcAnchor.y - _ship.y);
					_times.push(direction.length / _ship.shipDesc.speed);
					_directions.push(direction.normalise());
					_startTimeOffset = getTimer() - Test2.TIMESTAMP;
				}
			}
			/*var path:Array = onFindPath(_ship.x, _ship.y, e.stageX - x, e.stageY - y);
			for(var i:int=0; i<path.length;i+=4)
			{
			if(i == 0)
			{
			while(_directions.length > 0)
			{
			_directions.pop().dispose();
			_times.pop();
			}
			}
			if( i == path.length - 4)
			{
			_mcAnchor.x = path[i+2];
			_mcAnchor.y = path[i+3];
			_mcAnchor.play(EnumAction.EFFECT);
			_mcAnchor.visible = true;
			}
			var direction:Vec2 = Vec2.get(path[i + 2] - path[i], path[i+3] - path[i+1]);
			_times.push(direction.length / _ship.shipDesc.speed);
			_directions.push(direction.normalise());
			_startTimeOffset = getTimer() - Test2.TIMESTAMP;
			}*/
		}
		
		private function onFindPath(x1:Number,y1:Number,x2:Number,y2:Number):Array
		{
			var paths:Array=[]
			var nx1:int = x1 / GRID_SIZE, ny1:int = y1 / GRID_SIZE;
			var nx2:int = x2 / GRID_SIZE, ny2:int = y2 / GRID_SIZE;
			var sx:int = nx1>nx2?nx2:nx1, sy:int = ny1>ny2?ny2:ny1;
			var ex:int = nx1>nx2?nx1:nx2, ey:int = ny1>ny2?ny1:ny2;
			var upY:int, downY:int, flag:Boolean, dialoged:Boolean;
			for(var i:int=sy; i<=ey; i++)
			{
				upY = i;
				dialoged=false;
				for(var j:int=sx; j<=ex; j++)
				{
					var dt:Number = Math.abs((ny2 - ny1) * j +(nx1 - nx2) * i + ((nx2 * ny1) -(nx1 * ny2))) / Math.sqrt(Math.pow(ny2 - ny1, 2) + Math.pow(nx1 - nx2, 2));
					if(dt < 0.5)
					{
						dialoged=true;
						if(!_pathGrid.getNode(j, i).walkable)
						{
							flag=true;
							break;
						}
					}
					else if(dialoged)
					{
						break;
					}
				}
				if(flag)
				{
					break;
				}
			}
			if(!flag)
			{
				paths.push(nx1*GRID_SIZE + GRID_SIZE_HALF, ny1*GRID_SIZE + GRID_SIZE_HALF, nx2*GRID_SIZE + GRID_SIZE_HALF, ny2*GRID_SIZE + GRID_SIZE_HALF);
			}
			else if(upY > sy)
			{
				flag=false;
				for(i=ey; i>=upY; i--)
				{
					downY = i;
					dialoged = false;
					for(j=sx; j<=ex; j++)
					{
						dt = Math.abs((ny2 - ny1) * j +(nx1 - nx2) * i + ((nx2 * ny1) -(nx1 * ny2))) / Math.sqrt(Math.pow(ny2 - ny1, 2) + Math.pow(nx1 - nx2, 2));
						if(dt < 0.5)
						{
							dialoged=true;
							if(!_pathGrid.getNode(j, i).walkable)
							{
								flag=true;
								break;
							}
						}
						else if(dialoged)
						{
							break;
						}
					}
					if(flag)
					{
						break;
					}
				}
				
				if(downY < ey)
				{
					flag=true;
					for(i=sx+(ex-sx)*.5; flag; i%2==0?i++:i--)
					{
						flag = false;
						for(j=upY; j<=downY; j++)
						{
							if(!_pathGrid.getNode(i, j).walkable)
							{
								flag=true;
								break;
							}
						}
						if(i<=0 || i >= _mapDesc.cols)break;//can't find a path;
					}
					if(!flag)
					{
						if(upY!=downY)
							paths.push(nx1*GRID_SIZE + GRID_SIZE_HALF, ny1*GRID_SIZE + GRID_SIZE_HALF, i*GRID_SIZE + GRID_SIZE_HALF, (ny1<ny2?upY:downY)*GRID_SIZE + GRID_SIZE_HALF, i*GRID_SIZE + GRID_SIZE_HALF, (ny1<ny2?downY:upY)*GRID_SIZE + GRID_SIZE_HALF, nx2*GRID_SIZE + GRID_SIZE_HALF, ny2*GRID_SIZE + GRID_SIZE_HALF);
						else
							paths.push(nx1*GRID_SIZE + GRID_SIZE_HALF, ny1*GRID_SIZE + GRID_SIZE_HALF, i*GRID_SIZE + GRID_SIZE_HALF, upY*GRID_SIZE + GRID_SIZE_HALF, nx2*GRID_SIZE + GRID_SIZE_HALF, ny2*GRID_SIZE + GRID_SIZE_HALF);
					}
				}
			}
			return paths;
		}
		
		private function onShipMoveFinished():void
		{
			for(var i:int = 0; i < _mapDesc.citys.length; i++)
			{
				var mcDesc:MapCityDesc = _mapDesc.citys[i];
				if(LHelp.pointInRound(_mcAnchor.x, _mcAnchor.y, mcDesc.entryX, mcDesc.entryY, GRID_SIZE * 2))
				{
					MidLayer.CloseWindow(GangKouView);
					MidLayer.ShowWindowObj(CityView, {params:[mcDesc.id]});
				}
			}
			_mcAnchor.visible = false;
		}
		
		private var _directions:Vector.<Vec2> = new Vector.<Vec2>;
		private var _times:Vector.<int> = new Vector.<int>;
		private var _startTimeOffset:int;
		private function onFrameIn(event:Event):void
		{
			for(var i:int = 0; i < _mapBlocks.length; i++)
			{
				_mapBlocks[i].update(Test2.ELAPSED);
			}
			
			if(_mcAnchor.visible)
			{
				_mcAnchor.update(Test2.ELAPSED);
			}
			
			for(i = 0; i < _vpaodans.length; i++)
			{
				var mybody:PaoDanBody = _vpaodans[i];
				if(mybody.paodan.parent)
				{
					mybody.paodan.update(Test2.ELAPSED);
				}
				if(mybody.effect.parent)
				{
					if(mybody.effect.isPlaying())
					{
						mybody.effect.update(Test2.ELAPSED);
					}
					else
					{
						mybody.effect.parent.removeChild(mybody.effect);
					}
				}
			}
			
			_ship.update(Test2.ELAPSED);
			
			for(i = 0; i < _veffect2s.length; i++)
			{
				var ae:AnimationBmp = _veffect2s[i];
				if(ae.parent)
				{
					if(!ae.isPlaying())
					{
						if(ae.parent)
						{
							ae.parent.removeChild(ae);
							_effect2Index--;
						}
					}
					else
					{
						ae.update(Test2.ELAPSED);
					}
				}
			}
			
			if(_bosaidong.parent)
			{
				if(_bosaidong.isPlaying())
				{
					_bosaidong.update(Test2.ELAPSED);
				}
				else
				{
					_bosaidong.parent.removeChild(_bosaidong);
				}
			}
			
			for(var hd:ShipPlayer in _frozens)
			{
				_frozens[hd] -= Test2.ELAPSED;
				if(_frozens[hd] <= 0)
				{
					delete _frozens[hd];
				}
			}
			
			if(_bingheshiji.parent)
			{
				if(_bingheshiji.isPlaying())
				{
					for(i = 0 ; i < _hds.length; i++)
					{
						hd1 = _hds[i];
						if(hd1.visible && hd1.curBlood > 0 && !_frozens[hd1])
						{
							y1 = _bingheshiji.y; x1 = _bingheshiji.x; x0 = hd1.x; y0 = hd1.y;
							if(LHelp.pointInRound(x0,y0,x1,y1,_frozenRadius + 38))
							{
								_frozens[hd1] = FROZEN_SECONDS * 1000;
							}
						}
					}
					_bingheshiji.update(Test2.ELAPSED);
				}
				else
				{
					_bingheshiji.parent.removeChild(_bingheshiji);
				}
			}
			
			if(_xuanwofengbao.parent)
			{
				for(i = 0 ; i < _hds.length; i++)
				{
					var hd1:ShipPlayer = _hds[i];
					if(hd1.visible && hd1.curBlood > 0)
					{
						var y1:Number = _xuanwofengbao.y, x1:Number = _xuanwofengbao.x, x0:Number = hd1.x, y0:Number = hd1.y;
						if(LHelp.pointInRound(x0,y0,x1,y1,XUANWO_RADIUS))
						{
							var harm:int =  _xuanwoHarm * Test2.ELAPSED;
							hd1.setBlood(hd1.curBlood - harm, hd1.maxBlood);
						}
					}
				}
				_xuanwofengbao.update(Test2.ELAPSED);
			}
			
			if(_isPaused)
			{
				return;
			}
			
			waveAction();
			sfsAciton();
			paodanAction();
			haidaoAction();
			
			if(_directions && _directions.length > 0)
			{
				var elapsed:int = Test2.ELAPSED;
				if(_startTimeOffset)
				{
					elapsed -= _startTimeOffset;
					_startTimeOffset = 0;
				}
				if(_times[0] > elapsed)
				{
					_times[0] -= elapsed;
					var motion:Vec2 = _directions[0].mul(_ship.shipDesc.speed * elapsed);
					_ship.x += motion.x;
					_ship.y += motion.y;
					motion.dispose();
				}
				else
				{
					elapsed -= _times[0];
					var xs:Number = getSfXs(EnumSkillType.SF_JIASHU);
					motion = _directions[0].mul((_ship.shipDesc.speed * xs) * _times[0]);
					_ship.x += motion.x;
					_ship.y += motion.y;
					motion.dispose();
					_directions.shift().dispose();
					_times.shift();
					if(elapsed && _directions.length > 0)
					{
						_times[0] -= elapsed;
						motion = _directions[0].mul(_ship.shipDesc.speed * elapsed);
						_ship.x += motion.x;
						_ship.y += motion.y;
						motion.dispose();
						if(_times[0] <= 0)
						{
							_directions.shift().dispose();
							_times.shift();
						}
					}
				}
				if(_directions.length <= 0)
				{
					onShipMoveFinished();
				} 
				else
				{
					_ship.setRadius(_directions[0].angle);
				}
				focusMap(_ship.x, _ship.y);
			}
			
			for(i = 0; i < _arranges.length; i++)
			{
				for(var j:int = i + 1; j < _arranges.length; j++)
				{
					if(_arranges[i].y > _arranges[j].y)
					{
						swapChildren(_arranges[i], _arranges[j]);
						var hdt:DisplayObject = _arranges[i];
						_arranges[i] = _arranges[j];
						_arranges[j] = hdt;
					}
				}
			}
		}
		
		private function paodanAction():void
		{
			for(var i:int = 0; i < _vpaodans.length; i++)
			{
				var pd:PaoDanBody = _vpaodans[i];
				if(!pd.paodan.parent)
				{
					continue;
				}
				var hd:ShipPlayer = pd.target;
				if(pd.collsin(hd))
				{
					var effect:AnimationBmp = pd.effect;
					effect.x = (pd.paodan.x - hd.x) * Math.random() * .5;
					effect.y = (pd.paodan.y - hd.y) * Math.random() * .5;
					effect.play(EnumAction.EFFECT);
					hd.addChild(effect);
					var pj:Number = 1;
					if(hd == _ship)
					{
						var xs:Number = getSfXs(EnumSkillType.SF_FANGYU);
					}
					else
					{
						xs = getSfXs(EnumSkillType.SF_HUOLI);
					}
					playText(hd.x, hd.y - 20,"-" + int(pd.paodanDesc.hurt * pd.hurtDiscount * xs), RED_FORMAT);
					hd.setBlood(hd.curBlood - (pd.paodanDesc.hurt * pd.hurtDiscount * xs), hd.maxBlood);
					removeChild(pd.paodan);
				}
				else
				{
					var motion:Vec2 = Vec2.get(hd.x - pd.paodan.x, hd.y - pd.paodan.y).normalise();
					pd.paodan.rotation = rad2deg(motion.angle);
					motion.muleq(PAODAN_SPEED * Test2.ELAPSED);
					pd.paodan.x += motion.x;
					pd.paodan.y += motion.y;
					motion.dispose();
				}
			}
		}
		
		private function haidaoAction():void
		{
			var nearstHds:Vector.<ShipPlayer> = new Vector.<ShipPlayer>;
			var minDises:Vector.<int> = new Vector.<int>;
			var  nearstHd:ShipPlayer, minDis:int = int.MAX_VALUE;
			for(var i:int=0;i<_hds.length;i++)
			{
				var hd:ShipPlayer = _hds[i];
				if(!hd.visible || shipDropping(hd))
				{
					continue;
				}
				if(hd.curBlood <= 0)
				{
					dropShip(hd);
					continue;
				}
				
				var motion:Vec2 = Vec2.get(_ship.x - hd.x, _ship.y - hd.y);
				var distance:int = motion.length;
				if(distance < minDis)
				{
					minDis = distance;
					nearstHd = hd;
				}
				if(distance < _ship.shipDesc.range)
				{
					minDises.push(distance);
					nearstHds.push(hd);
				}
				if(!_frozens[hd])
				{
					var xs:Number = getSfXs(EnumSkillType.SF_FANWEI);
					var isInRange:Boolean = LHelp.pointInRound(_ship.x, _ship.y, hd.x, hd.y, hd.shipDesc.range * xs);
					if(isInRange)
					{
						fireHaiDao(hd);
					}
					motion.normalise().muleq(hd.shipDesc.speed * Test2.ELAPSED);
					if(!LHelp.pointInRound(_ship.x, _ship.y, hd.x, hd.y, hd.shipDesc.range * xs * .8))
					{
						hd.x += motion.x;
						hd.y += motion.y;
					}
					hd.setRadius(motion.angle);
					motion.dispose();
					hd.update(Test2.ELAPSED);
				}
			}
			
			for(i = 0; i < minDises.length; i++)
			{
				for(var j:int = i + 1; j < minDises.length; j++)
				{
					if(minDises[i] > minDises[j])
					{
						var t1:int = minDises[i];
						minDises[i] = minDises[j];
						minDises[j] = t1;
						var t2:ShipPlayer = nearstHds[i];
						nearstHds[i] = nearstHds[j];
						nearstHds[j] = t2;
					}
				}
			}
			
			fire(nearstHds, nearstHd);
		}
		
		private function fireHaiDao(hd:ShipPlayer):void
		{
			if(hd.shipDesc.id == 3)
			{
				rabberShip(hd);
				return;
			}
			if(hd.allowShoot)
			{
				hd.shootItev = 0;
				for each(var pd:PaoDanBody in _vpaodans)
				{
					if(!pd.paodan.parent && pd.paodanDesc.id == hd.shipDesc.bulletId)break;
				}
				pd.paodan.x = hd.x;
				pd.paodan.y = hd.y;
				pd.hurtDiscount = 1;
				pd.target = _ship;
				addChild(pd.paodan);
			}
		}
		
		private var _veffect2s:Vector.<AnimationBmp> = new Vector.<AnimationBmp>;
		private var _effect2Index:int;
		private function rabberShip(hd:ShipPlayer):void
		{
			//var md:HaiDaoWaveMemDesc = _groupDesc.getMemById(hd.bodyDesc.id);
			_ship.setBlood(_ship.curBlood + hd.shipDesc.hurt, _ship.maxBlood);
			playText(_ship.x,_ship.y, "" + hd.shipDesc.hurt, RED_FORMAT);
			hd.visible = false;
			if(_effect2Index < _veffect2s.length)
			{
				var effect:AnimationBmp = _veffect2s[_effect2Index++];
				effect.x = (hd.x - _ship.x) * Math.min(0.5, Math.random());
				effect.y = (hd.y - _ship.y) * Math.min(0.5, Math.random());
				effect.play(EnumAction.EFFECT);
				_ship.addChild(effect);
			}
		}
		
		private var _shootTimer:int;
		private var _selectSkill:ShenJiangDesc;
		private var _remainMills:int;
		private var _greenText:TextField;
		private var _greenBar:JinDuTiao;
		private function fire(nearestHds:Vector.<ShipPlayer>, nearestHd:ShipPlayer):void
		{
			_shootTimer += Test2.ELAPSED;
			_remainMills -= Test2.ELAPSED;
			if(_selectSkill)
			{
				_greenBar.setBlood(_remainMills, _selectSkill.wait * 1000);
			}
			
			var isShoot:Boolean = _shootTimer * _ship.shipDesc.shootSpeed >= 1;
			if(!isShoot)
			{
				return;
			}
			else
			{
				_shootTimer = 0;
			}
			
			if(_selectSkill)
			{
				if(_remainMills <= 0)
				{
					switch(_selectSkill.type)
					{
						case EnumSkillType.LIAN_SHE:
							if(nearestHds.length > 0)
							{
								liansePaoDan(nearestHds[0], _selectSkill);
							}
							break;
						case EnumSkillType.SAN_SHE:
							if(nearestHds.length > 0)
							{
								sansePaoDan(nearestHds, _selectSkill);
							}
							break;
						case EnumSkillType.BO_SAI_DONG:
							bosaidong(nearestHd, _selectSkill);
							break;
						case EnumSkillType.XUAN_WO:
							xuanwofengbao(_selectSkill);
							break;
						case EnumSkillType.ICE:
							bingheshiji(_selectSkill);
							break;
					}
					_remainMills = 0;
					_selectSkill = null;
					_ship.removeChild(_greenBar);
					_ship.removeChild(_greenText);
					return;
				}
			}
			else
			{
				var rand:Number = Math.random();
				for each(var sd:ShenJiangDesc in Buffer.mainPlayer.sjs)
				{
					rand -= sd.weight;
					if(rand < 0) 
					{
						_selectSkill = sd;
						_remainMills = sd.wait * 1000;
						_greenText.text = sd.name;
						_ship.addChild(_greenText);
						_ship.addChild(_greenBar);
						break;
					}
				}
			}
			
			if(nearestHds.length > 0)
			{
				shootPaoDan(nearestHds[0]);
			}
		}
		
		private var _bingheshiji:AnimationBmp = StaticTable.GetAniBmpByName("bingheshiji");
		private var _frozens:Dictionary = new Dictionary, _frozenRadius:int;
		private const FROZEN_SECONDS:Number = 3;
		private function bingheshiji(_selectSkill:ShenJiangDesc):void
		{
			_frozenRadius = _selectSkill.extra;
			_bingheshiji.x = _ship.x;
			_bingheshiji.y = _ship.y;
			addChildAt(_bingheshiji, getChildIndex(_arranges[0]));
			_bingheshiji.play(EnumAction.EFFECT);
		}
		
		private var _xuanwofengbao:AnimationBmp = StaticTable.GetAniBmpByName("xuanwofengbao");
		private var _xuanwoHarm:Number;
		private const XUANWO_RADIUS:Number = 200,XUANWO_TIME:Number = 2;
		private function xuanwofengbao(_selectSkill:ShenJiangDesc):void
		{
			_xuanwoHarm = _selectSkill.extra * 0.001;
			_xuanwofengbao.alpha = 1.0;
			_xuanwofengbao.x = _ship.x;
			_xuanwofengbao.y = _ship.y;
			_xuanwofengbao.play(EnumAction.EFFECT);
			addChildAt(_xuanwofengbao, getChildIndex(_arranges[0]));
			TweenLite.delayedCall(XUANWO_TIME, onXuanWuFinish);
		}
		
		private function onXuanWuFinish():void
		{
			removeChild(_xuanwofengbao);
		}
		
		private var _bosaidong:AnimationPlayer = StaticTable.GetAniPlayerByName("bosaidong");
		private const BOSAIDONG_DIS:Number = 70;
		private function bosaidong(neasthd:ShipPlayer, sd:ShenJiangDesc):void
		{
			if(!neasthd)return;
			var direction:Vec2 = Vec2.get(neasthd.x - _ship.x, neasthd.y - _ship.y).normalise();
			_bosaidong.x = _ship.x + direction.x * _ship.shipDesc.raidus * 3;
			_bosaidong.y = _ship.y + direction.y * _ship.shipDesc.raidus * 3;
			var brotation:Number = direction.angle + Math.PI / 2;
			_bosaidong.rotation = rad2deg(brotation);
			_bosaidong.play(EnumAction.EFFECT);
			addChild(_bosaidong);
			direction.dispose();
			for(var i:int = 0 ; i < _hds.length; i++)
			{
				var hd1:ShipPlayer = _hds[i];
				if(hd1.visible && hd1.curBlood > 0)
				{
					var y1:Number = _ship.y, y2:Number = neasthd.y, x1:Number = _ship.x, x2:Number = neasthd.x, x0:Number = hd1.x, y0:Number = hd1.y;
					var dt:Number = Math.abs((y2 - y1) * x0 +(x1 - x2) * y0 + ((x2 * y1) -(x1 * y2))) / Math.sqrt(Math.pow(y2 - y1, 2) + Math.pow(x1 - x2, 2));
					if(dt < BOSAIDONG_DIS)
					{
						var direction1:Vec2 = Vec2.get(x2-x1,y2-y1);
						var direction2:Vec2 = Vec2.get(x0-x1,y0-y1);
						if(Math.abs(direction1.angle - direction2.angle) < Math.PI / 2)
						{
							hd1.setBlood(hd1.curBlood - sd.extra, hd1.maxBlood);
							playText(hd1.x, hd1.y - 20, "-" + sd.extra, RED_FORMAT);
						}
						direction1.dispose();
						direction2.dispose();
					}
				}
			}
		}
		
		private var _isPaused:Boolean = false;
		public function get isPaused():Boolean
		{
			return _isPaused;
		}
		
		public function set isPaused(value:Boolean):void
		{
			_isPaused = value;
		}
		
		private var PAODAN_SPEED:Number = 0.3;
		private var _vpaodans:Vector.<MyBody> = new Vector.<MyBody>;
		private var _isLianSheing:Boolean = false;
		private function shootPaoDan(hd:ShipPlayer, discount:Number= 1, isLs:Boolean = false):void
		{
			_isLianSheing = isLs;
			for each(var pd:PaoDanBody in _vpaodans)
			{
				if(!pd.paodan.parent && pd.paodanDesc.id == Buffer.mainPlayer.curPaoDan)break;
			}
			pd.paodan.x = _ship.x;
			pd.paodan.y = _ship.y;
			pd.hurtDiscount = discount;
			pd.target = hd;
			addChild(pd.paodan);
		}
		
		private function liansePaoDan(hd:ShipPlayer, sd:ShenJiangDesc):void
		{
			var count:int = sd.extra;
			var tm:Number = 0.1;
			shootPaoDan(hd, sd.extra2, true);
			for(var i:int = 1; i < count; i++)
			{
				TweenLite.delayedCall(i * tm, shootPaoDan, [hd, sd.extra2, i < count - 1]);
			}
		}
		
		private function sansePaoDan(hds:Vector.<ShipPlayer>, sd:ShenJiangDesc):void
		{
			var count:int = sd.extra;
			for(var i:int = 0; i < hds.length && i < count; i++)
			{
				shootPaoDan(hds[i], sd.extra2);
			}
		}
		
		private const RED_FORMAT:TextFormat = new TextFormat(null, 24, Color.RED,true);
		private const BAOJI_FORMAT:TextFormat = new TextFormat(null, 28, Color.LIME,true);
		private const YELLOW_FORMAT:TextFormat = new TextFormat(null, 24, Color.YELLOW,true);
		private const GREEN_FORMAT:TextFormat = new TextFormat(null, 28, Color.GREEN,true);
		private var _tp:TextPool = new TextPool(9);
		private function playText(gx:Number, gy:Number, txt:String, format:TextFormat):void
		{
			var tf:TextField = _tp.popTf();
			tf.defaultTextFormat = format;
			tf.text = txt;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.x = gx - tf.width *.5;
			tf.y = gy - tf.height *.5;
			tf.cacheAsBitmap = true;
			addChild(tf);
			TweenLite.to(tf, 0.6, {y:tf.y - 80, onComplete:returnTf, onCompleteParams:[tf], ease:Linear.easeNone});
		}
		
		private function returnTf(tf:TextField):void
		{
			_tp.pushBack(tf);
			tf.parent.removeChild(tf);
		}
		
		private function getSfXs(type:int):Number
		{
			return _availableSfs[type - EnumSkillType.SF_START]?1 + _availableSfs[type - EnumSkillType.SF_START].sfDesc.extra:1;
		}
		
		private function dropShip(hd:ShipPlayer):void
		{
			var mpgr:MainPlayerGoldReq = new MainPlayerGoldReq;
			var xs:Number = getSfXs(EnumSkillType.SF_TANLAN);
			mpgr.addtion = hd.shipDesc.cost * xs;
			MySignals.Socket_Send.dispatch(mpgr);
			playText(hd.x,hd.y,"+" + mpgr.addtion, YELLOW_FORMAT);
			TweenLite.to(hd,1,{alpha:0, onComplete:onShipDroped, onCompleteParams:[hd]});
			return;
			var rand:Number = Math.random();
			for(var j:int = 0; j < Buffer.mainPlayer.sfs.length; j++)
			{
				var sf:ShenFuDesc = Buffer.mainPlayer.sfs[j];
				if(!sf.locked)
				{
					rand -= _dropSf;
					if(rand < 0)
					{
						addSF(hd.x,hd.y, sf);
						break;
					}
				}
			}
		}
		
		private var _sfs:Vector.<ShenFuPlayer> = new Vector.<ShenFuPlayer>;
		private const _dropSf:Number = 0.02, _remainSf:Number = 12*1000;
		private function addSF(x:Number, y:Number, sf:ShenFuDesc):void
		{
			var sfp:ShenFuPlayer = StaticTable.GetShenFuPlayer(sf);
			sfp.x = x - sfp.width *.5;
			sfp.y = y - sfp.height *.5;
			sfp.alpha = 0.6;
			sfp.remains = _remainSf;
			addChild(sfp);
			_sfs.push(sfp);
		}
		
		private function sfsAciton():void
		{
			for(var i:int = 0; i < _sfs.length; i++)
			{
				var sfp:ShenFuPlayer = _sfs[i];
				if(LHelp.pointInRound(sfp.x,sfp.y,_ship.x,_ship.y,_ship.shipDesc.raidus))
				{
					LightSF(sfp.sfDesc);
					sfp.remains = 0;
				}
				else
				{
					sfp.remains -= Test2.ELAPSED;
				}
				if(sfp.remains <= 0)
				{
					removeChild(_sfs[i]);
					_sfs.splice(i,1);
					i--;
				}
			}
			
			for(i = 0; i < _availableSfs.length; i++)
			{
				sfp = _availableSfs[i];
				if(sfp)
				{
					sfp.remains -= Test2.ELAPSED;
					if(sfp.remains <= 0)
					{
						var index:int = _sfSprite.getChildIndex(sfp);
						_sfSprite.removeChild(sfp);
						_availableSfs[i] = null;
						for(var j:int = index; j < _sfSprite.numChildren; j++)
						{
							_sfSprite.getChildAt(j).x += sfp.width + 10;
						}
					}
				}
			}
		}
		
		private var _sfSprite:Sprite = new Sprite;
		private var _availableSfs:Vector.<ShenFuPlayer> = new <ShenFuPlayer>[null,null,null,null,null,null];
		private function LightSF(sfDesc:ShenFuDesc):void
		{
			if(!_sfSprite.parent)
			{
				stage.addChild(_sfSprite);
				_sfSprite.x = StaticTable.STAGE_WIDTH;
			}
			if(_availableSfs[sfDesc.type - EnumSkillType.SF_START])
			{
				_availableSfs[sfDesc.type - EnumSkillType.SF_START].remains = sfDesc.time * 1000;
			}
			else
			{
				if(sfDesc.type == EnumSkillType.SF_ZHILIAO)
				{
					_ship.setBlood(_ship.curBlood + _ship.maxBlood * sfDesc.extra, _ship.maxBlood);
				}
				else
				{
					var sfp:ShenFuPlayer = StaticTable.GetShenFuPlayer(sfDesc);
					_sfSprite.addChild(sfp);
					sfp.remains = sfDesc.time * 1000;
					sfp.x = -(sfp.width+10) * _sfSprite.numChildren;
					_availableSfs[sfDesc.type - EnumSkillType.SF_START] = sfp;
				}
			}
			
		}
		
		override protected function destoryed():void
		{
			stage.removeChild(_sfSprite);
		}
		
		private function onShipDroped(hd:ShipPlayer):void
		{
			hd.alpha = 1;
			hd.visible=false;
		}
		
		private function shipDropping(hd:ShipPlayer):Boolean
		{
			return hd.alpha < 1;
		}
		
		private function drawCitys():void
		{
			for(var i:int = 0; i < _mapDesc.citys.length; i++)
			{
				var mcDesc:MapCityDesc = _mapDesc.citys[i];
				var bmp:Bitmap = StaticTable.GetBmpByCityId(mcDesc.id);
				bmp.x = mcDesc.posX;
				bmp.y = mcDesc.posY;
				addChild(bmp);
			}
		}
		
		private var _mapBlocks:Vector.<AnimationBmp> = new Vector.<AnimationBmp>;
		private function drawMap():void
		{
			for(var i:int = 0; i < _mapDesc.cols; i++)
			{
				for(var j:int = 0; j < _mapDesc.rows; j++)
				{
					var bmpName:String = _mapDesc.getBlockName(i,j);
					if(bmpName.indexOf("sea")==0)
					{
						var aniBmp:AnimationBmp = StaticTable.GetAniBmpByName(bmpName);
						aniBmp.x = i * _mapDesc.blockWidth;
						aniBmp.y = j * _mapDesc.blockHeight;
						addChild(aniBmp);
						_mapBlocks.push(aniBmp);
					}
					else
					{
						var bmp:Bitmap = StaticTable.GetBmp(bmpName);
						bmp.x = i * _mapDesc.blockWidth;
						bmp.y = j * _mapDesc.blockHeight;
						addChild(bmp);
					}
				}
			}
			
			for(i = 0; i < _mapDesc.islands.length; i++)
			{
				bmp = StaticTable.GetBmp(_mapDesc.islands[i].name);
				bmp.x = _mapDesc.islands[i].x;
				bmp.y = _mapDesc.islands[i].y;
				addChild(bmp);
			}
			
			for(i = 0; i < _mapDesc.citys.length; i++)
			{
				var mcDesc:MapCityDesc = _mapDesc.citys[i];
				var mcEntry:AnimationBmp = StaticTable.GetAniBmpByName("entry");
				mcEntry.x = mcDesc.entryX;
				mcEntry.y = mcDesc.entryY;
				addChild(mcEntry);
			}
		}
		
		private function focusMap(x:Number, y:Number, tween:Number = 0):void
		{
			MapLeftTop(StaticTable.STAGE_WIDTH * 0.5 - x, StaticTable.STAGE_HEIGHT * 0.5 - y, tween);
		}
		
		private function MapLeftTop(tx:Number, ty:Number, tween:Number = 0):void
		{
			var minX:int = StaticTable.STAGE_WIDTH - _mapDesc.width;
			var minY:int = StaticTable.STAGE_HEIGHT - _mapDesc.height;
			if(tx < minX)
			{
				tx = minX;
			}
			else if(tx > 0)
			{
				tx = 0;
			}
			if(ty < minY)
			{
				ty = minY;
			}
			else if(ty > 0)
			{
				ty = 0;
			}
			if(tween)
			{
				var distance:Number=LHelp.distance(tx,ty,this.x,this.y) / 250;
				if(distance / tween < 0.05)
				{
					this.x = tx;
					this.y = ty;
				}
				else
				{
					TweenLite.to(this,  distance / tween, {x:tx, y:ty});
				}
			}
			else
			{
				this.x = tx;
				this.y = ty;
			}
		}
	}
}