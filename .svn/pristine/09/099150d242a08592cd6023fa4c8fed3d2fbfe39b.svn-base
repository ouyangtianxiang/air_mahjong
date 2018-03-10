package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	public class NumberFnt extends Sprite
	{
		public function NumberFnt()
		{
			var file:File=new File("E:\\air_mahjong\\gamble\\games安卓\\font");
			
			dir(file);
			trace(file.isDirectory);
		}
		
		public function dir(file:File):void{
			var array:Array=file.getDirectoryListing();
			for each (var f:File in array){
					new NumberFntff(f);
			}		
		}
	}
}