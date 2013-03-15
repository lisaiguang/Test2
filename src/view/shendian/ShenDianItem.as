package view.shendian
{
	import data.StaticTable;
	import data.staticObj.SkillDesc;
	
	import lsg.shendian.ItemUI;
	
	import starling.utils.Color;
	
	import utils.JinDuTiao;
	
	public class ShenDianItem extends ItemUI
	{
		public var skillDesc:SkillDesc;
		private var _jdt:JinDuTiao;
		
		public function ShenDianItem(sd:SkillDesc)
		{
			skillDesc = sd;
			txtName.text = sd.name;
			txtGold.text = sd.gold ? sd.gold + "":"MAX";
			
			_jdt=new JinDuTiao(100,20,2, Color.YELLOW);
			_jdt.x = 220;
			_jdt.y = 25;
			addChild(_jdt);
			_jdt.setBlood(sd.level, StaticTable.SKILLTYPE2MAXLEVEL[sd.type]);
		}
	}
}