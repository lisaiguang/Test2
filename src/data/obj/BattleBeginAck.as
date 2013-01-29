package data.obj
{
	public class BattleBeginAck
	{
		public var mapId:int;
		public var weatherId:int;
		public var players:Vector.<BattlePlayer>;
		public var firstRound:PlayerRoundAck;
		public var error:int;
		
		public function BattleBeginAck()
		{
		}
	}
}