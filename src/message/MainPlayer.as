package message
{
	import data.staticObj.SkillDesc;

	public class MainPlayer extends Player
	{
		public var gold:int;
		public var curMapId:int;
		public var curCityId:int;
		public var curShip:int;
		public var curPaoDan:int;
		public var skills:Vector.<SkillDesc>=new Vector.<SkillDesc>;
		public function MainPlayer()
		{
			super();
		}
	}
}