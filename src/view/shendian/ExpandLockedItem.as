package view.shendian
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	import data.staticObj.EnumError;
	import data.staticObj.SkillDesc;
	
	import lsg.shendian.ExpandLockedItemUI;
	
	import message.MainPlayerUpSkillReq;
	
	public class ExpandLockedItem extends ExpandLockedItemUI
	{
		public var skillDesc:SkillDesc;
		
		public function ExpandLockedItem(sd:SkillDesc)
		{
			skillDesc = sd;
			txtName.text = sd.name;
			txtDesc.text = sd.desc;
			if(sd.gold)
			{
				txtGold.text = sd.gold + "";
			}
			else
			{
				txtGold.visible = txtTag.visible = false;
			}
			btnUp.addEventListener(MouseEvent.CLICK, onUpClick);
			if(sd.level == StaticTable.SKILLTYPE2MAXLEVEL[sd.type])
			{
				btnUp.visible =false;
			}
			
			var bp:Bitmap = StaticTable.GetBmp2("skill"+sd.type);
			bp.x = 8;
			bp.y=8;
			addChild(bp);
		}
		
		protected function onUpClick(event:MouseEvent):void
		{
			if(Buffer.mainPlayer.gold < skillDesc.gold)
			{
				Test2.Error(EnumError.GOLD_NO_ENOUGH);
			}
			else
			{
				var mes:MainPlayerUpSkillReq = new MainPlayerUpSkillReq;
				mes.type = skillDesc.type;
				mes.level = skillDesc.level;
				MySignals.Socket_Send.dispatch(mes);
			}
		}
	}
}