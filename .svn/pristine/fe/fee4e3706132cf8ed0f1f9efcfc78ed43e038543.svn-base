package ge.net.view
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ge.net.Bean;
	import ge.net.Table;
	
	public class Insert extends Sprite
	{
		private static var _it : Insert;
		private var table : Table;
		
		public static function get it() : Insert {
			if (_it == null) {
				_it = new Insert();
			}
			return _it;
		}
		private var array:Array=new Array();
		public function Insert(){
			this.graphics.beginFill(0xece9d8);
			this.graphics.drawRect(0, 20, 1000, 580);
			
			new Btn(this, 880, 560, 35, 18, "new",0x55AA55).addEventListener(MouseEvent.CLICK, onClickNew);
			
		}
		
		private function onClickNew(event:MouseEvent):void{
			var param:Array=[];
			for(var i:int=0;i<table.names.length;i++){
				var value:String=array[i].value;
				if(table.keys[0]==i){
					if(table.getObj(value)){
						array[i].error();
						return;
					}
				}
				param.push(value);
			}
			DataView.it.insert(param);
			hide();
		}
		
		public function hide() : void {
			if(parent){
				parent.removeChild(this);
			}
		}
		
		public function open(table : Table) : void {
			this.table = table;
			View.it.addChild(this);
			var o:Bean=table.getObj();
			for each (var it:IItem in array) {
				it.visible=false;
			}
			
			for(var i:int=0;i<table.names.length;i++){
				item(i).data(table.names[i],o);
			}
		}
		
		public function item(i:int):IItem{
			if(array[i]==null){
				array[i]=new IItem(this,int(i/20)*250,i%20*25+50);
			}
			return array[i];
		}
	}
}
