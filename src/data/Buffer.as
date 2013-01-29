package data
{
	
	import data.obj.MainPlayer;
	import data.obj.Player;

	public class Buffer
	{
		private static var _mainPlayer:MainPlayer;
		
		public static function get mainPlayer():MainPlayer
		{
			return _mainPlayer;
		}
		
		private static var _players:Vector.<Player> = new Vector.<Player>;

		public static function get palyers():Vector.<Player>
		{
			return _players;
		}
		
		public static function GetPlayerById(id:Number):Player
		{
			for each(var player:Player in _players)
			{
				if(player.id == id)
				{
					return player;
				}
			}
			return null;
		}

		
		public function Buffer()
		{
			MySignals.Create_Main_Player.add(CreatePlayer);
		}
		
		private function CreatePlayer(player:MainPlayer):void
		{
			_mainPlayer = player;
			_players.push(_mainPlayer);
		}
	}
}