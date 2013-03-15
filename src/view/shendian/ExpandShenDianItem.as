package view.shendian
{
	import flash.events.MouseEvent;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	import data.staticObj.EnumError;
	import data.staticObj.SkillDesc;
	
	import lsg.shendian.ExpandItemUI;
	
	import message.MainPlayerUpSkillReq;
	
	import starling.utils.Color;
	
	import utils.JinDuTiao;
	
	public class ExpandShenDianItem extends ExpandItemUI
	{
		public var skillDesc:SkillDesc;
		private var _jdt:JinDuTiao;
		
		public function ExpandShenDianItem(sd:SkillDesc)
		{
			skillDesc = sd;
			txtName.text = sd.name;
			txtGold.text = sd.gold ? sd.gold + "":"MAX";
			txtDesc.text = sd.desc;
			btnUp.addEventListener(MouseEvent.CLICK, onUpClick);
			
			_jdt=new JinDuTiao(100,20,2, Color.YELLOW);
			_jdt.x = 220;
			_jdt.y = 25;
			addChild(_jdt);
			_jdt.setBlood(sd.level, StaticTable.SKILLTYPE2MAXLEVEL[sd.type]);
			
			if(sd.level == StaticTable.SKILLTYPE2MAXLEVEL[sd.type])
			{
				btnUp.visible =false;
			}
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