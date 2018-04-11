//
//
//  a draggable rectangle for droping
//  (c) markus schorer, ms@reicheteile.org
//
// 0.1: started					(20050915)
//
//

import de.msite.*;
import mx.controls.Label;
//import mx.managers.FocusManager;

class de.msite.ZfSymbolDropper extends mx.core.UIComponent {
	static var symbolName:String = "ZfSymbolDropper";
	static var symbolOwner:Object = de.msite.ZfSymbolDropper;
	static var version:String = "0.1";
	var className:String = "ZfSymbolDropper";
	
	private var BoundingBox_mc:MovieClip;

	private var dropCursor:MovieClip;

	private var zoomify:ZfGis;
	private var label:Label;
	
	private var savedFocus:Object = null;
	
	function ZfSymbolDropper() {

//		_visible = false;
		zoomify = null;
		
		BoundingBox_mc._visible = false;
//		visible = false;
		
		debug( "created");
	}
	
	function init():Void {
		super.init();
	}
	
	function size():Void {
		super.size();
	}
	
	function createChildren():Void {
		dropCursor = attachMovie( "dropSymbol", "dropSymbol", 2 /*, { _visible:false}*/);
		debug( "cursor: "+dropCursor);
	}

	function debug( txt):Void {
		_root.debug( "DBG ZfSymbolDropper: "+txt);
	}

	public function attach( zmfy:ZfGis):Void {
		zoomify = zmfy;
		move( zmfy.x, zmfy.y);
		debug( "attach "+zoomify+"/"+zmfy);
//		zoomify.addEventListener( "zfview", this);
	}

	public function detach():Void {
		debug( "detach "+this+"/"+zoomify+".");
//		zoomify.removeEventListener( "zfview", this);
		
		zoomify = null;
	}
/*
	public function zfview( evt) {
		debug( "upd "+this+"/"+evt.target);
	
		if ( evt.detail.zoom > 0 && evt.detail.zoom <= 100 && zoom != evt.detail.zoom) {
			zoom = evt.detail.zoom;
			update( ZfGis( evt.target));
		}
	}
*/
/*	
	function zfinit( evt):Void {
		if ( scaledSymbols == null && symbolLayer == null) {
			scaledSymbols = zmfy.getScaledLabelLayer();
//			symbolLayerDepth = zmfy.getSymbolLevel();
			symbolLayer = scaledSymbols.createEmptyMovieClip( "windowZoomLayer", 32760);
		}
		debug( "zmfy inited. ("+symbolLayer+"/"+scaledSymbols+")");
		symbolsZoom = -1;
		
		if ( rs != null) {
			removeSymbols();
			setSymbols();
		}
	}
*/		
	public function setEnabled( state:Boolean) {
		
		if ( state) {
			this.setFocus();
//			debug( "focused: "+getFocus());
		} else {
//			debug( "stop");
		}
		enabled = state;

		// initially position it
		onMouseMove();
		visible = state;
//		zoomify.setEnabled( ! state);
		
		invalidate();
	}
	
	public function keyDown() {
		if ( ! enabled) return;
		
		debug( "keyd d: "+Key.getCode()+"/"+Key.ESCAPE);
		if ( Key.getCode() == Key.ESCAPE) {
			setEnabled( false);
		}
	}
	
	public function keyUp() {
		if ( ! enabled) return;
		debug( "keyd u: "+Key.getCode()+"/"+Key.ESCAPE);
		if ( Key.getCode() == Key.ESCAPE) {
			setEnabled( false);
		}
	}
	
	public function onMouseDown() {
		if ( ! enabled) return;

		updateAfterEvent();
	}
	
	public function onMouseUp() {
		if ( ! enabled) return;
		dropCursor._x = 0;
		dropCursor._y = 0;
		setView();
		
		updateAfterEvent();
		setEnabled( false);
	}
	
	public function onMouseMove() {
		if ( ! enabled) return;

//		dropCursor._x = zoomify._xmouse + zoomify.width / 2;
//		dropCursor._y = zoomify._ymouse + zoomify.height / 2;^
		move( x + _xmouse, y + _ymouse);
	}
	
	public function setView() {
		var posx:Number = (_x - zoomify.x) / zoomify.width;
		var posy:Number = (zoomify.y - _y) / zoomify.height;
		debug( "mup zf "+posx+","+posy+".");
		
		var vp:Rectangle = zoomify.getGisViewportBounds();
		
		var vb:Point = new Point( vp.centerx + posx * vp.width, vp.centery + posy * vp.height);
		debug( "drop off @ : "+vb);
				
		dispatchEvent( { target:this, type:'click', detail:vb});
	}
}
//==================================================
