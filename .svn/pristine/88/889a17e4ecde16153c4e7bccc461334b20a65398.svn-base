package
{
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class NumberFntff
	{
		private var array:Array;
		private var list:Array=[];
		private var w:int=0;
		private var h:int=0;
		private var dir:File;
		public function NumberFntff(file:File)
		{
			dir=file;
			array=file.getDirectoryListing();
			
			load();
		}
		
		private function load():void{
			if(array.length>0){
				var file:File=array.shift();
				new Bit(file,onCallback);
			}else{
				var bd2:BitmapData=new BitmapData(w,h*10,true,0x00FFFFFF);
				
				for(var i:int=0;i<list.length;i++){
					var bd:BitmapData=list[i];
					bd2.copyPixels(bd,new Rectangle(0,0,bd.width,bd.height),new Point((w-bd.width)/2,i*h));
				}
				
				var data:ByteArray=bd2.encode(new Rectangle(0,0,bd2.width,bd2.height),new PNGEncoderOptions());
				
				var fs:FileStream=new FileStream();
				fs.open(new File(dir.nativePath+".png"),FileMode.WRITE);
				fs.writeBytes(data);
				fs.close();
				
			}
		}
		
		private function onCallback(bd:BitmapData,str:String):void
		{
			w=Math.max(bd.width,w);
			h=Math.max(bd.height,h);
			list.push(bd);
			trace(str);
			load();
		}
	}
}