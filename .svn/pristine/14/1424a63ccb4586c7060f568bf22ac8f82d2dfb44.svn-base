package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	public class Replist extends Sprite
	{
		private var list:Array=[];
		public function Replist()
		{
			var file:File=new File("E:\air_mahjong\Client\assets\Texture");
			
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
					if(f.nativePath.lastIndexOf(".lua")!=-1){
						list.push(f);
					}
				}
			}			
		}
		
		public function next():void{
			if(list.length>0){
				var f:File=list.shift();
				new Plist(f,this);	
			}
		}
	}
}