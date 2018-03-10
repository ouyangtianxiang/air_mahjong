package ge.net.view {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	
	import ge.global.GM;
	import ge.net.Bean;
	import ge.net.Table;
	import ge.net.TableEvent;
	import ge.utils.tick.Tick;
	
	/**
	 * @author tianxiang.ouyang
	 */
	public class DataView extends Sprite {
		private static var _it : DataView;
		private var pageTxt : VText;
		
		public static function get it() : DataView {
			if (_it == null) {
				_it = new DataView();
			}
			return _it;
		}
		
		
		private static const rowsCount : int = 30;
		public static const colsCount : int = 10;
		
		private var page : int=0;
		private var maxPage : int;
		private var data : Array;
		
		private var rows:Vector.<Row>=new Vector.<Row>(rowsCount);
		private var head:Head;
		private var table : Table;
		private var tableName : VText;
		public var names:Array;
		private var sync:Btn;
		
		public function DataView() {
			this.graphics.beginFill(0xd1e6f3, .8);
			this.graphics.drawRect(0, 20, 1000, 580);
			
			cacheAsBitmap = true;
			
			tableName = new VText(this, "", 0, 0, 0xFFFFFF);
			
			sync=new Btn(this, 540, 1,  35, 18, "同步",0xFF0000);
			sync.addEventListener(MouseEvent.CLICK, onClickU);
			new Btn(this, 600, 1,  35, 18, "首页",0x55AA55).addEventListener(MouseEvent.CLICK, onClickPage1);
			new Btn(this, 640, 1,  35, 18, "上页",0x55AA55).addEventListener(MouseEvent.CLICK, onClickPage2);
			pageTxt = new VText(this, "0", 680, 0, 0xFFFFFF, 12, 35, 20);
			pageTxt.align = TextFormatAlign.CENTER;
			new Btn(this, 720, 1, 35, 18, "下页",0x55AA55).addEventListener(MouseEvent.CLICK, onClickPage3);
			new Btn(this, 760, 1, 35, 18, "未页",0x55AA55).addEventListener(MouseEvent.CLICK, onClickPage4);
			
			new Btn(this, 800, 1, 35, 18, "《《",0x55AA55).addEventListener(MouseEvent.CLICK, onClickCols1);
			new Btn(this, 840, 1, 35, 18, "》》",0x55AA55).addEventListener(MouseEvent.CLICK, onClickCols2);
			new Btn(this, 880, 1, 35, 18, "new",0x55AA55).addEventListener(MouseEvent.CLICK, onClickNew);
			
			head=new Head(this,0,20);
			for(var i:int=0;i<rowsCount;i++){
				rows[i]=new Row(this,0,i*18+40,i);
			}
		}
		
		protected function onClickU(event:MouseEvent):void{
			sync.text.color=sync.text.color==0xFFFFFF?0x666666:0xFFFFFF;
		}		
		
		public function insert(param:Array):void{
			GM.dispatchEvent(new ViewEvent(ViewEvent.INSERT,table.name,0,0,0,param));
		}
		
		public function del(o:Bean,name:String=null,n:int=0):void{
			GM.dispatchEvent(new ViewEvent(ViewEvent.DELETE,table.name,o.key,0,0,null));
		}
		
		public function update(o:Bean,fname:String,n:int):Boolean{
			if(sync.text.color==0xFFFFFF){
				var fieldIndex:int=table.names.indexOf(fname);
				GM.dispatchEvent(new ViewEvent(ViewEvent.UPDATE,table.name,o.key,fieldIndex,n,null));
				return true;
			}
			return false;
		}
		
		public function hide() : void {
			if(parent){
				parent.removeChild(this);
			}
			table.removeEventListener(TableEvent.DELETE, onChangeData);
			table.removeEventListener(TableEvent.INSERT, onChangeData);
			table.removeEventListener(TableEvent.UPDATE, onChangeData);
		}
		
		public function open(table : Table) : void {
			this.table = table;
			View.it.addChild(this);
			table.addEventListener(TableEvent.DELETE, onChangeData);
			table.addEventListener(TableEvent.INSERT, onChangeData);
			table.addEventListener(TableEvent.UPDATE, onChangeData);
			
			names=[];
			for(var i:int=0;i<table.names.length;i++){
				if(table.maps[i]){
					names.push(table.names[i]);
				}
			}
			cols=0;
			maxCols=Math.max(names.length-colsCount,0);
			tableName.text = table.name + " ( key: [" + keyValue() + "] )";
			init();
		}
		
		private function keyValue():Array{
			var value:Array=[];
			for(var i:int=0;i<table.keys.length;i++){
				value[i]=table.names[table.keys[i]];
			}
			return value;
		}
		
		private function onChangeData(event : TableEvent) : void {
			Tick.nextFrame(init);
		}
		
		private var cols:int;
		private var maxCols:int;
		private function refresh(index:int):void{
			cols = Math.min(maxCols, Math.max(0, index));
			head.refresh(cols);
			for (var i : int = 0;i < rowsCount;i++) {
				rows[i].refresh(cols);
			}
			Row.btn1.remove();
			Field.btn1.remove();
			Field.btn2.remove();
		}
		
		public function init() : void {
			data=table.getList(true);
			var names:Array=[];
			for(var i:int=0;i<table.keys.length;i++){
				names.push(table.names[table.keys[i]]);
			}
			data.sortOn(names, Array.NUMERIC);
			maxPage = int(data.length / rowsCount);
			Page(page);
		}
		
		private function onClickNew(event : MouseEvent) : void {
			Insert.it.open(table);
		}
		
		private function onClickPage1(event : MouseEvent) : void {
			Page(0);
		}
		
		private function onClickPage2(event : MouseEvent) : void {
			Page(page - 1);
		}
		
		private function onClickPage3(event : MouseEvent) : void {
			Page(page + 1);
		}
		
		private function onClickPage4(event : MouseEvent) : void {
			Page(maxPage);
		}
		
		private function onClickCols1(event : MouseEvent) : void {
			refresh(cols-1);
		}
		
		private function onClickCols2(event : MouseEvent) : void {
			refresh(cols+1);
		}
		
		private function Page(index : int) : void {
			page = Math.min(maxPage, Math.max(0, index));
			pageTxt.text = (page + 1) + "/" + (maxPage + 1);
			for (var i : int = 0;i < rowsCount;i++) {
				rows[i].Obj(data[i + page * rowsCount]);
			}
			refresh(cols);
		}
	}
}
