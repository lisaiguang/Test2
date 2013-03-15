package view.paodan
{
	import com.greensock.BlitMask;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	
	import lsg.PaoDanUI;
	
	import message.MainPlayerGoldAck;
	import message.PaoDan;
	import message.PaoDanDeleteNtf;
	import message.PaoDanEquipAck;
	import message.PaoDanEquipReq;
	import message.PaoDanSoldAck;
	import message.PaoDanSoldReq;
	
	import utils.LHelp;
	import utils.LazySprite;
	import utils.MCheckers;
	import utils.SlidePage;
	
	public class PaoDanView extends LazySprite
	{
		private var _ui:PaoDanUI = new PaoDanUI;
		private var _lchecker:MCheckers;
		
		private var _mc:Sprite;
		private var _mask:BlitMask;
		private var _sp:SlidePage;
		
		public function PaoDanView()
		{
			addChild(_ui);
			_ui.mcPaoDanDetail.gotoAndStop(1);
			_ui.btnClose.addEventListener(MouseEvent.CLICK, onClose);
			_ui.btnChuShou.addEventListener(MouseEvent.CLICK, onSold);
			_ui.btnEquip.addEventListener(MouseEvent.CLICK, onEquip);
			_ui.btnUpequip.addEventListener(MouseEvent.CLICK, onUnEquip);
			
			_lchecker = new MCheckers([_ui.tabPaodan, _ui.tabTeShu], {over:1, select:2, check:_ui.tabPaodan, click:onTab});
			
			addChild(_mc = new Sprite);
			_mask = new BlitMask(_mc, 0, 0, 500, 400);
			_mask.bitmapMode = false;
			
			_sp = new SlidePage(_mc, _mask);
			_sp.enableScrollX = true;
			
			onTab();
			printfMoney(Buffer.mainPlayer.gold);
			
			listen(MySignals.onMainPlayerGoldAck, onMainPlayerGoldNtf);
			listen(MySignals.onPaoDanEquipAck,  onPaoDanEquipAck);
			listen(MySignals.onPaoDanSoldAck, onPaoDanSoldAck);
			listen(MySignals.onPaoDanDeleteNtf, onPaoDanDeleteNtf);
			
			InitPos();
		}
		
		private function onPaoDanDeleteNtf(pddn:PaoDanDeleteNtf):void
		{
			if(_select && _select.paodan.id == pddn.id)
			{
				_select = null;
				printfSelectPaoDan(null);
			}
		}
		
		protected function onUnEquip(event:MouseEvent):void
		{
			if(_select)
			{
				Test2.Warn("您是否卸下" + _select.paodan.bulletDesc.tuzhi.name + "？", sendEquip, null, [false]);
			}
		}
		
		private function sendEquip(equip:Boolean):void
		{
			var pder:PaoDanEquipReq = new PaoDanEquipReq;
			pder.id = _select.paodan.id;
			pder.isEquip = equip;
			MySignals.Socket_Send.dispatch(pder);
		}
		
		protected function onEquip(event:MouseEvent):void
		{
			if(_select)
			{
				Test2.Warn("您是否装备" + _select.paodan.bulletDesc.tuzhi.name + "？", sendEquip, null, [true]);
			}
		}
		
		protected function onSold(event:MouseEvent):void
		{
			if(_select)
			{
				Test2.Warn("您是否装备" + _select.paodan.bulletDesc.tuzhi.name + "？", sendSold);
			}
		}
		
		private function sendSold():void
		{
			var pdsr:PaoDanSoldReq = new PaoDanSoldReq;
			pdsr.id = _select.paodan.id;
			pdsr.count = 1;
			MySignals.Socket_Send.dispatch(pdsr);
		}
		
		private function onPaoDanSoldAck(pdsa:PaoDanSoldAck):void
		{
			if(pdsa.error == 0)onTab(false);
		}
		
		private function onPaoDanEquipAck(pdea:PaoDanEquipAck):void
		{
			if(pdea.error == 0)
				onTab(false);
			else 
				Test2.Error(pdea.error);
		}
		
		public static const PAGE:int = 20;
		private function printfPaoDans(pds:Vector.<PaoDan>):void
		{
			TweenLite.killTweensOf(_mc);
			LHelp.Clear(_mc);
			var olds:PaoDanSprite = _select;
			_select = null;
			
			var totalPage:int = pds.length / PAGE + 0.99;
			for(var p:int = 0; p < totalPage; p++)
			{
				var start:int = p * PAGE;
				for(var i:int = 0; i + start < pds.length && i < PAGE; i++)
				{
					var pd:PaoDan = pds[i + start];
					var spt:PaoDanSprite = new PaoDanSprite(pd);
					spt.x = 8 + (i % 5) * 100 + p * 500;
					spt.y = 8 + int(i / 5) * 100;
					_mc.addChild(spt);
					_sp.registerClick(PaoDanSprite, onPaoDanSelect);
					if(olds && olds.paodan.id == pd.id)
					{
						_select = spt;
					}
				}
			}
			
			if(_select)
			{
				onPaoDanSelect(_select, false);
			}
			else
			{
				printfSelectPaoDan(null);
			}
			
			_mask.update(null, true);
		}
		
		private var _select:PaoDanSprite;
		protected function onPaoDanSelect(ps:PaoDanSprite, update:Boolean = true):void
		{
			if(_select)
			{
				LHelp.RemoveGlow(_select);
			}
			_select = ps;
			LHelp.AddGlow(ps);
			printfSelectPaoDan(ps.paodan);
			if(update)
			{
				_mask.update(null, true);
			}
		}
		
		private function printfSelectPaoDan(pd:PaoDan):void
		{
			if(_lchecker.getCheckIndex() == 0 && _ui.mcPaoDanDetail.currentFrame != 1)
			{
				_ui.mcPaoDanDetail.gotoAndStop(1);
			}
			
			if(_lchecker.getCheckIndex() == 1 && _ui.mcPaoDanDetail.currentFrame != 2)
			{
				_ui.mcPaoDanDetail.gotoAndStop(2);
			}
			
			if(pd == null)
			{
				_ui.txtName.text = "";
				if(_ui.mcPaoDanDetail.currentFrame == 1)
				{
					_ui.mcPaoDanDetail.txtSize.text = "";
					_ui.mcPaoDanDetail.txtRange.text = "";
					_ui.mcPaoDanDetail.txtHurt.text = "";
					_ui.mcPaoDanDetail.txtSold.text = "";
					_ui.mcPaoDanDetail.txtBaoShi.text = "";
					_ui.btnEquip.visible = _ui.btnUpequip.visible = _ui.btnChuShou.visible = false;
				}
				else
				{
					_ui.mcPaoDanDetail.txtDesc.text = "";
					_ui.btnEquip.visible = _ui.btnUpequip.visible = _ui.btnChuShou.visible = false;
				}
			}
			else
			{
				_ui.txtName.text = pd.bulletDesc.tuzhi.name;
				if(_ui.mcPaoDanDetail.currentFrame == 1)
				{
					_ui.mcPaoDanDetail.txtSize.text = pd.bulletDesc.tuzhi.width + "x" + pd.bulletDesc.tuzhi.height;
					_ui.mcPaoDanDetail.txtRange.text = pd.bulletDesc.range + "";
					_ui.mcPaoDanDetail.txtHurt.text = pd.bulletDesc.hurt + "";
					_ui.mcPaoDanDetail.txtBaoShi.text = StaticTable.GetBaoShiName(pd.bulletDesc.baoshi);
					_ui.mcPaoDanDetail.txtSold.text = pd.bulletDesc.sold + "";
					_ui.btnEquip.visible = !pd.isEquiped;
					_ui.btnUpequip.visible = pd.isEquiped;
					_ui.btnChuShou.visible = true;
				}
				else
				{
					_ui.mcPaoDanDetail.txtDesc.text = pd.bulletDesc.desc;
					_ui.btnEquip.visible = !pd.isEquiped;
					_ui.btnUpequip.visible = pd.isEquiped;
					_ui.btnChuShou.visible = false;
				}
			}
		}
		
		private function onMainPlayerGoldNtf(mpgn:MainPlayerGoldAck):void
		{
			printfMoney(mpgn.gold);
		}
		
		private function printfMoney(gold:int):void
		{
			_ui.txtGold.text = gold + "";
		}
		
		protected function onClose(event:MouseEvent):void
		{
			MidLayer.CloseWindow(PaoDanView);
		}
		
		private function onTab(update:Boolean = true):void
		{
			switch(_lchecker.getCheckIndex())
			{
				case 0:
				{
					printfPaoDans(Buffer.GetPaoDanNormal(true));
					break;
				}
					
				case 1:
				{
					printfPaoDans(Buffer.GetPaoDanNormal(false));
					break;
				}
			}
			
			if(update)
			{
				_mc.x = _ui.x + 268;
				_mc.y = _ui.y + 20;
			}
		}
		
		public function InitPos():void
		{
			_ui.x = (StaticTable.STAGE_WIDTH - _ui.width + 45)*.5;
			_ui.y = (StaticTable.STAGE_HEIGHT - _ui.height + 45)*.5;
			_sp.mcX = _ui.x + 268;
			_sp.mcY = _ui.y + 20;
		}
	}
}