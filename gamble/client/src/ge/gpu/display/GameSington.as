package ge.gpu.display {
	import flash.display3D.Context3D;
	import flash.events.Event;
	
	
	
	public class GameSington extends GameObject {
		public function GameSington(c : GameObject, mouseEnabled : Boolean = true) {
			c.addChild(this);
			this.mouseEnabled = mouseEnabled;
		}
		
		public var child : GameObject;
		
		internal override function render(context3D : Context3D) : void {
			if (_visible && child) {
				child.render(context3D);
			}
		}
		
		internal override function dispatch(event : Event) : Boolean {
			if (_visible && child && child.mouseEnabled) {
				return child.dispatch(event);
			}
			return false;
		}
		
		public override function addChild(child : GameObject) : void {
			if (this.child) {
				this.child.stage = null;
			}
			super.addChild(child);
			this.child = child;
		}
		
		public override function addChildAt(child : GameObject, i : uint) : void {
			throw new Error("GameSington cannot addChildAt...");
		}
		
		public override function removeChild(child : GameObject) : void {
			super.removeChild(child);
			this.child = list.length > 0 ? list[list.length - 1] : null;
			if (this.child) {
				this.child.stage = stage;
			}
		}
	}
}
