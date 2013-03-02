package view.gangkou
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.urbansquall.ginger.AnimationPlayer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import as3isolib.display.IsoSprite;
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.graphics.Stroke;
	
	import bit101.AStar;
	import bit101.Grid;
	import bit101.Node;
	
	import data.StaticTable;
	
	import eDpLib.events.ProxyEvent;
	
	import utils.LHelp;
	import utils.LazySprite;
	
	public class GangKouView extends LazySprite
	{
		private static const CELL_SIZE:int = 30;
		protected var pathGrid:Grid;
		
		public function GangKouView()
		{
			makeGrid();
			addEventListener(Event.ENTER_FRAME, onRender, false, 0, true);
		}
		
		protected function makeGrid():void
		{
			pathGrid = new Grid(10, 10);
			for(var i:int = 0; i < 20; i++)
			{
				pathGrid.setWalkable(Math.floor(Math.random() * 8) + 2,
					Math.floor(Math.random() * 8)+ 2,
					false);
			}
			drawGrid();
		}
		
		protected var playerBox:IsoBox;
		protected var isoView:IsoView;
		protected var isoScene:IsoScene;
		private var _playerSprite:IsoSprite;
		private var _role:AnimationPlayer;
		
		protected function drawGrid():void
		{
			isoScene = new IsoScene();
			
			for(var i:int = 0; i < pathGrid.numCols; i++)
			{
				for(var j:int = 0; j < pathGrid.numRows; j++)
				{
					var node:Node = pathGrid.getNode(i, j);
					var box:IsoBox = new IsoBox();
					
					if (node.walkable)
					{
						box.setSize(CELL_SIZE, CELL_SIZE, 0);
						box.addEventListener(MouseEvent.CLICK, onGridItemClick);
					}
					else
					{
						box.setSize(CELL_SIZE, CELL_SIZE, CELL_SIZE * 0.5);
						box.stroke = new Stroke(1,0xff0000);
					}
					
					box.moveTo(i * CELL_SIZE, j * CELL_SIZE, 0);
					isoScene.addChild(box);
				}
			}
			
			playerBox = new IsoBox();
			playerBox.stroke = new Stroke(1,0xffff00);
			playerBox.setSize(CELL_SIZE, CELL_SIZE, 1);
			isoScene.addChild(playerBox);
			
			_role = StaticTable.GetRoleAniPlayer(1);
			_playerSprite = new IsoSprite;
			_playerSprite.sprites = [_role];
			_playerSprite.z =  _role.height - 2*CELL_SIZE;
			isoScene.addChild(_playerSprite);
			
			isoView = new IsoView();
			isoView.setSize(StaticTable.STAGE_WIDTH, StaticTable.STAGE_HEIGHT);
			isoView.addScene(isoScene);
			addChild(isoView);
		}
		
		protected function onGridItemClick(evt:ProxyEvent):void 
		{
			var box:IsoBox = evt.target as IsoBox;
			
			var xpos:int = (box.x)/CELL_SIZE
			var ypos:int = Math.floor(box.y / CELL_SIZE)
			pathGrid.setEndNode(xpos,ypos);
			
			xpos = Math.floor(playerBox.x / CELL_SIZE);
			ypos = Math.floor(playerBox.y / CELL_SIZE);
			pathGrid.setStartNode(xpos, ypos);

			findPath();
		}
		
		private var path:Array;
		private var tl:TimelineLite;
		protected function findPath():void
		{
			var astar:AStar = new AStar();
			if(astar.findPath(pathGrid))
			{
				path = astar.path;
			}
			else
			{
				path = null;
			}
			if(tl)
			{
				tl.stop();
			}
			if(path && path.length > 0)
			{
				tl = new TimelineLite;
				for (var i:int = 0; i < path.length; i++)
				{
					var speed:Number = .3;
					var targetX:Number = path[i].x * CELL_SIZE;
					var targetY:Number = path[i].y * CELL_SIZE;
					if(i > 0)
					{
						speed *= LHelp.distance(path[i].x, path[i].y, path[i - 1].x, path[i - 1].y);
					}
					tl.append(new TweenLite(playerBox, speed, {x:targetX, y:targetY, ease:Linear.easeNone}));
				}
				tl.play();
			}
		}
		
		protected function onRender(event:Event):void
		{
			isoScene.render();
			_role.update(Test2.ELAPSED);
			_playerSprite.x = playerBox.x;
			_playerSprite.y = playerBox.y;
			isoScene.setChildIndex(_playerSprite, isoScene.getChildIndex(playerBox) + 1);
		}
	}
}