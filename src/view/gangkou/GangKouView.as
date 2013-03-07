package view.gangkou
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import bit101.AStar;
	import bit101.Grid;
	
	import data.Buffer;
	import data.StaticTable;
	import data.staticObj.MapCityDesc;
	import data.staticObj.MapDesc;
	
	import lsg.gangkou.McAnchor;
	import lsg.gangkou.McEntry;
	
	import message.EnumAction;
	
	import nape.geom.Vec2;
	
	import utils.BodyPlayer;
	import utils.LHelp;
	import utils.LazySprite;
	
	import view.city.CityView;
	
	public class GangKouView extends LazySprite
	{
		private var _mcDesc:MapCityDesc;
		private var _mapDesc:MapDesc;
		
		private var _terrain:Array;
		private var _pathGrid:Grid;
		private static const GRID_SIZE:int = 16;
		
		private var _ship:BodyPlayer;
		
		public function GangKouView()
		{
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
			
			_ship = StaticTable.GetShipBodyPlayer(Buffer.mainPlayer.curShip);
			setShipXY(_mcDesc.outX, _mcDesc.outY);
			addChild(_ship);
			
			drawCitys();
			focusMap(_ship.x, _ship.y);
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private var _mcAnchor:McAnchor;
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
					if(!_mcAnchor)
					{
						_mcAnchor = new McAnchor;
						addChildAt(_mcAnchor, getChildIndex(_ship));
					}
					_mcAnchor.x = e.stageX - x;
					_mcAnchor.y = e.stageY - y;
					_mcAnchor.visible = true;
					
					_pathGrid.setEndNode(ex,ey);
					_pathGrid.setStartNode(sx,sy);
					var astar:AStar = new AStar();
					astar.findPath(_pathGrid);
					
					var path:Array = astar.path;
					_directions = new Vector.<Vec2>;
					_times = new Vector.<int>;
					for (var i:int = 1; i < path.length; i++)
					{
						if(i==0)
						{
							direction = new Vec2(path[i].x * GRID_SIZE + GRID_SIZE / 2 - _ship.x, path[i].y * GRID_SIZE + GRID_SIZE / 2 - _ship.y);
						}
						else if(i < path.length - 1)
						{
							var direction:Vec2 = new Vec2((path[i].x - path[i - 1].x)*GRID_SIZE, (path[i].y - path[i - 1].y)*GRID_SIZE);
						}
						else
						{
							direction = new Vec2((e.stageX - x)  - (path[i - 1].x*GRID_SIZE + GRID_SIZE / 2), (e.stageY - y) - (path[i - 1].y*GRID_SIZE + GRID_SIZE / 2));
						}
						_times.push(direction.length / SHIP_SPEED);
						_directions.push(direction.normalise());
					}
					_startTimeOffset = getTimer() - Test2.TIMESTAMP;
				}
			}
		}
		
		private function onShipMoveFinished():void
		{
			for(var i:int = 0; i < _mapDesc.citys.length; i++)
			{
				var mcDesc:MapCityDesc = _mapDesc.citys[i];
				if(LHelp.pointInRound(_mcAnchor.x, _mcAnchor.y, mcDesc.entryX, mcDesc.entryY, GRID_SIZE))
				{
					MidLayer.CloseWindow(GangKouView);
					MidLayer.ShowWindowObj(CityView, {params:[mcDesc.id]});
				}
			}
			_mcAnchor.visible = false;
		}
		
		private var _hds:Vector.<BodyPlayer> = new Vector.<BodyPlayer>;
		private function addHaiDao():void
		{
			for(var i:int = 0; i < 10 && _hds.length < 10; i++)
			{
				var hx:int = Math.random() * _mapDesc.width;
				var hy:int = Math.random() * _mapDesc.height;
				if(_pathGrid.getNode(hx/GRID_SIZE,hy/GRID_SIZE).walkable)
				{
					if(!LHelp.pointInRect(hx,hy,_ship.x,_ship.y, StaticTable.STAGE_WIDTH/2, StaticTable.STAGE_HEIGHT/2))
					{
						var hd:BodyPlayer = StaticTable.GetShipBodyPlayer(2);
						hd.x = hx;
						hd.y = hy;
						var minY:int = int.MAX_VALUE;
						var minTarget:BodyPlayer = null;
						for(var j:int = 0; j < _hds.length; j++)
						{
							if(_hds[j].y > hy && _hds[j].y - hy < minY)
							{
								minY = _hds[j].y - hy;
								minTarget = _hds[j];
							}
						}
						if(minTarget)
						{
							addChildAt(hd, getChildIndex(minTarget));
						}
						else
						{
							addChild(hd);
						}
						_hds.push(hd);
					}
				}
			}
		}
		
		private var _directions:Vector.<Vec2>;
		private var _times:Vector.<int>;
		private var _startTimeOffset:int;
		private static const SHIP_SPEED:Number = 60 / 1000;
		
		private function onFrameIn(event:Event):void
		{
			if(_hds.length < 10) 
			{
				addHaiDao();
			}
			for(var i:int = 0 ; i < _hds.length; i++)
			{
				var hd:BodyPlayer = _hds[i];
				distance = Vec2.get(_ship.x - hd.x, _ship.y - hd.y).normalise().muleq(SHIP_SPEED * Test2.ELAPSED);
				hd.x += distance.x;
				hd.y += distance.y;
				hd.setRadius(distance.angle);
				if(hd.collsin(_ship))
				{
					removeChild(hd);
					_hds.splice(i,1);
					i--;
				}
				distance.dispose();
			}
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
					var distance:Vec2 = _directions[0].mul(SHIP_SPEED * elapsed);
					_ship.x += distance.x;
					_ship.y += distance.y;
					distance.dispose();
				}
				else
				{
					elapsed -= _times[0];
					distance = _directions[0].mul(SHIP_SPEED * _times[0]);
					_ship.x += distance.x;
					_ship.y += distance.y;
					distance.dispose();
					_directions.shift();
					_times.shift();
					if(elapsed && _directions.length > 0)
					{
						_times[0] -= elapsed;
						distance = _directions[0].mul(SHIP_SPEED * elapsed);
						_ship.x += distance.x;
						_ship.y += distance.y;
						distance.dispose();
						if(_times[0] <= 0)
						{
							_directions.shift();
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
			_ship.update(Test2.ELAPSED);
		}
		
		private function setShipXY(sx:Number, sy:Number):void
		{
			_ship.x = sx;
			_ship.y = sy;
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
		
		private function drawMap():void
		{
			for(var i:int = 0; i < _terrain.length; i++)
			{
				var cols:Array = _terrain[i];
				for(var j:int = 0; j < cols.length; j++)
				{
					var bmpName:String = cols[j];
					var bmp:Bitmap = StaticTable.GetBmp(bmpName);
					bmp.x = j * _mapDesc.blockWidth;
					bmp.y = i * _mapDesc.blockHeight;
					addChild(bmp);
				}
			}
			
			for(i = 0; i < _mapDesc.citys.length; i++)
			{
				var mcDesc:MapCityDesc = _mapDesc.citys[i];
				var mcEntry:McEntry = new McEntry;
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