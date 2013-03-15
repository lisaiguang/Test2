package data
{
	
	import data.staticObj.SkillDesc;
	
	import message.DaoJu;
	import message.DaoJuDeleteNtf;
	import message.MainPlayer;
	import message.MainPlayerGoldAck;
	import message.MainPlayerUpSkillAck;
	import message.PaoDan;
	import message.PaoDanDeleteNtf;
	import message.PaoDanEquipAck;
	
	public class Buffer
	{
		private static var _mainPlayer:MainPlayer;
		private static var _daojus:Vector.<DaoJu> = new Vector.<DaoJu>;
		public static var PaoDans:Vector.<PaoDan> = new Vector.<PaoDan>;
		
		public static function get DaoJus():Vector.<DaoJu>
		{
			return _daojus;
		}

		public static function get mainPlayer():MainPlayer
		{
			return _mainPlayer;
		}
		
		public function Buffer()
		{
			MySignals.onMainPlayer.add(CreatePlayer);
			MySignals.onMainPlayerGoldAck.add(onMainPlayerGoldNtf);
			MySignals.onMainPlayerUpSkillAck.add(onMainPlayerUpSkillAck);
			
			MySignals.onDaoJu.add(onDaoJu);
			MySignals.onDaoJuDeleteNtf.add(onDaoJuDeleteNtf);
			
			MySignals.onPaoDan.add(onPaoDan);
			MySignals.onPaoDanEquipAck.add(onPaoDanEquipAck);
			MySignals.onPaoDanDeleteNtf.add(onPaoDanDeleteNtf);
		}
		
		private function onMainPlayerUpSkillAck(mes:MainPlayerUpSkillAck):void
		{
			for(var i:int = 0; i < mainPlayer.skills.length; i++)
			{
				var sd:SkillDesc = mainPlayer.skills[i];
				if(sd.type == mes.type)
				{
					mainPlayer.skills[i] = StaticTable.GetSkillDescByTypeLevel(mes.type, mes.level);
				}
			}
		}
		
		public static function GetPaoDanNormal(isNormal:Boolean = true):Vector.<PaoDan>
		{
			var result:Vector.<PaoDan> = new Vector.<PaoDan>;
			for(var i:int = 0; i < PaoDans.length; i++)
			{
				if(PaoDans[i].bulletDesc.isNormal == isNormal)result.push(PaoDans[i]);
			}
			return result;
		}
		
		public static function GetPaoDanNewId():Number
		{
			var id:Number = 1;
			for(var i:int = 0; i < PaoDans.length; i++)
			{
				if(PaoDans[i].id >= id)id = PaoDans[i].id + 1;
			}
			return id;
		}
		
		private function onPaoDanDeleteNtf(pddn:PaoDanDeleteNtf):void
		{
			for(var i:int = 0; i< PaoDans.length; i++)
			{
				var pd:PaoDan = PaoDans[i];
				if(pd.id == pddn.id)
				{
					PaoDans.splice(i,1);
					break;
				}
			}
		}
		
		private function onPaoDanEquipAck(pdea:PaoDanEquipAck):void
		{
			if(pdea.error != 0) return;
			for(var i:int = 0; i< PaoDans.length; i++)
			{
				var pd:PaoDan = PaoDans[i];
				if(pd.id == pdea.id)
				{
					PaoDans.splice(i,1);
					break;
				}
			}
			
			if(pd.isEquiped)
			{
				PaoDans.unshift(pd);
			}
			else
			{
				PaoDans.push(pd);
			}
		}
		
		private function onPaoDan(tpd:PaoDan):void
		{
			for(var i:int = 0; i< PaoDans.length; i++)
			{
				var pd:PaoDan = PaoDans[i];
				if(pd.id == tpd.id)
				{
					pd.count = tpd.count;
					pd.isEquiped = pd.isEquiped;
					return;
				}
			}
			PaoDans.push(tpd);
		}
		
		static public function GetPaoDanById(id:Number):PaoDan
		{
			for(var i:int = 0; i< PaoDans.length; i++)
			{
				var dj:PaoDan = PaoDans[i];
				if(dj.id == id)
				{
					return dj;
				}
			}
			return null;
		}
		
		static public function GetPaoDanByEquiped():Vector.<PaoDan>
		{
			var rsult:Vector.<PaoDan> = new Vector.<PaoDan>;
			for(var i:int = 0; i< PaoDans.length; i++)
			{
				var pd:PaoDan = PaoDans[i];
				if(pd.isEquiped)
				{
					rsult.push(pd);
				}
			}
			return rsult;
		}
		
		static public function GetPaoDanBulletIdByEquiped():Vector.<int>
		{
			var rsult:Vector.<int> = new Vector.<int>;
			for(var i:int = 0; i< PaoDans.length; i++)
			{
				var pd:PaoDan = PaoDans[i];
				if(pd.isEquiped)
				{
					rsult.push(pd.bulletId);
				}
			}
			return rsult;
		}
		
		private function onMainPlayerGoldNtf(mpgn:MainPlayerGoldAck):void
		{
			_mainPlayer.gold = mpgn.gold;
		}
		
		public static function GetDaoJusByType(type1:int, type2:int = 0):Vector.<DaoJu>
		{
			var result:Vector.<DaoJu> = new Vector.<DaoJu>;
			for(var i:int = 0; i< _daojus.length; i++)
			{
				var dj:DaoJu = _daojus[i];
				if(dj.daojuDesc.type == type1 || dj.daojuDesc.type == type2)
				{
					result.push(dj);
				}
			}
			return result;
		}
		
		public static function GetDaoJuById(id:Number):DaoJu
		{
			for(var i:int = 0; i< _daojus.length; i++)
			{
				var dj:DaoJu = _daojus[i];
				if(dj.id == id)
				{
					return dj;
				}
			}
			return null;
		}
		
		private function onDaoJu(tdj:DaoJu):void
		{
			for(var i:int = 0; i< _daojus.length; i++)
			{
				var dj:DaoJu = _daojus[i];
				if(dj.id == tdj.id)
				{
					dj.count = tdj.count;
					return;
				}
			}
			_daojus.push(tdj);
		}
		
		private function onDaoJuDeleteNtf(djdn:DaoJuDeleteNtf):void
		{
			for(var i:int = 0; i< _daojus.length; i++)
			{
				var dj:DaoJu = _daojus[i];
				if(dj.id == djdn.id)
				{
					_daojus.splice(i,1);
					return;
				}
			}
		}
				
		private function CreatePlayer(player:MainPlayer):void
		{
			_mainPlayer = player;
		}
	}
}