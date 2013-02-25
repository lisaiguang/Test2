package warn
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	
	import flash.events.MouseEvent;
	
	import data.StaticTable;
	
	import lsg.WarnUI;

	public class WarnView extends WarnUI
	{
		private var obj:Object;
		
		public function WarnView(obj:Object)
		{
			this.obj = obj;
			this.txtContent.text = obj.content;
			
			if(obj.cancle)
			{
				this.btnOK.x = 104;
				this.btnCancle.x = 284;
				this.btnOK.visible = this.btnCancle.visible = true;
			}
			else
			{
				this.btnOK.x = 191;
				this.btnCancle.visible = false;
				this.btnOK.visible = true;
			}
			
			btnCancle.addEventListener(MouseEvent.CLICK, onClose);
			btnClose.addEventListener(MouseEvent.CLICK, onClose);
			btnOK.addEventListener(MouseEvent.CLICK, onOK);
			MidLayer.DisableMouse();
		}
		
		protected function onOK(event:MouseEvent):void
		{
			MidLayer.CloseWindow(WarnView);
			if(obj.ok)
			{
				obj.ok.apply(null, obj.okParams);
			}
		}
		
		protected function onClose(event:MouseEvent = null):void
		{
			MidLayer.CloseWindow(WarnView);
			if(obj.cancle)
			{
				obj.cancle.apply(null, obj.cancleParams);
			}
		}
		
		public function autoInit():void
		{
			this.x = (StaticTable.STAGE_WIDTH - this.width + 45)*.5;
			this.y = (StaticTable.STAGE_HEIGHT - this.height + 45)*.5;
			TweenLite.from(this, 0.7, {transformAroundCenter:{scaleX:0.5, scaleY:0.5}, ease:Elastic.easeOut});
		}
	}
}