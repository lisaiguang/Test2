package data.staticObj
{
	public class HaiDaoWaveDesc
	{
		public var remains:Number;
		public var npcPoses:Vector.<int> = new Vector.<int>;
		public var members:Vector.<HaiDaoWaveMemDesc> = new Vector.<HaiDaoWaveMemDesc>;
		
		public function getMemById(id:int):HaiDaoWaveMemDesc
		{
			for each(var md:HaiDaoWaveMemDesc in members)
			{
				if(md.id == id)return md;
			}
			return null;
		}
	}
}