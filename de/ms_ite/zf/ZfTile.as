//
//
//  a container for a tile
//  (c) markus schorer, ms@reicheteile.org
//	v 1.0
//
// 0.1: start
//
//

package de.ms_ite.zf {
	
//	import flash.display.*;
//	import mx.core.UIComponent;
//	import flash.net.URLRequest;
	import flash.events.*;
	import flash.system.*;
	import mx.controls.*;
	import mx.containers.*;
	
	public class ZfTile extends Image {
		
		public static var IDLE:Number = 0;
		public static var QUEUED:Number = 1;
		public static var LOAD:Number = 2;
		public static var DONE:Number = 3;
	//	static var KILL:Number = 3;
	
		protected static var col:Number = 0xc0c0c0;
		
		protected var state:Number = IDLE;		
		protected var url:String;
		
		public var loader:ZfLoader;
		
		public var tier:int;
		public var row:int;
		public var col:int;
		
		// object constructor
		// init all variables
		public function ZfTile() {
			super();
			
			debug( "create: "+name);
		
			state = IDLE;
/*
			contentLoaderInfo.addEventListener( Event.COMPLETE, loaded);
			contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progress);
*/			
			addEventListener( Event.COMPLETE, loaded);
			addEventListener( ProgressEvent.PROGRESS, progress);

			scaleContent = false;

			width=256;
			height=256;
		}
		
		public function loadMovie( url:String):void {
			debug( "load tile: "+name+" "+state+"/"+loader+" / "+url);
			
			if (( state == LOAD || state == DONE) && this.url == url) {
				debug( "is loaded loadMovie: "+state);
				loaded( null);
				return;
			}
	
//			tile.alpha = 0.2;
			this.url = url;
	
			if ( loader != null) {
//				if ( state == IDLE) {
					loader.queueTile( this);
					state = QUEUED;
//				}
			} else {
				load( url /*new URLRequest( url)*/);
			}
		}
		
		override public function load( url:Object=null /*URLRequest , context:LoaderContext = null*/):void {
			debug( "load.");
			if ( state == IDLE || state == QUEUED) {
				state = LOAD;
//				super.load(( url == null) ? new URLRequest( this.url) : url);
				super.load(( url == null) ? this.url : url);
			}
		}
		
		// are we loaded?
		public function isLoaded():Boolean {
			return state == DONE;
		}
		
		protected function loaded( evt:Event):void {
			state = DONE;
			visible = true;
			debug( "load done."); 
			
//			dispatchEvent( new Event( Event.COMPLETE));
		}
	
		protected function progress( evt:ProgressEvent):void {
			debug( "  loading: "+evt.bytesLoaded+"/"+evt.bytesTotal); 
//			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, evt.bubbles, evt.cancelable, evt.bytesLoaded, evt.bytesTotal));
		}	

/*		
		public function get bytesTotal():Number {
			return contentLoaderInfo.bytesTotal;
		}
		
		public function get bytesLoaded():Number {
			return contentLoaderInfo.bytesLoaded;
		}
*/
		public function cancel():void {
			debug( "cancel("+state+") tile: "+name);
			
			//if ( loader != null && (state == QUEUED || state == LOAD)) loader.removeTile( this);
//			if ( state == QUEUED && loader != null) loader.removeTile( this);

			switch( state) {
				case IDLE: break;

				case LOAD: /*	try { close(); } catch( e:Error) { ; } */
				case QUEUED: if ( loader != null) loader.removeTile( this, state);
					/*try { unload(); } catch( e:Error) { ; }*/
					state = IDLE;
				break;
				
				case DONE:
					if ( loader != null) loader.removeTile( this, state);
				break;
			}
			visible = false;
		}

		protected function debug( txt:String):void {
//			trace( "DBG ZFT("+name+"): "+txt);
		}
	}
}
//==================================================