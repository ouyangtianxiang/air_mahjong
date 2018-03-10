package game {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public class Load extends URLLoader {
		private var url:String;
		private var error:int;
		
		public function Load(url:String,onComplete:Function,onIoError:Function,onProgress:Function=null) {
			this.url = url;
			dataFormat = URLLoaderDataFormat.BINARY;
			addEventListener(Event.COMPLETE, onComplete);
			addEventListener(IOErrorEvent.IO_ERROR, onRetries);
			addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			if(onProgress){
				addEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			loads();
		}
		
		private function loads():void {
			load(new URLRequest(url));
		}
		
		protected function onRetries(event:IOErrorEvent):void {
			error++;
			if (error < 5) {
				event.stopPropagation();
				event.stopImmediatePropagation();
				loads();
			}
		}
	}
}
