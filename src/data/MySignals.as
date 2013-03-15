package data
{
	import message.BattleBeginAck;
	import message.BattleFinishAck;
	import message.DaoJu;
	import message.DaoJuDeleteNtf;
	import message.DaoJuHeChengAck;
	import message.DaoJuSoldAck;
	import message.MainPlayer;
	import message.MainPlayerGoldAck;
	import message.MainPlayerUpSkillAck;
	import message.PaoDan;
	import message.PaoDanDeleteNtf;
	import message.PaoDanEquipAck;
	import message.PaoDanSoldAck;
	import message.PlayerDisjustAck;
	import message.PlayerFallAck;
	import message.PlayerHurtAck;
	import message.PlayerMoveAck;
	import message.PlayerRoundAck;
	import message.PlayerShootAck;
	
	import org.osflash.signals.Signal;

	public class MySignals
	{
		public static var Socket_Send:Signal = new Signal(Object);
		
		public static var onBattleBeginAck:Signal = new Signal(BattleBeginAck);
		public static var onBattleFinishAck:Signal = new Signal(BattleFinishAck);
		
		public static var onPlayerRoundAck:Signal = new Signal(PlayerRoundAck);
		public static var onPlayerHurtAck:Signal = new Signal(PlayerHurtAck);
		public static var onPlayerFallAck:Signal = new Signal(PlayerFallAck);
		public static var onPlayerShootAck:Signal = new Signal(PlayerShootAck);
		public static var onPlayerMoveAck:Signal = new Signal(PlayerMoveAck);
		public static var onPlayerDisjustAck:Signal = new Signal(PlayerDisjustAck);
		
		public static var onMainPlayer:Signal = new Signal(MainPlayer);
		public static var onMainPlayerGoldAck:Signal = new Signal(MainPlayerGoldAck);
		public static var onMainPlayerUpSkillAck:Signal = new Signal(MainPlayerUpSkillAck);
		
		public static var onDaoJu:Signal = new Signal(DaoJu);
		public static var onDaoJuDeleteNtf:Signal = new Signal(DaoJuDeleteNtf);
		public static var onDaoJuSoldAck:Signal = new Signal(DaoJuSoldAck);
		public static var onDaoJuHeChengAck:Signal = new Signal(DaoJuHeChengAck);
		
		public static var onPaoDan:Signal = new Signal(PaoDan);
		public static var onPaoDanDeleteNtf:Signal = new Signal(PaoDanDeleteNtf);
		public static var onPaoDanEquipAck:Signal = new Signal(PaoDanEquipAck);
		public static var onPaoDanSoldAck:Signal = new Signal(PaoDanSoldAck);
	}
}