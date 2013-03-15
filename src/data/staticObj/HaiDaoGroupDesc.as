package data.staticObj
{
	public class HaiDaoGroupDesc
	{
		public var start:int;
		public var end:int;
		public var members:Vector.<HaiDaoGroupMemDesc> = new Vector.<HaiDaoGroupMemDesc>;
		
		public function getMemById(id:int):HaiDaoGroupMemDesc
		{
			for each(var md:HaiDaoGroupMemDesc in members)
			{
				if(md.id == id)return md;
			}
			return null;
		}
	}
}