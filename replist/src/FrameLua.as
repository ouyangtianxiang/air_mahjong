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
	
	
	public class FrameLua
	{
		public function FrameLua(fileName:String,o:Object,plist:PLua)
		{
			
			var frame:Rectangle=new Rectangle(o.x,o.y,o.width,o.height);
			var offset:Point=new Point(o.offsetX,o.offsetY);
			var rotated:Boolean=o["rotated"];
			var size:Point=new Point(o.utWidth,o.utHeight);
			
			trace("fileName",fileName);
			trace("frame",frame);
			trace("offset",offset);
			trace("rotated",rotated);
			trace("sourceSize",size);
			
			
			var bd2:BitmapData=new BitmapData(size.x,size.y,true,0x00FFFFFF);
			if(rotated){
				for(var _y:int=0;_y<=frame.height;_y++){
					for(var _x:int=0;_x<=frame.width;_x++){
						
						var color:uint=plist.bd.getPixel32(frame.x+_x,frame.y+_y);
						
						
						bd2.setPixel32(size.x-(offset.x+_y),offset.y+_x,color);
					}
				}
			}else{
				bd2.copyPixels(plist.bd,frame,new Point(offset.x,offset.y));
			}
			
			var data:ByteArray=bd2.encode(new Rectangle(0,0,bd2.width,bd2.height),new PNGEncoderOptions());
			
			var fs:FileStream=new FileStream();
			fs.open(new File(plist.dir.nativePath+"/"+fileName),FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
	}
}