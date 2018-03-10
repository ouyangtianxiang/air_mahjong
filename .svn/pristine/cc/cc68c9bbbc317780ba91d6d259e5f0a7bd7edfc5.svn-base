package{
	import flash.external.ExtensionContext;

	public class ANE{  
		private var _context:ExtensionContext;  

		public function get context():ExtensionContext{
			return _context;
		}

		public function ANE(extensionID:String, contextType:String){  
			_context = ExtensionContext.createExtensionContext(extensionID, contextType);  
		}  
		
		public function get Call():Function{
			return _context.call;
		}
	}  
}


  