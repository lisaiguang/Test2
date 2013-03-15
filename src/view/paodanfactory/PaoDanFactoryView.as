package view.paodanfactory
{
	import com.greensock.BlitMask;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	
	import lsg.PaoDanFactoryUI;
	
	import message.DaoJu;
	import message.DaoJuHeChengAck;
	import message.DaoJuHeChengReq;
	import message.EnumDaoJuType;
	import message.MainPlayerGoldAck;
	import message.PaoDan;
	
	import utils.LHelp;
	import utils.LazySprite;
	import utils.SCheckers;
	import utils.SlidePage;
	
	import view.daoju.DaoJuSprite;
	import view.paodan.PaoDanSprite;
	
	public class PaoDanFactoryView extends LazySprite
	{
		private var _ui:PaoDanFactoryUI = new PaoDanFactoryUI;
		private var _schecker:SCheckers;
		
		private var _mc:Sprite;
		private var _mask:BlitMask;
		private var _sp:SlidePage;
		
		public function PaoDanFactoryView()
		{
			addChild(_ui);
			_ui.btnClose.addEventListener(MouseEvent.CLICK, onClose);
			LHelp.AddGrey(_ui.btnHeCheng);
			_ui.btnHeCheng.mouseEnabled = _ui.btnHeCheng.mouseChildren = false;
			_ui.btnHeCheng.addEventListener(MouseEvent.CLICK, onHeChengClick);
			_ui.btnChongZhi.visible = false;
			
			_schecker = new SCheckers([_ui.mcHuoYao, _ui.mcJinShu, _ui.mcTuZhi, _ui.mcBaoShi], {check:_ui.mcHuoYao, click:onTab, effect:SCheckers.EFFECT_GLOW});
			
			addChild(_mc = new Sprite);
			_mask = new BlitMask(_mc, 0, 0, 600, 200);
			_mask.bitmapMode = false;
			
			_sp = new SlidePage(_mc, _mask);
			_sp.enableScrollX = true;
			
			onTab(false);
			printfMoney(Buffer.mainPlayer.gold);
			InitPos();
			
			listen(MySignals.onDaoJuHeChengAck, onDaoJuHeChengAck);
			listen(MySignals.onMainPlayerGoldAck, onMainPlayerGoldNtf);
		}
		
		private function onMainPlayerGoldNtf(mess:MainPlayerGoldAck):void
		{
			printfMoney(mess.gold);
		}
		
		private function clearSelect(index:int):void
		{
			var old:DaoJuSprite = _selects[index];
			var checker:Sprite = _schecker.getCheck(index);
			if(old)
			{
				checker.removeChildAt(numChildren - 1);
				_txts[index].text = "";
				if(index == _schecker.getCheckIndex())
				{
					if(_selects[index])
					{
						LHelp.RemoveGlow(_selects[index]);
					}
				}
				_selects[index] = null;
			}
		}
		
		private var _ps:PaoDanSprite;
		private function onDaoJuHeChengAck(mess:DaoJuHeChengAck):void
		{
			for(var i:int = 0; i < _selects.length; i++)
			{
				clearSelect(i);
			}
			printfSelectDaoJu(null);
			
			if(mess.error == 0)
			{
				_schecker.SetCheck(null);
				var pd:PaoDan = Buffer.GetPaoDanById(mess.paodanId);
				printfPaoDan(pd);
			}
			else
			{
				Test2.Error(mess.error);
			}
		}
		
		private function printfPaoDan(pd:PaoDan):void
		{
			if(_ps)
			{
				if(_ps.parent)_ps.parent.removeChild(_ps);
			}
			
			if(pd)
			{
				_ps = new PaoDanSprite(pd);
				_ui.mcPaoDan.addChild(_ps);
				_ui.txtPaoDan.text = pd.bulletDesc.sold + "G";
				_ui.txtName.text = pd.bulletDesc.tuzhi.name;
				_ui.txtDesc.text = pd.bulletDesc.desc;
				LHelp.Clear(_mc);
				LHelp.AddGlow(_ui.mcPaoDan);
			}
			else
			{
				_ps = null;
				_ui.txtPaoDan.text = "";
				_ui.txtName.text = "";
				_ui.txtDesc.text = "";
				LHelp.RemoveGlow(_ui.mcPaoDan);
			}
		}
		
		protected function onHeChengClick(event:MouseEvent):void
		{
			var mess:DaoJuHeChengReq = new DaoJuHeChengReq;
			for(var i:int = 0; i < _selects.length; i++)
			{
				switch(i)
				{
					case 0:
						mess.huoyao = _selects[i].daoju.id;
						break;
					case 1:
						mess.jinshu = _selects[i].daoju.id;
						break;
					case 2:
						mess.tuzhi = _selects[i].daoju.id;
						break;
					case 3:
						if(_selects[i])
							mess.baoshi = _selects[i].daoju.id;
						break;
				}
			}
			MySignals.Socket_Send.dispatch(mess);
		}
		
		public function InitPos():void
		{
			_ui.x = (StaticTable.STAGE_WIDTH - _ui.width + 45)*.5;
			_ui.y = (StaticTable.STAGE_HEIGHT - _ui.height + 45)*.5;
			_sp.mcX = _ui.x + 211;
			_sp.mcY = _ui.y + 205;
		}
		
		private function printfMoney(gold:int):void
		{
			_ui.txtGold.text = gold + "";
		}
		
		private function onTab(update:Boolean = true):void
		{
			printfPaoDan(null);
			switch(_schecker.getCheckIndex())
			{
				case 0:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.HuoYao))
					break;
				case 1:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.JinShu))
					break;
				case 2:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.TuZhi))
					break;
				case 3:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.BaoShi))
					break;
			}
			
			if(update)
			{
				_mc.x = int(_ui.x + 211);
				_mc.y = int(_ui.y + 205);
			}
		}
		
		public static const PAGE:int = 12;
		public static const LIE:int = 6;
		private function printfDaoJus(djs:Vector.<DaoJu>):void
		{
			TweenLite.killTweensOf(_mc);
			LHelp.Clear(_mc);
			var olds:DaoJuSprite = _select;
			_select = null;
			
			var totalPage:int = djs.length / PAGE + 0.99;
			for(var p:int = 0; p < totalPage; p++)
			{
				var start:int = p * PAGE;
				for(var i:int = 0; i + start < djs.length && i < PAGE; i++)
				{
					var dj:DaoJu = djs[i + start];
					var spt:DaoJuSprite = new DaoJuSprite(dj);
					spt.x = 8 + (i % LIE) * 100 + p * LIE * 100;
					spt.y = 8 + int(i / (LIE)) * 100;
					_mc.addChild(spt);
					_sp.registerClick(DaoJuSprite, onDaoJuSelect);
					if(olds && olds.daoju.id == dj.id)
					{
						_select = spt;
					}
				}
			}
			if(_select)
			{
				onDaoJuSelect(_select, false);
			}
			else
			{
				printfSelectDaoJu(null);
			}
			_mask.update(null, true);
		}
		
		private var _selects:Vector.<DaoJuSprite> = new <DaoJuSprite>[null, null, null, null];
		protected function onDaoJuSelect(ds:DaoJuSprite, isClick:Boolean = true):void
		{
			if(_select)
			{
				LHelp.RemoveGlow(_select);
				if(isClick && _select.daoju.id == ds.daoju.id)
				{
					_select = null;
					printfSelectDaoJu(null);
					return;
				}
			}
			_select = ds;
			LHelp.AddGlow(_select);
			printfSelectDaoJu(_select.daoju);
			
			if(isClick)
			{
				_mask.update(null, true);
			}
		}
		
		private function get _select():DaoJuSprite
		{
			return _selects[_schecker.getCheckIndex()];
		}
		
		private var _txts:Vector.<TextField> = new <TextField>[_ui.txtHuoYao, _ui.txtJinShu, _ui.txtTuZhi, _ui.txtBaoShi];
		private function set _select(ds:DaoJuSprite):void
		{
			var ci:int = _schecker.getCheckIndex();
			var checker:DisplayObjectContainer = _schecker.getCheck();
			var old:DaoJuSprite = _selects[ci];
			if(old)
			{
				checker.removeChildAt(numChildren - 1);
				_txts[ci].text = "";
				_selects[ci] = null;
			}
			if(ds)
			{
				var bmp:Bitmap = StaticTable.GetDaoJuIcon(ds.daoju.itemId);
				checker.addChild(bmp);
				_txts[ci].text = ds.daoju.daojuDesc.sold + "G";
				_selects[ci] = ds;
			}
		}
		
		private function printfSelectDaoJu(dj:DaoJu):void
		{
			if(dj)
			{
				_ui.txtName.text = dj.daojuDesc.name;
				_ui.txtDesc.text = dj.daojuDesc.desc;
			}
			else
			{
				_ui.txtName.text = "";
				_ui.txtDesc.text = "";
			}
			
			var totalMoney:int, countForHeCheng:int;
			for(var i:int = 0; i < _selects.length; i++)
			{
				if(_selects[i])
				{
					totalMoney += _selects[i].daoju.daojuDesc.sold;
					if(i < 3)
					{
						countForHeCheng++;
					}
				}
			}
			
			if(countForHeCheng < 3)
			{
				LHelp.AddGrey(_ui.btnHeCheng);
				_ui.btnHeCheng.mouseEnabled = _ui.btnHeCheng.mouseChildren = false;
			}
			else
			{
				LHelp.RomoveGrey(_ui.btnHeCheng);
				_ui.btnHeCheng.mouseEnabled = _ui.btnHeCheng.mouseChildren = true;
			}
			
			if(totalMoney)
			{
				_ui.txtHeCheng.text = totalMoney + "G";
			}
			else
			{
				_ui.txtHeCheng.text = "";
			}
		}
		
		protected function onClose(event:MouseEvent):void
		{
			MidLayer.CloseWindow(PaoDanFactoryView);
		}
	}
}