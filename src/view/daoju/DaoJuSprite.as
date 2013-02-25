package view.daoju
{
	import flash.display.Sprite;
	
	import data.StaticTable;
	
	import message.DaoJu;
	
	public class DaoJuSprite extends Sprite
	{
		public var daoju:DaoJu;
		
		public function DaoJuSprite(dj:DaoJu)
		{
			daoju = dj;
			addChild(StaticTable.GetDaoJuIcon(dj.itemId));
		}
	}
}