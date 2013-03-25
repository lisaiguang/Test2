package data
{
	import com.urbansquall.ginger.Animation;
	import com.urbansquall.ginger.AnimationBmp;
	import com.urbansquall.ginger.AnimationPlayer;
	import com.urbansquall.ginger.tools.AnimationBuilder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import bit101.Grid;
	
	import data.staticObj.AnimationDesc;
	import data.staticObj.DaoJuDesc;
	import data.staticObj.EnumBodyType;
	import data.staticObj.HaiDaoGroupDesc;
	import data.staticObj.HaiDaoWaveDesc;
	import data.staticObj.HaiDaoWaveMemDesc;
	import data.staticObj.MapCityDesc;
	import data.staticObj.MapDesc;
	import data.staticObj.MapIslandDesc;
	import data.staticObj.PaoDanDesc;
	import data.staticObj.RoleBulletDesc;
	import data.staticObj.RoleDesc;
	import data.staticObj.ShenFuDesc;
	import data.staticObj.ShenJiangDesc;
	import data.staticObj.ShipDesc;
	import data.staticObj.TuZhiDesc;
	
	import lsg.DaojuIcon1;
	import lsg.DaojuIcon2;
	import lsg.DaojuIcon3;
	import lsg.DaojuIcon4;
	import lsg.bmp.anchor;
	import lsg.bmp.bullet1;
	import lsg.bmp.bullet2;
	import lsg.bmp.city1;
	import lsg.bmp.entry;
	import lsg.bmp.island1;
	import lsg.bmp.land1;
	import lsg.bmp.role1;
	import lsg.bmp.sea1;
	import lsg.bmp.seaGrid1;
	import lsg.bmp.seaGrid2;
	import lsg.bmp.ship1;
	import lsg.bmp.ship2;
	import lsg.bmp.ship3;
	import lsg.bmp.skill1;
	import lsg.bmp.skill10;
	import lsg.bmp.skill11;
	import lsg.bmp.skill2;
	import lsg.bmp.skill3;
	import lsg.bmp.skill4;
	import lsg.bmp.skill5;
	import lsg.bmp.skill6;
	import lsg.bmp.skill7;
	import lsg.bmp.skill8;
	import lsg.bmp.skill9;
	import lsg.bmp.target;
	import lsg.bullet.Icon1;
	import lsg.bullet.Icon2;
	import lsg.bullet.Icon3;
	import lsg.bullet.Icon4;
	import lsg.bullet.b1;
	import lsg.bullet.b2;
	import lsg.map.bg1;
	import lsg.map.preview1;
	import lsg.paodan.effect1;
	import lsg.paodan.effect2;
	import lsg.shenji.bingheshiji;
	import lsg.shenji.bosaidong;
	import lsg.shenji.xuanwofengbao;
	
	import message.EnumDaoJuType;
	
	import mybodys.PaoDanBody;
	import mybodys.ShenFuPlayer;
	import mybodys.ShipPlayer;
	
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
		
		[Embed(source = "../../assets/config/animation.xml", mimeType="application/octet-stream")]
		private static var AnimationConfig:Class;
		
		[Embed(source = "../../assets/config/seamap.xml", mimeType="application/octet-stream")]
		private static var SeamapConfig:Class;
		
		[Embed(source = "../../assets/config/body.xml", mimeType="application/octet-stream")]
		private static var BodyConfig:Class;
		
		[Embed(source = "../../assets/config/skill.xml", mimeType="application/octet-stream")]
		private static var SkillConfig:Class;
		
		public static function Init():void
		{
			var bulletsXml:XML = new XML(new bulletConfig);
			for(i = 0; i < bulletsXml.sb.length(); i++)
			{
				tzDes = new TuZhiDesc;
				tzDes.id 
			}
			for(var i:int = 0; i < bulletsXml.tz.length(); i++)
			{
				var tzXml:XML = bulletsXml.tz[i];
				var tzDes:TuZhiDesc = new TuZhiDesc;
				tzDes.id = int(tzXml.@id);
				tzDes.width = int(tzXml.@width);
				tzDes.height = int(tzXml.@height);
				tzDes.mass = int(tzXml.@mass);
				tzDes.name = tzXml.@name;
				TUZHI_DESC.push(tzDes);
				for(var j:int = 0; j < tzXml.b.length(); j++)
				{
					var bulletXML:XML = tzXml.b[j];
					var bs:RoleBulletDesc = new RoleBulletDesc;
					bs.id = int(bulletXML.@id);
					bs.tuzhi = tzDes;
					bs.baoshi = bulletXML.@bs?int(bulletXML.@bs):0;
					bs.hurt = int(bulletXML.@hurt);
					bs.sold = int(bulletXML.@sold);
					var clearParams:Array = String(bulletXML.@clear).split(",");					
					var bomb:Shape = new Shape;
					bomb.graphics.beginFill(0xffffff, 1);
					if(clearParams[0] == RoleBulletDesc.CLEAR_CIRCLE)
					{
						bs.range = clearParams[1] * clearParams[1] * Math.PI;
						bomb.graphics.drawCircle(0, 0, clearParams[1]);
					}
					else if(clearParams[0] == RoleBulletDesc.CLEAR_RECT)
					{
						bs.range = clearParams[1]  * clearParams[2];
						bomb.graphics.drawRect(0,0,clearParams[1],clearParams[2]);
					}
					bomb.graphics.endFill();
					bs.clearShape = bomb;
					StaticTable.BULLET_DESC.push(bs);
				}
				for(j = 0; j < tzXml.sb.length(); j++)
				{
					bulletXML = tzXml.sb[j];
					bs = new RoleBulletDesc;
					bs.tuzhi = tzDes;
					bs.baoshi = bulletXML.hasOwnProperty("@bs")?int(bulletXML.@bs):0;
					bs.id = int(bulletXML.@id);
					bs.desc = bulletXML.@desc;
					StaticTable.BULLET_DESC.push(bs);
				}
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
				ds.itemId = int(dx.@id);
				ds.type = int(dx.@type);
				if(ds.type == 1 || ds.type == 2)
				{
					ds.extra = int(dx.@level);
				}
				else if(ds.type == 3)
				{
					ds.extra = int(dx.@tz);
				}
				else
				{
					ds.extra = int(dx.@bs);
				}
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
			
			xml = new XML(new AnimationConfig);
			for(i = 0; i < xml.bmp.length(); i++)
			{
				var bmpXml:XML = xml.bmp[i];
				var animations:Array = [];
				BMPNAME2ANIDESCS[String(bmpXml.@name)] = animations;
				for(j=0;j<bmpXml.a.length();j++)
				{
					var aniXml:XML = bmpXml.a[j];
					var aniDesc:AnimationDesc = new AnimationDesc;
					aniDesc.name = aniXml.@name;
					aniDesc.width = Number(aniXml.@width);
					aniDesc.height = Number(aniXml.@height);
					aniDesc.startX = Number(aniXml.@startX);
					aniDesc.startY = Number(aniXml.@startY);
					aniDesc.count = int(aniXml.@count);
					aniDesc.fps = aniXml.hasOwnProperty("@fps")?int(aniXml.@fps):12;
					aniDesc.rotation = aniXml.hasOwnProperty("@rotation")?int(aniXml.@rotation):1;
					aniDesc.loop = aniXml.hasOwnProperty("@loop")?int(aniXml.@loop):true;
					aniDesc.offsetX = aniXml.hasOwnProperty("@offsetX")? Number(aniXml.@offsetX) : -aniDesc.width/2;
					aniDesc.offsetY = aniXml.hasOwnProperty("@offsetY")? Number(aniXml.@offsetY) : -aniDesc.height/2;
					animations.push(aniDesc);
					ANIMATION_DESC.push(aniDesc);
				}
			}
			AnimationConfig = null;
			
			xml = new XML(new SeamapConfig);
			for(i = 0; i < xml.map.length(); i++)
			{
				var mapXml:XML = xml.map[i];
				var mapDesc:MapDesc = new MapDesc;
				mapDesc.id = int(mapXml.@id);
				mapDesc.name = mapXml.@name;
				mapDesc.width = Number(mapXml.@width);
				mapDesc.height = Number(mapXml.@height);
				mapDesc.rows = Number(mapXml.@rows);
				mapDesc.cols = Number(mapXml.@cols);
				mapDesc.blockWidth = mapDesc.height / mapDesc.rows;
				mapDesc.blockHeight = mapDesc.width / mapDesc.cols;
				for(j=0;j<mapXml.city.length();j++)
				{
					var cityXml:XML = mapXml.city[j];
					var mcDesc:MapCityDesc = new MapCityDesc;
					mcDesc.id = int(cityXml.@id);
					mcDesc.posX = Number(cityXml.@posX);
					mcDesc.posY = Number(cityXml.@posY);
					mcDesc.entryX = Number(cityXml.@entryX);
					mcDesc.entryY = Number(cityXml.@entryY);
					mcDesc.outX = Number(cityXml.@outX);
					mcDesc.outY = Number(cityXml.@outY);
					mapDesc.citys.push(mcDesc);
				}
				for(j=0;j<mapXml.block.length();j++)
				{
					var blockXml:XML = mapXml.block[j];
					mapDesc.blockDic[int(blockXml.@col)*1000 + int(blockXml.@row)] = String(blockXml.@name);
				}
				for(j=0;j<mapXml.island.length();j++)
				{
					var islandXml:XML = mapXml.island[j];
					var miDesc:MapIslandDesc = new MapIslandDesc;
					miDesc.x = int(islandXml.@x);
					miDesc.y = int(islandXml.@y);
					miDesc.name = String(islandXml.@name);
					mapDesc.islands.push(miDesc);
				}
				SEAMAP_DESC.push(mapDesc);
			}
			SeamapConfig = null;
			
			xml = new XML(new BodyConfig);
			for(i = 0; i < xml.ship.length(); i++)
			{
				var shipXml:XML = xml.ship[i];
				var shipDesc:ShipDesc = new ShipDesc;
				shipDesc.id = int(shipXml.@id);
				shipDesc.type = int(shipXml.@type);
				shipDesc.animation = "ship" + shipDesc.id;
				shipDesc.name = String(shipXml.@name);
				shipDesc.speed = Number(shipXml.@speed);
				shipDesc.blood = int(shipXml.@blood);
				shipDesc.range = int(shipXml.@range);
				shipDesc.cost = int(shipXml.@cost);
				shipDesc.hurt = int(shipXml.@hurt);
				if(shipXml.hasOwnProperty("@shootSpeed"))
				{
					shipDesc.shootSpeed = Number(shipXml.@shootSpeed);
				}
				if(shipXml.hasOwnProperty("@bulletId"))
				{
					shipDesc.bulletId = int(shipXml.@bulletId);
				}
				if(shipDesc.type == EnumBodyType.CIRCLE)
				{
					shipDesc.raidus = Number(shipXml.@radius);
				}
				else if(shipDesc.type == EnumBodyType.RECT)
				{
					shipDesc.width = Number(shipXml.@width);
					shipDesc.height = Number(shipXml.@height);
				}
				SHIP_DESC.push(shipDesc);
			}
			for(i = 0; i < xml.bullet.length(); i++)
			{
				var pdXml:XML = xml.bullet[i];
				var pdDesc:PaoDanDesc = new PaoDanDesc;
				pdDesc.id = int(pdXml.@id);
				pdDesc.type = int(pdXml.@type);
				pdDesc.effect = pdXml.@effect;
				pdDesc.animation = "bullet" + pdDesc.id;
				pdDesc.name = String(pdXml.@name);
				if(pdDesc.type == EnumBodyType.CIRCLE)
				{
					pdDesc.raidus = Number(pdXml.@radius);
				}
				else if(pdDesc.type == EnumBodyType.RECT)
				{
					pdDesc.width = Number(pdXml.@width);
					pdDesc.height = Number(pdXml.@height);
				}
				pdDesc.hurt = int(pdXml.@hurt);
				PAODAN_DESC.push(pdDesc);
			}
			for(i = 0; i < xml.hdGroup.length();i++)
			{
				var groupXml:XML = xml.hdGroup[i];
				var groupDesc:HaiDaoGroupDesc=new HaiDaoGroupDesc;
				groupDesc.id = int(groupXml.@id);
				
				for(j = 0; j < groupXml.wave.length(); j++)
				{
					var waveXml:XML = groupXml.wave[j];
					var waveDesc:HaiDaoWaveDesc = new HaiDaoWaveDesc;
					waveDesc.remains = Number(waveXml.@time) * 1000;
					var poses:Array = String(waveXml.@npcPos).split(",");
					for(k=0;k<poses.length;k++)
					{
						waveDesc.npcPoses.push(int(poses[j]));
					}
					for(var k:int = 0; k < waveXml.member.length(); k++)
					{
						var memXml:XML = waveXml.member[k];
						var memDesc:HaiDaoWaveMemDesc = new HaiDaoWaveMemDesc;
						memDesc.id = int(memXml.@id);
						memDesc.count = int(memXml.@count);
						waveDesc.members.push(memDesc);
					}
					groupDesc.waves.push(waveDesc);
				}
				
				HAODAO_GROUPS.push(groupDesc);
			}
			BodyConfig = null;
			
			xml = new XML(new SkillConfig);
			for(i = 0; i < xml.sj.length(); i++)
			{
				var sjXml:XML = xml.sj[i];
				var sjDesc:ShenJiangDesc = new ShenJiangDesc;
				sjDesc.type = int(sjXml.@type);
				sjDesc.level = int(sjXml.@level);
				sjDesc.name = sjXml.@name;
				sjDesc.desc = sjXml.@desc;
				sjDesc.weight = Number(sjXml.@weight);
				sjDesc.wait = Number(sjXml.@wait);
				sjDesc.extra = Number(sjXml.@extra);
				if(sjXml.hasOwnProperty("@extra2"))
				{
					sjDesc.extra2 = Number(sjXml.@extra2);
				}
				if( sjXml.hasOwnProperty("@gold"))
				{
					sjDesc.gold = int(sjXml.@gold);
				}
				else
				{
					SKILLTYPE2MAXLEVEL[sjDesc.type]=sjDesc.level;
				}
				SKILL_DESC.push(sjDesc);
			}
			
			for(i = 0; i < xml.sf.length(); i++)
			{
				var sfXml:XML = xml.sf[i];
				var sfDesc:ShenFuDesc = new ShenFuDesc;
				sfDesc.type = int(sfXml.@type);
				sfDesc.level = int(sfXml.@level);
				sfDesc.name = sfXml.@name;
				sfDesc.desc = sfXml.@desc;
				sfDesc.extra = Number(sfXml.@extra);
				sfDesc.time = Number(sfXml.@time);
				if( sfXml.hasOwnProperty("@gold"))
				{
					sfDesc.gold = int(sfXml.@gold);
				}
				else
				{
					SKILLTYPE2MAXLEVEL[sfDesc.type]=sfDesc.level;
				}
				SHENFU_DESC.push(sfDesc);
			}
			SkillConfig = null;
		}
		
		public static var SHENFU_DESC:Vector.<ShenFuDesc> = new Vector.<ShenFuDesc>;
		public static function GetShenFuByTypeLevel(type:int, level:int):ShenFuDesc
		{
			for each(var sd:ShenFuDesc in SHENFU_DESC)
			{
				if(sd.type == type && sd.level == level)return sd;
			}
			return null;
		}
		
		public static var SKILLTYPE2MAXLEVEL:Dictionary = new Dictionary;
		public static var SKILL_DESC:Vector.<ShenJiangDesc> = new Vector.<ShenJiangDesc>;
		public static function GetSkillDescByTypeLevel(type:int, level:int):ShenJiangDesc
		{
			for each(var sd:ShenJiangDesc in SKILL_DESC)
			{
				if(sd.type == type && sd.level == level)return sd;
			}
			return null;
		}
		
		public static var HAODAO_GROUPS:Vector.<HaiDaoGroupDesc> = new Vector.<HaiDaoGroupDesc>;
		public static function GetHaoDaoGroup(id:int):HaiDaoGroupDesc
		{
			for each(var sd:HaiDaoGroupDesc in HAODAO_GROUPS)
			{
				if(sd.id == id)return sd;
			}
			return null;
		}
		
		public static var PAODAN_DESC:Vector.<PaoDanDesc> = new Vector.<PaoDanDesc>;
		public static function GetPaoDanDesc(id:int):PaoDanDesc
		{
			for each(var sd:PaoDanDesc in PAODAN_DESC)
			{
				if(sd.id == id)return sd;
			}
			return null;
		}
		
		public static function GetPaoDanBody(id:int):PaoDanBody
		{
			var pdDesc:PaoDanDesc = GetPaoDanDesc(id);
			var mybody:PaoDanBody = new PaoDanBody(pdDesc);
			mybody.paodan = GetAniBmpByName(pdDesc.animation);
			mybody.effect = GetAniBmpByName(pdDesc.effect);
			return mybody;
		}
		
		public static var SHIP_DESC:Vector.<ShipDesc> = new Vector.<ShipDesc>;
		public static function GetShipDesc(id:int):ShipDesc
		{
			for each(var sd:ShipDesc in SHIP_DESC)
			{
				if(sd.id == id)return sd;
			}
			return null;
		}
		
		public static var SEAMAP_DESC:Vector.<MapDesc> = new Vector.<MapDesc>;
		public static function GetSeaMapDesc(id:int):MapDesc
		{
			for each(var md:MapDesc in SEAMAP_DESC)
			{
				if(md.id == id)return md;
			}
			return null;
		}
		
		public static function GetMapCityDesc(mapId:int, cityId:int):MapCityDesc
		{
			for each(var md:MapDesc in SEAMAP_DESC)
			{
				if(md.id == mapId)
				{
					for each(var mc:MapCityDesc in md.citys)
					{
						if(mc.id == cityId)return mc;
					}
				}
			}
			return null;
		}
		
		public static function GetSeaMapGrid(mapId:int):Grid
		{
			var bd:BitmapData = GetBmpData("seaGrid" + mapId);
			var grid:Grid = new Grid(bd.width, bd.height);
			for(var i:int = 0; i < bd.width; i++)
			{
				for(var j:int = 0; j < bd.height; j++)
				{
					grid.setWalkable(i,j, bd.getPixel32(i,j)>>>24 == 0);
				}
			}
			return grid;
		}
		
		public static function GetBmpByCityId(cityId:int):Bitmap
		{
			return GetBmp("city1", false);
		}
		
		public static function GetBmp(name:String, cache:Boolean = true):Bitmap
		{
			var bmp:Bitmap = new Bitmap(GetBmpData(name, cache));
			return bmp;
		}
		
		public static function GetShenFuPlayer(sf:ShenFuDesc):ShenFuPlayer
		{
			return new ShenFuPlayer(sf, GetBmpData2("skill" + sf.type));
		}
		public static function GetBmp2(name:String, cache:Boolean = true):Bitmap
		{
			var bmp:Bitmap = new Bitmap(GetBmpData2(name));
			return bmp;
		}
		
		public static const bmpClasses:Array = [skill1,skill2,skill3,skill4,skill5,skill6,skill7,skill8,skill9,skill10,skill11];
		public static function GetBmpData2(name:String):BitmapData
		{
			var bd:BitmapData = BitmapDataPool.getBitmapData(getDefinitionByName("lsg.bmp." + name) as Class);
			return bd;
		}
		
		public static function GetBmpData(name:String, cache:Boolean = true):BitmapData
		{
			switch(name)
			{
				case "seaGrid1":
					if(cache) bd = BitmapDataPool.getBitmapData(seaGrid1);
					else bd = new seaGrid1;
					break;
				case "seaGrid2":
					if(cache) bd = BitmapDataPool.getBitmapData(seaGrid2);
					else bd = new seaGrid2;
					break;
				case "target":
					if(cache) bd = BitmapDataPool.getBitmapData(target);
					else bd = new target;
					break;
				case "anchor":
					if(cache) bd = BitmapDataPool.getBitmapData(anchor);
					else bd = new anchor;
					break;
				case "entry":
					if(cache) bd = BitmapDataPool.getBitmapData(entry);
					else bd = new entry;
					break;
				case "land1":
					if(cache) var bd:BitmapData = BitmapDataPool.getBitmapData(land1);
					else bd = new land1;
					break;
				case "sea1":
					if(cache) bd = BitmapDataPool.getBitmapData(sea1);
					else bd = new sea1;
					break;
				case "island1":
					if(cache) bd = BitmapDataPool.getBitmapData(island1);
					else bd = new island1;
					break;
				case "city1":
					if(cache) bd = BitmapDataPool.getBitmapData(city1);
					else bd = new city1;
					break;
				case "ship1":
					if(cache) bd = BitmapDataPool.getBitmapData(ship1);
					else bd = new ship1;
					break;
				case "ship2":
					if(cache) bd = BitmapDataPool.getBitmapData(ship2);
					else bd = new ship2;
					break;
				case "bullet1":
					if(cache) bd = BitmapDataPool.getBitmapData(bullet1);
					else bd = new bullet1;
					break;
				case "bullet2":
					if(cache) bd = BitmapDataPool.getBitmapData(bullet2);
					else bd = new bullet2;
					break;
				case "ship3":
					if(cache) bd = BitmapDataPool.getBitmapData(ship3);
					else bd = new ship3;
					break;
				case "role1":
					if(cache) bd = BitmapDataPool.getBitmapData(role1);
					else bd = new role1;
					break;
				case "b1":
					if(cache) bd = BitmapDataPool.getBitmapData(b1);
					else bd = new b1;
					break;
				case "b2":
					if(cache) bd = BitmapDataPool.getBitmapData(b2);
					else bd = new b2;
					break;
				case "effect1":
					if(cache) bd = BitmapDataPool.getBitmapData(effect1);
					else bd = new effect1;
					break;
				case "effect2":
					if(cache) bd = BitmapDataPool.getBitmapData(effect2);
					else bd = new effect2;
					break;
				case "bosaidong":
					if(cache) bd = BitmapDataPool.getBitmapData(bosaidong);
					else bd = new bosaidong;
					break;
				case "xuanwofengbao":
					if(cache) bd = BitmapDataPool.getBitmapData(xuanwofengbao);
					else bd = new xuanwofengbao;
					break;
				case "bingheshiji":
					if(cache) bd = BitmapDataPool.getBitmapData(bingheshiji);
					else bd = new bingheshiji;
					break;
			}
			return bd;
		}
		
		public static var ANIMATION_DESC:Vector.<AnimationDesc> = new Vector.<AnimationDesc>;
		public static var BMPNAME2ANIDESCS:Dictionary = new Dictionary;
		public static var BMPNAME2ANIMATIONs:Dictionary = new Dictionary;
		public static function GetAnimationsByBmpName(bn:String):Vector.<Animation>
		{
			var animations:Vector.<Animation> = BMPNAME2ANIMATIONs[bn];
			if(!animations)
			{
				animations = new Vector.<Animation>;
				var bd:BitmapData = GetBmpData(bn, false);
				var aniDescs:Array = BMPNAME2ANIDESCS[bn];
				for(var i:int = 0; i< aniDescs.length; i++)
				{
					var aniDesc:AnimationDesc = aniDescs[i];
					var animation:Animation = AnimationBuilder.importStrip(aniDesc.fps, bd, aniDesc.width, aniDesc.height, aniDesc.count, aniDesc.startX, aniDesc.startY,
						aniDesc.rotation, aniDesc.offsetX, aniDesc.offsetY);
					animation.isLooping = aniDesc.loop;
					animations.push(animation);
				}
				bd.dispose();
				BMPNAME2ANIMATIONs[bn] = animations;
			}
			return animations;
		}
		
		public static function FreeAnimations():void
		{
			for(var key:String in BMPNAME2ANIMATIONs)
			{
				delete BMPNAME2ANIMATIONs[key];
			}
		}
		
		public static function GetAniPlayerByName(name:String):AnimationPlayer
		{
			var ab:AnimationPlayer = new AnimationPlayer;
			var animations:Vector.<Animation> = GetAnimationsByBmpName(name);
			var aniDescs:Array = BMPNAME2ANIDESCS[name];
			for(var i:int = 0; i<animations.length; i++)
			{
				ab.addAnimation(aniDescs[i].name, animations[i]);
			}
			return ab;
		}
		
		public static function GetAniBmpByName(name:String):AnimationBmp
		{
			var ab:AnimationBmp = new AnimationBmp;
			var animations:Vector.<Animation> = GetAnimationsByBmpName(name);
			var aniDescs:Array = BMPNAME2ANIDESCS[name];
			for(var i:int = 0; i<animations.length; i++)
			{
				ab.addAnimation(aniDescs[i].name, animations[i]);
			}
			return ab;
		}
		
		public static var ERROR_DIC:Dictionary = new Dictionary;
		public static var DAOJU_DESC:Vector.<DaoJuDesc> = new Vector.<DaoJuDesc>;
		public static function GetBaoShiName(baoshi:int):String
		{
			for each(var bs:DaoJuDesc in DAOJU_DESC)
			{
				if(bs.type == EnumDaoJuType.BaoShi && bs.bs == baoshi)return bs.name;
			}
			return "无镶嵌";
		}
		
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
		
		public static var BULLET_DESC:Vector.<RoleBulletDesc> = new Vector.<RoleBulletDesc>;
		public static var TUZHI_DESC:Vector.<TuZhiDesc> = new Vector.<TuZhiDesc>;
		public static function GetTuZhiDescById(id:int):TuZhiDesc
		{
			for each(var bs:TuZhiDesc in TUZHI_DESC)
			{
				if(bs.id == id)return bs;
			}
			return null;
		}
		
		public static function GetBulletDesc(id:int):RoleBulletDesc
		{
			for each(var bs:RoleBulletDesc in BULLET_DESC)
			{
				if(bs.id == id)return bs;
			}
			return null;
		}
		
		public static function GetNormalBulletByTuzhiBaoShi(tzId:int, baoshi:int):RoleBulletDesc
		{
			for each(var bs:RoleBulletDesc in BULLET_DESC)
			{
				if(bs.isNormal && bs.tuzhi.id == tzId && bs.baoshi == baoshi)return bs;
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
			return GetAniPlayerByName("role1");
		}
		
		public static function GetShipBodyPlayer(id:int):ShipPlayer
		{
			var sd:ShipDesc = GetShipDesc(id);
			var bp:ShipPlayer = new ShipPlayer();
			bp.bodyDesc = sd;
			var animations:Vector.<Animation> = GetAnimationsByBmpName(sd.animation);
			var aniDescs:Array = BMPNAME2ANIDESCS[sd.animation];
			for(var i:int = 0; i<animations.length; i++)
			{
				bp.addAnimation(aniDescs[i].name, animations[i]);
			}
			return bp;
		}
		
	}
}