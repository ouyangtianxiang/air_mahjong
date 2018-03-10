package ge.gpu.display{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import ge.events.GameEvent;
	import ge.global.GM;
	import ge.gpu.index.IndexQuad;
	import ge.gpu.program.Program;
	import ge.gpu.texture.BaseTexture;
	import ge.gpu.utils.ColorTransform;
	
	
	
	public class Quad extends GameObject{
		
		public function Quad(){
		}
		
		protected function mouseHit(event:Event):Boolean{
			return _texture.width*absScaleX/(GameEvent.StageX(event)-drawX)>=1&&_texture.height*absScaleY/(GameEvent.StageY(event)-drawY)>=1;
		}
		
		internal override function dispatch(event:Event):Boolean{
			if(mouseEnabled && visible && _texture){
				if(mouseHit(event)){
					dispatchEvent(event);
					return true;
				}
			}
			return false;
		}
		
		private var _texture:BaseTexture;
		protected var _intersect:Boolean;
		
		public function get texture():BaseTexture{
			return _texture;
		}
		
		public function get anchorX() : Number {
			return _anchorX;
		}
		
		public function get anchorY() : Number {
			return _anchorY;
		}
		
		private var _anchorX:Number=0;
		private var _anchorY:Number=0;
		private var ax:Number=0;
		private var ay:Number=0;
		public function anchor(ax:Number,ay:Number):void{
			this.ax=ax;
			this.ay=ay;
			_anchorX=_width*ax;
			_anchorY=_height*ay;
			position();
		}	
		
		public function set texture(value:BaseTexture):void	{
			this._texture=value;
			size();
			position();
		}
		
		
		public function get drawX() : Number {
			return absX-absScaleX*anchorX;
		}
		
		public function get drawY() : Number {
			return absY-absScaleY*anchorY;
		}

		
		protected var matrix3D:Matrix3D=new Matrix3D();
		protected override function onPosition():void{
			if(_texture){
				var _x:Number=drawX/GM.GameWidth*2-1;
				var _y:Number=(GM.GameHeight-drawY)/GM.GameHeight*2-1;
				var sx:Number=absScaleX*_texture.width/GM.GameWidth*2;
				var sy:Number=absScaleY*_texture.width/GM.GameHeight*2;
				matrix3D.identity();
				if(_rotation){
					matrix3D.appendRotation(_rotation,Vector3D.Z_AXIS,new Vector3D(anchorX/_texture.width,-anchorY/_texture.width,0));
				}
				matrix3D.appendScale(sx,sy,1);
				matrix3D.appendTranslation(_x,_y,0);
				_intersect=Game3D.it.intersect(drawX,drawY,_texture.width*absScaleX,_texture.height*absScaleY);
			}
		}
		private var _rotation:Number=0;
		
		private var sourceFactor:String=Context3DBlendFactor.SOURCE_ALPHA;
		private var destinationFactor:String=Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
		public function set blendModeADD(value:Boolean):void{
			if(value){
				this.sourceFactor=Context3DBlendFactor.ONE;
				this.destinationFactor=Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
			}else{
				this.sourceFactor=Context3DBlendFactor.SOURCE_ALPHA;
				this.destinationFactor=Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			}
		}
		
		public function get rotation():Number{
			return _rotation;
		}
		
		public function set rotation(value:Number):void{
			if(_rotation!=value){
				_rotation = value;
				position();
			}
		}
		
		protected override function onRender(context3D:Context3D):void{
			if(_intersect && _texture){
				if(_colorTransform){
					_colorTransform.render(context3D,_texture.program);
				}else{
					context3D.setProgram (_texture.program.program(Program.DEFAULT));
				}
				if(_texture.render(context3D)){
					context3D.setBlendFactors(sourceFactor, destinationFactor);
					context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix3D, true);
					context3D.drawTriangles(IndexQuad.it.buffer);
				}
			}
		}
		
		private var _width:Number=0;
		private var _height:Number=0;
		private function size():void{
			if(_texture){
				_width=_texture.width*_scaleX;
				_height=_texture.height*_scaleY;
				anchor(ax,ay);
			}
		}
		
		public function circle(x:Number,y:Number,r:Number):void{
			_colorTransform=new ColorTransform();
			_colorTransform.circle(x,y,r);
		}
		
		public function get width():int{
			return _width;
		}
		
		public function get height():int{
			return _height;
		}
		
		public override function set scaleX(value:Number):void{
			super.scaleX=value;
			size();
		}
		
		public override function set scaleY(value:Number):void{
			super.scaleY=value;
			size();
		}
	}
}