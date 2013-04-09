package view.more
{
	import com.adobe.ane.productStore.ProductStore;
	import com.adobe.ane.productStore.TransactionEvent;
	import flash.events.MouseEvent;
	import data.MiniBuffer;
	import lsg.BuyYaoDaYeUI;
	
	public class GouMaiVeiw extends BuyYaoDaYeUI
	{
		private var productStore:ProductStore = null;
		
		public function GouMaiVeiw()
		{
			super();
			productStore = new ProductStore;
			
			if(!productStore.available)
			{
				trace("!productStore.available");
			}
			else
			{
				trace("productStore.available");
			}
			productStore.addEventListener(TransactionEvent.PURCHASE_TRANSACTION_SUCCESS, purchaseTransactionSucceeded);
			productStore.addEventListener(TransactionEvent.PURCHASE_TRANSACTION_CANCEL, purchaseTransactionCanceled);
			productStore.addEventListener(TransactionEvent.PURCHASE_TRANSACTION_FAIL, purchaseTransactionFailed);
			
			btnReturn.addEventListener(MouseEvent.CLICK, onReturn);
			btnBuy.addEventListener(MouseEvent.CLICK, onBuy);
			
			btnBuy.visible = !MiniBuffer.cookies.data.purchased;
		}
		
		protected function purchaseTransactionFailed(event:TransactionEvent):void
		{
			trace("failed");
		}
		
		protected function purchaseTransactionCanceled(event:TransactionEvent):void
		{
			trace("cancled");
		}
		
		protected function purchaseTransactionSucceeded(event:TransactionEvent):void
		{
			MiniBuffer.cookies.data.purchased = true;
			MiniBuffer.cookies.flush();
			btnBuy.visible = false;
		}
		
		protected function onBuy(event:MouseEvent):void
		{
			trace("here");
			productStore.makePurchaseTransaction("weiyou.caishendao.yaodaye",1);
		}
		
		protected function onReturn(event:MouseEvent):void
		{
			MidLayer.CloseWindow(GouMaiVeiw);
		}
	}
}