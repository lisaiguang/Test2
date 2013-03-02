package message
{
	import data.StaticTable;
	import data.staticObj.BulletDesc;

	public class PaoDan
	{
		public var id:Number;
		public var bulletId:int;
		public var level:int;
		public var count:int;
		public var isEquiped:Boolean;
		
		public function PaoDan()
		{
		}
		
		private var _ds:BulletDesc;
		public function get bulletDesc():BulletDesc
		{
			if(!_ds)_ds=StaticTable.GetBulletDesc(bulletId);
			return _ds;
		}
	}
}