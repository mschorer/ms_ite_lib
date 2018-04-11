package de.ms_ite.tools {

/*
 *
 * the class to communicate with the sde-embedded com-stub
 *
 */

	import flash.net.LocalConnection;
	import flash.events.*;
	
	public class DebugConnection extends LocalConnection {
		
//		private var sendingLC:LocalConnection = null;
		private var isMaster:Boolean;
		private var parent:Object;
		
		private var in_tag:String;
		private var out_tag:String;
		
		public function DebugConnection( parent:Object, master:Boolean=true) {
			super();
			addEventListener( StatusEvent.STATUS, handleStatusChange); 
			
			this.parent = parent;
			isMaster = master;
			
			if ( isMaster) {
				out_tag = "_lc_msite_trace";
				in_tag = "_lc_msite_dbg";
			} else {
				in_tag = "_lc_msite_trace";
				out_tag = "_lc_msite_dbg";
			}
			
			debug( "sending on "+out_tag);
			
			allowDomain('*');
	//		if ( ! master) {			
			if ( ! master) debug( "listening on "+in_tag+" : "+connect( in_tag));
	//		}
		}
		
		protected function handleStatusChange( event:StatusEvent):void {
            switch (event.level) {
                case "status":
//                    trace("LocalConnection.send() succeeded");
                    break;
                case "error":
//                    trace("LocalConnection.send() failed");
					connectionError();
                    break;
            }
        }
	
		public function connectionError():void {
//			trace( "connection error.");
		}
		
		//----------------------------------------------------------------
	
		public function debug( txt:String, level:Number=0):void {
			netDebug( txt, level);
		}
		
		public function netDebug( txt:String, level:Number=0):void {
			if ( isMaster) {
				debugLocal( "send("+out_tag+"): "+txt);
				send( out_tag, "trace", txt, level)
			} else {
				debugLocal( "isSlave: "+txt);
			}
		}
	
		protected function debugLocal( txt:String):void {
//			trace( txt);
		}
	}
}
//----------------------------------------------------------------