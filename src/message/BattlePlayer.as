package message
{
	import data.StaticTable;
	
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	import data.staticObj.RoleDesc;
	import data.staticObj.EnumAction;

	public class BattlePlayer
	{
		public var id:Number;
		public var name:String;
		public var role:int;
		
		public var curBlood:int;
		public var curMagic:int;
		
		public var lastForce:Number = 0;
		public var force:Number = 0;
		public var degree:Number;
		
		public var x:Number;
		public var y:Number;
		public var direction:int;
		public var rotation:Number = 0;
		public var action:String = EnumAction.ROLE_WAITING;
		public var moved:Boolean;
		
		public var curBulletIds:Vector.<int> = new Vector.<int>;
		public var group:int;
		
		public function BattlePlayer()
		{
		}
		
		public function get rotationDeg():Number
		{
			if(direction == EnumDirection.LEFT){
				return -180 + degree + rad2deg(rotation);
			}else{
				return -(degree) + rad2deg(rotation);
			}
		}
		
		public function get rotationRad():Number
		{
			if(direction == EnumDirection.LEFT){
				return deg2rad(-180 + degree) + rotation;
			}else{
				return rotation + deg2rad(-degree);
			}
		}
		
		public function get roleDesc():RoleDesc
		{
			return StaticTable.GetRoleDesc(role);
		}
	}
}