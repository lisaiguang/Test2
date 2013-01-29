package data.obj
{
	import data.StaticTable;

	public class BattlePlayer
	{
		public var id:Number;
		public var name:String;
		public var role:int;
		
		public var curBlood:int;
		public var curMagic:int;
		
		public var force:Number;
		public var degree:Number;
		
		public var x:Number;
		public var y:Number;
		public var direction:int;
		public var action:int;
		
		public var curBulletIds:Vector.<int> = new Vector.<int>;
		public var group:int;
		
		public function BattlePlayer()
		{
		}
		
		public function get rotationDeg():Number
		{
			if(direction == EnumDirection.LEFT){
				return -180+degree;
			}else{
				return -degree;
			}
		}
		
		public function get roleDesc():RoleDesc
		{
			return StaticTable.GetRoleDesc(role);
		}
	}
}