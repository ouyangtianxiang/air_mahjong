package ge.gpu.display {
	import ge.gpu.texture.ATFTexture;
	import ge.gpu.texture.BaseTexture;
	import ge.gpu.texture.MCTexture;
	
	public class MCBase extends Quad {
		private var atf:ATFTexture;
		internal var len : int;
		private var _g:*=0;
		private var group:Vector.<int>;
		private var callback:Function;
		
		public function load(url : String,callback:Function=null) : void {
			len=100;
			this.callback=callback;
			MCTexture.Load(url,onLoad);
		}
		
		public function set g(value:*):void{
			_g = value;
			if(atf){
				group=atf.group[value];
				if(group){
					len = group.length;
				}
			}
		}
		
		private function onLoad(atf:ATFTexture):void{
			this.scale=atf.scale;
			this.atf=atf;
			if(atf.type==0||atf.type==2||atf.type==3){
				blendModeADD=true;
			}
			g=_g;
			if(callback!=null){
				callback();
				callback=null;
			}
		}
		
		public function frame(fram : uint) : void {
			if (group && group.length > fram) {
				var tg : BaseTexture = atf.subtexture[group[fram]];
				anchor(tg.fwidth/2, tg.fheight/2);
				texture = tg;
			}
		}
		
		public function clear() : void {
			group = null;
			atf=null;
			texture = null;
		}
	}
} 