package data
{
	import data.obj.BattleBeginAck;
	import data.obj.BattleBeginReq;
	import data.obj.BattlePlayer;
	import data.obj.EnumDirection;
	import data.obj.PlayerHurtAck;
	import data.obj.PlayerHurtReq;
	import data.obj.PlayerRoundAck;
	import data.obj.PlayerRoundReq;

	public class MySocket
	{
		private var _bba:BattleBeginAck;
		private var _whichPlayer:int;
		
		public function MySocket()
		{
			MySignals.Socket_Send.add(onSend);
		}
		
		private function onSend(mes:Object):void
		{
			if(mes is BattleBeginReq)
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
				
				player.curBulletIds = new <int>[1];
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
				
				player.curBulletIds = new <int>[1];
				bba.players.push(player);
				
				var fr:PlayerRoundAck = new PlayerRoundAck;
				fr.playerId = 1;
				fr.timeLeft = 30;
				fr.weatherStreight = 1;
				bba.firstRound = fr;
				
				MySignals.onBattleBeginAck.dispatch(bba);
				_bba = bba;
			}
			else if(mes is PlayerRoundReq)
			{
				_whichPlayer = (_whichPlayer + 1) % 2;
				var pra:PlayerRoundAck = new PlayerRoundAck;
				pra.timeLeft = 30;
				pra.weatherStreight = 1;
				pra.playerId = _bba.players[_whichPlayer].id;
				Test2.Delay(500, MySignals.onPlayerRoundAck.dispatch, [pra]);
			}
			else if(mes is PlayerHurtReq)
			{
				var phr:PlayerHurtReq = mes as PlayerHurtReq;
				var pha:PlayerHurtAck = new PlayerHurtAck;
				pha.pids = new Vector.<Number>;
				pha.hurts = new Vector.<uint>;
				for(var i:int = 0; i < phr.pids.length; i++)
				{
					pha.pids.push(phr.pids[i]);
					pha.hurts.push(300 - Math.abs(phr.distances[i]));
				}
				MySignals.onPlayerHurtAck.dispatch(pha);
			}
		}
	}
}