package mybodys
{
	import com.urbansquall.ginger.AnimationBmp;
	
	import data.staticObj.BodyDesc;
	import data.staticObj.PaoDanDesc;
	
	
	public class PaoDanBody extends MyBody
	{
		public var hurtDiscount:Number;
		public var target:ShipPlayer;
		public var effect:AnimationBmp;
		
		public function PaoDanBody(bd:BodyDesc)
		{
			super(bd);
		}
		
		public function get paodanDesc():PaoDanDesc
		{
			return bodyDesc as PaoDanDesc;
		}
		
		public function set paodanDesc(desc:PaoDanDesc):void
		{
			bodyDesc = desc
		}
		
		public function get paodan():AnimationBmp
		{
			return animation as AnimationBmp;
		}
		
		public function set paodan(val:AnimationBmp):void
		{
			animation = val;
		}
	}
}