package ge.gpu.display{
	
	
	public class IScroll extends GameObject{
		public var callback:Function;
		internal var _index:int;
		internal var _width:int;
		internal var _height:int;

		public function get width():int{
			return _width;
		}

		public function get height():int{
			return _height;
		}

		public function IScroll(){
			this.mouseEnabled=true;
		}
		
		public function init():void{
		}

		public function get index():int	{
			return _index;
		}

		public function data(o:*):void{
			throw new Error("not override");
		}
	}
}