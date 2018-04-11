//
//
//  a draggable rectangle for zooming
//  (c) markus schorer, ms@reicheteile.org
//
// 0.1: started					(20050915)
//
//

import de.msite.*;
import mx.controls.Label;
//import mx.managers.FocusManager;

class de.msite.ZfZoomFrame extends mx.core.UIComponent {
	static var symbolName:String = "ZfZoomFrame";
	static var symbolOwner:Object = de.msite.ZfZoomFrame;
	static var version:String = "0.1";
	var className:String = "ZfZoomFrame";
	
	private var BoundingBox_mc:MovieClip;

	private var zoomCursor:MovieClip;
	private var zoomLayer:MovieClip;

	private var zoomify:ZfGis;
	private var label:Label;
	
	private var zoom:Number;
	
	private var doDrag:Boolean = false;
	private var savedFocus:Object = null;
	
	function ZfZoomFrame() {

//		_visible = false;
		zoomify = null;
		zoom = -1;
		
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
//		label = Label( createClassObject( mx.controls.Label, "label", 1, {} ));
//		label.move( 0, -13); 
		zoomLayer = createEmptyMovieClip( "zoomLayer", 1);
		zoomLayer._visible = false;
		debug( "cursor: "+zoomLayer);
		zoomCursor = attachMovie( "winZoomCursor", "zoomCursor", 2 /*, { _visible:false}*/);
		debug( "cursor: "+zoomCursor);
	}

	function debug( txt):Void {
//		_root.debug( "DBG ZfZoomFrame: "+txt);
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
		debug( "upd "+this+"/"+evt.target);
	
		if ( evt.detail.zoom > 0 && evt.detail.zoom <= 100 && zoom != evt.detail.zoom) {
			zoom = evt.detail.zoom;
			update( ZfGis( evt.target));
		}
	}
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
	// the progress bar
	// draw the bars with alpha
	private function update( zf:ZfGis):Void {
		with( zoomLayer) {
			clear();
			
			beginFill( 0xffffff, 30);
			lineStyle( 2, 0xffffff, 60);
			moveTo( 0, 0);
			lineTo( _parent._xmouse, 0);
			lineTo( _parent._xmouse, _parent._ymouse);
			lineTo( 0, _parent._ymouse);
			lineTo( 0, 0);
			endFill();
		}
	}
	
	public function setEnabled( state:Boolean) {
		zoomLayer._visible = false;
		zoomLayer.clear();
		
		if ( state) {
			this.setFocus();
			debug( "focused: "+getFocus());
			move( x + _xmouse, y + _ymouse);
		} else {
			debug( "stop");
		}
		visible = state;
		zoomify.setEnabled( ! state);
		enabled = state;
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

		zoomLayer.clear();
		zoomLayer._visible = true;
//		move( x + _xmouse, y + _ymouse);
		doDrag = true;
		updateAfterEvent();
	}
	
	public function onMouseUp() {
		if ( ! enabled) return;
		doDrag = false;
		zoomCursor._x = 0;
		zoomCursor._y = 0;
		setView();
		
		updateAfterEvent();
		setEnabled( false);
	}
	
	public function onMouseMove() {
		if ( ! enabled) return;
/*		
		zoomCursor._x = _root._xmouse;
		zoomCursor._y = _root._ymouse;
*/		
		if ( doDrag == true) {
			update();
			zoomCursor._x = _xmouse;
			zoomCursor._y = _ymouse;
		} else {
			move( x + _xmouse, y + _ymouse);
		}
	}
	
	public function setView() {
		if ( _parent == zoomify) {
			var minx = (Math.min( _x, _x + _xmouse)) / zoomify.width;
			var maxx = (Math.max( _x, _x + _xmouse)) / zoomify.width;
			var miny = ( - Math.min( _y, _y + _ymouse)) / zoomify.height;
			var maxy = ( - Math.max( _y, _y + _ymouse)) / zoomify.height;
		} else {
			var minx = (Math.min( _x, _x + _xmouse) - zoomify.x) / zoomify.width;
			var maxx = (Math.max( _x, _x + _xmouse) - zoomify.x) / zoomify.width;
			var miny = (zoomify.y - Math.min( _y, _y + _ymouse)) / zoomify.height;
			var maxy = (zoomify.y - Math.max( _y, _y + _ymouse)) / zoomify.height;
		}
		debug( "mup zf "+minx+","+miny+" - "+maxx+","+maxy+".");
		
		var vpb:Rectangle = zoomify.getGisViewportBounds();
		var vpc:Point = new Point( zoomify.getGisX(), zoomify.getGisY());

		var vb:Rectangle = new Rectangle();
		vb.mbrAddCoord( vpc.x + minx * vpb.width, vpc.y + miny * vpb.height);
		vb.mbrAddCoord( vpc.x + maxx * vpb.width, vpc.y + maxy * vpb.height);
		
		// disable labels, so no extreem scaling can happen
//		zoomify.setLabelVisible( false);
		dispatchEvent( { target:this, type:'change', detail:vb});
//		zoomify.showGisMap( vpc.x + minx * vpb.width, vpc.y + miny * vpb.height, vpc.x + maxx * vpb.width, vpc.y + maxy * vpb.height);
	}
}
//==================================================
