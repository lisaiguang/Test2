package utils
{
	import flash.text.TextField;
	
	public class TextPool
	{
		private var _texts:Vector.<TextField> = new Vector.<TextField>;
		public function TextPool(count:int)
		{
			for(var i:int = 0; i < count; i++)
			{
				_texts.push(new TextField);
			}
		}
		
		public function popTf():TextField
		{
			if(_texts.length == 0)
			{
				return new TextField;
			}
			return _texts.pop();
		}
		
		public function pushBack(tf:TextField):void
		{
			_texts.push(tf);
		}
	}
}