package game {
	import flash.utils.ByteArray;
	
	import game.res.LoadBinary;
	
	/**
	 * @author txoy
	 */
	public class Config {
		public static var xml : XML;
		private var callback : Function;
		
		public function Config(callback : Function) : void {
			this.callback = callback;
			new LoadBinary("config.xml",onConfig);
		}
		
		private function onConfig(data:ByteArray) : void {
			xml=new XML(data);
			callback();
		}
	}
}
