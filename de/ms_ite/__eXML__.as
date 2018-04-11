//
// a class to pass keys to any object
//
package de.ms_ite { 
	
	import flash.xml.*;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class e__eXML__extends XMLDocument {
		public var owner:Object;
		public var func:Function;
		
		private var ul:URLLoader;
		public var loaded:Boolean;
		
		function eXML( p:Object, f:Function){
			super();
			
			owner = p;
			func = f;
			loaded = false;
			
			ignoreWhite = true;
			
			ul = new URLLoader();
			ul.addEventListener( Event.COMPLETE, completeHandler);
			ul.addEventListener( IOErrorEvent.IO_ERROR, errorHandler);
	//		trace( "XM: "+owner);
		}
		
		public function load( url:String):void {
//			trace( "loading xml: "+url);
			var uri:URLRequest = new URLRequest( url);
//			owner.debug( "eXML loading from: "+url);
			
			ul.load( uri);
		}
		
		private function completeHandler( evt:Event):void {
//			owner.debug( "load ok: "+ul.data);
			loaded = true;
			
			try {
				parseXML( ul.data);
			} catch( e:Error) {
				trace( "parsing error: "+e+" @ "+ul.data);
			}
			
			hasLoaded( true);
		}
		
		private function errorHandler( evt:IOErrorEvent):void {
			owner.error( "load error: "+this);
			loaded = false;
			hasLoaded( false);
		}
		
		public function hasLoaded( s:Boolean):void {
//			owner.debug( "XM: "+s+" / "+this);
			func.call( owner, s, this);
		}
	}
}