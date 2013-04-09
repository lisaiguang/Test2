package data
{
	import com.urbansquall.ginger.Animation;
	import com.urbansquall.ginger.AnimationBmp;
	import com.urbansquall.ginger.AnimationPlayer;
	import com.urbansquall.ginger.tools.AnimationBuilder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import data.staticObj.AnimationDesc;
	import data.staticObj.BodyBoxDesc;
	
	import lsg.bmp.MiniBoom;
	import lsg.bmp.MiniCs;
	import lsg.bmp.MiniTk;
	import lsg.bmp.MiniTk3;
	import lsg.bmp.jubaopen;
	import lsg.bmp.shalou;
	import lsg.bmp.tongqian;
	import lsg.bmp.yinzi;
	import lsg.bmp.yuanbao;
	import lsg.bmp.zadan;
	import lsg.bmp.zhujia;
	import lsg.music.BgMusic;
	import lsg.music.BoomMusic;
	
	import music.SoundPlayer;
	
	public class StaticTable
	{
		public static var STAGE_WIDTH:int  = 640;
		public static var STAGE_HEIGHT:int = 960;

		[Embed(source = "../../assets/config/error.xml", mimeType="application/octet-stream")]
		private static var ErrorConfig:Class;
		
		[Embed(source = "../../assets/config/animation.xml", mimeType="application/octet-stream")]
		private static var AnimationConfig:Class;

		[Embed(source = "../../assets/config/newBody.xml", mimeType="application/octet-stream")]
		private static var NewBodyConfig:Class;
		
		public static function Init():void
		{
			var xml:XML = new XML(new ErrorConfig);
			for(var i:int = 0; i < xml.e.length(); i++)
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
				for(var j:int=0;j<bmpXml.a.length();j++)
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

			xml = new XML(new NewBodyConfig);
			for(i = 0; i < xml.box.length(); i++)
			{
				var boxXml:XML = xml.box[i];
				var boxDesc:BodyBoxDesc = new BodyBoxDesc;
				boxDesc.id = int(boxXml.@id);
				boxDesc.name = String(boxXml.@name);
				boxDesc.width = Number(boxXml.@width);
				boxDesc.height = Number(boxXml.@height);
				BodyBox_DESC.push(boxDesc);
			}
			NewBodyConfig = null;
			
			var musiclist:Array = [BgMusic, BoomMusic];
			for(i = 0; i < musiclist.length; i++)
			{
				var sp:SoundPlayer = new SoundPlayer(musiclist[i]);
				_sounds.push(sp);
			}
		}
		
		private static var _sounds:Array = new Array;
		public static function GetSoundPlayer(id:int):SoundPlayer
		{
			return  _sounds[id];
		}
		
		public static var BodyBox_DESC:Vector.<BodyBoxDesc> = new Vector.<BodyBoxDesc>;
		public static function GetBodyBoxDescById(id:int):BodyBoxDesc
		{
			for(var i:int = 0; i < BodyBox_DESC.length; i++)
			{
				var bd:BodyBoxDesc = BodyBox_DESC[i];
				if(bd.id == id)return bd;
			}
			return null;
		}
		
		public static function GetBmp(name:String, cache:Boolean = true):Bitmap
		{
			var bmp:Bitmap = new Bitmap(GetBmpData(name, cache));
			return bmp;
		}
		
		public static function GetBmpData(name:String, cache:Boolean = true):BitmapData
		{
			switch(name)
			{
				case "MiniBoom":
					if(cache) bd = BitmapDataPool.getBitmapData(MiniBoom);
					else bd = new MiniBoom;
					break;
				case "MiniCs":
					if(cache) bd = BitmapDataPool.getBitmapData(MiniCs);
					else bd = new MiniCs;
					break;
				case "MiniTk":
					if(cache) bd = BitmapDataPool.getBitmapData(MiniTk);
					else bd = new MiniTk;
					break;
				case "MiniTk3":
					if(cache) bd = BitmapDataPool.getBitmapData(MiniTk);
					else bd = new MiniTk3;
					break;
				case "jubaopen":
					if(cache) bd = BitmapDataPool.getBitmapData(jubaopen);
					else bd = new jubaopen;
					break;
				case "yinzi":
					if(cache) bd = BitmapDataPool.getBitmapData(yinzi);
					else bd = new yinzi;
					break;
				case "tongqian":
					if(cache) bd = BitmapDataPool.getBitmapData(tongqian);
					else bd = new tongqian;
					break;
				case "zadan":
					if(cache) bd = BitmapDataPool.getBitmapData(zadan);
					else bd = new zadan;
					break;
				case "yuanbao":
					if(cache) bd = BitmapDataPool.getBitmapData(yuanbao);
					else bd = new yuanbao;
					break;
				case "zhujia":
					if(cache) bd = BitmapDataPool.getBitmapData(zhujia);
					else bd = new zhujia;
					break;
				case "shalou":
					if(cache) var bd:BitmapData = BitmapDataPool.getBitmapData(shalou);
					else bd = new shalou;
					break;
				//
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
	}
}