//
//
//  a scale for zoomify maps
//  (c) markus schorer, ms@reicheteile.org
//
// 0.1: converted to as2 class					(20050608)
//
//

import de.msite.*;
import mx.controls.Label;

class de.msite.ZfMapScale extends mx.core.UIObject {
	static var symbolName:String = "ZfMapScale";
	static var symbolOwner:Object = de.msite.ZfMapScale;
	static var version:String = "0.1";
	var className:String = "ZfMapScale";
	
	private var BoundingBox_mc:MovieClip;

	private var zoomify:ZfImage;
	private var label:Label;
	
	private var zoom:Number;
	
	function ZfMapScale() {

//		_visible = false;
		zoomify = null;
		zoom = -1;
		
		BoundingBox_mc._visible = false;
		
		debug( "created");
	}
	
	function init():Void {
		super.init();
	}
	
	function size():Void {
		super.size();
	}
	
	function createChildren():Void {
		label = Label( createClassObject( mx.controls.Label, "label", 1, {} ));
		label.autoSize = "right";
		label.move( 0, -16); 
	}

	function debug( txt):Void {
//		_root.debug( "DBG ZfMapScale: "+txt);
	}

	public function attach( zmfy:ZfGis):Void {
		zoomify = zmfy;
		debug( "attach "+zoomify+"/"+zmfy);
		zoomify.addEventListener( "zfview", this);
	}

	public function detach():Void {
		debug( "detach "+this+"/"+zoomify+".");
		zoomify.removeEventListener( "zfview", this);
		
		zoomify = null;
	}

	public function zfview( evt) {
		debug( "upd ("+(evt.detail.zoom > 0)+" / "+ (evt.detail.zoom <= 101)+" / "+ (zoom != evt.detail.zoom)+") "+this+"/"+evt.target);
	
		if ( evt.detail.zoom >= 0 && zoom != evt.detail.zoom) {
			zoom = evt.detail.zoom;
			updateScale( ZfGis( evt.target));
		}
	}
	
	// the progress bar
	// draw the bars with alpha
	private function updateScale( zf:ZfGis):Void {
		var divs, div, scale;
		
		debug( "update: "+this+"  "+zf+".");
		debug( "update: "+x+","+y+".");
		var gk = zf.getGisViewportBounds();
		var vp = zf.getSize();
		
		var mppx = gk.width / vp.width;
		var mppy = gk.height / vp.height;
	
		debug( "scale: "+gk.width+","+gk.height+"   "+vp.width+","+vp.height);
		debug( "scale: "+mppx+","+mppy);
	
		// scale dynamically
		// divs: number of black/white fields in scale
		// div:  scaling divider
		if ( mppx < 1) {
			divs = 2;
			div = 100;
			scale = 1;
		} else if ( mppx < 2) {
			divs = 2;
			div = 200;
			scale = 1;
		} else if ( mppx < 5) {
			divs = 5;
			div = 500;
			scale = 1;
		} else if ( mppx < 10) {
			divs = 2;
			div = 1000;
			scale = 1000;
		} else if ( mppx < 20) {
			divs = 2;
			div = 2000;
			scale = 1000;
		} else if ( mppx < 50) {
			divs = 5;
			div = 5000;
			scale = 1000;
		} else if ( mppx < 100) {
			divs = 5;
			div = 10000;
			scale = 1000;
		} else if ( mppx < 250) {
			divs = 5;
			div = 25000;
			scale = 1000;
		} else {
			divs = 4;
			div = 100000;
			scale = 1000;
		}
		
		var size = div / mppx;
	//	debug( "scale: "+""+int( div / 1000)+" "+((div >= 1000) ? 'k' : '')+"m");
	
		label.text = ""+int( div / scale)+" "+((scale == 1000) ? 'k' : '')+"m";
		label.move( size - 25, label.y);
		
		clear();
		
		beginFill( 0xffffff, 70);
	//	lineStyle( 1, 0x000000, 30);
		moveTo( -5, -20);
		lineTo( -5, 15);
		lineTo( size+24, 15);
		lineTo( size+24, -20);
		lineTo( -5, -20);
		endFill();
	
		beginFill( 0xffffff, 50);
		lineStyle( 1, 0x000000, 50);
		moveTo( 0, 0);
		lineTo( 0, 7);
		lineTo( size-1, 7);
		lineTo( size-1, 0);
		lineTo( 0, 0);
		endFill();
	
		var xstep = size / divs;
		var i=1;
		while( i < divs) {
			var xs = xstep * i++;
			var xe = xstep * i++;
			
			beginFill( 0x000000, 50);
			lineStyle();
			moveTo( xs, 0);
			lineTo( xs, 7);
			lineTo( xe, 7);
			lineTo( xe, 0);
			lineTo( 0, 0);
			endFill();
		}
/*		
		if ( x < 0) move( 0, y);
		if ( y < 0) move( x, y);
		if ( x+width > Stage.width) move( Stage.width - width, y);
		if ( y+height > Stage.height) move( x, Stage.height - height);
*/
	};
	
	private function onPress() {
		startDrag(this, false);
	}
	private function onRelease() {
		stopDrag();
	}
	private function onRollOver() {
		// add tooltip?
	}
	private function onRollOut() {
		// unset tooltip
	}
	private function onDragOut() {
		// unset tooltip
	}
}
//==================================================
