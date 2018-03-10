package ge.events {
	import ge.ui.Grid;

	import flash.events.Event;

	/**
	 * @author Administrator
	 */
	public class GridEvent extends Event {
		public static const CLICK : String = "CLICK";
		public static const SHOW : String = "SHOW";
		public static const DOUBLE_CLICK : String = "DOUBLE_CLICK";
		public static const STOP_DRAG : String = "StopDrag";
		public static const START_DRAG : String = "StartDrag";
		public var grid : Grid;
		public var dragTarget : Object;

		public function GridEvent(type : String, grid : Grid, dragTarget : Object = null) {
			super(type);
			this.grid = grid;
			this.dragTarget = dragTarget;
		}
	}
}
