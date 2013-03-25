package view.shendian
{
	import flash.display.Bitmap;
	
	import data.StaticTable;
	import data.staticObj.SkillDesc;
	
	import lsg.shendian.LockedItemUI;
	
	public class LockedItem extends LockedItemUI
	{
		public var skillDesc:SkillDesc;
		
		public function LockedItem(sd:SkillDesc)
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
			
			var bp:Bitmap = StaticTable.GetBmp2("skill"+sd.type);
			bp.x = 8;
			bp.y=8;
			addChild(bp);
		}
	}
}