package data.staticObj
{
	public class ShenFuDesc extends SkillDesc
	{
		public var time:Number;
		
		public function get locked():Boolean
		{
			return extra == 0;
		}
	}
}