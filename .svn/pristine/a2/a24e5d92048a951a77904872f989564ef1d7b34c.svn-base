package ge.gpu.display {
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	
	import ge.events.GameEvent;
	import ge.events.GameEventDispatcher;
	import ge.global.GM;
	import ge.gpu.index.IndexQuad;
	import ge.gpu.program.AGAL;
	import ge.gpu.texture.ATFTexture;
	
	public class Game3D extends GameObject {
		public static var it : Game3D;
		private var context3D : Context3D;
		private var _stage : Stage;
		private var game : GameObject;
		private var MainClass : Class;
		
		public function Game3D(_stage : Stage, mainClass : Class) {
			it = this;
			this._stage = _stage;
			this.MainClass = mainClass;
			_stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			_stage.stage3Ds[0].requestContext3D();
			_stage.addEventListener(GameEvent.DOWN, onMouseDown);
			_stage.addEventListener(GameEvent.UP, onMouseUp);
			mouseEnabled = true;
		}
		
		protected function onMouseDown(event : Event) : void {
			if (event.target == event.currentTarget) {
				GameEventDispatcher.Press(event);
				dispatch(event);
			}
		}
		
		protected function onMouseUp(event : Event) : void {
			if (event.target == event.currentTarget) {
				dispatch(event);
				GameEventDispatcher.Release(event);
			}
		}
		
		public function intersect(x : Number, y : Number, width : Number, height : Number) : Boolean {
			var top : int = Math.ceil(height > 0 ? y : y + height);
			var below : int = height < 0 ? y : y + height;
			var left : int = Math.ceil(width > 0 ? x : x + width);
			var right : int = width < 0 ? x : x + width;
			return !(left >= GM.GameWidth || top >= GM.GameHeight || right <= 0 || below <= 0);
		}
		
		private function onContext3DCreate(event : Event) : void {
			var stage3d : Stage3D = event.target as Stage3D;
			context3D = stage3d.context3D;
			if (context3D == null) {
				return;
			}
			if (game == null) {
				game = new MainClass();
				addChild(game);
			}
			context3D.enableErrorChecking = GM.Debug;
			context3D.setDepthTest(true, Context3DCompareMode.ALWAYS);
			context3D.configureBackBuffer(stage.fullScreenWidth, stage.fullScreenHeight, 0, true);
			
			scaleX = GM.GameWidth / stage.fullScreenWidth;
			scaleY = GM.GameHeight / stage.fullScreenHeight;
			game.position();
			
			ATFTexture.Init(context3D);
			IndexQuad.Init(context3D);
			AGAL.Init(context3D);
			
			onActivaie();
		}
		
		public function onActivaie() : void {
			_stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function onDeactivate() : void {
			_stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e : Event) : void {
			if (context3D) {
				context3D.clear(0, 0, 0, 1);
				render(context3D);
				context3D.present();
			}
		}
		
		public override function get stage() : Stage {
			return _stage;
		}
	}
}
