package view.paodan
{
	import flash.display.Bitmap;
	
	import data.StaticTable;
	
	import lsg.PaoDanPanel;
	
	import message.PaoDan;

	public class PaoDanSprite extends PaoDanPanel
	{
		public var paodan:PaoDan;
		
		public function PaoDanSprite(pd:PaoDan)
		{
			paodan = pd;
			var bmp:Bitmap = StaticTable.GetBulletIcon(pd.bulletId);
			bmp.x = width*.5 - bmp.width * .5;
			bmp.y = height*.5 - bmp.height * .5;
			addChildAt(bmp, 1);
			txtEquip.text = pd.isEquiped?"E":"";
		}
	}
}