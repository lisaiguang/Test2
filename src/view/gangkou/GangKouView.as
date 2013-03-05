package view.gangkou
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.urbansquall.ginger.AnimationPlayer;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import bit101.AStar;
	import bit101.Grid;
	
	import data.Buffer;
	import data.StaticTable;
	import data.staticObj.MapCityDesc;
	import data.staticObj.MapDesc;
	
	import lsg.gangkou.McAnchor;
	import lsg.gangkou.McEntry;
	
	import utils.LHelp;
	import utils.LazySprite;
	
	import view.city.CityView;
	
	public class GangKouView extends LazySprite
	{
		private var _ship:AnimationPlayer;
		private var _mcDesc:MapCityDesc;
		private var _mapDesc:MapDesc;
		
		private var _terrain:Array;
		private var _pathGrid:Grid;

		private static const GRID_SIZE:int = 16;
		
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
			
			_ship = StaticTable.GetShipAniPlayer(Buffer.mainPlayer.curShip);
			setShipXY(_mcDesc.outX, _mcDesc.outY);
			addChild(_ship);
			
			drawCitys();
			focusMap(_ship.x, _ship.y);
			addEventListener(Event.ENTER_FRAME, onFrameIn);
			addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private var _mcAnchor:McAnchor;
		private var tl:TimelineLite;
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
					
					if(tl)
					{
						tl.kill();
					}
					
					LHelp.RecordTime();
					
					_pathGrid.setEndNode(ex,ey);
					_pathGrid.setStartNode(sx,sy);
					var astar:AStar = new AStar();
					astar.findPath(_pathGrid);
					LHelp.PrintTime("find path:");
					
					var path:Array = astar.path;
					if(path && path.length > 0)
					{
						tl = new TimelineLite({onComplete:onShipMoveFinished});
						for (var i:int = 1; i < path.length; i++)
						{
							var speed:Number = .3;
							var targetX:Number = path[i].x * GRID_SIZE;
							var targetY:Number = path[i].y * GRID_SIZE;
							speed *= LHelp.distance(path[i].x, path[i].y, i > 0 ? path[i - 1].x : sx, i > 0 ? path[i - 1].y : sy);
							tl.append(new TweenLite(_ship, speed, {x:targetX, y:targetY, ease:Linear.easeNone}));
						}
						tl.play();
					}
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
		
		private function onFrameIn(event:Event):void
		{
			if(tl && tl.active)
			{
				focusMap(_ship.x, _ship.y);
			}
			_ship.update(Test2.ELAPSED);
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
		
		private function setShipXY(sx:Number, sy:Number):void
		{
			_ship.x = sx;
			_ship.y = sy;
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