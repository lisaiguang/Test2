package view.battle
{
	import lsg.battle.DisjustUI;
	
	public class AdjustView extends DisjustUI
	{
		public function AdjustView()
		{
		}
		
		public function printfDegree(degree:int):void
		{
			mcPointer.rotation = degree;
		}
	}
}