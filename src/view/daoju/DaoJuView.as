package view.daoju
{
	import com.greensock.BlitMask;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	
	import lsg.DaoJuUI;
	
	import message.DaoJu;
	import message.DaoJuDeleteNtf;
	import message.DaoJuSoldAck;
	import message.DaoJuSoldReq;
	import message.EnumDaoJuType;
	import message.MainPlayerGoldNtf;
	
	import utils.LHelp;
	import utils.LazySprite;
	import utils.MCheckers;
	import utils.SlidePage;
	
	public class DaoJuView extends LazySprite
	{
		private var _ui:DaoJuUI;
		private var _lchecker:MCheckers;
		private var _content:Sprite;
		private var _mask:BlitMask;
		private var _sp:SlidePage;
		
		public function DaoJuView()
		{
			addChild(_ui = new DaoJuUI);
			_lchecker = new MCheckers([_ui.tabCaiLiao, _ui.tabTuZhi, _ui.tabBaoShi], {over:1, select:2, check:_ui.tabCaiLiao, click:onTab});
			_ui.btnClose.addEventListener(MouseEvent.CLICK, onClose);
			_ui.btnChuShou.addEventListener(MouseEvent.CLICK, onSold);
			
			addChild(_content = new Sprite);
			_mask = new BlitMask(_content, 0, 0, 500, 400);
			_mask.bitmapMode = false;
			
			_sp = new SlidePage(_content, _mask);
			_sp.enableScrollX = true;
			
			printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.HuoYao, EnumDaoJuType.JinShu));
			printfMoney(Buffer.mainPlayer.gold);
			
			listen(MySignals.onDaoJuSoldAck, onDaoJuSoldAck);
			listen(MySignals.onMainPlayerGoldNtf, onMainPlayerGoldNtf);
			
			InitPos();
		}
		
		public function InitPos():void
		{
			_ui.x = (StaticTable.STAGE_WIDTH - _ui.width + 45)*.5;
			_ui.y = (StaticTable.STAGE_HEIGHT - _ui.height + 45)*.5;
			_sp.mcX = _ui.x + 268;
			_sp.mcY = _ui.y + 20;
		}
		
		private function onDaoJuSoldAck(dj:DaoJuSoldAck):void
		{
			if(dj.error == 0)
			{
				onTab(false);
			}
			else
			{
				Test2.Error(dj.error);
			}
		}
		
		private function onMainPlayerGoldNtf(mpgn:MainPlayerGoldNtf):void
		{
			printfMoney(mpgn.gold);
		}
		
		protected function onSold(event:MouseEvent):void
		{
			Test2.Warn("您是否出售" + _select.daoju.daojuDesc.name + "?", onSoldOK);
		}
		
		private function onSoldOK():void
		{
			if(_select)
			{
				var dsr:DaoJuSoldReq = new DaoJuSoldReq;
				dsr.id = _select.daoju.id;
				dsr.count = 1;
				MySignals.Socket_Send.dispatch(dsr);
			}
		}
		
		private function onTab(update:Boolean = true):void
		{
			switch(_lchecker.getCheckIndex())
			{
				case 0:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.HuoYao, EnumDaoJuType.JinShu))
					break;
				case 1:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.TuZhi))
					break;
				case 2:
					printfDaoJus(Buffer.GetDaoJusByType(EnumDaoJuType.BaoShi))
					break;
			}
			
			if(update)
			{
				_content.x = _ui.x + 268;
				_content.y = _ui.y + 20;
			}
		}
		
		protected function onClose(event:MouseEvent):void
		{
			MidLayer.CloseWindow(DaoJuView);
		}
		
		private function printfMoney(gold:int):void
		{
			_ui.txtGold.text = gold + "";
		}
		
		public static const PAGE:int = 20;
		private function printfDaoJus(djs:Vector.<DaoJu>):void
		{
			TweenLite.killTweensOf(_content);
			LHelp.Clear(_content);
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
					spt.x = 8 + (i % 5) * 100 + p * 500;
					spt.y = 8 + int(i / 5) * 100;
					_content.addChild(spt);
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
		
		private var _select:DaoJuSprite;
		protected function onDaoJuSelect(ds:DaoJuSprite, update:Boolean = true):void
		{
			if(_select)
			{
				LHelp.RemoveGlow(_select);
			}
			_select = ds;
			LHelp.AddGlow(_select);
			printfSelectDaoJu(_select.daoju);
			if(update)
			{
				_mask.update(null, true);
			}
		}
		
		private function printfSelectDaoJu(dj:DaoJu):void
		{
			if(dj)
			{
				_ui.txtName.text = dj.daojuDesc.name;
				_ui.txtDesc.text = dj.daojuDesc.desc;
				_ui.txtSold.text = dj.daojuDesc.sold + "";
				_ui.btnChuShou.visible = true;
			}
			else
			{
				_ui.txtName.text = "";
				_ui.txtDesc.text = "";
				_ui.txtSold.text = "";
				_ui.btnChuShou.visible = false;
			}
		}
		
	}
}