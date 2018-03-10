package ge.gpu.texture{
	import ge.gpu.vertex.Vertex;
	
	
	public class SliceTexture extends BaseTexture{
		public function SliceTexture(p:BaseTexture,u:int,v:int,w:int,h:int,rotated:Boolean){
			super(p.root);
			this._width=w;
			this._height=h;
			var _w:int=rotated?h:w;
			var _h:int=rotated?w:h;
			this._u=rotated?p.v+p.height-v-h:p.u+u;
			this._v=rotated?p.u+u:p.v+v;
			_vertex=new Vertex(_u/root.width,_v/root.height,_w/root.width,_h/root.height,_height/_width,rotated);
		}
		
		public override function dispose():void{
			_vertex.dispose();
		}
	}
}

