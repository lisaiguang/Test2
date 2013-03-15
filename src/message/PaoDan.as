package message
{
	import data.StaticTable;
	import data.staticObj.RoleBulletDesc;

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
		
		private var _ds:RoleBulletDesc;
		public function get bulletDesc():RoleBulletDesc
		{
			if(!_ds)_ds=StaticTable.GetBulletDesc(bulletId);
			return _ds;
		}
	}
}