package phys
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import nape.callbacks.CbType;
	import nape.geom.AABB;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.IsoFunction;
	import nape.geom.MarchingSquares;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	public class Terrain
	{
		public var GRAND:CbType = new CbType;
		public var bd:BitmapData;
		
		private var bounds:AABB;
		private var cells:Vector.<Body>;
		private var cellsize:Number;
		private var subsize:Number;
		private var cWidth:int;
		private var cHeight:int;
		private var offset:Vec2;
		private var space:Space;
		private var bitmapIso:IsoFunction;
		
		public function Terrain(space:Space, bd:BitmapData, offset:Vec2, cellsize:Number, subsize:Number):void
		{
			this.space = space;
			this.bd = bd;
			this.offset = offset;
			this.cellsize = cellsize;
			this.subsize = subsize;
			
			this.cWidth = int(Math.ceil(bd.width/cellsize));
			this.cHeight = int(Math.ceil(bd.height/cellsize));
			
			cells = new Vector.<Body>();
			for(var i:int = 0; i<cWidth*cHeight; i++) cells.push(null);
			
			bounds = new AABB(0,0,cellsize,cellsize); 
			bitmapIso = new BitmapIsoFunction(bd);
			invalidate(new AABB(0,0,bd.width,bd.height));
		}
		
		public function get position():Vec2
		{
			return offset;
		}
		
		public function invalidate(region:AABB):void
		{
			//compute effected cells
			var x0:int = int(region.min.x/cellsize); if(x0<0) x0 = 0;
			var y0:int = int(region.min.y/cellsize); if(y0<0) y0 = 0;
			var x1:int = int(region.max.x/cellsize); if(x1>= cWidth) x1 = cWidth-1;
			var y1:int = int(region.max.y/cellsize); if(y1>=cHeight) y1 = cHeight-1;
			
			for(var y:int = y0; y<=y1; y++)
			{
				for(var x:int = x0; x<=x1; x++)
				{
					var b:Body = cells[y*cWidth+x];
					if(b!=null) {
						//if cell body exists, clear it for re-use
						b.space = null;
						b.shapes.clear();
						b.position = offset;
					}
					
					//compute polygons in cell
					bounds.x = x*cellsize;
					bounds.y = y*cellsize;
					var polys:GeomPolyList = MarchingSquares.run(bitmapIso, bounds, Vec2.weak(subsize,subsize));
					if(polys.empty()) continue;
					
					if(b==null)
					{
						cells[y*cWidth+x] = b = new Body(BodyType.STATIC, offset);
						b.cbTypes.add(GRAND);
					}
					
					for (var i:int = 0; i < polys.length; i++) {
						var p:GeomPoly = polys.at(i);
						var qolys:GeomPolyList = p.convexDecomposition(true);
						
						for (var j:int = 0; j < qolys.length; j++) {
							var q:GeomPoly = qolys.at(j);
							b.shapes.add(new Polygon(q));
							q.dispose();
						}

						qolys.clear();
						p.dispose();
					}
					
					polys.clear();
					b.space = space;
				}
			}
		}
	}

}