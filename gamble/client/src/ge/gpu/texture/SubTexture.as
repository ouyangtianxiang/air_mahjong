package ge.gpu.texture{
	import ge.gpu.vertex.Vertex;

	public class SubTexture extends BaseTexture{
		public function SubTexture(p:BaseTexture,xml:XML){
			super(p.root);
			//<SubTexture name="" x="2" y="174" rotated="true" width="170" height="78" frameX="-476" frameY="-453" frameWidth="1024" frameHeight="1024"/>
			this._rotated=xml.@rotated=="true";
			var w:int=xml.@width;
			var h:int=xml.@height;
			var u:int=xml.@x;
			var v:int=xml.@y;
			this._width=rotated?h:w;
			this._height=rotated?w:h;
			this._u=rotated?v:u;
			this._v=rotated?u:v;
			this._x=int(xml.@frameX);
			this._y=int(xml.@frameY);
			this._fwidth=Math.max(int(xml.@frameWidth),_width);
			this._fheight=Math.max(int(xml.@frameHeight),_height);
			_vertex=new Vertex(u/root.width,v/root.height,w/root.width,h/root.height,_height/_width,rotated);
		}
		
		public override function dispose():void{
			_vertex.dispose();
		}
	}
}