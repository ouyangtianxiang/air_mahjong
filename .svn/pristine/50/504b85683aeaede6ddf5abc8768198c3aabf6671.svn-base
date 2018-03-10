package ge.gpu.display {
	import ge.events.GameEvent;
	
	
	public class CheckBox extends ImageBtn {
		private var group:Object;
		
		public function CheckBox(c : GameObject, x : int, y : int, img : String,mark:String,text:String,color:uint,group:Object,def:Boolean=false) {
			super(c, x, y, img);
			this.group=group;
			this.mark(mark);
			var txt:GameText=new GameText(this,20,0,color);
			txt.anchor(0,0.5);
			txt.text=text;
			select=def;
			
			this.addEventListener(GameEvent.CLICK,onClick);
		}
		
		private function onClick(o:GameObject):void
		{
			if(!select){
				select=!select;
			}
		}
		
		public override function set select(value:Boolean):void{
			_mark.visible=value;
			if(value){
				if(group.obj!=null){
					group.obj.select=false;
				}
				group.obj=this;
			}
		}
		
		public override function get select():Boolean{
			return _mark.visible;
		}
	}
}
