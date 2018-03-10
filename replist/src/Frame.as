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
	

	public class Frame
	{
		public function Frame(fileName:String,dict:XML,plist:Plist)
		{
			var list:XMLList=dict.children();
			
			var frame:Rectangle=strArray(list[1].text());
			var offset:Rectangle=strArray(list[3].text());
			var rotated:Boolean=list[5].name()=="true";
			var sourceColorRect:Rectangle=strArray(list[7].text());
			var sourceSize:Rectangle=strArray(list[9].text());
			
			trace("fileName",fileName);
			trace("frame",frame);
			trace("offset",offset);
			trace("rotated",rotated);
			trace("sourceColorRect",sourceColorRect);
			trace("sourceSize",sourceSize);
			
			
			var bd2:BitmapData=new BitmapData(sourceSize.x,sourceSize.y,true,0x00FFFFFF);
			if(rotated){
				for(var _y:int=0;_y<=frame.height;_y++){
					for(var _x:int=0;_x<=frame.width;_x++){
						
						var color:uint=plist.bd.getPixel32(frame.x+(frame.height-_y),frame.y+_x);
						
						
						bd2.setPixel32(sourceColorRect.x+_x,sourceColorRect.y+_y,color);
					}
				}
			}else{
				bd2.copyPixels(plist.bd,frame,new Point(sourceColorRect.x,sourceColorRect.y));
			}
			
			var data:ByteArray=bd2.encode(new Rectangle(0,0,bd2.width,bd2.height),new PNGEncoderOptions());

			var fs:FileStream=new FileStream();
			fs.open(new File(plist.dir.nativePath+"/"+fileName),FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		private function strArray(str:String):Rectangle
		{
			var myPattern:RegExp = /{|}/gi; 
			str=str.replace(myPattern,"");
			
			var arr:Array=str.split(",");
			var frameRect:Rectangle=new Rectangle(arr[0],arr[1],arr[2],arr[3])
			return frameRect;
		}
	}
}