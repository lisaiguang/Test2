package view.paihang
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	import data.MiniBuffer;
	
	import lsg.PaiHangBangUI;
	
	import view.welcome.MiniMainMenuView;
	
	CONFIG::ios
		{
			import flash.display.BitmapData;
			import lsg.bmp.Weibo;
			import flash.display.Sprite;
		}
		public class PaiHangView extends PaiHangBangUI
		{
			public function PaiHangView()
			{
				txtFuHao.text = MiniBuffer.cookies.data.fuhao + "两";
				txtTiGan.text = MiniBuffer.cookies.data.bestTiGan + "两";
				txtShouZhi.text = MiniBuffer.cookies.data.bestFinger + "两";
				txtYaoBa.text = MiniBuffer.cookies.data.yaoba + "两";
				
				CONFIG::android
					{
						btnFuHao.visible = btnTiGan.visible = btnShouZhi.visible = btnYaoBa.visible = false;
					}
					CONFIG::ios
					{
						if(_sui.isSupported)
						{
							var bd:BitmapData = new Weibo;
							var spt:Sprite = new Sprite;
							spt.addChild(new Bitmap(bd));
							spt.scaleX = spt.scaleY = 1.4;
							spt.x = txtFuHao.x + txtFuHao.width + 10;
							spt.y = txtFuHao.y + (txtFuHao.height - spt.height)*.5;
							spt.addEventListener(MouseEvent.CLICK, onFuHaoWeiboClick);
							addChild(spt);
							
							spt = new Sprite;
							spt.addChild(new Bitmap(bd));
							spt.scaleX = spt.scaleY = 1.4;
							spt.x = txtTiGan.x + txtTiGan.width+ 10;
							spt.y = txtTiGan.y + (txtTiGan.height - spt.height)*.5;
							spt.addEventListener(MouseEvent.CLICK, onTiGanWeiboClick);
							addChild(spt);
							
							spt = new Sprite;
							spt.addChild(new Bitmap(bd));
							spt.scaleX = spt.scaleY = 1.4;
							spt.x = txtShouZhi.x + txtShouZhi.width+ 10;
							spt.y = txtShouZhi.y + (txtShouZhi.height - spt.height)*.5;
							spt.addEventListener(MouseEvent.CLICK, onShouZhiWeiboClick);
							addChild(spt);
							
							spt = new Sprite;
							spt.addChild(new Bitmap(bd));
							spt.scaleX = spt.scaleY = 1.4;
							spt.x = txtYaoBa.x + txtYaoBa.width+ 10;
							spt.y = txtYaoBa.y + (txtYaoBa.height - spt.height)*.5;
							spt.addEventListener(MouseEvent.CLICK, onYaoBaWeiboClick);
							addChild(spt);
						}
						btnFuHao.addEventListener(MouseEvent.CLICK, onFuHao);
						btnTiGan.addEventListener(MouseEvent.CLICK, onTiGan);
						btnShouZhi.addEventListener(MouseEvent.CLICK, onShouZhi);
						btnYaoBa.addEventListener(MouseEvent.CLICK, onYaoBa);
					}
					
					btnReturn.addEventListener(MouseEvent.CLICK, onReturn);
			}
			
			CONFIG::ios
				{
					private var _sui:SocialUI=new SocialUI(SocialServiceType.SINAWEIBO);
					protected function onFuHaoWeiboClick(event:MouseEvent):void
					{
						_sui.setMessage("我在摇你大爷中拥有" + txtFuHao.text + "黄金，你也来试试吧！");
						_sui.addURL("https://itunes.apple.com/us/app/yao-ni-da-ye/id631859685");
						_sui.launch();
					}
					
					protected function onTiGanWeiboClick(event:MouseEvent):void
					{
						_sui.setMessage("我用手指接住了" + txtFuHao.text + "黄金，你也来试试吧！");
						_sui.addURL("https://itunes.apple.com/us/app/yao-ni-da-ye/id631859685");
						_sui.launch();
					}
					
					protected function onShouZhiWeiboClick(event:MouseEvent):void
					{
						_sui.setMessage("我用体感接住了" + txtShouZhi.text + "黄金，你也来试试吧！");
						_sui.addURL("https://itunes.apple.com/us/app/yao-ni-da-ye/id631859685");
						_sui.launch();
					}
					
					protected function onYaoBaWeiboClick(event:MouseEvent):void
					{
						_sui.setMessage("我摇出了" + txtYaoBa.text + "黄金，你也来试试吧！");
						_sui.addURL("https://itunes.apple.com/us/app/yao-ni-da-ye/id631859685");
						_sui.launch();
					}
				}
				
				protected function onReturn(event:MouseEvent):void
				{
					MidLayer.CloseWindow(PaiHangView);
					MidLayer.ShowWindow(MiniMainMenuView);
				}
				
				protected function onYaoBa(event:MouseEvent):void
				{
					CONFIG::ios
						{
							CaiShenDao.GcController.showLeaderboardView("4");
						}
				}
				
				protected function onShouZhi(event:MouseEvent):void
				{
					CONFIG::ios
						{
							CaiShenDao.GcController.showLeaderboardView("3");
						}
				}
				
				protected function onTiGan(event:MouseEvent):void
				{
					CONFIG::ios
						{
							CaiShenDao.GcController.showLeaderboardView("2");
						}
				}
				
				protected function onFuHao(event:MouseEvent):void
				{
					CONFIG::ios
						{
							CaiShenDao.GcController.showLeaderboardView("1");
						}
				}
		}
}