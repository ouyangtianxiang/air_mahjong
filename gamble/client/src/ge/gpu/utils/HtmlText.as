package ge.gpu.utils{
	
	public dynamic class HtmlText extends Array{
		private var _color:uint;
		public function HtmlText(str:String=null,color : Object = null, size : Object = null,stroke : Object = null, bold : Object = null){
			_color=uint(color);
			if(str){
				append(str,color,size,stroke,bold);
			}
		}
		public function append(str:String,color : Object = null, size : Object = null,stroke : Object = null, bold : Object = null):void{
			push(str,color,size,stroke,bold);
		}
		
		public function appends(...arg:*) : void {
			appends2(arg);
		}
		
		public function appends2(arr:Array):void{
			var color:uint=_color;
			while(arr.length>0){
				var str:String = arr.shift();
				if(str.charAt()=="#"){
					color=uint("0x"+str.substr(1));
				}else{
					append(str,color);
				}
			}
		}
	}
}