package ge.gpu.display {
	import flash.events.Event;
	
	import ge.gpu.texture.BaseTexture;
	import ge.gpu.texture.LoadTexture;
	import ge.gpu.texture.UITexture;
	
	public class Image extends Quad {
		private var _img : String;
		
		public function Image(c : GameObject, x : int, y : int, img : String = null) {
			this.x = x;
			this.y = y;
			if (c != null) {
				c.addChild(this);
			}
			this.img = img;
		}
		
		public function get img():String{
			return _img;
		}
		
		public function set img(value : String) : void {
			_img = value;
			texture = value == null ? null : UITexture.UI( _img);
		}
		
		private var url:String;
		public function load(url : String) : void {
			this.url=url;
			LoadTexture.Load(url, onLoad);
		}
		
		private function onLoad(texture : BaseTexture) : void {
			if(texture.url.indexOf(url)==0){
				this.texture = texture;
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function unload() : void {
			this.texture = null;
		}
	}
}
