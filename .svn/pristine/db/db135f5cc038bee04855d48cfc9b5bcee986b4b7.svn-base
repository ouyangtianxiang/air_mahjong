package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	public class ReFont extends Sprite
	{
		private var list:Array=[];
		public function ReFont()
		{
			var file:File=new File("E:\\air_mahjong\\gamble\\games安卓");
			
			dir(file);
			next();
			trace(file.isDirectory);
		}
		
		public function dir(file:File):void{
			var array:Array=file.getDirectoryListing();
			for each (var f:File in array){
				if(f.isDirectory){
					dir(f);
				}else{
					if(f.nativePath.lastIndexOf(".fnt")!=-1){
						list.push(f);
					}
				}
			}			
		}
		
		public function next():void{
			if(list.length>0){
				var f:File=list.shift();
				new Fnt(f,this);	
			}
		}
	}
}