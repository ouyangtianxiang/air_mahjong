package ge.gpu.display {
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.events.Event;
	
	import ge.events.GameEventDispatcher;
	import ge.gpu.utils.ColorTransform;
	
	public class GameObject extends GameEventDispatcher {
		public const list:Vector.<GameObject>=new Vector.<GameObject>;
		public var name : *;
		private var _stage : Stage;
		protected var _visible : Boolean = true;
		private var _x : Number = 0;
		private var _y : Number = 0;
		internal var _parent : GameObject;
		protected var _scaleX : Number = 1;
		protected var _scaleY : Number = 1;
		private var _mouseEnabled : Boolean = false;
		
		public function GameObject() {
		}
		
		public function get mouseEnabled() : Boolean {
			return _mouseEnabled;
		}
		
		public function set mouseEnabled(value : Boolean) : void {
			_mouseEnabled = value;
		}
		
		internal function dispatch(event : Event) : Boolean {
			if(mouseEnabled && visible){
				for(var i:int=list.length-1;i>=0;i--){
					if(list[i].dispatch(event)){
						dispatchEvent(event);
						return true;
					}
				}
			}
			return false;
		}
		
		public function addChild(child:GameObject):void{
			child.remove();
			list.push(child);
			child._parent=this;
			child.position();
			child.stage=stage;
		}
		
		public function addChildAt(child:GameObject,i:uint):void{
			child.remove();
			list.splice(i,0,child);
			child._parent=this;
			child.position();
			child.stage=stage;
		}
		
		public function removeChild(child:GameObject):void{
			var i:int=list.indexOf(child);
			if(i>=0){
				child._parent=null;
				list.splice(i,1);
				child.stage=null;
			}
		}
		
		public function removeChildAll():void{
			while(list.length>0){
				var child:GameObject=list.shift();
				child._parent=null;
				child.stage=null;
			}
		}
		
		public function remove() : void {
			if (_parent) {
				_parent.removeChild(this);
			}
		}
		
		internal function render(context3D : Context3D) : void {
			if (_visible) {
				onRender(context3D);
				for(var i:int=0;i<list.length;i++){
					list[i].render(context3D);
				}
			}
		}
		
		protected function onRender(context3D : Context3D) : void {
		}
		
		private var _absScaleX : Number = 1;
		private var _absScaleY : Number = 1;
		private var _absX : Number = 0;
		private var _absY : Number = 0;
		
		public function get absX() : Number {
			return _absX;
		}
		
		public function get absY() : Number {
			return _absY;
		}

		
		public function get absScaleX() : Number {
			return _absScaleX;
		}
		
		public function get absScaleY() : Number {
			return _absScaleY;
		}
		
		public function set scale(value : Number) : void {
			if (_scaleX != value || _scaleY != value) {
				_scaleX = value;
				_scaleY = value;
				position();
			}
		}
		
		public function get scaleX() : Number {
			return _scaleX;
		}
		
		public function set scaleX(value : Number) : void {
			if (_scaleX != value) {
				_scaleX = value;
				position();
			}
		}
		
		public function get scaleY() : Number {
			return _scaleY;
		}
		
		public function set scaleY(value : Number) : void {
			if (_scaleY != value) {
				_scaleY = value;
				position();
			}
		}
		
		
		internal function position() : void {
			if (_parent) {
				_absScaleX = _scaleX * _parent.absScaleX;
				_absScaleY = _scaleY * parent.absScaleY;
				_absX = _x * _parent.absScaleX + _parent.absX;
				_absY = _y * parent.absScaleY + _parent.absY;
				onPosition();
				for(var i:int=0;i<list.length;i++){
					list[i].position();
				}
			}
		}
		
		protected function onPosition() : void {
		}
		
		public function get parent() : GameObject {
			return _parent;
		}
		
		public function get x() : Number {
			return _x;
		}
		
		public function set x(value : Number) : void {
			if (_x != value) {
				_x = value;
				position();
			}
		}
		
		public function get y() : Number {
			return _y;
		}
		
		public function set y(value : Number) : void {
			if (_y != value) {
				_y = value;
				position();
			}
		}
		
		public function get visible() : Boolean {
			return _visible;
		}
		
		public function set visible(value : Boolean) : void {
			_visible = value;
		}
		
		public function get stage() : Stage {
			return _stage;
		}
		
		public function set stage(value : Stage) : void {
			if (value != _stage) {
				if (value) {
					_stage = value;
					for(var i:int=0;i<list.length;i++){
						list[i].stage=value;
					}
					onPosition();
					onAddedStage();
				} else {
					onRemoveStage();
					for(var l:int=list.length-1;l>=0;l--){
						list[l].stage=value;
					}
					_stage = value;
				}
			}
		}
		
		protected var _gray : Boolean;
		
		public function get gray() : Boolean {
			return _gray;
		}
		
		public function set gray(value : Boolean) : void {
			if(_gray != value){
				_gray = value;
				colorTransform();
				for each (var o:GameObject in list){
					o.gray=value;
				}
			}
		}
		
		protected var _alpha:Number=1;
		
		public function get alpha():Number{
			return _alpha;
		}
		
		public function set alpha(value:Number):void{
			if(_alpha!=value){
				_alpha=value;
				colorTransform();
				for each (var o:GameObject in list){
					o.alpha=value;
				}
			}
		}
		
		protected var _color:uint=0xFFFFFF;
		protected var _overlap:Boolean=false;
		
		public function setColor(value:uint,overlap:Boolean=false):void{
			if(_color!=value||_overlap!=overlap){
				_color=value; 
				_overlap=overlap; 
				colorTransform();
				for each (var o:GameObject in list){
					o.setColor(value,overlap);
				}
			}
		}
		
		protected var _colorTransform:ColorTransform;
		protected function colorTransform():void{
			if(_color==(_overlap?0:0xFFFFFF)&&_alpha==1&&!_gray){
				_colorTransform=null;
			}else{
				if(_colorTransform==null){
					_colorTransform=new ColorTransform();
				}
				if(_gray){
					_colorTransform.gray(_alpha);	
				}else{
					_colorTransform.color(_color,_alpha,_overlap);
				}
			}
		}
		
		public function onAddedStage() : void {
		}
		
		public function onRemoveStage() : void {
		}
		
		public function dispose():void{
			while(list.length>0){
				var child:GameObject=list.shift();
				child._parent=null;
				child.stage=null;
				child.dispose();
			}
		}
	}
}
