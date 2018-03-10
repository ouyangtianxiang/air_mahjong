package ge.utils{
	import ge.gpu.display.GameObject;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class Shake implements ITick{
		private static var _it : Shake;
		
		public static function get it() : Shake {
			if (_it == null) {
				_it = new Shake();
			}
			return _it;
		}
		private var obj:GameObject;
		public function start(obj:GameObject,sum:int,type:int=0):void{
			this.obj=obj;
			i = 0;
			index = 0;
			shakeType = type;
			this.sum = sum;
			Tick.addTick(this);
		}
		private var shakeType : int
		private var shakes : Array = [7, -7];
		private var i : int;
		private var index : int;
		private var sum : int;
		
		public function run(dt : Number) : void {
			if (i < shakes.length) {
				if (shakeType == 0) {
					obj.x = shakes[i++];
				} else {
					obj.y = shakes[i++];
				}
			} else {
				index++;
				i = 0;
				if (index == sum) {
					obj.y = 0;
					obj.x = 0;
					Tick.removeTick(this);
				}
				
			}
		}
		
	}
}