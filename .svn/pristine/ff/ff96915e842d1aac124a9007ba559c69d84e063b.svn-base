package ge.net.view {
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	import ge.net.Table;

	/**
	 * @author tianxiang.ouyang
	 */
	public class TableIcon extends Sprite {
		private var table : Table;
		private var txt : VText;

		public function TableIcon(Container : DisplayObjectContainer, x : int, y : int, table : Table) {
			this.x = x;
			this.y = y;
			Container.addChild(this);
			this.table = table;

			txt = new VText(this, table.name, 0, 0, 0xFFFF00, 12, 0, 0);
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;
			this.doubleClickEnabled = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private static var ctf : Array = [new ColorTransform(.7, .7, .7), new ColorTransform(1, 1, 1)];
		private static var Icon : TableIcon;

		private static function Select(icon : TableIcon) : void {
			if (Icon != null) {
				Icon.txt.color = 0xFFFF00;
				Icon.txt.background = false;
				Icon.txt.border = false;
				Icon.transform.colorTransform = ctf[1];
			}
			Icon = icon;
			Icon.txt.color = 0xFFFFFF;
			Icon.txt.background = true;
			Icon.txt.backgroundColor = 0x316ac5;
			Icon.txt.border = true;
			Icon.txt.borderColor = 0xAAAAAA;
			Icon.transform.colorTransform = ctf[0];
		}

		private function onMouseDown(event : MouseEvent) : void {
			Select(this);
		}

		private function onDoubleClick(event : MouseEvent) : void {
			DataView.it.open(table);
		}
	}
}
