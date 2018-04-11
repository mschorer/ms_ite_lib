/*

(c) by ms@ms-ite.org

v0.1

todo:
- rework to be a true v2 component

v0.1: startet v2 development			(20060215)
*/

package de.ms_ite.zf {

	import flash.events.*;
	import flash.utils.*;
	
	public class ZfLoader extends EventDispatcher {
	
		// limit script-time used in single run
	//	static var CPU_LIMIT:Number = 1000;
	
		private var waitqueue:Array;
		private var loadqueue:Array;
		
		private var tilesTotal:int = 0;		
		private var tilesLoaded:int = 0;
		private var tilesLoading:int = 0;
		private var tilesRatio:Number = 0;
	
		private static var PARLOADS:Number = 5;
		
		// object constructor
		// init all variables
		function ZfLoader() {
			super()		

			waitqueue = new Array();
			loadqueue = new Array();
			
			debug( "createloadComponent");
		};
		
		// return the queue status
		public function isEmpty():Boolean {
			return ( loadqueue.length == 0 && waitqueue.length == 0);
		};
		
		// print debug messages
		protected function debug( txt:String):void {
//			trace( "DBG ZfLoader: "+txt);
		};
		protected function error( txt:String):void {
			trace( "ERR ZfLoader: "+txt);
		};
		
		public function getBytesLoaded():Number {
			return tilesLoaded;
		}
		
		public function getBytesTotal():Number {
			return tilesTotal;
		}
		
		// add an object for monitoring
		// register callback and movie clip (for retriggering)
		public function queueTile( tile:ZfTile):void {
//			debug( "queue: "+tile.name);
			// decide on loadstatus to immediately queue tiles
			if ( loadqueue.length < PARLOADS) queueLoading( tile);
			else queueWaiting( tile);
			
			tilesTotal++;
		};
		
		// add to the load queue
		private function queueLoading( tile:ZfTile):void {
			debug( "queue loading: "+tile.name);
			loadqueue.push( tile);
			tile.addEventListener( Event.COMPLETE, tileDone);
			tile.addEventListener( ProgressEvent.PROGRESS, tileProgress);
			tile.load( null);
			tilesLoading++;
		}
		
		// add to the wait queue
		private function queueWaiting( tile:ZfTile):void {
			debug( "queue waiting: "+tile.name);
			waitqueue.push( tile);
		}
		
		// remove an object from monitoring
		public function removeTile( tile:ZfTile, state:int):void {
			debug( "remove from queue: "+tile.name);
			
			switch ( state) {
				case ZfTile.DONE:
				case ZfTile.LOAD:
					removeLoadQueue( tile);
					tileDone( null);
				break;
				
				case ZfTile.QUEUED: removeWaitQueue( tile);
				break;
			}			
		}
		
		public function removeLoadQueue( tile:ZfTile):void {
			
			loadqueue = removeQueue( tile, loadqueue);
			tile.removeEventListener( Event.COMPLETE, tileDone);
			tile.removeEventListener( ProgressEvent.PROGRESS, tileProgress);
		}
		
		public function removeWaitQueue( tile:ZfTile):void {			
			waitqueue = removeQueue( tile, waitqueue);
		}
		
		private function removeQueue( tile:ZfTile, queue:Array):Array {
			var j:Number = 0;
	
			var i:int = queue.indexOf( tile);
			if ( i > 0) queue = queue.slice( i, 1);
			else {
				if ( i == 0) queue.pop();
				else debug( "clean error: "+queue+" / "+tile);
			}
			
			return queue;
		}
		
		// clear the wait-queue, loading tiles are untouched
		public function clear():void {
			var i:int;
			
			debug( "clear +w:"+waitqueue.length+" / l:"+loadqueue.length);
			
			var temp:Array = loadqueue.concat();
			for( i=0; i < temp.length; i++) {
				ZfTile( temp[i]).cancel();
			}
			
			temp = waitqueue.concat();
			for( i=0; i < temp.length; i++) {
				ZfTile( temp[i]).cancel();
			}
			debug( "clear -w:"+waitqueue.length+" / l:"+loadqueue.length);
/*	
			loadqueue = new Array();
			waitqueue = new Array();
*/
			tilesTotal = 0;
			tilesLoaded = 0;
			tileDone( null);
			debug( "clearQueue");
		};
		
		//-----------------------------------------------------------------

		private function tileDone( evt:Event):void {
			if ( evt != null) {
				var tile:ZfTile = ZfTile( evt.target);
	
				debug( "  tile done: "+tile.name);
				
				tilesLoading--;			
				tilesLoaded++;
				
				removeLoadQueue( tile);
			}

			// fill queue
			while( loadqueue.length < PARLOADS && waitqueue.length > 0) {
				queueLoading( ZfTile( waitqueue.shift()));
			}
		}
		
		private function tileProgress( evt:ProgressEvent):void {
			var tile:ZfTile = ZfTile( evt.target);			

			tilesRatio = (evt.bytesTotal != 1) ? ( evt.bytesLoaded / evt.bytesTotal) : 1;
//			debug( "  tile prog: "+tile.name+" / "+tilesRatio);
		}
	}			
}
//==================================================