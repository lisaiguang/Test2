package data
{
	import com.greensock.TweenLite;
	
	import flash.utils.Dictionary;
	
	import data.staticObj.EnumBaoShi;
	import data.staticObj.RoleBulletDesc;
	import data.staticObj.ShenJiangDesc;
	
	import message.BattleBeginAck;
	import message.BattleBeginReq;
	import message.BattleFinishAck;
	import message.BattlePlayer;
	import message.DaoJu;
	import message.DaoJuDeleteNtf;
	import message.DaoJuHeChengAck;
	import message.DaoJuHeChengReq;
	import message.DaoJuSoldAck;
	import message.DaoJuSoldReq;
	import message.EnumDirection;
	import message.MainPlayerGoldAck;
	import message.MainPlayerGoldReq;
	import message.MainPlayerUpSkillAck;
	import message.MainPlayerUpSkillReq;
	import message.PaoDan;
	import message.PaoDanDeleteNtf;
	import message.PaoDanEquipAck;
	import message.PaoDanEquipReq;
	import message.PaoDanSoldAck;
	import message.PaoDanSoldReq;
	import message.PlayerDisjustAck;
	import message.PlayerDisjustReq;
	import message.PlayerFallAck;
	import message.PlayerFallReq;
	import message.PlayerHurtAck;
	import message.PlayerHurtReq;
	import message.PlayerMoveAck;
	import message.PlayerMoveReq;
	import message.PlayerRoundAck;
	import message.PlayerRoundReq;
	import message.PlayerShootAck;
	import message.PlayerShootReq;
	
	import nape.geom.Vec2;
	
	public class MySocket
	{
		private var _bba:BattleBeginAck;
		private var _whichPlayer:int;
		private var _isFinish:Boolean = false;
		
		public function MySocket()
		{
			MySignals.Socket_Send.add(onSend);
		}
		
		private var _groupDic:Dictionary = new Dictionary;
		
		private function onSend(mes:*):void
		{
			if(mes is MainPlayerUpSkillReq)
			{
				var skillDesc:ShenJiangDesc = StaticTable.GetSkillDescByTypeLevel(mes.type, mes.level);
				mpgn = new MainPlayerGoldAck;
				mpgn.gold = Buffer.mainPlayer.gold - skillDesc.gold;
				MySignals.onMainPlayerGoldAck.dispatch(mpgn);
				var mpusa:MainPlayerUpSkillAck = new MainPlayerUpSkillAck;
				mpusa.type = skillDesc.type;
				mpusa.level = skillDesc.level + 1;
				MySignals.onMainPlayerUpSkillAck.dispatch(mpusa);
			}
			else if(mes is MainPlayerGoldReq)
			{
				var mpgr:MainPlayerGoldReq = mes;
				var mpga:MainPlayerGoldAck = new MainPlayerGoldAck;
				mpga.gold = mpgr.addtion + Buffer.mainPlayer.gold;
				MySignals.onMainPlayerGoldAck.dispatch(mpga);
			}
			else if(mes is BattleBeginReq)
			{
				var bba:BattleBeginAck = new BattleBeginAck;
				bba.error = 0;
				bba.mapId = 1;
				bba.weatherId = 1;
				bba.players = new Vector.<BattlePlayer>;
				
				var player:BattlePlayer = new BattlePlayer;
				player.id = 1;
				player.name = "lsg";
				player.role = 1;
				
				player.curBlood = 1000;
				player.curMagic = 1000;
				
				player.degree = 0;
				player.force = 0;
				
				player.x = 600;
				player.y = 0;
				player.direction = EnumDirection.RIGHT;
				player.group = 1;
				_groupDic[1] = 1;
				
				player.curBulletIds = Buffer.GetPaoDanBulletIdByEquiped();
				bba.players.push(player);
				
				player = new BattlePlayer;
				player.id = 2;
				player.name = "haha";
				player.role = 2;
				
				player.curBlood = 1000;
				player.curMagic = 1000;
				
				player.degree = 0;
				player.force = 0;
				
				player.x = 800;
				player.y = 0;
				player.direction = EnumDirection.LEFT;
				player.group = 2;
				_groupDic[2] = 1;
				
				player.curBulletIds = new <int>[1,2,3,4];
				bba.players.push(player);
				
				var fr:PlayerRoundAck = new PlayerRoundAck;
				fr.playerId = 1;
				fr.timeLeft = 30;
				fr.weatherStreight = 1;
				bba.firstRound = fr;
				
				MySignals.onBattleBeginAck.dispatch(bba);
				_bba = bba;
				_whichPlayer = 0;
				_isFinish = false;
			}
			else if(mes is PlayerRoundReq && !_isFinish)
			{
				_whichPlayer = (_whichPlayer + 1) % 2;
				var bp:BattlePlayer = _bba.players[_whichPlayer];
				
				var pra:PlayerRoundAck = new PlayerRoundAck;
				pra.timeLeft = 30;
				pra.weatherStreight = 1;
				pra.playerId = bp.id;
				TweenLite.delayedCall(0.5, MySignals.onPlayerRoundAck.dispatch, [pra]);
				
				if(bp.id != Buffer.mainPlayer.id)
				{
					for each(var tbp:BattlePlayer in _bba.players)
					{
						if(tbp.id != bp.id && tbp.group != bp.group)
						{
							break;
						}
					}
					var target:Vec2 = Vec2.get(tbp.x, tbp.y + 10).subeq(Vec2.weak(bp.x, bp.y));
					psa = new PlayerShootAck;
					psa.pid = bp.id;
					psa.bid = _bba.players[_whichPlayer].curBulletIds[1];
					psa.rad = target.angle;
					psa.force =90;
					TweenLite.delayedCall(4, MySignals.onPlayerShootAck.dispatch, [psa]);
					target.dispose();
				}
			}
			else if(mes is PlayerHurtReq)
			{
				var phr:PlayerHurtReq = mes;
				var pha:PlayerHurtAck = new PlayerHurtAck;
				pha.pids = new Vector.<Number>;
				pha.hurts = new Vector.<uint>;
				var bs:RoleBulletDesc = StaticTable.GetBulletDesc(phr.bid);
				for(var i:int = 0; i < phr.pids.length; i++)
				{
					pha.pids.push(phr.pids[i]);
					pha.hurts.push(bs.hurt - Math.abs(phr.distances[i]));
				}
				MySignals.onPlayerHurtAck.dispatch(pha);
				checkIfBattleFinish();
			}
			else if(mes is PlayerFallReq)
			{
				var pfr:PlayerFallReq = mes;
				var pfa:PlayerFallAck = new PlayerFallAck;
				pfa.playerId = pfr.playerId;
				MySignals.onPlayerFallAck.dispatch(pfa);
				checkIfBattleFinish();
			}
			else if(mes is PlayerShootReq)
			{
				var psr:PlayerShootReq = mes;
				var psa:PlayerShootAck = new PlayerShootAck;
				psa.bid = psr.bid;
				psa.pid = psr.pid;
				psa.force = psr.force;
				psa.rad = psr.rad;
				MySignals.onPlayerShootAck.dispatch(psa);
			}
			else if(mes is PlayerDisjustReq)
			{
				var pdr:PlayerDisjustReq = mes;
				if(pdr.action == 0)
				{
					bp = _bba.players[_whichPlayer];
					bp.degree = pdr.degree;
				}
				var pda:PlayerDisjustAck = new PlayerDisjustAck;
				pda.pid = pdr.pid;
				pda.direction = pdr.direction;
				pda.degree = pdr.degree;
				pda.action = pdr.action;
				MySignals.onPlayerDisjustAck.dispatch(pda);
			}
			else if(mes is PlayerMoveReq)
			{
				var pmr:PlayerMoveReq = mes;
				if(pmr.action == 0)
				{
					bp = _bba.players[_whichPlayer];
					bp.x = pmr.x;
					bp.y = pmr.y;
					bp.rotation = pmr.rotation;
				}
				var pma:PlayerMoveAck = new PlayerMoveAck;
				pma.pid = pmr.pid;
				pma.direction = pmr.direction;
				pma.action = pmr.action;
				pma.x = pmr.x;
				pma.y = pmr.y;
				pma.rotation = pmr.rotation;
				MySignals.onPlayerMoveAck.dispatch(pma);
			}
			else if(mes is DaoJuSoldReq)
			{
				var dsr:DaoJuSoldReq = mes;
				var dj:DaoJu = Buffer.GetDaoJuById(dsr.id);
				dj.count -= dsr.count;
				if(dj.count <= 0)
				{
					var djdn:DaoJuDeleteNtf = new DaoJuDeleteNtf;
					djdn.id = dj.id;
					MySignals.onDaoJuDeleteNtf.dispatch(djdn);
				}
				else
				{
					MySignals.onDaoJu.dispatch(dj);
				}
				var djsa:DaoJuSoldAck = new DaoJuSoldAck;
				djsa.id = dsr.id;
				djsa.count = dsr.count;
				MySignals.onDaoJuSoldAck.dispatch(djsa);
				var mpgn:MainPlayerGoldAck = new MainPlayerGoldAck;
				mpgn.gold = Buffer.mainPlayer.gold + dj.daojuDesc.sold;
				MySignals.onMainPlayerGoldAck.dispatch(mpgn);
			}
			else if(mes is PaoDanSoldReq)
			{
				var pdsr:PaoDanSoldReq = mes;
				var pd:PaoDan = Buffer.GetPaoDanById(pdsr.id);
				pd.count -= pdsr.count;
				if(pd.count <= 0)
				{
					var pddn:PaoDanDeleteNtf = new PaoDanDeleteNtf;
					pddn.id = pd.id;
					MySignals.onPaoDanDeleteNtf.dispatch(pddn);
				}
				else
				{
					MySignals.onPaoDan.dispatch(pd);
				}
				var pdsa:PaoDanSoldAck = new PaoDanSoldAck;
				pdsa.id = pdsr.id;
				pdsa.count = pdsr.count;
				MySignals.onPaoDanSoldAck.dispatch(pdsa);
				mpgn = new MainPlayerGoldAck;
				mpgn.gold = Buffer.mainPlayer.gold + pd.bulletDesc.sold;
				MySignals.onMainPlayerGoldAck.dispatch(mpgn);
			}
			else if(mes is PaoDanEquipReq)
			{
				var pder:PaoDanEquipReq = mes;
				pd = Buffer.GetPaoDanById(pder.id);
				if(pder.isEquip && Buffer.GetPaoDanBulletIdByEquiped().length >= 4)
				{
					pdea = new PaoDanEquipAck;
					pdea.error = -2;
					MySignals.onPaoDanEquipAck.dispatch(pdea);
					return;
				}
				pd.isEquiped = pder.isEquip;
				MySignals.onPaoDan.dispatch(pd);
				var pdea:PaoDanEquipAck = new PaoDanEquipAck;
				pdea.id = pder.id;
				pdea.isEquip = pdea.isEquip;
				MySignals.onPaoDanEquipAck.dispatch(pdea);
			}
			else if(mes is DaoJuHeChengReq)
			{
				var djhcr:DaoJuHeChengReq = mes;
				var huoyao:DaoJu = Buffer.GetDaoJuById(djhcr.huoyao);
				var jinshu:DaoJu = Buffer.GetDaoJuById(djhcr.jinshu);
				var tuzhi:DaoJu = Buffer.GetDaoJuById(djhcr.tuzhi);
				var baoshi:DaoJu = Buffer.GetDaoJuById(djhcr.baoshi);
				
				var tm:int;
				tm += huoyao.daojuDesc.sold;
				tm += jinshu.daojuDesc.sold;
				tm += tuzhi.daojuDesc.sold;
				if(baoshi)tm += baoshi.daojuDesc.sold;
				
				if(Buffer.mainPlayer.gold < tm)
				{
					djhca = new DaoJuHeChengAck;
					djhca.error = -1;
					MySignals.onDaoJuHeChengAck.dispatch(djhca);
					return;
				}
				else
				{
					mpgn = new MainPlayerGoldAck;
					mpgn.gold = Buffer.mainPlayer.gold - tm;
					MySignals.onMainPlayerGoldAck.dispatch(mpgn);
				}
				
				huoyao.count --;
				if(huoyao.count <= 0)
				{
					djdn = new DaoJuDeleteNtf;
					djdn.id = huoyao.id;
					MySignals.onDaoJuDeleteNtf.dispatch(djdn);
				}
				else
				{
					MySignals.onDaoJu.dispatch(huoyao);
				}
				jinshu.count --;
				if(jinshu.count <= 0)
				{
					djdn = new DaoJuDeleteNtf;
					djdn.id = jinshu.id;
					MySignals.onDaoJuDeleteNtf.dispatch(djdn);
				}
				else
				{
					MySignals.onDaoJu.dispatch(jinshu);
				}
				tuzhi.count --;
				if(tuzhi.count <= 0)
				{
					djdn = new DaoJuDeleteNtf;
					djdn.id = tuzhi.id;
					MySignals.onDaoJuDeleteNtf.dispatch(djdn);
				}
				else
				{
					MySignals.onDaoJu.dispatch(tuzhi);
				}
				
				if(baoshi)
				{
					baoshi.count --;
					if(baoshi.count <= 0)
					{
						djdn = new DaoJuDeleteNtf;
						djdn.id = baoshi.id;
						MySignals.onDaoJuDeleteNtf.dispatch(djdn);
					}
					else
					{
						MySignals.onDaoJu.dispatch(baoshi);
					}
				}
				
				pd = new PaoDan();
				pd.id = Buffer.GetPaoDanNewId();
				pd.bulletId = StaticTable.GetNormalBulletByTuzhiBaoShi(tuzhi.daojuDesc.tz, baoshi ? baoshi.daojuDesc.bs:EnumBaoShi.NONE).id;
				pd.level = 0;
				pd.count = 1;
				pd.isEquiped = false;
				MySignals.onPaoDan.dispatch(pd);
				
				var djhca:DaoJuHeChengAck = new DaoJuHeChengAck;
				djhca.paodanId = pd.id;
				djhca.count = 1;
				MySignals.onDaoJuHeChengAck.dispatch(djhca);
			}
		}
		
		private function checkIfBattleFinish():void
		{
			if(_isFinish){
				return;
			}
			for(var i:int = 0; i < _bba.players.length; i++)
			{
				if(_bba.players[i].curBlood <= 0)
				{
					_groupDic[_bba.players[i].group]--;
					if(_groupDic[_bba.players[i].group] <= 0)
					{
						_isFinish = true;
						var bfa:BattleFinishAck = new BattleFinishAck;
						bfa.winGroup = _bba.players[i].group == 1?2:1;
						MySignals.onBattleFinishAck.dispatch(bfa);
						break;
					}
				}
			}
		}
	}
}