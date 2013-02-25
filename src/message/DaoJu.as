package message
{
	import data.StaticTable;
	import data.staticObj.DaoJuDesc;

	public class DaoJu
	{
		public var id:Number;
		public var itemId:int;
		public var count:int;
		
		public function DaoJu()
		{
		}
		
		private var _ds:DaoJuDesc;
		public function get daojuDesc():DaoJuDesc
		{
			if(!_ds)_ds=StaticTable.GetDaoJuDesc(itemId);
			return _ds;
		}
	}
}