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

	public class FrameFnt
	{
		public function FrameFnt(str:String,plist:Fnt,size:int)
		{
			var myPattern:RegExp = /  /g;
			str=str.replace(myPattern," ");
			str=str.replace(myPattern," ");
			str=str.replace(myPattern," ");
			var array:Array=str.split(" ");
			var obj:Object={};
			for each (var i:String in array) 
			{//char id=47 x=0 y=129 width=17 height=27 xoffset=-2 yoffset=3 xadvance=11 page=0 chnl=0 letter="/"
				var arr:Array=i.split("=");
				if(arr.length==2){
					obj[arr[0]]=arr[1];
				}
			}
			if(obj["width"]*obj["height"]>0){
			var fileName:String=obj["id"]+".png";
				
			var bd2:BitmapData=new BitmapData(obj["width"],obj["height"],true,0x00FFFFFF);
				bd2.copyPixels(plist.bd,new Rectangle(obj["x"],obj["y"],obj["width"],obj["height"]),new Point());
			
			var data:ByteArray=bd2.encode(new Rectangle(0,0,bd2.width,bd2.height),new PNGEncoderOptions());
			
			var fs:FileStream=new FileStream();
			fs.open(new File(plist.dir.nativePath+"/"+fileName),FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
			}
			
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