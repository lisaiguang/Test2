package view.gangkou
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.urbansquall.ginger.AnimationBmp;
	import com.urbansquall.ginger.AnimationPlayer;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
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
	import data.staticObj.HaiDaoGroupMemDesc;
	import data.staticObj.MapCityDesc;
	import data.staticObj.MapDesc;
	import data.staticObj.SkillDesc;
	
	import message.MainPlayerGoldReq;
	
	import myphys.MyBody;
	
	import nape.geom.Vec2;
	
	import starling.utils.Color;
	import starling.utils.rad2deg;
	
	import utils.BodyPlayer;
	import utils.LHelp;
	import utils.LazySprite;
	import utils.TextPool;
	
	import view.city.CityView;
	
	public class GangKouView extends LazySprite
	{
		private var _mcDesc:MapCityDesc;
		private var _mapDesc:MapDesc;
		
		private var _terrain:Array;
		private var _pathGrid:Grid;
		private static const GRID_SIZE:int = 32;
		
		private var _ship:BodyPlayer;
		private var _arranges:Vector.<DisplayObject> = new Vector.<DisplayObject>;
		private var _groupDesc:HaiDaoGroupDesc;
		private var _skills:Vector.<SkillDesc>;
		
		public function GangKouView()
		{
			_skills = Buffer.mainPlayer.skills;
			_mcDesc = StaticTable.GetMapCityDesc(Buffer.mainPlayer.curMapId, Buffer.mainPlayer.curCityId);
			_mapDesc = _mcDesc.mapDesc;
			_pathGrid = StaticTable.GetSeaMapGrid(_mapDesc.id)
			
			_terrain = [];
			for(var i:int = 0; i < _mapDesc.rows; i++)
			{
				var cols:Array = [];
				for(var j:int = 0; j < _mapDesc.cols; j++)
				{
					if(i == 0 || i == _mapDesc.rows - 1)
					{
						cols.push("land1");
						continue;
					}
					if(j == 0 || j == _mapDesc.cols - 1)
					{
						cols.push("land1");
						continue;
					}
					cols.push("sea1");
				}
				_terrain.push(cols);
			}
			drawMap();
			
			_mcAnchor = StaticTable.GetAniBmpByName("anchor");
			addChild(_mcAnchor);
			
			_groupDesc = StaticTable.GetHaoDaoGroup(Buffer.mainPlayer.gold);
			for(i = 0; i < _groupDesc.members.length; i++)
			{
				var memDesc:HaiDaoGroupMemDesc = _groupDesc.members[i];
				for(j = 0; j < memDesc.count; j++)
				{
					var hd:BodyPlayer = StaticTable.GetShipBodyPlayer(memDesc.id);
					hd.mouseEnabled = hd.mouseChildren = false;
					hd.setBlood(hd.shipDesc.blood, hd.shipDesc.blood);
					hd.visible = false;
					addChild(hd);
					_hds.push(hd);
					_arranges.push(hd);
				}
			}
			
			_ship = StaticTable.GetShipBodyPlayer(Buffer.mainPlayer.curShip);
			_ship.mouseEnabled = _ship.mouseChildren =false;
			_ship.x = _mcDesc.outX;
			_ship.y = _mcDesc.outY;
			addChild(_ship);
			_arranges.push(_ship);
			focusMap(_ship.x, _ship.y);
			
			for(i = 0; i < 8; i++)
			{
				var pd:MyBody = StaticTable.GetPaoDanMyBody(Buffer.mainPlayer.curPaoDan);
				_vpaodans.push(pd);
			}
			
			for(i = 0; i < 6; i++)
			{
				var effect:AnimationBmp = StaticTable.GetAniBmpByName("effect1");
				_veffects.push(effect);
			}
			
			for(i = 0; i < 2; i++)
			{
				effect = StaticTable.GetAniBmpByName("effect2");
				_veffect2s.push(effect);
			}
			
			drawCitys();
			_greenText = new TextField();
			_greenText.defaultTextFormat = GREEN_FORMAT;
			_greenText.text = "";
			_greenText.selectable = false;
			_greenText.autoSize = TextFieldAutoSize.CENTER;
			_greenText.cacheAsBitmap = true;
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			addEventListener(MouseEvent.CLICK, onMouseClick);
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
		
		private var _hds:Vector.<BodyPlayer> = new Vector.<BodyPlayer>;
		private var _pos:int;
		private function addHaiDao():void
		{
			for(var i:int = 0; i < _hds.length; i++)
			{
				var hd:BodyPlayer =  _hds[i];
				if(!hd.visible)
				{
					var r1:Number =  Math.random() ;
					if(_pos == 0)
					{
						var hy:Number = (Math.random() < 0.5? -r1 : r1) * StaticTable.STAGE_HEIGHT * .5  + _ship.y;
						var hx:Number = _ship.x + StaticTable.STAGE_WIDTH * .6;
					}
					else if(_pos == 2)
					{
						hy = (Math.random() < 0.5? -r1 : r1) * StaticTable.STAGE_HEIGHT * .5 + _ship.y;
						hx = _ship.x - StaticTable.STAGE_WIDTH * .6;
					}
					else if(_pos == 1)
					{
						hx = (Math.random() < 0.5? -r1 : r1) * StaticTable.STAGE_WIDTH * .5 + _ship.x;
						hy = _ship.y + StaticTable.STAGE_HEIGHT * .6;
					}
					else if(_pos == 3)
					{
						hx = (Math.random() < 0.5? -r1 : r1) * StaticTable.STAGE_WIDTH * .5  + _ship.x;
						hy = _ship.y - StaticTable.STAGE_HEIGHT * .6;
					}
					_pos = (_pos + 1)%4;
					if(hx > 0 && hy > 0  && hx < _mapDesc.width && hy < _mapDesc.height && _pathGrid.getNode(hx/GRID_SIZE,hy/GRID_SIZE).walkable)
					{
						hd.x = hx;
						hd.y = hy;
						hd.setBlood(hd.shipDesc.blood, hd.shipDesc.blood);
						hd.visible = true;
					}
				}
			}
		}
		
		private var _directions:Vector.<Vec2> = new Vector.<Vec2>;
		private var _times:Vector.<int> = new Vector.<int>;
		private var _startTimeOffset:int;
		private function onFrameIn(event:Event):void
		{
			LHelp.RecordTime();
			for(var i:int = 0; i < _mapBlocks.length; i++)
			{
				_mapBlocks[i].update(Test2.ELAPSED);
			}
			if(_mcAnchor.visible)
			{
				_mcAnchor.update(Test2.ELAPSED);
			}
			
			for(i = 0; i < _pdIndex; i++)
			{
				var mybody:MyBody = _vpaodans[i];
				if(mybody.aniBmp.parent)
					mybody.aniBmp.update(Test2.ELAPSED);
			}
			
			_ship.update(Test2.ELAPSED);
			
			for(i = 0; i < _veffects.length; i++)
			{
				var ae:AnimationBmp = _veffects[i];
				if(ae.parent)
				{
					if(!ae.isPlaying())
					{
						if(ae.parent)
						{
							ae.parent.removeChild(ae);
							_effectIndex--;
						}
					}
					else
					{
						ae.update(Test2.ELAPSED);
					}
				}
			}
			
			for(i = 0; i < _veffect2s.length; i++)
			{
				ae = _veffect2s[i];
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
			
			for(var hd:BodyPlayer in _frozens)
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
							if(LHelp.pointInRound(x0,y0,x1,y1,_frozenRadius + 15))
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
					var hd1:BodyPlayer = _hds[i];
					if(hd1.visible && hd1.curBlood > 0)
					{
						var y1:Number = _xuanwofengbao.y, x1:Number = _xuanwofengbao.x, x0:Number = hd1.x, y0:Number = hd1.y;
						if(LHelp.pointInRound(x0,y0,x1,y1,XUANWO_RADIUS))
						{
							var harm:int =  _xuanwoHarm * Test2.ELAPSED;
							hd1.setBlood(hd1.curBlood - harm, hd1.maxBlood);
							if(!_xuanwoHarmsDic[hd1])_xuanwoHarmsDic[hd1]=0;
							_xuanwoHarmsDic[hd1] += harm;
							if(hd1.curBlood <= 0)
							{
								playText(hd1.x,hd1.y-20,"-"+_xuanwoHarmsDic[hd1],RED_FORMAT);
								delete _xuanwoHarmsDic[hd1];
							}
						}
					}
				}
				_xuanwofengbao.update(Test2.ELAPSED);
			}
			
			if(_isPaused)
			{
				return;
			}
			
			addHaiDao();
			var nearstHds:Vector.<BodyPlayer> = new Vector.<BodyPlayer>;
			var minDises:Vector.<int> = new Vector.<int>;
			var  nearstHd:BodyPlayer, minDis:int = int.MAX_VALUE;
			for(i = 0 ; i < _hds.length; i++)
			{
				hd = _hds[i];
				if(!hd.visible || shipDropping(hd))
				{
					continue;
				}
				var collsinShip:Boolean = hd.collsin(_ship);
				var pds:Array = _hd2pd[hd];
				if(pds)
				{
					for(j = 0; j < pds.length; j++) 
					{
						var pd:MyBody = pds[j];
						var isExpotion:Boolean = hd.collsin(pd) || collsinShip;
						if(isExpotion)
						{
							if(_effectIndex < _veffects.length)
							{
								var effect:AnimationBmp = _veffects[_effectIndex++];
								effect.x = (pd.animation.x - hd.x) * Math.random() * .5;
								effect.y = (pd.animation.y - hd.y) * Math.random() * .5;
								effect.play(EnumAction.EFFECT);
								hd.addChild(effect);
							}	
							hd.setBlood(hd.curBlood - pd.paodanDesc.hurt * _pd2Discont[pd], hd.maxBlood);
							playText(hd.x, hd.y - 20, "-" + (pd.paodanDesc.hurt * _pd2Discont[pd]), RED_FORMAT);
							removeChild(pd.animation);
							_pdIndex--;
							pds.splice(j,1);
							j--;
						}
						else
						{
							motion = Vec2.get(hd.x - pd.animation.x, hd.y - pd.animation.y).normalise();
							pd.animation.rotation = rad2deg(motion.angle);
							motion.muleq(PAODAN_SPEED * Test2.ELAPSED);
							pd.animation.x += motion.x;
							pd.animation.y += motion.y;
							motion.dispose();
						}
					}
				}
				
				if(hd.curBlood <= 0)
				{
					if((!pds || pds.length <= 0) && !_isLianSheing)
					{
						dropShip(hd);
					}
				}
				else
				{
					if(collsinShip && !_isLianSheing)
					{
						rabberShip(hd);
					}
					else
					{
						motion = Vec2.get(_ship.x - hd.x, _ship.y - hd.y);
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
							motion.normalise().muleq(hd.shipDesc.speed * Test2.ELAPSED);
							hd.x += motion.x;
							hd.y += motion.y;
							hd.setRadius(motion.angle);
							motion.dispose();
							hd.update(Test2.ELAPSED);
						}
					}
				}
			}
			
			for(i = 0; i < minDises.length; i++)
			{
				for(j = i + 1; j < minDises.length; j++)
				{
					if(minDises[i] > minDises[j])
					{
						var t1:int = minDises[i];
						minDises[i] = minDises[j];
						minDises[j] = t1;
						var t2:BodyPlayer = nearstHds[i];
						nearstHds[i] = nearstHds[j];
						nearstHds[j] = t2;
					}
				}
			}
			
			fire(nearstHds, nearstHd);
			
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
					motion = _directions[0].mul(_ship.shipDesc.speed * _times[0]);
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
						var hdt:BodyPlayer = _arranges[i];
						_arranges[i] = _arranges[j];
						_arranges[j] = hdt;
					}
				}
			}
			LHelp.PrintTime("frame:");
		}
		
		private var _veffect2s:Vector.<AnimationBmp> = new Vector.<AnimationBmp>;
		private var _effect2Index:int;
		private function rabberShip(hd:BodyPlayer):void
		{
			var md:HaiDaoGroupMemDesc = _groupDesc.getMemById(hd.bodyDesc.id);
			var mpgr:MainPlayerGoldReq = new MainPlayerGoldReq;
			mpgr.addtion = Buffer.mainPlayer.gold > -md.lost? md.lost : -Buffer.mainPlayer.gold;
			MySignals.Socket_Send.dispatch(mpgr);
			playText(_ship.x,_ship.y, mpgr.addtion.toString(), YELLOW_FORMAT);
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
		private var _selectSkill:SkillDesc;
		private var _remainMills:int;
		private var _greenText:TextField;
		private function fire(nearestHds:Vector.<BodyPlayer>, nearestHd:BodyPlayer):void
		{
			_shootTimer += Test2.ELAPSED;
			_remainMills -= Test2.ELAPSED;
			if(_selectSkill)
			{
				_ship.setBlood(_remainMills, _selectSkill.wait * 1000, Color.GREEN);
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
					_ship.clearBlood();
					_ship.removeChild(_greenText);
					return;
				}
			}
			else
			{
				var rand:Number = Math.random();
				for each(var sd:SkillDesc in _skills)
				{
					rand -= sd.weight;
					if(rand < 0) 
					{
						_selectSkill = sd;
						_remainMills = sd.wait * 1000;
						_greenText.text = sd.name;
						_greenText.y = -_ship.shipDesc.raidus * 2.5;
						_greenText.x = _greenText.width * -.5;
						_ship.addChild(_greenText);
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
		private function bingheshiji(_selectSkill:SkillDesc):void
		{
			_frozenRadius = _selectSkill.extra;
			_bingheshiji.scaleX =  _frozenRadius / 162;
			_bingheshiji.scaleY =  _frozenRadius / 162;
			_bingheshiji.x = _ship.x;
			_bingheshiji.y = _ship.y;
			addChildAt(_bingheshiji, getChildIndex(_arranges[0]));
			_bingheshiji.play(EnumAction.EFFECT);
		}
		
		private var _xuanwofengbao:AnimationBmp = StaticTable.GetAniBmpByName("xuanwofengbao");
		private var _xuanwoHarm:Number, _xuanwoHarmsDic:Dictionary = new Dictionary;
		private const XUANWO_RADIUS:Number = 200,XUANWO_TIME:Number = 2;
		private function xuanwofengbao(_selectSkill:SkillDesc):void
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
			for(var hd:BodyPlayer in _xuanwoHarmsDic)
			{
				playText(hd.x,hd.y-20,"-"+_xuanwoHarmsDic[hd],RED_FORMAT);
				delete _xuanwoHarmsDic[hd];
			}
		}
		
		private var _bosaidong:AnimationPlayer = StaticTable.GetAniPlayerByName("bosaidong");
		private const BOSAIDONG_DIS:Number = 70;
		private function bosaidong(neasthd:BodyPlayer, sd:SkillDesc):void
		{
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
				var hd1:BodyPlayer = _hds[i];
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
		private var _pdIndex:int;
		private var _veffects:Vector.<AnimationBmp> = new Vector.<AnimationBmp>;
		private var _effectIndex:int;
		private var _hd2pd:Dictionary = new Dictionary;
		private var _pd2Discont:Dictionary = new Dictionary;
		private var _isLianSheing:Boolean = false;
		private function shootPaoDan(hd:BodyPlayer, discont:Number= 1, isLs:Boolean = false):void
		{
			_isLianSheing = isLs;
			var pd:MyBody = _vpaodans[_pdIndex++];
			pd.animation.x = _ship.x;
			pd.animation.y = _ship.y;
			if(!_hd2pd[hd])_hd2pd[hd]=[];
			_hd2pd[hd].push(pd);
			_pd2Discont[pd] = discont;
			addChild(pd.animation);
		}
		
		private function liansePaoDan(hd:BodyPlayer, sd:SkillDesc):void
		{
			var count:int = sd.extra;
			var tm:Number = 0.1;
			shootPaoDan(hd, 1, true);
			for(var i:int = 1; i < count; i++)
			{
				TweenLite.delayedCall(i * tm, shootPaoDan, [hd, 1, i < count - 1]);
			}
		}
		
		private function sansePaoDan(hds:Vector.<BodyPlayer>, sd:SkillDesc):void
		{
			var count:int = sd.extra;
			for(var i:int = 0; i < hds.length && i < count; i++)
			{
				shootPaoDan(hds[i]);
			}
		}
		
		private const RED_FORMAT:TextFormat = new TextFormat(null, 24, Color.RED,true);
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
			TweenLite.to(tf, 0.65, {y:tf.y - 70, onComplete:returnTf, onCompleteParams:[tf], ease:Linear.easeNone});
		}
		
		private function returnTf(tf:TextField):void
		{
			_tp.pushBack(tf);
			tf.parent.removeChild(tf);
		}
		
		private function dropShip(hd:BodyPlayer):void
		{
			var md:HaiDaoGroupMemDesc = _groupDesc.getMemById(hd.bodyDesc.id);
			var mpgr:MainPlayerGoldReq = new MainPlayerGoldReq;
			mpgr.addtion = md.cost;
			MySignals.Socket_Send.dispatch(mpgr);
			playText(hd.x,hd.y,"+" + md.cost, YELLOW_FORMAT);
			TweenLite.to(hd,1,{alpha:0, onComplete:onShipDroped, onCompleteParams:[hd]});
		}
		
		private function onShipDroped(hd:BodyPlayer):void
		{
			hd.alpha = 1;
			hd.visible=false;
		}
		
		private function shipDropping(hd:BodyPlayer):Boolean
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
			for(var i:int = 0; i < _terrain.length; i++)
			{
				var cols:Array = _terrain[i];
				for(var j:int = 0; j < cols.length; j++)
				{
					var bmpName:String = cols[j];
					var block:Bitmap = StaticTable.GetAniBmpByName(bmpName);
					block.x = j * _mapDesc.blockWidth;
					block.y = i * _mapDesc.blockHeight;
					addChild(block);
					_mapBlocks.push(block);
				}
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
		
		protected override function destoryed():void
		{
			for(var i:int = 0; i < _terrain.length; i++)
			{
				var cols:Array = _terrain[i];
				for(var j:int = 0; j < cols.length; j++)
				{
					var bmpName:String = cols[i];
					StaticTable.DestoryBmp(bmpName);
				}
			}
		}
	}
}