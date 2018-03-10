package game.font{
	import flash.text.Font;

	public class GameFont{
		/**
		 * 
		 */
		[Embed(source="fzzy_GBK.TTF",fontName="fzzy_GBK", advancedAntiAliasing="true", embedAsCFF="false" ,mimeType="application/x-font")]
		public static var FontClass : Class;
		public static var font : Font=new FontClass();

		public static var it:GameFont=new GameFont();
		public function GameFont(){
			Font.registerFont(FontClass);
		}
	}
}
