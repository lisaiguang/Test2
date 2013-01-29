package data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import data.obj.BulletDesc;
	import data.obj.RoleDesc;
	
	import lsg.bullet.Icon1;
	import lsg.bullet.b1;
	import lsg.bullet.clear1;
	import lsg.map.bg1;
	import lsg.map.preview1;
	import lsg.role.r1;
	import lsg.role.r2;
	
	import utils.McSprite;

	public class StaticTable
	{
		public static var STAGE_WIDTH:int  = 960;
		public static var STAGE_HEIGHT:int = 640;
		
		[Embed(source = "../../assets/config/bullet.xml", mimeType="application/octet-stream")]
		private static var bulletConfig:Class;
		
		[Embed(source = "../../assets/config/role.xml", mimeType="application/octet-stream")]
		private static var RoleConfig:Class;
		
		public static function Init():void
		{
			var bulletsXml:XML = new XML(new bulletConfig);
			for(var i:int = 0; i < bulletsXml.b.length(); i++)
			{
				var bulletXML:XML = bulletsXml.b[i];
				var bs:BulletDesc = new BulletDesc;
				bs.id = int(bulletXML.@id);
				bs.boundWidth = int(bulletXML.@boundWidth);
				bs.boundHeight = int(bulletXML.@boundHeight);
				bs.mass = int(bulletXML.@mass);
				
				var clearParams:Array = String(bulletXML.@clear).split(",");
				for each(var param:* in clearParams)
				{
					bs.clearParams.push(int(param));
				}
				StaticTable.BULLET_DESC.push(bs);
			}
			bulletConfig = null;
			
			var rolesXml:XML = new XML(new RoleConfig);
			for(i = 0; i < rolesXml.r.length(); i++)
			{
				var roleXML:XML = rolesXml.r[i];
				var rs:RoleDesc = new RoleDesc;
				rs.id = int(roleXML.@id);
				rs.boundWidth = int(roleXML.@boundWidth);
				rs.boundHeight = int(roleXML.@boundHeight);
				StaticTable.ROLE_DESC.push(rs);
			}
			RoleConfig = null;
		}
		
		public static var ROLE_DESC:Vector.<RoleDesc> = new Vector.<RoleDesc>;
		
		public static function GetRoleDesc(id:int):RoleDesc
		{
			for each(var bs:RoleDesc in ROLE_DESC)
			{
				if(bs.id == id)return bs;
			}
			return null;
		}
		
		public static var BULLET_DESC:Vector.<BulletDesc> = new Vector.<BulletDesc>;
		
		public static function GetBulletDesc(id:int):BulletDesc
		{
			for each(var bs:BulletDesc in BULLET_DESC)
			{
				if(bs.id == id)return bs;
			}
			return null;
		}
		
		public static function GetMapBmd(id:int):BitmapData
		{
			var bd:BitmapData = new bg1;
			return bd;
		}
		
		public static function GetMapPreview(id:int):BitmapData
		{
			var bd:BitmapData = new preview1;
			return bd;
		}
		
		public static function GetBulletIcon(bid:int):BitmapData
		{
			var bd:BitmapData = new Icon1;
			return bd;
		}
		
		public static function GetRoleMcSprite(role:int):McSprite
		{
			var bd:BitmapData = new [r1, r2][role - 1]();
			var bmp:Bitmap = new Bitmap(bd);
			bmp.x = -bmp.width*0.5;
			bmp.y = -bmp.height*0.5;
			var mcBmp:McSprite = new McSprite;
			mcBmp.addChild(bmp);
			return mcBmp;
		}
		
		public static function GetBulletMcSprite(id:int):McSprite
		{
			var bd:BitmapData = new [b1][id - 1]();
			var bmp:Bitmap = new Bitmap(bd);
			bmp.x = -bmp.width*0.5;
			bmp.y = -bmp.height*0.5;
			var mcBmp:McSprite = new McSprite;
			mcBmp.addChild(bmp);
			return mcBmp;
		}
		
		private static var clearDic:Dictionary = new Dictionary;
		public static function GetBulletClear(id:int):Sprite
		{
			var bomb:Sprite  = clearDic[id];
			
			if(!bomb)
			{
				var _bs:BulletDesc = GetBulletDesc(id);
				bomb = new Sprite;
				bomb.graphics.beginFill(0xffffff, 1);
				if(_bs.clearParams[0] == BulletDesc.CLEAR_CIRCLE)
					bomb.graphics.drawCircle(0, 0, _bs.clearParams[1]);
				else if(_bs.clearParams[0] == BulletDesc.CLEAR_RECT)
					bomb.graphics.drawRect(0,0,_bs.clearParams[1],_bs.clearParams[2]);
				bomb.graphics.endFill();
				clearDic[id] =bomb;
			}
			
			return bomb;
		}
	}
}