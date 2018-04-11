package de.ms_ite.components {
	import flash.events.*;
	
	import mx.containers.*;
	import mx.controls.Label;
	
	public class Watermark extends Canvas {
		
		protected var labels:Array;
		
		public function Watermark() {
			alpha = 0.5;
			labels = new Array();
			
			horizontalScrollPolicy = 'off';
			verticalScrollPolicy = 'off';
			
//			addEventListener( Event.RESIZE, handleResize);
			addEventListener( Event.ADDED, handleAdd);
		}
		
		protected function handleAdd( evt:Event):void {
			debug( "added to: "+parent);
			handleResize( null);
			parent.addEventListener( Event.RESIZE, handleResize);
		}
		
		protected function handleResize( evt:Event):void {
			var i:int;
			var temp:Label;
			
			width = parent.width;
			height = parent.height;
			
			var num:int = width * height / 10000;
			
			if ( Math.abs( num - labels.length) / num > 0.25) {
				if ( num < labels.length) {
					for( i = 0; i < (labels.length - num); i++) {
						removeChild( labels.pop());
						debug( "remove");
					}
				} else {
					for( i = 0; i < ( num - labels.length); i++) {
						temp = new Label();
						temp.setStyle( 'fontSize', (12 + Math.random() * 12)); 
						temp.setStyle( 'fontFamily', 'embVerdana');
						temp.setStyle( 'color', 0xffffff);
						temp.text = 'Demo';
						temp.x = Math.random() * width;
						temp.y = Math.random() * height;
						labels.push( temp);
						addChild( temp);
						debug( "add");
					}
				}
			} else {
				num = labels.length;
				for( i = 0; i < num; i++) {
					temp = Label( labels[ i]);
					temp.x = Math.random() * width;
					temp.y = Math.random() * height;
					debug( "repos");
				}				
			}
		}
		
		protected function debug( txt:String):void {
//			trace( "DBG WTRMRK: "+txt);
		}
	}
}