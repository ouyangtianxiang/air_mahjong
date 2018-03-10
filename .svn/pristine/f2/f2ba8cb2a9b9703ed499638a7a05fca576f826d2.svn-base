package game.effect {
	import flash.events.Event;
	
	import ge.global.Atf;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.Image;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class Turn extends Image implements ITick {
		private var scaleValue : Number;
		private var isBlendModeADD : Boolean;
		private var speed : int;
		
		public function Turn(c : GameObject, x : int, y : int, img : int, scaleValue : Number = 1, isBlendModeADD : Boolean = true, speed : int = 3) {
			super(c, x, y);
			this.scaleValue = scaleValue;
			this.isBlendModeADD = isBlendModeADD;
			this.speed = speed;
			addEventListener(Event.COMPLETE, complete);
			load("res/other/" + img + Atf);
		}
		
		private function complete(event : Image) : void {
			anchor(this.width / 2, this.height / 2);
			scale = scaleValue;
			blendModeADD = isBlendModeADD;
		}
		
		public override function onAddedStage() : void {
			Tick.addTick(this);
		}
		
		public override function onRemoveStage() : void {
			Tick.removeTick(this);
		}
		
		public function run(dt : Number) : void {
			rotation -= speed;
		}
	}
}
