package data
{
	import com.urbansquall.ginger.Animation;
	import com.urbansquall.ginger.AnimationPlayer;
	import com.urbansquall.ginger.tools.AnimationBuilder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import data.staticObj.BulletDesc;
	import data.staticObj.DaoJuDesc;
	import data.staticObj.RoleDesc;
	
	import lsg.DaojuIcon1;
	import lsg.DaojuIcon2;
	import lsg.DaojuIcon3;
	import lsg.DaojuIcon4;
	import lsg.bullet.Icon1;
	import lsg.bullet.Icon2;
	import lsg.bullet.Icon3;
	import lsg.bullet.Icon4;
	import lsg.bullet.b1;
	import lsg.bullet.b2;
	import lsg.map.bg1;
	import lsg.map.preview1;
	import lsg.role.r1;
	
	import message.EnumAction;
	
	import utils.McSprite;

	public class StaticTable
	{
		public static var STAGE_WIDTH:int  = 960;
		public static var STAGE_HEIGHT:int = 640;
		
		[Embed(source = "../../assets/config/bullet.xml", mimeType="application/octet-stream")]
		private static var bulletConfig:Class;
		
		[Embed(source = "../../assets/config/role.xml", mimeType="application/octet-stream")]
		private static var RoleConfig:Class;
		
		[Embed(source = "../../assets/config/daoju.xml", mimeType="application/octet-stream")]
		private static var DaoJuConfig:Class;
		
		[Embed(source = "../../assets/config/error.xml", mimeType="application/octet-stream")]
		private static var ErrorConfig:Class;
		
		public static function Init():void
		{
			var bulletsXml:XML = new XML(new bulletConfig);
			for(var i:int = 0; i < bulletsXml.b.length(); i++)
			{
				var bulletXML:XML = bulletsXml.b[i];
				var bs:BulletDesc = new BulletDesc;
				bs.id = int(bulletXML.@id);
				bs.bulletId = int(bulletXML.@bulletId);
				bs.shootType = int(bulletXML.@shootType);
				bs.hurt = int(bulletXML.@hurt);
				bs.boundWidth = int(bulletXML.@width);
				bs.boundHeight = int(bulletXML.@height);
				bs.mass = int(bulletXML.@mass);
				bs.name = bulletXML.@name;
				bs.desc = bulletXML.@desc;
				bs.sold = int(bulletXML.@sold);
				
				var clearParams:Array = String(bulletXML.@clear).split(",");
				for each(var param:* in clearParams)
				{
					bs.clearParams.push(int(param));
				}
				StaticTable.BULLET_DESC.push(bs);
				
				var bomb:Sprite = new Sprite;
				bomb.graphics.beginFill(0xffffff, 1);
				if(bs.clearParams[0] == BulletDesc.CLEAR_CIRCLE)
					bomb.graphics.drawCircle(0, 0, bs.clearParams[1]);
				else if(bs.clearParams[0] == BulletDesc.CLEAR_RECT)
					bomb.graphics.drawRect(0,0,bs.clearParams[1],bs.clearParams[2]);
				bomb.graphics.endFill();
				clearDic[bs.id] =bomb;
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
				rs.IQ = int(roleXML.@IQ);
				StaticTable.ROLE_DESC.push(rs);
			}
			RoleConfig = null;
			
			var xml:XML = new XML(new DaoJuConfig);
			for(i = 0; i < xml.d.length(); i++)
			{
				var dx:XML = xml.d[i];
				var ds:DaoJuDesc = new DaoJuDesc;
				ds.itemId = int(dx.@itemId);
				ds.type = int(dx.@type);
				ds.level = int(dx.@level);
				ds.name = dx.@name;
				ds.desc = dx.@desc;
				ds.sold = int(dx.@sold);
				StaticTable.DAOJU_DESC.push(ds);
			}
			DaoJuConfig = null;
			
			xml = new XML(new ErrorConfig);
			for(i = 0; i < xml.e.length(); i++)
			{
				var ex:XML = xml.e[i];
				ERROR_DIC[int(ex.@id)] = ex.@str;
			}
			ErrorConfig = null;
		}
		
		public static function GetPaoDanIdByHeCheng(hy:int, js:int, tz:int, bs:int = 0):int
		{
			var id:int;
			
			return id;
		}
		public static var ERROR_DIC:Dictionary = new Dictionary;
		public static var DAOJU_DESC:Vector.<DaoJuDesc> = new Vector.<DaoJuDesc>;
		public static function GetDaoJuDesc(itemId:int):DaoJuDesc
		{
			for each(var bs:DaoJuDesc in DAOJU_DESC)
			{
				if(bs.itemId == itemId)return bs;
			}
			return null;
		}
		
		public static function GetDaoJuIcon(itemId:int):Bitmap
		{
			switch(itemId)
			{
				case 1:
					var bd:BitmapData = BitmapDataPool.getBitmapData(DaojuIcon1);
					break;
				case 2:
					bd = BitmapDataPool.getBitmapData(DaojuIcon2);
					break;
				case 3:
					bd = BitmapDataPool.getBitmapData(DaojuIcon3);
					break;
				case 4:
					bd = BitmapDataPool.getBitmapData(DaojuIcon4);
					break;
				
			}
			var bmp:Bitmap = new Bitmap(bd);
			return bmp;
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
		
		public static function GetBulletIcon(bid:int):Bitmap
		{
			switch(bid)
			{
				case 1:
					var bd:BitmapData = BitmapDataPool.getBitmapData(Icon1);
					break;
				case 2:
					bd = BitmapDataPool.getBitmapData(Icon2);
					break;
				case 3:
					bd = BitmapDataPool.getBitmapData(Icon3);
					break;
				case 4:
					bd = BitmapDataPool.getBitmapData(Icon4);
					break;
					
			}
			var bmp:Bitmap = new Bitmap(bd);
			return bmp;
		}
		
		public static function GetBulletMcSprite(id:int):McSprite
		{
			switch(id)
			{
				case 1:
				{
					var bd:BitmapData = new b1;
					break;
				}
				case 2:
				{
					bd = new b2;
					break;
				}
			}
			var bmp:Bitmap = new Bitmap(bd);
			bmp.x = -bmp.width*0.5;
			bmp.y = -bmp.height*0.5;
			var mcBmp:McSprite = new McSprite;
			mcBmp.addChild(bmp);
			return mcBmp;
		}
		
		public static function GetRoleAniPlayer(role:int):AnimationPlayer
		{
			var bd:BitmapData = new r1;
			var ap:AnimationPlayer = new AnimationPlayer();
			
			animation = AnimationBuilder.importStrip(12, bd, 32, 64, 4, 0, 64, 1, -16, -32);
			animation.isLooping = true;
			ap.addAnimation(EnumAction.ROLE_WAITING, animation);
			
			var animation:Animation = AnimationBuilder.importStrip( 12, bd, 32, 64, 4, 0, 0, 1, -16, -32);
			animation.isLooping = true;
			ap.addAnimation(EnumAction.ROLE_MOVING,  animation);
			
			return ap;
		}
		
		private static var clearDic:Dictionary = new Dictionary;
		public static function GetBulletClear(id:int):Sprite
		{
			return clearDic[id];
		}
	}
}