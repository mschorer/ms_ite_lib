package de.ms_ite.tools {

/*
 *
 * the class to communicate with the sde-embedded com-stub
 *
 */

	import flash.events.*;
	import flash.net.LocalConnection;
	
	public class DebugChannel extends LocalConnection {
		
		private static var dbc:DebugChannel = null;
		
		private var in_tag:String;
		private var out_tag:String;
		
		public static function getInstance():DebugChannel {
			if ( dbc == null ) dbc = new DebugChannel();
			
			return dbc;
		}
		
		public function DebugChannel() {
			super();
			addEventListener( StatusEvent.STATUS, handleStatusChange); 
			
			out_tag = "_lc_msite_trace";
			in_tag = "_lc_msite_dbg";
			
			debug( "sending on "+out_tag);
			
			allowDomain('*');
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
			debugLocal( "send("+out_tag+"): "+txt);
			send( out_tag, "trace", txt, level)
		}
	
		protected function debugLocal( txt:String):void {
//			trace( txt);
		}
	}
}
//----------------------------------------------------------------