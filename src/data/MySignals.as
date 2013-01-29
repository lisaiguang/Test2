package data
{
	import data.obj.BattleBeginAck;
	import data.obj.MainPlayer;
	import data.obj.PlayerHurtAck;
	import data.obj.PlayerRoundAck;
	
	import org.osflash.signals.Signal;

	public class MySignals
	{
		public static var Socket_Send:Signal = new Signal(Object);
		
		public static var onBattleBeginAck:Signal = new Signal(BattleBeginAck);
		public static var onPlayerRoundAck:Signal = new Signal(PlayerRoundAck);
		public static var onPlayerHurtAck:Signal = new Signal(PlayerHurtAck);
		
		public static var Create_Main_Player:Signal = new Signal(MainPlayer);
	}
}