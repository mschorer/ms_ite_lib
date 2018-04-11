//
// a symbol store
// the basic functions
//

interface de.msite.Store {
	public function setZoomHyst( n:Number):Void;
	
	//-----------------------------------------------------------------------------
	// zoomify interface functions
	
	function attach( zf:de.msite.ZfGis):Void;
	function isAttached( Void):Boolean;
	function detach( zf:de.msite.ZfGis):Void;
/*
	function zfinit( evt):Void;
	function zfview( evt):Void
*/		
	//-----------------------------------------------------------------------------
	// debug
	
	//-----------------------------------------------------------------------------
	// external interface

	public function getMBR():de.msite.Rectangle;

	// redraw symbols in store, adapt to resolution ...
	// redraw incrementally
	public function addSymbolsStatic( symStore:Array, zf:de.msite.ZfGis):Void;
	// add symbols to zoomify
	public function setSymbols():Void;
	// clear the results
	public function clear():Void;
	// add a resultset row to the store
	public function addRow( cnames:Array, row:Object ):Number;
	// redraw symbols in store, adapt to resolution ...
	// redraw incrementally
	public function redrawSymbols():Void;
	// remove all symbols in store
	public function removeSymbols():Void;
	// service has retrieved all the data
	// to be overridden in subclass
	public function loadDone():Void;
	// count and limit of loaded symbols
	// to be overridden in subclass
	public function symbolsLoaded( count:Number, total:Number):Void;
	// highlight a symbol
	// to be overridden in subclass
	public function select( idx:Number):String;
}
