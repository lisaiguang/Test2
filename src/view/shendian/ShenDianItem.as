package view.shendian
{
	import flash.display.Bitmap;
	
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
			if(sd.gold)
			{
				txtGold.text = sd.gold + "";
			}
			else
			{
				txtGold.visible = txtTag.visible = false;
			}
			
			_jdt=new JinDuTiao(100,20,2, Color.YELLOW);
			_jdt.x = 260;
			_jdt.y = 32;
			addChild(_jdt);
			_jdt.setBlood(sd.level, StaticTable.SKILLTYPE2MAXLEVEL[sd.type]);
			
			var bp:Bitmap = StaticTable.GetBmp2("skill"+sd.type);
			bp.x = 8;
			bp.y=8;
			addChild(bp);
		}
	}
}