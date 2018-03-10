package ge.net.view
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ge.net.Table;
	
	public class TableView extends Sprite
	{
		private static var _it : TableView;
		
		public static function get it() : TableView {
			if (_it == null) {
				_it = new TableView();
			}
			return _it;
		}
		public function TableView(){
			this.graphics.beginFill(0x666666, .8);
			this.graphics.drawRect(0, 0, 1000, 580);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		private function onAdded(event : Event) : void {
			Refresh();
		}
		public function Refresh() : void {
			var array : Array = [];
			for each (var table:Table in Table.array){
				if(table){
					array.push(table);
				}
			}
			array.sortOn("name");
			for (var i : int = 0;i < array.length;i++) {
				new TableIcon(this, int(i / 29) * 150, i % 29 * 20, array[i]);
			}
		}
		public function show(c:DisplayObjectContainer,x:int,y:int):void{
			this.x=x;
			this.y=y;
			c.addChild(this);			
		}
		public function hide() : void {
			this.parent.removeChild(this);
			while (numChildren > 0) {
				removeChildAt(0);
			}
		}
	}
}