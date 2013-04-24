package view.caishen
{
	import flash.events.MouseEvent;
	
	import data.MiniBuffer;
	import data.StaticTable;
	
	import lsg.MiniOverUI;
	
	import view.welcome.MiniMainMenuView;
	
	CONFIG::ios
		{
			import flash.display.Sprite;
			import flash.display.Bitmap;
			import lsg.bmp.Weibo;
		}
		
		public class CaiShenFinishView extends MiniOverUI
		{
			private var _curScore:int;
			public function CaiShenFinishView(score:int)
			{
				_curScore=score;
				CONFIG::ios
					{
						if(_sui.isSupported)
						{
							_btnWeibo = new Sprite;
							var bmp:Bitmap = new Bitmap(new Weibo);
							bmp.scaleX = bmp.scaleY = 1.4;
							_btnWeibo.addChild(bmp);
							_btnWeibo.x=60;
							_btnWeibo.y=btnRetry.y + (btnRetry.height - _btnWeibo.height);
							addChild(_btnWeibo);
							_btnWeibo.addEventListener(MouseEvent.CLICK, onWeiboClick);
							btnRetry.x = 172;
							btnMenu.x+=6;
						}
					}
					
					txtContetn.text = "您得到了"+score+"两黄金，是否继续？";
				btnRetry.addEventListener(MouseEvent.CLICK, onReTry);
				btnMenu.addEventListener(MouseEvent.CLICK, onMenu);
				InitPos();
			}
			
			CONFIG::ios
				{
					private var _btnWeibo:Sprite, _sui:SocialUI=new SocialUI(SocialServiceType.SINAWEIBO);
					protected function onWeiboClick(event:MouseEvent):void
					{
						_sui.setMessage("我在摇你大爷中接到了"+_curScore+"两黄金，你也来试试吧！");
						_sui.addURL("https://itunes.apple.com/us/app/yao-ni-da-ye/id631859685");
						_sui.launch();
					}
				}
				
				private function InitPos():void
				{
					x = (StaticTable.STAGE_WIDTH - width)*0.5;
					y = (StaticTable.STAGE_HEIGHT - height)*0.5;
				}
				
				protected function onMenu(event:MouseEvent):void
				{
					MidLayer.CloseWindow(CaiShenFinishView);
					MidLayer.CloseWindow(CaiShenView);
					MidLayer.CloseWindow(CaiShenShakeView);
					MidLayer.ShowWindow(MiniMainMenuView);
				}
				
				protected function onReTry(event:MouseEvent):void
				{
					MidLayer.CloseWindow(CaiShenFinishView);
					if(MiniBuffer.model == 2)
					{
						MidLayer.ShowWindow(CaiShenShakeView);
					}
					else if(MiniBuffer.model == 1)
					{
						MidLayer.ShowWindow(CaiShenView);
					}
					else
					{
						MidLayer.ShowWindow(CaiShenView);
					}
				}
		}
}