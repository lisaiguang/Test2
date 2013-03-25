package message
{
	import data.staticObj.ShenFuDesc;
	import data.staticObj.ShenJiangDesc;

	public class MainPlayer extends Player
	{
		public var gold:int;
		public var curMapId:int;
		public var curCityId:int;
		public var curShip:int;
		public var curPaoDan:int;
		public var sjs:Vector.<ShenJiangDesc>=new Vector.<ShenJiangDesc>;
		public var sfs:Vector.<ShenFuDesc>=new Vector.<ShenFuDesc>;
		public function MainPlayer()
		{
			super();
		}
	}
}