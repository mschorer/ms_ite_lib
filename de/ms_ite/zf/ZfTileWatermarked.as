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
	
	public class ZfTileWatermarked extends ZfTile {
		
		protected var watermark:Label;
	
		public function ZfTileWatermarked() {
			super();

			watermark = new Label();
			addChild( watermark);			
			watermark.text = "demo";
			watermark.alpha = 0.6;
			watermark.setStyle( 'fontSize', 24);
//			watermark.setStyle( 'fontWeight', 'bold');
			watermark.setStyle( 'fontFamily', 'embVerdanaB');
			watermark.setStyle( 'color', 0xffffff);
			watermark.width=100;
			watermark.height=30;
		}
		
		
		override protected function loaded( evt:Event):void {
			super.loaded( evt);
			
			swapChildren( watermark, getChildAt( numChildren - 1));
		}
	}
}
//==================================================