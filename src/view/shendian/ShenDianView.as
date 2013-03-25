package view.shendian
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import data.Buffer;
	import data.MySignals;
	import data.StaticTable;
	import data.staticObj.ShenFuDesc;
	import data.staticObj.ShenJiangDesc;
	
	import lsg.shendian.ShenDianUI;
	
	import message.MainPlayerUpSkillAck;
	
	import utils.LHelp;
	import utils.LazySprite;
	
	public class ShenDianView extends LazySprite
	{
		private static const SCROLL_WIDTH:Number = 656;
		private static const SCROLL_HEIGHT:Number = 430;
		private var _ui:ShenDianUI = new ShenDianUI;
		private var _mc:Sprite;
		private var _mask:Bitmap;
		
		public function ShenDianView()
		{
			addChild(_ui);
			_ui.btnClose.addEventListener(MouseEvent.CLICK, onClose);
			
			_mask = LHelp.GetRectBmp(1,1);
			_mask.width = SCROLL_WIDTH;
			_mask.height = SCROLL_HEIGHT;
			addChild(_mask);
			
			_mc = new Sprite;
			_mc.mask = _mask;
			addChild(_mc);
			
			printfSkills();
			InitPos();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			listen(MySignals.onMainPlayerUpSkillAck, onMainPlayerUpSkillAck);
		}
		
		private function onMainPlayerUpSkillAck(mes:MainPlayerUpSkillAck):void
		{
			printfSkills();
		}
		
		private var _sy:Number, _isClick:Boolean;
		protected function onMouseDown(event:MouseEvent):void
		{
			_sy = _mc.y - event.stageY;
			_isClick = true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private var _select:int;
		protected function onMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if(_isClick)
			{
				var si:ShenDianItem = LHelp.FindParentByClass(event.target as DisplayObject, ShenDianItem);
				if(si)
				{
					_select = si.skillDesc.type;
				}
				else
				{
					var lsi:LockedItem = LHelp.FindParentByClass(event.target as DisplayObject, LockedItem);
					if(lsi)
					{
						_select = lsi.skillDesc.type;
					}
				}
				printfSkills();
			}
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			_mc.y = _sy + event.stageY;
			if(_mc.y > mcOriginalY)
			{
				_mc.y = mcOriginalY;
			}
			else if(_mc.y < mcOriginalY  + SCROLL_HEIGHT - _mc.height)
			{
				_mc.y = mcOriginalY  + SCROLL_HEIGHT - _mc.height;
			}
			if(Math.abs(_mc.y - event.stageY - _sy) > 8)
			{
				_isClick = false;
			}
		}
		
		private var maxY:Number;
		private function printfSkills():void
		{
			TweenLite.killTweensOf(_mc);
			LHelp.Clear(_mc);
			var addY:Number = 0;
			for(var i:int = 0; i < Buffer.mainPlayer.sjs.length; i++)
			{
				var sk:ShenJiangDesc = Buffer.mainPlayer.sjs[i];
				if(sk.type != _select)
				{
					var si:ShenDianItem = new ShenDianItem(sk);
					si.cacheAsBitmap = true;
					si.y = 87 * i + addY;
					_mc.addChild(si);
				}
				else
				{
					var esi:ExpandShenDianItem = new ExpandShenDianItem(sk);
					esi.cacheAsBitmap = true;
					esi.y = 87 * i;
					_mc.addChild(esi);
					addY = 161 - 82;
				}
			}
			
			for(; i < Buffer.mainPlayer.sfs.length + 5; i++)
			{
				var sf:ShenFuDesc = Buffer.mainPlayer.sfs[i-5];
				if(sf.type != _select)
				{
					if(sf.locked)
					{
						var lsi:LockedItem = new LockedItem(sf);
						lsi.cacheAsBitmap = true;
						lsi.y = 87 * i + addY;
						_mc.addChild(lsi);
					}
					else
					{
						si = new ShenDianItem(sf);
						si.cacheAsBitmap = true;
						si.y = 87 * i + addY;
						_mc.addChild(si);
					}
				}
				else
				{
					if(sf.locked)
					{
						var elsi:ExpandLockedItem = new ExpandLockedItem(sf);
						elsi.cacheAsBitmap = true;
						elsi.y = 87 * i;
						_mc.addChild(elsi);
						addY = 161 - 82;
					}
					else
					{
						esi = new ExpandShenDianItem(sf);
						esi.cacheAsBitmap = true;
						esi.y = 87 * i;
						_mc.addChild(esi);
						addY = 161 - 82;
					}
				}
			}
		}
		
		protected function onSiClick(event:MouseEvent):void
		{
			
		}
		
		public function get mcOriginalY():Number
		{
			return _ui.y + 56;
		}
		
		public function get mcOriginalX():Number
		{
			return _ui.x + 22;
		}
		
		public function InitPos():void
		{
			_ui.x = (StaticTable.STAGE_WIDTH - _ui.width + 45)*.5;
			_ui.y = (StaticTable.STAGE_HEIGHT - _ui.height + 45)*.5;
			_mc.x = mcOriginalX;
			_mc.y = mcOriginalY;
			_mask.x = _mc.x;
			_mask.y = _mc.y;
		}
		
		protected function onClose(event:MouseEvent):void
		{
			MidLayer.CloseWindow(ShenDianView);
		}
	}
}