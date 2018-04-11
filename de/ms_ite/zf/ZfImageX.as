/*

(c) 2004, 2005 by ms@reicheteile.org

v3.0a1

3.0a1: ported to flex2, restructuring tileTiers

*/
/*
Based on Zoomify for AS1, ported to AS2
Copyright Zoomify, Inc., 2002-2003.  All rights reserved.

*/

package de.ms_ite.zf {
	//==========================================================================
	import mx.core.*;
	import flash.xml.*;
	import flash.events.*
	import flash.display.*;
	import flash.utils.*;
	import de.ms_ite.*;
	
	public class ZfImageX extends UIComponent {
	
		// limit script-time used in single run
	//	static var CPU_LIMIT:Number = 1000;
	
		static private var numPremadeLevels:Number = 20;
	
		public static var CLIP_LEFT:Number 	= 1;
		public static var CLIP_RIGHT:Number 	= 2;
		public static var CLIP_TOP:Number 		= 4;
		public static var CLIP_BOTTOM:Number 	= 8;
		public static var CLIP_MASKRECT:Number = 15;
	
		public static var CLIP_MINZOOM:Number 	= 16;
		public static var CLIP_MAXZOOM:Number 	= 32;
		public static var CLIP_MASKZOOM:Number = 48;
	
		private var clipBounds:Bounds;
		
		private var gClip:Boolean = false;
		private var gClipSaved:Boolean = false;
		
		private var gClipHyst:Number = 10;
		private var gClipEvents:Number = 0;
		private var gClipAllow:Boolean = false;
		
		private var gResolution:Number;
		
		protected var bounds:Bounds;
		
		private var gEnabled:Boolean = true;
		//Turns on and off the Zs
		private var gSetViewCalled:Boolean = false;
		private var gURLChanged:Boolean = true;
		private var gMustResetViewer:Boolean = true;
		protected var gInitialized:Boolean = false;
		private var gImgInfoLoaded:Boolean = false;
		private var gInitCalled:Boolean = false;
		
//		private var invisiblePanMouse_btn:UIComponent = null;
	
		private var mapDimmer:MovieClip;
		
		private var mapLayer:UIComponent;
		
		private var gUpdatePhase:Number;
	
	//	private var maskdummy_mc:MovieClip;
	//	private var tierdummy_mc:MovieClip;
		private var mask_mc:UIComponent = null;
		private var mcBoundingBox:MovieClip;
	
		protected var gViewWidth:Number = 500;
		protected var gViewHeight:Number = 350;
		protected var gImageWidth:Number = -1;
		protected var gImageHeight:Number = -1;
		private var gOffscreenX:Number = 50000;
	
		private var _isLivePreview:Boolean = false;
		//This is the default size of the component. We need this in order to properly determin scale.
		private var _initialX:Number = 0;
		private var _initialY:Number = 0;
		private var _initialZoom:Number = 1;
		private var _sizeChanged:Boolean = false;
		protected var _imagePath:String = '';
		private var _imageNode:XMLNode = null;
		private var keysEnabled:Boolean;
		protected var _minZoom:Number;
		protected var _maxZoom:Number;
		
		private var gZoom:Number;
		private var gTierCount:Number;
		private var gPanPositionX:Number;
		private var gPanPositionY:Number;
		private var gSavedInitialX:Number;
		private var gSavedInitialY:Number;
		private var gSavedInitialZoom:Number;
		// callbacks
		private var gFocusCallback:Array;	// = new Array();
		private var gRectCallback:Array;	// = new Array();
		private var gViewCallback:Array;	// = new Array();
		private var gInitializeCallback:Array;	// = new Array();
		private var gStatusCallback:Array;	// = new Array();
		private var gClipCallback:Array;	// = new Array();
		//end
		private var gCurrentTier:Number;
		private var gCurrentTier_mc:UIComponent;
		private var gOldTier:Number;
		private var gCurrentTierOld_mc:UIComponent;
		private var gBackgroundTier:Number;
		
		private var gCurrentTierBackground_mc:UIComponent;
		private var gLabelTier_mc:UIComponent;
		private var gLabelTier_mc_labels:UIComponent;
	/*	
		private var gScaledWindowTop:Number;
		private var gScaledWindowRight:Number;
		private var gScaledWindowLeft:Number;
		private var gScaledWindowBottom:Number;
	*/
		private var gScaledWindow:Bounds;
		
		private var gTileCountHeight:Array;	// = new Array();
		private var gTileCountWidth:Array;	// = new Array();
		private var gTierWidth:Array;	// = new Array();
		private var gTierHeight:Array;	// = new Array();
		private var gRegistrationPointX:Number;
		private var gRegistrationPointY:Number;
		private var gLabelArray:Array;
		private var gLabelVisibility:Boolean;
		private var gSavedLabelVisibility:Boolean;
/*	
		private var gOriginalPanMouseXScale:Number;
		private var gOriginalPanMouseYScale:Number;
*/	
		private var gOriginalMovieWidth:Number;
		private var gOriginalMovieHeight:Number;
		private var gCurrentTierArray:Number;
	
		private var tierList:Array;
	
		private var gTierTileCount:Array;	// = new Array();
		private var gTilesUsedArray1:Array;	// = new Array();
		private var gTilesUsedArray2:Array;	// = new Array();
		private var gTilesUsedOldTierArray1:Array;	// = new Array();
		private var gTilesUsedOldTierArray2:Array;	// = new Array();
		private var gStartTier:Number;
		private var gTileSize:Number;
		private var gVersion:Number;
		// load queue manager
		private var loader:ZfLoader = null;
	//	private var gBlipIntervall:Number;
		
		private var gMouseWheelInterval:Number;
		
		private var symbolLevel:Number;
		private var	hasKBFocus:Boolean;
		
		private var map_filters:Array;
		private var registeredMouseWheelHandlers:Number;
		
		public var tileClass:Class;
		
		private var tileCache:Array;
		
		//===========================================================================
		protected function debug(text:String):void {
//			trace("DBG ZMFY(" + this + "): " + text);
		}
		protected function error(text:String):void {
			trace("ERR ZMFY(" + this + "): " + text);
		}
		//===========================================================================
		
		public function registerLComponent( cbcomp:ZfLoader):void {
	//		error("reg LComp "+cbcomp);
			loader = cbcomp;
		}
		//===========================================================================
		/*setImagePath: The path that is passed into this function must be relative to the 
			root of the server.  This function needs to be followed by a call to updateView in 
			order to apply the change.*/
		public function setImagePath( path:String, node:XMLNode):void {
			debug("setImagePath: " + path+"/"+node);
			if (loader != null) {
				loader.clear();
			}
	
			_imageNode = node;
			_imagePath = path;
			gURLChanged = true;
			gImgInfoLoaded = false;
			gClipSaved = gClip;
			gClip = false;		
			debug("setImagePath--");
		}
		public function getImagePath():String {
			return _imagePath;
		}
		public function getImageNode():XMLNode {
			return _imageNode;
		}
	
		/*setSize: Modifying the width and height of the instance of the image will result in
			the stretching of the image unless this function is called afterwards.  This function
			needs to be followed by a call to updateView in order to apply the change.*/
		public function setSize(width:Number, height:Number):void {
//			super.setSize( width, height);
			
//			trace("setSize: " + width+","+height);
			scaleX = 1;
			gViewWidth = width;
			scaleY = 1;
			gViewHeight = height;
			_sizeChanged = true;
			gMustResetViewer = true;
			clipZoom();
			clipPosition();
			
			dispatchChangeEvent();
		}
		
		public function updateComplete( evt:Event):void {
//			trace( "upd "+mask_mc+" "+width+","+height);
			
			setSize( width, height);
			
			var hw:int = width / 2;
			var hh:int = height / 2;
			mapLayer.x = hw;
			mapLayer.y = hh;

			with( mask_mc.graphics) {
				clear();			
				beginFill( 0x00ff00, 1);
				moveTo( -hw, -hh);
				lineTo( -hw, hh);
				lineTo( hw, hh);
				lineTo( hw, -hh);
				lineTo( -hw, -hh);
				endFill();
			}
			/*
			with ( invisiblePanMouse_btn.graphics) {
				clear();
				beginFill( 0xff0000, 0.2);
				moveTo( -hw, -hh);
				lineTo( -hw, hh);
				lineTo( hw, hh);
				lineTo( hw, -hh);
				lineTo( -hw, -hh);
				endFill();
			}
			*/
		}
		
		public function getSize():Dimension {
			var b:Dimension = new Dimension();
			b.width = gViewWidth;
			b.height = gViewHeight;
			return b;
		}
	
		public function getImageSize():Object {
			var b:Object = new Object();
			b.width = gURLChanged ? -1 : gImageWidth;
			b.height = gURLChanged ? -1 : gImageHeight;
			return b;
		}
	
		/*setFocus: When called with a true value, this functions enables this instance to
			accept key events.  Focus will also be set to true by the user clicking on the 
			image.  If a focus callback has been set, it is called at this time if focus is true.*/
	
		public function enableKeys(focus:Boolean):void {
	//		error( "keys: "+focus);
			keysEnabled = focus;
	//		castFocusEvent();
			dispatchEvent( new ZfEvent( ZfEvent.FOCUS));
		}
		
		public function getResolution():Number {
			return gResolution;
		}
		
		//===============================================================================
		
		public function setClipping( state:Boolean):void {
			gClip = state;
		}
		public function clearClip():void {
			gClip = false;
			gClipEvents = 0;
		}
		public function setClip( minx:Number, miny:Number, maxx:Number, maxy:Number):void {
			clipBounds.left = Math.max( minx, maxx);
			clipBounds.right = Math.min( minx, maxx);
			clipBounds.top = Math.max( miny, maxy);
			clipBounds.bottom = Math.min( miny, maxy);
			
	//		error( "set Clipping: x("+clipBounds.left+" / "+clipBounds.right+")\t\ty("+clipBounds.bottom+" / "+clipBounds.top+")");
	
			if ( gImgInfoLoaded) gClip = true;
			else ( "saving clip info.");
			gClipSaved = true;
			
			clipZoom();
			if ( gZoom < _minZoom) {
	//			setClipEvent( CLIP_MASKZOOM, CLIP_MINZOOM);
				setZoom( _minZoom);
			}
	//		clipPosition();
	//		fillView();
	//		updateAfterEvent();
	//		if ( gCurrentTier >= 0) clipPosition();
		}
	
		private function clipZoom():void {
			if ( gClip) {
				var vp_asp:Number = gViewWidth / gViewHeight;
				// calculate vp-aspect in vp-units corrected by image-aspect
				var cl_asp:Number = ( clipBounds.width / clipBounds.height) * ( gImageWidth / gImageHeight);
				var zf:Number;
				
	//			error( "zoom clip: "+gViewWidth+" / "+gViewHeight+" ? "+(clipBounds.width / 2)+" / "+( clipBounds.height / 2));
				if ( vp_asp > cl_asp) {
					// viewport is wider than clipping area
					// width limits
					zf = gViewWidth / ( gImageWidth * clipBounds.width);
	//				error( "###zoom clip horiz: "+zf);
				} else {
					// viewport is taller than clipping area
					// height limits
					zf = gViewHeight / ( gImageHeight * clipBounds.height);
	//				error( "###zoom clip vert: "+zf);
				}
				_minZoom = zf;
				if ( _initialZoom < _minZoom) _initialZoom = zf;
				if ( gSavedInitialZoom < _minZoom) gSavedInitialZoom = zf;
	//			if ( _maxZoom < zf) _maxZoom = zf;
	//			error( "clip zoom to: "+_minZoom);
			}
		}
	
		private function clipPan( offx:Number, offy:Number):Number {
	
			var clipFlags:Number = 0;
		
			var x:Number = gCurrentTier_mc.x + offx;
			var y:Number = gCurrentTier_mc.y + offy;
			
			if ( gClip) {
				// calculate the current tier size
				var tw:Number = (getTierWidth(gCurrentTier) * gCurrentTier_mc.scaleX);
				var th:Number = (getTierHeight(gCurrentTier) * gCurrentTier_mc.scaleY);
				
				var vw:Number = gViewWidth / 2;
				var vh:Number = gViewHeight / 2;
	/*			
				debug( "offs: "+vw+" x "+vh);
				debug( "tier size scaled: "+tw+" x "+th+"    "+gCurrentTier_mc.scaleX+" x "+gCurrentTier_mc.scaleY);
	*/			
				// adjust clipping to current tier-size, correct for screen size
				var l:Number = clipBounds.left * tw - vw;
				var r:Number = clipBounds.right * tw + vw;
				var t:Number = clipBounds.top * th - vh;
				var b:Number = clipBounds.bottom * th + vh;
		
	//			debug( "limits: "+r+" x "+l+"\t\t"+t+" x "+b);
		
				// calculate position
				var panx:Number = gPanPositionX * tw;
				var pany:Number = gPanPositionY * th;
		
	//			debug( "viewpos: "+x+" , "+y+"   +   "+gPanPositionX+" , "+gPanPositionY);
		
				if ( l < r) {
					l = (l + r) / 2;
					r = l;
				}
				if ( t < b) {
					t = ( t + b) / 2;
					b = t;
				}
	/*
				debug( "clip:"+r+" < "+(x+panx)+" < "+l);
				debug( "clip:"+b+" < "+(y+pany)+" < "+t);
	*/
				if (( x + panx) > l) x = l - panx;
				if ( r > ( x + panx)) x = r - panx;
				if ( t < ( y + pany)) y = t - pany;
				if (( y + pany) < b) y = b - pany;
				
	//			error( "clip:"+l+" < "+int(x)+"["+gClipHyst+"] + "+panx+" < "+r);
	//			error( "clip:"+b+" < "+int(y)+"["+gClipHyst+"] + "+pany+" < "+t+"\n");
	
				if (( x + panx) >= (l - gClipHyst)) clipFlags |= CLIP_LEFT;
				if ((r + gClipHyst) >= ( x + panx)) clipFlags |= CLIP_RIGHT;
				if ((t - gClipHyst) <= ( y + pany)) clipFlags |= CLIP_TOP;
				if (( y + pany) <= (b + gClipHyst)) clipFlags |= CLIP_BOTTOM;
	
	//			debug( "##clip pn event: "+clipFlags);
				setClipEvent( CLIP_MASKRECT, clipFlags);
			}
	
	//		if ( clipFlags != 0) panStop();
	
			gCurrentTier_mc.x = x;
			gCurrentTier_mc.y = y;
	
	//		debug( "pan-: "+panx+"\t"+pany+"\t\tl: "+l+"\t"+r+"\t\tx: "+x+"\t"+y+"\n");
			return clipFlags;
		}
	
		private function clipPosition():Number {
	
			var clipFlags:Number = 0;
		
			if ( gClip) {
				// calculate position
				var x:Number = gPanPositionX;	// / 2);	//( getTierWidth(gCurrentTier) / 2);
				var y:Number = gPanPositionY;	// / 2);	//( getTierHeight(gCurrentTier) / 2);
	
				// calculate the current tier size
				var zf:Number = getZoom();
				var cHyst:Number = ( gClipHyst / zf ) / gImageWidth;
				
				var vw:Number = (( gViewWidth / zf ) / gImageWidth) / 2;
				var vh:Number = (( gViewHeight / zf ) / gImageHeight) / 2;
				
	//			debug( "###vw: "+gViewWidth+"/"+(gViewWidth / zf)+" = "+vw+"\t\th: "+cHyst+"\tzf: "+zf);
	//			debug( "offs: "+gViewHeight+"/"+( gViewHeight / zf )+" = "+vh+"\t\t"+cHyst+"\t"+zf);
				
	//			debug( "tier size scaled: "+tw+" x "+th+"    "+gCurrentTier_mc.scaleX+" x "+gCurrentTier_mc.scaleY);
	
	//			debug( "clipx:"+clipBounds.right+" < "+x+" < "+clipBounds.left);
	//			debug( "clipy:"+clipBounds.bottom+" < "+x+" < "+clipBounds.top);
				// adjust clipping to current tier-size, correct for screen size
				// reverse left/right
				var l:Number = clipBounds.left - vw;
				var r:Number = clipBounds.right + vw;
				var t:Number = clipBounds.top - vh;
				var b:Number = clipBounds.bottom + vh;
		
	//			debug( "clip:"+clipBounds.right+" < "+x+" < "+clipBounds.left+"\t\t"+clipBounds.bottom+" < "+y+" < "+clipBounds.top);
	//			debug( "clipx+:"+r+" < "+x+" < "+l);
	//			debug( "clipy+:"+b+" < "+y+" < "+t);
	
				if ( l < r) {
					l = (l+r)/2;
					r = l;
				}
				if ( t < b) {
					t = (b+t)/2;
					b = t;
				}
				
				if ( l < x) x = l;
				if ( x < r) x = r;
				
				if ( t < y) y = t;
				if ( y < b) y = b;
				
				if (Math.abs( l - x) <= cHyst) clipFlags |= CLIP_LEFT;
				if (Math.abs( r - x) <= cHyst) clipFlags |= CLIP_RIGHT;
				if (Math.abs( t - y) <= cHyst) clipFlags |= CLIP_TOP;
				if (Math.abs( b - y) <= cHyst) clipFlags |= CLIP_BOTTOM;
	/*
				debug( "##l "+cHyst+" ? "+Math.abs(l - x));
				debug( "##r "+cHyst+" ? "+Math.abs(r - x));
				debug( "##t "+cHyst+" ? "+Math.abs(t - y));
				debug( "##b "+cHyst+" ? "+Math.abs(b - y));
	//			debug( "clip:"+clipBounds.right+" < "+x+" < "+clipBounds.left+"\t\t"+clipBounds.bottom+" < "+y+" < "+clipBounds.top);
	//			debug( "clipx -:"+r+" < "+x+" < "+l);
	//			debug( "clipy -:"+b+" < "+y+" < "+t);
	*/
				gPanPositionX = x;
				gPanPositionY = y;
	
	//			debug( "##clip hv event: "+clipFlags);
				setClipEvent( CLIP_MASKRECT, clipFlags);
			}
			
			return clipFlags;
		}
	
		private function clipPositionY( y :Number):Number {
	
			if ( gClip) {
				var clipFlags:Number = 0;
				var zf:Number = getZoom();
				var cHyst:Number = ( gClipHyst / zf ) / gImageWidth;
				
				var vh:Number = (( gViewHeight / zf ) / gImageHeight) / 2;			
				var t:Number = clipBounds.top - vh;
				var b:Number = clipBounds.bottom + vh;
		
				debug( "###clipY ("+vh+"/"+zf+") x:"+t+"/"+clipBounds.top+" < "+y+" < "+b+"/"+clipBounds.bottom);
	//			debug( "##clip y:"+b+" < "+y+" < "+t);
	
				if ( t < b) {
					t = (b+t)/2;
					b = t;
				}
				
				if ( t < y) y = t;
				if ( y < b) y = b;
				
				if (Math.abs( t - y) <= cHyst) clipFlags |= CLIP_TOP;
				if (Math.abs( b - y) <= cHyst) clipFlags |= CLIP_BOTTOM;
	
	//			debug( "##clip y:"+b+" < "+y+" < "+t);
	
	//			if ( clipFlags) debug( "##clip v event: "+clipFlags);
				setClipEvent( CLIP_TOP | CLIP_BOTTOM, clipFlags);
			}
			return y;
		}
	
		private function clipPositionX( x:Number):Number {
	
			if ( gClip) {
				var clipFlags:Number = 0;
				var zf:Number = getZoom();
				var cHyst:Number = ( gClipHyst / zf ) / gImageWidth;
				
				var vw:Number = (( gViewWidth / zf ) / gImageWidth) / 2;
				var l:Number = clipBounds.left - vw;
				var r:Number = clipBounds.right + vw;
	
				debug( "###clipX ("+vw+"/"+zf+") x:"+r+"/"+clipBounds.right+" < "+x+" < "+l+"/"+clipBounds.left);
	
				if ( l < r) {
					l = (l+r)/2;
					r = l;
				}
				if ( x > l) x = l;
				if ( r > x) x = r;
				
				if (Math.abs( l - x) <= cHyst) clipFlags |= CLIP_LEFT;
				if (Math.abs( r - x) <= cHyst) clipFlags |= CLIP_RIGHT;
	//			debug( "clip:"+clipBounds.right+" < "+x+" < "+clipBounds.left+"\t\t"+clipBounds.bottom+" < "+y+" < "+clipBounds.top);
	//			debug( "###clip x:"+r+" < "+x+" < "+l);
	
	//			if ( clipFlags) debug( "##clip event: "+clipFlags);
				setClipEvent( CLIP_LEFT | CLIP_RIGHT, clipFlags);
			}
			return x;
		}
	
		public function setClipEvent( mask:Number, events:Number):void {
	//		debug( "event check:\t"+gClipEvents+"\t"+mask+"\t"+events);
			if ( ! gClip) return;
			if ( mask == 0) return;
			
			// check if masked bits are equal
	//		if (( gClipEvents & mask) == ( events & mask)) return;
			// only send "no clipping" once
			if (( gClipEvents & mask) == ( events & mask) && ( events == 0)) return;
			
			// copy bits
			gClipEvents = (gClipEvents & ~ mask) | ( events & mask);
			debug( "event  cast:\t"+gClipEvents+"\t"+mask+"\t"+events+" "+(gClipEvents & CLIP_LEFT)+" "+(gClipEvents & CLIP_RIGHT)+" "+(gClipEvents & CLIP_TOP)+" "+(gClipEvents & CLIP_BOTTOM)+" "+(gClipEvents & CLIP_MAXZOOM)+" "+(gClipEvents & CLIP_MINZOOM));
	
			// allow clipping after not clipping once
			if ( gClipEvents == 0) gClipAllow = true;
			
			if ( gClipAllow) dispatchEvent( new ZfEvent( ZfEvent.CLIP));	//{ type:'zfclip', target:this, detail:gClipEvents});
	
	//		castClipEvent( gClipEvents);
		}
		
		public function clearClipEvent( mask:Number, events:Number):void {
	//		debug( "event check:\t"+gClipEvents+"\t"+mask+"\t"+events);
			if ( mask == 0) return;
			
			// check if any masked bit is set
			if (( gClipEvents & mask) == 0) return;
			
			// clear active bits
			gClipEvents ^= ( events & mask);
	//		debug( "event  cast:\t"+gClipEvents+"\t"+mask+"\t"+events);
	
			gClipAllow = true;
			dispatchEvent( new ZfEvent( ZfEvent.CLIP));	//{ type:'zfclip', target:this, detail:gClipEvents});
	//		castClipEvent( gClipEvents);
		}
	
		public function setInitialView(x:Number, y:Number, zoom:Number):void {
			debug( "setInitialView: "+x+","+y+" @ "+zoom);
			clipZoom();
			_initialX = x;	//clipPositionX( x);
			_initialY = y;	//clipPositionY( y);
			_initialZoom = (zoom >= _minZoom) ? zoom : _minZoom;
			
			gSavedInitialX = _initialX;
			gSavedInitialY = _initialY;
			gSavedInitialZoom = _initialZoom;
	
	//		debug( "## setInitialView: "+_initialX+","+_initialY+" @ "+_initialZoom);
	
	/*
			fillView();
	
			setZoom(zoom);
			updateAfterEvent();
	*/
		}
	
		/*setView: The values x and y will be between -1 (far left of image) and 1 (far right 
			of image). This representation is 'resolution independent'.  These values can be obtained 
			for any view  by calling getX and getY.  (Note that Zoomify's other viewers can be used 
			obtain X and Y for any view by using the keystoke combination 's'+'i'.)  The zoom value 
			is used to control the magnification of the image where 100 means 100% magnification. 
			Calls to setView should be followed by a call to updateView in order to force the 
			component to draw the new view.*/
		public function setView(x:Number, y:Number, zoom:Number):void {
			debug( "##setView: "+x+","+y+" @ "+zoom);
			clipZoom();
			if ( zoom < _minZoom) zoom = _minZoom;
			setZoom(zoom);
	
			gPanPositionX = clipPositionX( x);
			gPanPositionY = clipPositionY( y);
	
			debug( "setView: "+gPanPositionX+","+gPanPositionY+" @ "+zoom);
	
	//		dispatchChangeEvent();
	//		fillView();
	//		updateAfterEvent();
		}
		/* setX: sets the x value of the view.  The values x and y will be between -1 (far left of image) and 1 (far right 
			of image). This representation is 'resolution independent'.  These values can be obtained 
			for any view  by calling getX and getY.  (Note that Zoomify's other viewers can be used 
			obtain X and Y for any view by using the keystoke combination 's'+'i'.) */
		public function setX(x:Number):void {
			gPanPositionX = clipPositionX( x);
	//		fillView();
	//		updateAfterEvent();
			dispatchChangeEvent();
		}
		/* setY: sets the y value of the view.  The values x and y will be between -1 (far left of image) and 1 (far right 
			of image). This representation is 'resolution independent'.  These values can be obtained 
			for any view  by calling getX and getY.  (Note that Zoomify's other viewers can be used 
			obtain X and Y for any view by using the keystoke combination 's'+'i'.) */
		public function setY(y:Number):void {
			gPanPositionY = clipPositionY( y);
	//		fillView();
	//		updateAfterEvent();
			dispatchChangeEvent();
		}
		/*maxView: show whole map */
		public function maxView():void {
			debug( "maxView");
	
	//		setView(_initialX, _initialY, _initialZoom);
			setView( 0, 0, _minZoom);
			
	//		updateView();
			dispatchChangeEvent();
			callLater( updateView);
		}
		
		/*resetView: resets the view to the initial view coordinates */
		public function resetView():void {
	//		debug( "resetView");
	
			setView(_initialX, _initialY, _initialZoom);
	//		setView( 0, 0, _minZoom);
			dispatchChangeEvent();
			callLater( updateView);
		}
		/*updateView: causes the Zoomify viewer to render the current view.  This must be 
			called after calling setView, setImagePath, setByteHandlerURL or setZoom*/
		public function updateView():void {
			debug("updateview: ini:" + gUpdatePhase+"/"+gInitialized+"/res:"+gMustResetViewer + "/url:" + gURLChanged);
			debug("init: "+_initialX+" / "+gSavedInitialX+" , "+_initialY+" / "+gSavedInitialY+" @ "+_initialZoom+" / "+gSavedInitialZoom);
	
			if ( gMustResetViewer == true || gURLChanged == true) {
				gSavedInitialX=_initialX;
				gSavedInitialY=_initialY;
				gSavedInitialZoom=_initialZoom;
				
				gLabelTier_mc.visible = false;
	//			error( "LABELVIS: "+gSavedLabelVisibility);
				
				if (gInitialized == true) {
					if (gURLChanged == false) {
						_initialX=getX();
						_initialY=getY();
						_initialZoom=getZoom();
						
						cleanup();
						
					} else cleanup();
				}
				
	//			delInit();
				callLater( zfsetup);
				
				debug( "updateView -1-");
				gUpdatePhase = 1;
				return;
			}
			
			if (gInitialized == true) {
				_initialX = gSavedInitialX;
				_initialY = gSavedInitialY;
				_initialZoom = gSavedInitialZoom;
	/*
				if (gSetViewCalled == true) {
					panStop();
					gSetViewCalled = false;
				}
	*/
				setTier();
	/*
				clipZoom();
				clipPosition();
	*/
				fillView( true);
				
				gUpdatePhase = 0;
			}
			debug( "updateView -2-");
		}
	
		/*setMinZoom: sets the minimum amount of zoom allowed.  If set to -1, minZoom
			will be calculated and set so as to cause the image to exactly fill the screen*/
		public function setMinZoom(minZoom:Number):void {
			_minZoom = minZoom;
			clipZoom();
			dispatchChangeEvent();
	//		debug( "minZoom: "+_minZoom);
		}
		public function getMinZoom():Number {
			return _minZoom;
		}
		/*setMaxZoom: sets the maximum amount of zoom allowed.*/
		public function setMaxZoom(maxZoom:Number):void {
			_maxZoom = maxZoom;
			clipZoom();
			dispatchChangeEvent();
	//		debug( "maxZoom: "+_maxZoom);
		}
		public function getMaxZoom():Number {
			return _maxZoom;
		}
		/*setZoom: sets the current zoom.  The zoom value is used to control the magnification
			of the image where 100 means 100% magnification.  Note that passing a -1 in for 
			zoom will cause this function to calculate the zoom so that the image fits exactly
			into the given view area.*/
		public function setZoom(zoom:Number):void {
			var baseWidth:Number;
			debug( "setZoom: "+zoom+" : "+_maxZoom);
			gZoom = zoom;
			clipZoom();
			if (gInitialized == true) {
				var tempZoom:Number;
				if (zoom == -1 || _minZoom == -1) {
					baseWidth = getTierWidth(gTierCount);
					var baseHeight:Number = getTierHeight(gTierCount);
					
					var testWidth:Number = gViewWidth / baseWidth;
					var testHeight:Number = gViewHeight / baseHeight;
					
					if (testWidth > testHeight) {
						tempZoom = testHeight;
					} else {
						tempZoom = testWidth;
					}
				}
				//If minZoom has not been set, set it to fill the screen.
				if (_minZoom == -1) {
					_minZoom = tempZoom;
				} else {
					if ( zoom < _minZoom) {
						gZoom = _minZoom;
					}
				}
				if (zoom == -1) {
					gZoom = tempZoom;
				} 
				if ( _maxZoom > 0 && gZoom > _maxZoom) {
					gZoom = _maxZoom;
				}
	/*			
				if ( gZoom < 0.1 || gZoom > 500) {
					gZoom = Math.max( Math.min( 500, gZoom), 0.1);
					error( "correcting extreme zoom.");
				}
	*/			
				baseWidth = getTierWidth(gTierCount);
				var currentWidth:Number;
	/*			
				if ( Math.abs( currentWidth) < 1) {
					debug( "w2small");
					currentWidth = 1;
				}
	*/				
				//The scale is the zoom multiplied by the ratio between the base width and the current width.
				//Set it for the current tier
				currentWidth = getTierWidth(gCurrentTier);
				gCurrentTier_mc.scaleX = gZoom * baseWidth / currentWidth;
				gCurrentTier_mc.scaleY = gCurrentTier_mc.scaleX;
				//Set it for the old tier
				currentWidth = getTierWidth(gOldTier);
				if ( gCurrentTierOld_mc != null) {
					gCurrentTierOld_mc.scaleX = gZoom * baseWidth / currentWidth;
					gCurrentTierOld_mc.scaleY = gCurrentTierOld_mc.scaleX;
				}
				//Set it for the background tier
				currentWidth = getTierWidth(gBackgroundTier);
				gCurrentTierBackground_mc.scaleX = gZoom * baseWidth / currentWidth;
	//			trace( "##setZoom: "+gCurrentTierBackground_mc.scaleX);
				
				gCurrentTierBackground_mc.scaleY = gCurrentTierBackground_mc.scaleX;
				
				//Set it for the gLabelTier_mc tier
				gLabelTier_mc.scaleX = gZoom;		// * baseWidth / currentWidth;
				gLabelTier_mc.scaleY = gLabelTier_mc.scaleX;
			}
			var ze:Number = 0;
			if ( gZoom == _minZoom) ze = CLIP_MINZOOM;
			if ( gZoom == _maxZoom) ze = CLIP_MAXZOOM;
			setClipEvent( CLIP_MASKZOOM, ze);
			dispatchChangeEvent();
		}
		/*getX: returns the current x position of the Zoomify camera.  This value can be applied 
			using setView.*/
		public function getX():Number {
			return gPanPositionX;
		}
		/*getY: returns the current y position of the Zoomify camera.  This value can be applied 
			using setView.*/
		public function getY():Number {
			return gPanPositionY;
		}
		/*getZoom: returns the current zoom of the Zoomify camera.  This value can be applie using
			setView or setZoom.*/
		public function getZoom():Number {
	//		debug( "getZooM: "+gCurrentTier+"/"+gTierCount);
			var baseWidth:Number = getTierWidth( gTierCount);
	/*		var currentWidth = getTierWidth( gBackgroundTier);
			var zoom = gCurrentTierBackground_mc.scaleX * currentWidth / baseWidth;
	*/		
			var cw:Number = getTierWidth( gCurrentTier);
	//		var z:Number = gCurrentTier_mc.scaleX * getTierWidth( gCurrentTier) / baseWidth;
	
			return ( gCurrentTier_mc.scaleX * cw / baseWidth);
			
	//		trace( "getZooM: "+gCurrentTierBackground_mc.scaleX+" * "+currentWidth+" / "+baseWidth+" = "+zoom);
	//		trace( "getZooM: "+gCurrentTier_mc.scaleX+" * "+cw+" / "+baseWidth+" = "+z);
			
	//		return z;
		}
		public function getPixelZoom():Number {
	//		debug( "getZooM: "+gCurrentTier+"/"+gTierCount);
			return gCurrentTierBackground_mc.scaleX;
		}
	
		/*getTierCount: returns the number of tiers or resolution levels in the image.*/
		public function getTierCount():Number {
			return gTierCount;
		}
		/*getTileCountHeight: returns the number of tiles for the given tier in the y direction.
			Note: the first tier is #1 but first array element is #0*/
		public function getTileCountHeight(tier:int):Number {
			return gTileCountHeight[tier - 1];
		}
		/*getTileCountWidth: returns the number of tiles for the given tier in the x direction.
			Note: the first tier is #1 but first array element is #0*/
		public function getTileCountWidth(tier:int):Number {
			return gTileCountWidth[tier - 1];
		}
		/*getTierWidth: returns the width in pixels of the given tier.  Note: the first tier is 
			#1 but first array element is #0*/
		public function getTierWidth(tier:int):Number {
			return gTierWidth[tier - 1];
		}
		/*getTierHeight: gets the height in pixels of the given tier.  Note: the first tier is 
			#1 but first array element is #0*/
		public function getTierHeight(tier:int):Number {
			return gTierHeight[tier - 1];
		}
		
		//setEnabled - turns on/off all mouse and keyboard action
		public function setEnabled(enabled:Boolean):void {
			gEnabled = enabled;
		}
		/*zoomIn: called by the zoomInBtn and when the zoom in key is pressed. The scale 
			of the current, background, and old tiers are reset with verification to ensure that
			the maxZoom setting is not exceeded.*/
		public function zoomIn( zoomFactor:Number=1.2):void {
			
			// allow clipping by user interaction
			gClipAllow = true;
	
			if (gInitialized == true) {
				if (gCurrentTier > gBackgroundTier) {
					gCurrentTier_mc.scaleX = gCurrentTier_mc.scaleX * zoomFactor;
					gCurrentTier_mc.scaleY = gCurrentTier_mc.scaleY * zoomFactor;
				}
				if (gOldTier > gBackgroundTier) {
					gCurrentTierOld_mc.scaleX = gCurrentTierOld_mc.scaleX * zoomFactor;
					gCurrentTierOld_mc.scaleY = gCurrentTierOld_mc.scaleY * zoomFactor;
				}
				gCurrentTierBackground_mc.scaleX = gCurrentTierBackground_mc.scaleX * zoomFactor;
				gCurrentTierBackground_mc.scaleY = gCurrentTierBackground_mc.scaleY * zoomFactor;
				gLabelTier_mc.scaleX = gLabelTier_mc.scaleX * zoomFactor;
				gLabelTier_mc.scaleY = gLabelTier_mc.scaleY * zoomFactor;
				var currentZoom:Number = getZoom();
				if (currentZoom >= _maxZoom) {
					setZoom(_maxZoom);
				} else {
					setClipEvent( CLIP_MASKZOOM, 0);
				}
				clipPosition();
				
				dispatchChangeEvent();
			}
		}
		/*zoomOut: called by the zoomOutBtn and when the zoom out key is pressed. The scale 
			of the current, background, and old tiers are reset with verification to ensure that
			the minZoom setting is not exceeded.*/
		public function zoomOut( zoomFactor:Number=1.2):void {
	
			// allow clipping by user interaction
			gClipAllow = true;
	
			if (gInitialized == true) {
				var currentZoom:Number = getZoom();
				if (currentZoom > _minZoom) {
					if (gCurrentTier > gBackgroundTier) {
						gCurrentTier_mc.scaleX = gCurrentTier_mc.scaleX / zoomFactor;
						gCurrentTier_mc.scaleY = gCurrentTier_mc.scaleY / zoomFactor;
					}
					if (gOldTier > gBackgroundTier) {
						gCurrentTierOld_mc.scaleX = gCurrentTierOld_mc.scaleX / zoomFactor;
						gCurrentTierOld_mc.scaleY = gCurrentTierOld_mc.scaleY / zoomFactor;
					}
					gCurrentTierBackground_mc.scaleX = gCurrentTierBackground_mc.scaleX / zoomFactor;
					gCurrentTierBackground_mc.scaleY = gCurrentTierBackground_mc.scaleY / zoomFactor;
					gLabelTier_mc.scaleX = gLabelTier_mc.scaleX / zoomFactor;
					gLabelTier_mc.scaleY = gLabelTier_mc.scaleY / zoomFactor;
					
					currentZoom = getZoom();
					if (currentZoom < _minZoom) {
						setZoom(_minZoom);
						setClipEvent( CLIP_MASKZOOM, CLIP_MINZOOM);
					} else {
						setClipEvent( CLIP_MASKZOOM, 0);
					}
				} else {
					setClipEvent( CLIP_MASKZOOM, CLIP_MINZOOM);
				}
				clipPosition();
				
				dispatchChangeEvent();
			}
		}
	
		public function pan( panx:Number, pany:Number):void {
			if (gInitialized == true) {
				var clev:Number;
				
				// allow clipping by user interaction
				gClipAllow = true;
	
				var incrementWeightedX:Number = panx * gCurrentTier_mc.scaleX;
				var incrementWeightedY:Number = pany * gCurrentTier_mc.scaleY;
	
				clev = clipPan( incrementWeightedX, incrementWeightedY);
	
				gCurrentTierOld_mc.x = gCurrentTier_mc.x;
				gCurrentTierOld_mc.y = gCurrentTier_mc.y;
	
				gCurrentTierBackground_mc.x = gCurrentTier_mc.x;
				gCurrentTierBackground_mc.y = gCurrentTier_mc.y;
	
				gLabelTier_mc.x = gCurrentTier_mc.x;
				gLabelTier_mc.y = gCurrentTier_mc.y;
				
				if ( clev) panStop();
				
				dispatchChangeEvent();
			}
		}
	
		/*panLeft: called when the panLeftBtn is clicked or the pan left key is pressed. The image 
			position is changed by an amount scaled to allow for the current amount of zoom.*/
		public function panLeft( step:Number=0):void {
			if ( step == 0) step = gViewWidth / 50;
			pan( -step, 0);
		}
		/*panUp: called when the panUpBtn is clicked or the pan up key is pressed. The image 
			position is changed by an amount scaled to allow for the current amount of zoom.*/
		public function panUp( step:Number=0):void {
			if ( step == 0) step = gViewWidth / 50;
			pan( 0, -step);
		}
		/*panDown: called when the panDownBtn is clicked or the pan down key is pressed. The image 
			position is changed by an amount scaled to allow for the current amount of zoom.*/
		public function panDown( step:Number=0):void {
			if ( step == 0) step = gViewWidth / 50;
			pan( 0, step);
		}
		/*panRight: called when the panRightBtn is clicked or the pan right key is pressed. The image 
			position is changed by an amount scaled to allow for the current amount of zoom.*/
		public function panRight( step:Number=0):void {
			if ( step == 0) step = gViewWidth / 50;
			pan( step, 0);
		}
		
		/*panStop: called whenever any of the pan buttons are released.  Note that any pan of 
			a view simply pans a tier 'container' movie clip. The tiles that are contained therein 
			are positioned at the completion of the pan motion and the tier container is then reset 
			to a centered position (to ensure that future zooms are relative to the center point.
			This approach ensures that minimal processing (tile positioning) occurs during panning. 
			This provides a much smoother pan experience. 
			
			The order of processing is as follows: First, the amount of motion is calculated. Next, 
			this motion measurement is scaled based on the current amount of zoom. Next, the 
			gPanPosition variable is updated. This variable is used by the drawing functions to reposition 
			the tiles. Lastly, the x and y coordinates of the current, background,and old tiers are 
			reset and the tiers are recentered.*/
		public function panStop():void {
	//		debug("##panStop");
			if (gInitialized == true) {
				clipPan( 0, 0);
				var motionX:Number = (gCurrentTier_mc.x - gRegistrationPointX);
				var motionY:Number = (gCurrentTier_mc.y - gRegistrationPointY);
				var motionScaledX:Number = motionX / (getTierWidth(gCurrentTier) * gCurrentTier_mc.scaleX);
				var motionScaledY:Number = motionY / (getTierHeight(gCurrentTier) * gCurrentTier_mc.scaleY);
				// dir changed
				gPanPositionX = gPanPositionX + motionScaledX;
				gPanPositionY = gPanPositionY + motionScaledY;
				
				gCurrentTier_mc.x = gRegistrationPointX;
				gCurrentTier_mc.y = gRegistrationPointY;
				if ( gCurrentTierOld_mc != null) {
					gCurrentTierOld_mc.x = gRegistrationPointX;
					gCurrentTierOld_mc.y = gRegistrationPointY;
				}
				gCurrentTierBackground_mc.x = gRegistrationPointX;
				gCurrentTierBackground_mc.y = gRegistrationPointY;
				
				gLabelTier_mc.x = gRegistrationPointX;
				gLabelTier_mc.y = gRegistrationPointY;
	/*
				gLabelTier_mc.x = gPanPositionX * (getTierWidth(gCurrentTier) * gCurrentTier_mc.scaleX / 200);
				gLabelTier_mc.y = - gPanPositionY * (getTierHeight(gCurrentTier) * gCurrentTier_mc.scaleY / 200);
	*/
			}
	//		trace( "pan: "+gLabelTier_mc.x+"\t"+gLabelTier_mc.y+"\t\t"+(gPanPositionX)+"\t"+(gPanPositionY));
		}
	
		// all label code is reduced to this call
		// labels are handled completely in an external store which is attached via callbacks
		
		public function getScaledLabelLayer():UIComponent {
			return gLabelTier_mc_labels;
		}
	
		public function setLabelVisible( state:Boolean):void {
	
			if ( gLabelTier_mc.visible != state) {
				
				gLabelTier_mc.visible = state;
				
				var o:Object = new Object;
				o.x = getX();
				o.y = getY();
				o.zoom = getZoom();
				o.labels = state;
				
				dispatchEvent( new ZfEvent( ZfEvent.VIEW));	//{ type:'zfview', target:this, detail:o});
			}
			
			gSavedLabelVisibility = state;
		}
		
		public function getLabelVisible( ):Boolean {
			return gLabelTier_mc.visible;
		}
	
		/*
		 * setMapFilters
		 * 
		 * Assigns the filters-array to all visible tiles of the map.
		 */
		public function set mapfilters( farr:Array):void {
			var i:int;
			map_filters = farr;
	
			var tuc:Number = gTilesUsedArray1.length;
			for( i = 0; i < tuc; i++) {
				gTilesUsedArray1[ i].filters = map_filters;
			}
										 
			var tuc2:Number = gTilesUsedArray2.length;
			for( i = 0; i < tuc2; i++) {
				gTilesUsedArray2[ i].filters = map_filters;
			}
			
			error( "updated: "+tuc+" / "+tuc2);
		}
		
		/*
		 * setMapFilters
		 * 
		 * Returns the filters-array from the map.
		 */
		public function get mapfilters():Array {
			return map_filters;
		}
	
		public function getSymbolLevel():Number {
			var temp:Number = symbolLevel++;
			return temp;
		}
		
		public function setMapContrast( ctr:Number):void {
			mapDimmer.alpha = ctr;
		}
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: PRIVATE METHODS :::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::: MOUSE, BUTTON, AND KEY FUNCTIONS ::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		/*initKeyHandler: Creates a keyListener and handles key events.  Key events will be ignored
			if focus is set to false.*/
	
		private function dispatchChangeEvent():void {
/*			
			var o:Object = new Object;
			o.x = getX();
			o.y = getY();
			o.zoom = getZoom();
*/			
			dispatchEvent( new Event( Event.CHANGE));	//{ type:'change', target:this, detail:o});
		}
	
		// allow and keep track of registered listeners for mousewheel events
		override public function addEventListener( event:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			super.addEventListener(event, listener);
			
			if( event == "onMouseWheel") {
				registeredMouseWheelHandlers++;
			}
			
		}
		
		// allow and keep track of registered listeners for mousewheel events
		override public function removeEventListener( event:String, listener:Function, useCapture:Boolean=false):void{
			super.addEventListener(event, listener);
			
			if( event == "onMouseWheel") {
				registeredMouseWheelHandlers--;
			}			
		}
	
		private function handleMouseWheel( evt:MouseEvent):void {
	//		debug( "wheel("+this+"): "+delta+" / "+target);
	
			// only handle mousewheel internally if no listeners are registered
			if ( registeredMouseWheelHandlers == 0) {
				// allow clipping by user interaction
				gClipAllow = true;
	
				if ( evt.delta > 0) zoomIn( 1.1);
				else zoomOut( 1.1);
				
				if ( gMouseWheelInterval != 0) clearInterval( gMouseWheelInterval);
				gMouseWheelInterval = setInterval( mwUpdate, 500);
				debug( "MouseWheel zoom "+evt.delta);
			}
		}
	
		private function mwUpdate():void {
	//		debug( "MouseWheel updateView!");
			clearInterval( gMouseWheelInterval);
			gMouseWheelInterval = 0;
			
			updateView();
		}
		
		public function initKeyHandler():void {
			
			addEventListener( "focusIn", focusIn);
			addEventListener( "focusOut", focusOut);
				
			addEventListener( MouseEvent.MOUSE_WHEEL, handleMouseWheel);
	/*		
			addEventListener( "onPress", this);
			addEventListener( "onRelease", this);
			addEventListener( "onReleaseOutside", this);
			addEventListener( "onSetFocus", this);
			addEventListener( "onKillFocus", this);
			addEventListener( "onRollOver", this);
			addEventListener( "onRollOut", this);
	*/
		}
	/*
		function onPress() {
	//		error( "invb down");
			mousePan("start");
		}
		
		function onRelease() {
	//		error( "invb up");
			mousePan("stop");
		}
		function onReleaseOutside() {
	//		error( "relo");
			mousePan("stop");
			enableKeys( false);
		}
	
		function onSetFocus( of) {
	//		error( "get Focus");
			enableKeys( true);
			hasKBFocus = true;
		}
		function onKillFocus() {
	//		error( "lost Focus");
			enableKeys( false);
			hasKBFocus = false;
		}
	
		function onRollOver() {
	//		error( "roll in");
			enableKeys( true);
		}
		function onRollOut() {
	//		error( "roll out");
			enableKeys( false);
		}
	*/
		private function focusIn( evt:Event):void {
	//		error( "focus "+evt.type+": "+evt.target);
			hasKBFocus = true;
		}
		private function focusOut( evt:Event):void {
	//		error( "focus "+evt.type+": "+evt.target);
			hasKBFocus = false;
		}
	
		// keypresses
		private function handleKeyDown( evt:Event):void {
	//		trace( "down("+this+"): kb "+hasKBFocus+"  ke "+keysEnabled+"  en "+gEnabled);
			
			if ( hasKBFocus == false || keysEnabled == false || !gEnabled) {
				return;
			}
	
			// allow clipping by user interaction
			gClipAllow = true;
	
		}
		private function keyUp():void {
			if (keysEnabled == false) {
				return;
			}
		}
		/*mousePan: mouse events handled in this function are triggered in the invisible button 
			included in the component. On mouse down, an interval is begun that checks the mouse 
			position and sync's the background and old tier positions (see syncTierMotion below).
			Additionally, focus is set to true.  On mouse up, all movies are adjusted so that 
			their gPanPosition variables reflect their current position. gPanPosition is
			used by the drawing loop to determine where to draw tiles.*/
		public function mousePan( panEvent:String):void {
	//		if ( ! this instanceof ZfImage) return;
	//		error("mousePan ("+this+")" + panEvent + " " + gInitialized + "," + gEnabled + ".");
			if (gInitialized == true && gEnabled) {
				// allow clipping by user interaction
				gClipAllow = true;
	
				if (panEvent == "start") {
					gCurrentTier_mc.startDrag();
					
					addEventListener( 'mouseMove', syncTierMotion);
					enableKeys(true);
	//				invisiblePanMouse_btn.setFocus();
	//				setFocus();
				}
				if (panEvent == "stop") {
					
					gCurrentTier_mc.stopDrag();
					removeEventListener( 'mouseMove', syncTierMotion);
	//				delete onMouseMove;
	
					panStop();
					updateView();
				}
			}
		}
		/*syncTierMotion: mouse events are handled by the mousePan function (see above). They
			are triggered in the invisible button included in the component. On mouse down, an 
			interval is begun that checks the mouse position and sync's the background and old 
			tier positions. Additionally, focus is set to true.  On mouse up, all movies are 
			adjusted so that their gPanPosition variables reflect their current position. 
			gPanPosition is used by the drawing loop to determine where to draw tiles.*/
		private function syncTierMotion( evt:Event):void {
	//		error( "sync");
			clipPan( 0, 0);
			if ( gCurrentTierOld_mc != null) {
				gCurrentTierOld_mc.x = gCurrentTier_mc.x;
				gCurrentTierOld_mc.y = gCurrentTier_mc.y;
			}
			gCurrentTierBackground_mc.x = gCurrentTier_mc.x;
			gCurrentTierBackground_mc.y = gCurrentTier_mc.y;
			gLabelTier_mc.x = gCurrentTier_mc.x;
			gLabelTier_mc.y = gCurrentTier_mc.y;
		}
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::   INITIALIZATION/ DESTROY FUNCTIONS  ::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		/*Constructor: calls init, sets callbacks to empty, ititializes the key handler and
			sets up tier (containers) movie clips to match the component parameters.*/
			
		function ZfImageX() {
			super();
			debug("ZfImage constructor.");
			
			tileClass = de.ms_ite.zf.ZfTile;
			
			map_filters = null;
			registeredMouseWheelHandlers = 0;
			
			this.useHandCursor = true;
			
			enabled = true;
			tabChildren = false;
			
			hasKBFocus = false;
			
			bounds = new Bounds();
			bounds.mbrAddCoord( -0.5, -0.5);
			bounds.mbrAddCoord( 0.5, 0.5);
			
			clipBounds = new Bounds();
			clipBounds.mbrAddCoord( -0.5, -0.5);
			clipBounds.mbrAddCoord( 0.5, 0.5);
			
			gScaledWindow = new Bounds();
	
			gMouseWheelInterval = 0;
			symbolLevel = 1;
	
			//Turns on and off the Zs
			gViewWidth = gOriginalMovieWidth = 500;
			gViewHeight = gOriginalMovieHeight = 350;
			gSavedInitialX = _initialX;
			gSavedInitialY = _initialY;
			gSavedInitialZoom = _initialZoom;
	
			gMustResetViewer = false;
			gURLChanged = true;
			gImgInfoLoaded = false;
			gInitialized = false;
	/*
			// callbacks
			gFocusCallback = new Array();
			gRectCallback = new Array();
			gViewCallback = new Array();
			gInitializeCallback = new Array();
			gStatusCallback = new Array();
			gClipCallback = new Array();
	*/
			_maxZoom = 1;
			_minZoom = 0;
			
			gLabelArray = new Array();
			//Header data
			gImageWidth = 0;
			gImageHeight = 0;
			gTierCount = 0;
			gCurrentTierArray = 1;
	
			gStartTier = 1;
			gCurrentTier = 1;
			gBackgroundTier = 1;
			gOldTier = 1;
			gRegistrationPointY = 0;
			gPanPositionX = 0;
			gPanPositionY = 0;
			gZoom = -1;
			gTileSize = 256;
			//The tier 'container' movie clips
			gCurrentTier_mc = null;
			gCurrentTierOld_mc = null;
			gCurrentTierBackground_mc = null;
			gRegistrationPointX = 0;
			//ms
			if (loader != null) {
				loader.clear();
			}
			
			mapLayer = null;
			//end
	/*		
			if (_imagePath != "") {
				zfsetup();
			}
	*/
			initKeyHandler();
			
			zfsetup();

			addEventListener( 'updateComplete', updateComplete);			
		}
		
		protected function zfsetup():void {
			debug("##zfi init+");
	
	//		error( "focusMan: "+getFocusManager());
			
			gMustResetViewer = false;
			gInitialized = false;
	//		getFocus();
	
			addEventListener( MouseEvent.MOUSE_DOWN, mhandler);
			addEventListener( MouseEvent.MOUSE_UP, mhandler);
			addEventListener( MouseEvent.MOUSE_OUT, mhandler);
			addEventListener( MouseEvent.ROLL_OVER, mhandler);
			addEventListener( MouseEvent.ROLL_OUT, mhandler);
		
			if ( gMouseWheelInterval != 0) clearInterval( gMouseWheelInterval);
			gMouseWheelInterval = 0;

			if ( mapLayer == null) {
				mapLayer = new UIComponent();
				addChild( mapLayer);
			}			

			setupClips();
			setupTiers();
	
			gMustResetViewer = false;
	
			mapDimmer.x = 0;
			mapDimmer.y = 0;
			mapDimmer.width = 500;
			mapDimmer.height = 350;
/*	
			invisiblePanMouse_btn.x = 0;
			invisiblePanMouse_btn.y = 0;
			invisiblePanMouse_btn.width = 500;
			invisiblePanMouse_btn.height = 350;
			// adapt active area to resizes
			gOriginalPanMouseXScale = invisiblePanMouse_btn.scaleX;
			gOriginalPanMouseYScale = invisiblePanMouse_btn.scaleY;
*/	
/*
			// adapt mask to resizes
			mask_mc.width = gViewWidth;
			mask_mc.height = gViewHeight;
*/			
			//Arrays and Objects - 11
			gTileCountWidth = new Array();
			gTileCountHeight = new Array();
			gTierTileCount = new Array();
			gTierWidth = new Array();
			gTierHeight = new Array();
			gTilesUsedArray1 = new Array();
			gTilesUsedArray2 = new Array();
			gTilesUsedOldTierArray1 = new Array();
			gTilesUsedOldTierArray2 = new Array();
			
			//mouse
			//This is completely unexplainable.  The button has no width and height but it has
			//an x and y scale.  The scale does not match what you would expect it to be based on
			//how much the component has been scaled.  But, if you further modify this scale
			//by the amount the component has actually been scaled, you end up with a button filling the
			//view area.  Maybe someone at Macromedia can explain this to me some day.
			/*
			invisiblePanMouse_btn.scaleX = gOriginalPanMouseXScale * gViewWidth / gOriginalMovieWidth;
			invisiblePanMouse_btn.scaleY = gOriginalPanMouseYScale * gViewHeight / gOriginalMovieHeight;
			
			mapDimmer.scaleX = gOriginalPanMouseXScale * gViewWidth / gOriginalMovieWidth;
			mapDimmer.scaleY = gOriginalPanMouseYScale * gViewHeight / gOriginalMovieHeight;
			*/
			
			gInitCalled = true;
			if ( gURLChanged && _imagePath.length > 0) {
				gURLChanged = false;
				gImgInfoLoaded = false;
				getImagePropertiesFile();
			} else {
				
				// only rebuild the map
				// delay rebuild after updating/deleting
				if ( gImgInfoLoaded) {
	//				doLater( this, "buildAfterBlip");
					callLater( buildPyramid);
	
	//				if ( gBlipIntervall == 0) gBlipIntervall = setInterval( this, "buildAfterBlip", 10);
					debug( "delayed rebuild");
				} else debug( "no imginfo yet");
			}
			debug("##zfi init-");
	}
	
		protected function setupClips():void {
			debug("##zfi clips+");
			
	//			attachMovie("invisiblePanMouse_btn", "invisiblePanMouse_btn", 40000);
			if ( mapDimmer != null) mapLayer.removeChild( mapDimmer);
			
			mapDimmer = new MovieClip();
			mapLayer.addChild( mapDimmer);
/*				
			createEmptyMovieClip("mapDimmer", 7998);
			mapDimmer.beginFill( 0xffffff, 100);
			mapDimmer.moveTo( -250, -175);
			mapDimmer.lineTo( 250, -175);
			mapDimmer.lineTo( 250, 175);
			mapDimmer.lineTo( -250, 175);
			mapDimmer.lineTo( -250, -175);
			mapDimmer.endFill();
	//		mapDimmer.visible = false;
			mapDimmer.alpha = 0;
*/	
			//mask
	//		debug( "init: mask: "+mask_mc);
	//			attachMovie("mask_mc", "mask_mc", 10002);
	//		debug( "init: MASK");

			if ( mask_mc != null) {
//				mapLayer.mask = null;
//				mapLayer.removeChild( mask_mc);
			} else {
				mask_mc = new UIComponent();	//createEmptyMovieClip("mask_mc", 10002);
				mapLayer.addChild( mask_mc);				
				error( "mask: "+mask_mc);
			}
			
			
			var wh:int = width / 2;
			var hh:int = height / 2;
			with( mask_mc.graphics) {			
				clear();
				beginFill( 0x0000ff, 0.4);
				moveTo( -wh, -hh);
				lineTo( wh, -hh);
				lineTo( wh, hh);
				lineTo( -wh, hh);
				lineTo( -wh, -hh);
				endFill();
			}
	
			mapLayer.mask = mask_mc;
//			mask_mc.visible = false;
	
			//Labels
			if ( gLabelTier_mc != null) {
//				if ( gLabelTier_mc_labels != null) gLabelTier_mc.removeChild( gLabelTier_mc_labels);
//				mapLayer.removeChild( gLabelTier_mc);
			} else { 
				gLabelTier_mc = new UIComponent();	//attachMovie("tier_mc", "gLabelTier_mc", 9000);
				mapLayer.addChild( gLabelTier_mc);
				error( "## premakeLabelTier: "+gLabelTier_mc+".");
			}
			gLabelTier_mc.x = 0;
			gLabelTier_mc.y = 0;
			gLabelTier_mc.scaleX = 1;
			gLabelTier_mc.scaleY = 1;
	//		gLabelTier_mc.width = gViewWidth;
	//		gLabelTier_mc.height = gViewHeight;
			gLabelTier_mc.rotation = 0;
			gLabelTier_mc.visible = true;
			
			if ( gLabelTier_mc_labels == null) {
				gLabelTier_mc_labels = new UIComponent();
				gLabelTier_mc.addChild( gLabelTier_mc_labels);
				error( "## premakeLabelTier.labels: "+gLabelTier_mc_labels+".");
			}
			gLabelTier_mc_labels.visible = true;
			gLabelVisibility = true;
			gSavedLabelVisibility = true;
/*
			with(gLabelTier_mc_labels.graphics) {
				for( var r:int = 0; r < 2500; r += 250) {			
					lineStyle(1, 0x0000ff, 40);
					moveTo( -r, -r);
					lineTo( r, -r);
					lineTo( r, r);
					lineTo( -r, r);
					lineTo( -r, -r);
					endFill();
				}
			}
*/	
	//		debug("##zfi tiers-");
	
			//ms
			if (loader != null) loader.clear();
			//end
			debug("##zfi clips-");
		}
		
		protected function mhandler( evt:Event):void {
			debug( "evt: "+evt.toString());
			switch( evt.type) {
				case MouseEvent.MOUSE_DOWN:
					mousePan( 'start');
				break;
				case MouseEvent.MOUSE_UP:
				case MouseEvent.MOUSE_OUT:
					mousePan( 'stop');
				break;
				case MouseEvent.ROLL_OUT:
					// dis keys
				break;
				case MouseEvent.ROLL_OVER:
					// en keys
				break;
			}	
		}
		
		protected function setupTiers():void {
			debug("##zfi tiers+");
			
			//Create the empty tiers
			var tempTier_mc:MovieClip;
	
			tierList = new Array();
			tileCache = new Array();
			
			var labelIndex:int = mapLayer.getChildIndex( gLabelTier_mc);
			
			for (var i:Number = 0; i < numPremadeLevels; i++) {
				var movieClipString:String = "tier" + i + "_mc";
	//			tempTier_mc = eval("this." + movieClipString);
				//ms
				// always create new tiers, otherwise we get stuck with timings
	//			if (tempTier_mc == undefined) 
				//end
				if ( tierList[ i] != null) mapLayer.removeChild( tierList[i]);
				var temp:UIComponent = new UIComponent();	//attachMovie("tier_mc", "tier" + i + "_mc", i);
				mapLayer.addChildAt( temp, labelIndex++);
	
				debug( "premakeTier: "+temp+".");
				temp.x = 0;
				temp.y = 0;
				temp.width = gViewWidth;
				temp.height = gViewHeight;
				temp.scaleX = 1;
				temp.scaleY = 1;
				temp.rotation = 0;
				temp.visible = false;
//				temp.quality = "BEST";
	//			temp.alpha = 40;
	
				tierList[i] = temp;
				tileCache[ i] = new Array();
			}
			debug("##zfi tiers-");
	}
	
		//=====================================================================================
	
		private function viewerInitialized():void {
			debug("INITIALIZED");
			//ms
			//Call the "Init" callback if there is one
			
			gClipAllow = false;
			
			dispatchEvent( new ZfEvent( ZfEvent.INIT));		//{ type:'zfinit', target:this});
			dispatchEvent( new ZfEvent( ZfEvent.STATUS));	//{ type:'zfstatus', target:this, detail:"Image initialized."});
			
			callLater( restoreLabelVis);
			
	//		castInitEvent();
	//		castStatusEvent("Image initialized.");
			//end
		}
		
		public function restoreLabelVis():void {
			setLabelVisible( gSavedLabelVisibility);
		}
		
		/*
		 * cleanup
		 *
		 * cleanup all tiles
		 *
		 */
	
		private function cleanup():void {
			debug("CLEAN+");
			var tempTile:ZfTile;
			var ctier:int, rowCounter:Number, columnCounter:Number, i:Number;
	//		var current:Number = (new Date).getTime();
	
			if (gInitialized == false) {
				return;
			}
			
			gInitialized = false;
			var doBreak:Boolean = false;
			
			//Dispose any background tier tiles
			for (ctier = 0; ctier < numPremadeLevels; ctier++) {
				for (rowCounter = 0; rowCounter < tileCache[ctier].length; rowCounter++) {
					for (columnCounter = 0; columnCounter < tileCache[ctier][rowCounter]; columnCounter++) {
		/*				var consumed:Number = (new Date).getTime() - current;
						if ( consumed > CPU_LIMIT) {
							error( "break after: "+consumed+" ");
							doBreak = true;
							break;
						}
						var tileName:String = gBackgroundTier + "-" + rowCounter + "-" + columnCounter;
						var mcTileString:String = "this.tier" + gBackgroundTier + "_mc" + "." + tileName;
*/						
						tempTile = ZfTile( tileCache[ctier][rowCounter][columnCounter]);
						if (tempTile != null) {
							tempTile.x = gOffscreenX;
							tempTile.cancel();
							tierList[ ctier].removeChild( tempTile);
							tileCache[ctier][rowCounter][columnCounter] = null;
						}
					}
					tileCache[ ctier][rowCounter] = null;
	//				if ( doBreak) break;
				}
				tileCache[ ctier] = null;
				mapLayer.removeChild( tierList[ ctier]);
			}

			//Dispose of all of our arrays and objects
			tierList = new Array();
			tileCache = new Array();
			debug("CLEAN-");
		}
	
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::: VIEW DRAWING FUNCTIONS ::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		/*Developer access only.  Complex drawing code.  Modify at your own risk.*/
		/*Overview of drawing approach: At any time and for any view, three 'tiers' of image data
			are present in the Zoomify Flash Component display. 
			
			The 'current tier' is visible, pannable, and zoomable. The other tiers are sync'd with its 
			motion.  The 'old tier' is the most recent current tier. It is used as a visual placeholder 
			while the current tier is refreshed. This occurs primarily when one zooms in. The 'background 
			tier' is a low resolution display held behind the current tier. It is a visual placeholder 
			like the old tier, but is used primarily when zooming out. It is downloaded once and saved 
			for use throughout a viewing session.  Note that the current tier and background tiers may 
			be one and the same if the view is zoomed out sufficiently.
			
			The drawing process begins with a call to setTier, which determines the appropriate resolution  
			tier to display. This is followed by a call to fillView, which determines the tiles required,
			identifies and/or requests the offsets for those tiles, and finally requests and draws the tiles.
			Note that each each time fillView is called, all tiles are set invisible.  As each tile is
			drawn its visibility flag is set true.  After all tiles are drawn, those still set invisible are 
			unloaded.*/
		/*initView: prepares variables and objects for initial view*/
		private function initView():void {
	//		debug( "##initView: "+gCurrentTier+" / "+gBackgroundTier);
	
			gCurrentTier = gStartTier;
			gCurrentTier_mc = tierList[ gCurrentTier];
			
			gOldTier = gStartTier - 1;
			if (gOldTier == gBackgroundTier) {
				gOldTier = 1;
			}
			gCurrentTierOld_mc = tierList[ gOldTier];
			gCurrentTierBackground_mc = tierList[ gBackgroundTier];
	//		debug( "##initView bgtier: "+gCurrentTierBackground_mc+" = "+"this.tier" + gBackgroundTier + "_mc");
			gRegistrationPointX = 0;
			gRegistrationPointY = 0;
/*			
			gCurrentTier_mc.rotation = 0;
			gCurrentTierOld_mc.rotation = 0;
			gCurrentTierBackground_mc.rotation = 0;
*/			
			//Sync new current tier scale and rotation with old tier;
			gCurrentTierBackground_mc.scaleX = gCurrentTier_mc.scaleX / (getTierWidth(gBackgroundTier) / getTierWidth(gCurrentTier));
	//		trace( "##initView: "+gCurrentTierBackground_mc.scaleX);
			
			gCurrentTierBackground_mc.scaleY = gCurrentTier_mc.scaleY / (getTierHeight(gBackgroundTier) / getTierHeight(gCurrentTier));
			gLabelTier_mc.rotation = 0;
			gLabelTier_mc.scaleX = gCurrentTierBackground_mc.scaleX;
			gLabelTier_mc.scaleY = gLabelTier_mc.scaleX;
	//		debug("iniV: " + _initialX + "," + _initialY + "@" + _initialZoom);
			setView(_initialX, _initialY, _initialZoom);
		}
		
		/*setTier: determines whether current tier of resolution must change based on amount 
			of zoom and setTierThreshold variable.  Includes functionality to change tier if 
			determined to be appropriate. Precedes test with verification that choice of image 
			to be displayed has not changed (if so, tier test is unnecessary).*/

		private function setTier():void {
	//		var current:Number = (new Date).getTime();
			var i:Number;
			
	//		debug("+setTier(" + gTierCount+") for "+getZoom()+" - "+currentTier);
			//	if ((gCurrentTier>gBackgroundTier && (gCurrentTier_mc.scaleX>100) || (gCurrentTier_mc.scaleX<50)) || (gCurrentTier<=gBackgroundTier)) 
			var currentTier:Number = gTierCount;
			var currZoom:Number = 1.0;
			var tempZoom:Number = getZoom();

			while (currZoom > tempZoom && currentTier > 1) {
				currentTier--;
				currZoom /= 2;
			}
			if (currentTier < gTierCount) {
				currentTier++;
			}
			debug("+setTier(" + gTierCount+") for "+getZoom()+" - "+currentTier);
	
			var tierWidth:Number = getTierWidth(gTierCount);
			var tierHeight:Number = getTierHeight(gTierCount);
			tierWidth = getTierWidth(currentTier);
			tierHeight = getTierHeight(currentTier);
			//Compare current tier with appropriate tier and switch if different 
			
			if (currentTier != gCurrentTier) {
				//Store old current tier, create new current tier, center it;
				if (gCurrentTier > gBackgroundTier) {
					gCurrentTierOld_mc = gCurrentTier_mc;
				}
	//			debug("setTier " + "this.tier" + currentTier + "_mc");
				gCurrentTier_mc = tierList[ currentTier];
				gCurrentTier_mc.x = gRegistrationPointX;
				gCurrentTier_mc.y = gRegistrationPointY;

				//Sync new current tier scale and rotation with background tier;
				gCurrentTier_mc.scaleX = gCurrentTierBackground_mc.scaleX / (getTierWidth(currentTier) / getTierWidth(gBackgroundTier));
				gCurrentTier_mc.scaleY = gCurrentTierBackground_mc.scaleY / (getTierHeight(currentTier) / getTierHeight(gBackgroundTier));

				if (gOldTier > gBackgroundTier) {
					//				debug( " sT: save current to old");
					//Remove old tier, copy the current tier in and reconstuct arrays
					var t:ZfTile;
					for (i = 0; i < gTilesUsedOldTierArray1.length; i++) {
						t = ZfTile( gTilesUsedOldTierArray1[i]);	//eval(gTilesUsedOldTierArray1[i]);
	//					debug( "del: "+tempTile+"/"+gTilesUsedOldTierArray1[i]+"#");
						if (t != null) {
							t.cancel();
							tileCache[ t.tier][ t.row][ t.col] = null;
						}
					}
					for (i = 0; i < gTilesUsedOldTierArray2.length; i++) {
						t = ZfTile( gTilesUsedOldTierArray2[i]);	//eval(gTilesUsedOldTierArray2[i]);
	//					debug( "del: "+tempTile+"/"+gTilesUsedOldTierArray2[i]+"#");
						if (t != null) {
							t.cancel();
							tileCache[ t.tier][ t.row][ t.col] = null;
						}
					}
				}
	//			delete gTilesUsedOldTierArray1;
	//			delete gTilesUsedOldTierArray2;
				gOldTier = gCurrentTier;
				gCurrentTier = currentTier;
				if (gOldTier < gCurrentTier) {
					gTilesUsedOldTierArray1 = gTilesUsedArray1.concat();
					gTilesUsedOldTierArray2 = gTilesUsedArray2.concat();
				} else {
					gTilesUsedOldTierArray1 = new Array();
					gTilesUsedOldTierArray2 = new Array();
					if (gOldTier > gBackgroundTier) {
						//					debug( " sT: clean 1");
						for (i = 0; i < gTilesUsedArray1.length; i++) {
							t = ZfTile( gTilesUsedArray1[i]);		//eval(gTilesUsedArray1[i]);
	//						debug( "del: "+tempTile+"/"+gTilesUsedArray1[i]+"#");
							if (t != null) {
								t.cancel();
								tileCache[ t.tier][ t.row][ t.col] = null;
							}
						}
						for (i = 0; i < gTilesUsedArray2.length; i++) {
							t = ZfTile( gTilesUsedArray2[i]);		//eval(gTilesUsedArray2[i]);
	//						debug( "del: "+tempTile+"/"+gTilesUsedArray2[i]+"#");
							if (t != null) {
								t.cancel();
								tileCache[ t.tier][ t.row][ t.col] = null;
							}
						}
					}
					gOldTier = gCurrentTier - 1;
					if (gOldTier <= 0) {
						gOldTier = 1;
					}
					gCurrentTierOld_mc = tierList[ gOldTier];
					gCurrentTierOld_mc.x = gRegistrationPointX;
					gCurrentTierOld_mc.y = gRegistrationPointY;

					//Sync new current tier scale and rotation with old tier;
					gCurrentTierOld_mc.scaleX = gCurrentTierBackground_mc.scaleX / (getTierWidth(gOldTier) / getTierWidth(gBackgroundTier));
					gCurrentTierOld_mc.scaleY = gCurrentTierBackground_mc.scaleY / (getTierHeight(gOldTier) / getTierHeight(gBackgroundTier));
				}
				gTilesUsedArray1 = new Array();
				gTilesUsedArray2 = new Array();
				gCurrentTier_mc.visible = true;
				if ( gCurrentTierOld_mc != null) gCurrentTierOld_mc.visible = true;
			}
/*			
			for( i=0; i < currentTier; i++) {
				tierList[ i].alpha = 0.1;
			}
			tierList[ currentTier].alpha = 0.8;
			for( i=currentTier+1; i < tierList.length; i++) {
				tierList[ i].alpha = 0.1;
			}
*/
			debug("-setTier(" + gTierCount+") for "+getZoom()+" - "+currentTier);
		}
		
		//====================================================================================
		/*fillView: checks the current, background, and old tiers to determine if drawing is
			required.  If so, calls fillViewWithParams is called as necessary to draw each tier.
			Additionally, any tiles not to be drawn (out of view) are unloaded.*/
			
		private function fillView( postEvents:Boolean=true):void {
	//		var current:Number = (new Date).getTime();
			var i:Number;
			
			debug("##FILL VIEW "+getZoom());
						
			if ( loader != null) loader.clear();
			//Always draw the background tier
			fillViewWithParams(gBackgroundTier, gCurrentTierBackground_mc, null);
			
			var tempTile:ZfTile;
			if ( gCurrentTierArray == 1) {
	//			debug( " fV: current tier == 1");
				for (i = 0; i < gTilesUsedArray2.length; i++) {
					ZfTile( gTilesUsedArray2[i]).visible = false;
				}
				if (gCurrentTier > gBackgroundTier) {
					fillViewWithParams(gCurrentTier, gCurrentTier_mc, gTilesUsedArray1);
				}
				for (i = 0; i < gTilesUsedArray2.length; i++) {
					tempTile = ZfTile( gTilesUsedArray2[i]);		//eval(gTilesUsedArray2[i]);
					if (tempTile != null && tempTile.visible == false && gCurrentTier != gBackgroundTier) {
						tempTile.cancel();
					}
				}

				if (gOldTier < gCurrentTier && gOldTier > 0) {
					for (i = 0; i < gTilesUsedOldTierArray2.length; i++) {
						ZfTile( gTilesUsedOldTierArray2[i]).visible = false;
					}
					if (gOldTier > gBackgroundTier) {
						fillViewWithParams(gOldTier, gCurrentTierOld_mc, gTilesUsedOldTierArray1);
					}
					for (i = 0; i < gTilesUsedOldTierArray2.length; i++) {
						tempTile = ZfTile( gTilesUsedOldTierArray2[i]);	//eval(gTilesUsedOldTierArray2[i]);
						if (tempTile != null && tempTile.visible == false && gOldTier != gBackgroundTier) {
	//						debug( " fV: tuoa2= "+tempTile.name);
							tempTile.cancel();
						}
					}
				}
				gTilesUsedOldTierArray2 = new Array();
				gTilesUsedArray2 = new Array();
				gCurrentTierArray = 2;
			} else {
	//			debug(" fV: current tier != 1");
				for (i = 0; i < gTilesUsedArray1.length; i++) {
					ZfTile( gTilesUsedArray1[i]).visible = false;
				}
				if (gCurrentTier > gBackgroundTier) {
					fillViewWithParams(gCurrentTier, gCurrentTier_mc, gTilesUsedArray2);
				}
				for (i = 0; i < gTilesUsedArray1.length; i++) {
					tempTile = ZfTile( gTilesUsedArray1[i]);		//eval(gTilesUsedArray1[i]);
					if (tempTile != null && tempTile.visible == false && gCurrentTier != gBackgroundTier) {
						tempTile..cancel();
					}
				}
				if (gOldTier < gCurrentTier && gOldTier > 0) {
					for (i = 0; i < gTilesUsedOldTierArray1.length; i++) {
						ZfTile( gTilesUsedOldTierArray1[i]).visible = false;
					}
					if (gOldTier > gBackgroundTier) {
						fillViewWithParams(gOldTier, gCurrentTierOld_mc, gTilesUsedOldTierArray2);
					}
					for (i = 0; i < gTilesUsedOldTierArray1.length; i++) {
						tempTile = ZfTile( gTilesUsedOldTierArray1[i]);		//eval(gTilesUsedOldTierArray1[i]);
						if (tempTile != null && tempTile.visible == false && gOldTier != gBackgroundTier) {
							tempTile.cancel();
						}
					}
				}
				gTilesUsedOldTierArray1 = new Array();
				gTilesUsedArray1 = new Array();
				gCurrentTierArray = 1;
			}
			
			if ( postEvents) dispatchEvent( new ZfEvent( ZfEvent.VIEW));	//{ type:'zfview', target:this, detail:o});		
			
			debug( "##fill view--");
		}
	
		/*fillViewWithParams: Determines which tiles are within the current view. Draws the tiles*/
		private function fillViewWithParams(tier:Number, mClip:UIComponent, newTierArray:Array):void {	//newTierArrayName:String):void  {
		
			if ( mClip == null) {
				error( "INCREASE PREMADELEVELS!");
				return;
			}
			
	//		debug( "fillViewWithParams+: "+tier+" , "+mClip+" , "+newTierArray+".");
	
			//Downloads tiles and positions within current tier movieclip;
			var i:int;
			var tempTile:ZfTile;
			var tileName:String = "";
			var tileLevel:int = 0;
			var rowCounter:int = 0;
			var columnCounter:int = 0;
			
			var tierWidth:int = getTierWidth(tier);
			var tierHeight:int = getTierHeight(tier);
			
			// reverse left/right
			var screenRectLeft:Number = -gViewWidth / 2;
			var screenRectRight:Number = gViewWidth / 2;
			var screenRectTop:Number = -gViewHeight / 2;
			var screenRectBottom:Number = gViewHeight / 2;
			
			var scale:Number = mClip.scaleX;
	//		debug( "scale: "+mClip+" # "+mClip.scaleX);
			var scaledTileSize:Number = scale * gTileSize;
			//ms get the horizontal tiles count for depth calulation
			var horTiles:int = getTileCountWidth(tier);
			//ms end
			//Calculate the rect of the image
			// reverse left/right
			var imageRectLeft:Number = gPanPositionX * tierWidth - tierWidth / 2;
			var imageRectRight:Number = gPanPositionX * tierWidth + tierWidth / 2;
			var imageRectTop:Number = gPanPositionY * tierHeight - tierHeight / 2;
			var imageRectBottom:Number = gPanPositionY * tierHeight + tierHeight / 2;
	
	//		debug( "base data: "+gPanPositionX+", "+gPanPositionY+"     "+tierWidth+"/"+scale);
			
			//Calculate the center
			var scaledCenterX:Number = tierWidth * scale / 2 - gPanPositionX * tierWidth * scale;
			var scaledCenterY:Number = tierHeight * scale / 2 - gPanPositionY * tierHeight * scale;
	
	//		debug( "scaled center: "+scaledCenterX+" , "+scaledCenterY);
	
			//Calculate the scaled image rect
			var scaledTop:Number = scaledCenterY + screenRectTop;
			var scaledLeft:Number = scaledCenterX + screenRectLeft;
			var scaledBottom:Number = scaledCenterY + screenRectBottom;
			var scaledRight:Number = scaledCenterX + screenRectRight;
	
	//		debug( "scaled dims: "+scaledLeft+" , "+scaledRight+"  #  "+scaledTop+" , "+scaledBottom);
	
			//These we need for the "Rect callback
			gScaledWindow.top = scaledTop / (scale * tierHeight);
			gScaledWindow.bottom = scaledBottom / (scale * tierHeight);
			gScaledWindow.left = scaledLeft / (scale * tierWidth);
			gScaledWindow.right = scaledRight / (scale * tierWidth);
			
			//Determine which tiles we need
			var leftViewColumn:Number = Math.floor(scaledLeft / scaledTileSize) + 1;
			var topViewRow:Number = Math.floor(scaledTop / scaledTileSize) + 1;
			var rightViewColumn:Number = Math.floor(scaledRight / scaledTileSize) + 1;
			var bottomViewRow:Number = Math.floor(scaledBottom / scaledTileSize) + 1;
			
	//		debug( "view rows: "+leftViewColumn+" , "+rightViewColumn+"  #  "+topViewRow+" , "+bottomViewRow);
			
			if (leftViewColumn < 1 || tier == gBackgroundTier) {
				leftViewColumn = 1;
			}
			if (topViewRow < 1 || tier == gBackgroundTier) {
				topViewRow = 1;
			}
			if (rightViewColumn > getTileCountWidth(tier) || tier == gBackgroundTier) {
				rightViewColumn = getTileCountWidth(tier);
			}
			if (bottomViewRow > getTileCountHeight(tier) || tier == gBackgroundTier) {
				bottomViewRow = getTileCountHeight(tier);
			}
			var viewColumns:int = rightViewColumn - leftViewColumn + 1;
			var viewRows:int = bottomViewRow - topViewRow + 1;
			//		debug("fillViewWithParams(" + tier + "," + mClip + "," + newTierArrayName + ")");
	
			if ( isNaN( topViewRow) || isNaN( bottomViewRow) || isNaN(leftViewColumn) || isNaN(rightViewColumn)) return;
			
			debug( "view rows: "+leftViewColumn+" , "+rightViewColumn+"  #  "+topViewRow+" , "+bottomViewRow);
					
	//		var current:Number = (new Date).getTime();
			i = 0;
			var doBreak:Boolean = false;
	
			//Loop through the tiles and draw them
			for (rowCounter = topViewRow; rowCounter <= bottomViewRow; rowCounter++) {
				for (columnCounter = leftViewColumn; columnCounter <= rightViewColumn; columnCounter++) {
					
	/*				var consumed:Number = (new Date).getTime() - current;
					if ( i > 0 && consumed > CPU_LIMIT) {
						error( "break after: "+i+"/"+consumed+" ");
						error( "break view rows: "+leftViewColumn+" , "+rightViewColumn+"  #  "+topViewRow+" , "+bottomViewRow);
						doBreak = true;
						break;
					}
					i++;
	*/
					var xPosition:int = (columnCounter - 1) * gTileSize + imageRectLeft;
					var yPosition:int = (rowCounter - 1) * gTileSize + imageRectTop;
					tileName = tier + "-" + rowCounter + "-" + columnCounter;
	//				debug( "fillViewWithParams: "+tileName);
					//ms base depth-calculation on tier-width, not viewport-width, create really unique depth-levels
					//			tileLevel = ((columnCounter)+((rowCounter-1)*viewColumns))%65000;
					tileLevel = ((columnCounter) + ((rowCounter) * horTiles)) % 65000;
					//ms end
					//Create and load movieclip - if not already present;
//					var mcTileString = "this.tier" + tier + "_mc" + "." + tileName;

					if ( tileCache[ tier] == null) tileCache[ tier] = new Array();
					if ( tileCache[ tier][rowCounter] == null) tileCache[ tier][rowCounter] = new Array();
					var mcTile:ZfTile = ZfTile( tileCache[tier][rowCounter][columnCounter]);

					var tileSource:String = getFolderTileURL( tier-1, columnCounter-1, rowCounter-1);
					//tileSource will be "missing" if we don't have the offset yet
					var check:Boolean = ( mcTile == null);
					var created:Boolean = false;
					if (mcTile == null) {
						mcTile = new tileClass( tier, rowCounter, columnCounter);
						mcTile.loader = loader;
						mClip.addChild( mcTile);
						
						tileCache[tier][rowCounter][columnCounter] = mcTile;
						created = check;
//						debug("CR** " +mClip.name+" / "+mcTile.name + "  ld_" + mcTile.isLoaded());
					}
					mcTile.loadMovie(tileSource);
					
					// assign filter array to newly created tiles
					mcTile.filters = map_filters;
					
					//Place tile movieclip and set visible;
					mcTile.x = xPosition;
					mcTile.y = yPosition;

					if (tier != gBackgroundTier) {
						if ( newTierArray != null) newTierArray.push( mcTile);
					}
				}
				if ( doBreak) break;
			}
			mClip.visible = true;
	//		if (tier == gBackgroundTier) {
			if (tier == gCurrentTier) {
	//			gLabelTier_mc_labels.x = imageRectLeft;
	//			gLabelTier_mc_labels.y = imageRectTop;
				
				var baseWidth:int = getTierWidth( gTierCount);
			
				gLabelTier_mc_labels.x = gPanPositionX * tierWidth * scale / getZoom();
				gLabelTier_mc_labels.y = gPanPositionY * tierHeight * scale / getZoom();
				
	//			trace( "labels("+gLabelTier_mc_labels.scaleX+"): "+gLabelTier_mc_labels.x+","+gLabelTier_mc_labels.y);
			}
			debug( "fillViewWithParams-: "+tier+" , "+mClip+".");
		}
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::: IMAGE FILE HEADER REQUEST FUNCTIONS :::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		/* Folder stuff */
		private function getImagePropertiesFile():void {
			var pathLen:int = _imagePath.length;
	/*		
			if (_imagePath.charAt(pathLen - 1) != '/') {
				_imagePath = _imagePath + "/";
			}
	*/
			// use the helper class to get called in out context
			var myXML:eXML = new eXML( this, parseImagePropertiesData);
			var propertiesURL:String = _imagePath + "/ImageProperties.xml";
			debug("props: " + propertiesURL);
			
			gInitialized = false;
			debug( "loading IMAGE_PROPERTIES: "+propertiesURL);
			myXML.load( propertiesURL);
		}
	
		public function setImageProperties( node:XMLNode, status:Boolean):void {
			_imagePath = node.firstChild.attributes.path;
			var pathLen:int = _imagePath.length;
			
			debug( "set ("+status+") imProps: "+_imagePath);
	/*		
			if (_imagePath.charAt(pathLen - 1) != '/') {
				_imagePath = _imagePath + "/";
			}
	*/
			gInitialized = false;
			gURLChanged = false;
			gImgInfoLoaded = true;
			
	//		debug( "setting IMAGE_PROPERTIES.");
			var txml:XMLDocument = new XMLDocument();
			txml.appendChild(node);
	//		debug( "created: XML: "+txml);
			
			parseImagePropertiesData( status, txml);
		}
	
		private function xmlToLowerCase( node:XML):void {
			if (node == null) {
				return;
			}
	//		node.nodeName = node.nodeName.toLowerCase();
	//		debug("node: " + node.nodeName + ".");
	/*
			for (var i = 0; i < node.attributes.length; i++) {
	//			debug("  att: " + node.attributes[i] + " = " + node.attributes[node.attributes[i]] + ".");
			}
	*/
	/*
			for (var i = 0; i < node.childNodes.length; i++) {
	//			trace( "zfi 16");
				xmlToLowerCase(node.childNodes[i]);
			}
	*/
		}
		protected function parseImagePropertiesData( status:Boolean, node:XMLNode):void {
			if ( ! status ) {
				error("parse xml ("+status+") in " + node + ".");
				return;
			}
			
	//		xmlToLowerCase(node);
			var rootNodes:Array = node.childNodes;
			var i:Number;
			var imageWidth:Number = 0;
			var imageHeight:Number = 0;
			var version:Number;
			var numTiles:Number;
			var tileSize:Number;
	//		var current:Number = (new Date).getTime();
	
			for (i = 0; i < rootNodes.length; i++) {
	/*			var consumed:Number = (new Date).getTime() - current;
				if ( consumed > CPU_LIMIT) {
					error( "break after: "+consumed+" ");
					break;
				}
	*/
				debug("rnode: (" + rootNodes[i].nodeName + ")");
				if (rootNodes[i].nodeName.toUpperCase() == "IMAGE_PROPERTIES") {
					imageWidth = parseInt((rootNodes[i].attributes.width == undefined)? rootNodes[i].attributes.WIDTH : rootNodes[i].attributes.width);
					imageHeight = parseInt((rootNodes[i].attributes.height == undefined) ? rootNodes[i].attributes.HEIGHT : rootNodes[i].attributes.height);
					tileSize = parseInt((rootNodes[i].attributes.tilesize == undefined) ? rootNodes[i].attributes.TILESIZE : rootNodes[i].attributes.tilesize);
					gVersion = parseFloat((rootNodes[i].attributes.version == undefined) ? rootNodes[i].attributes.VERSION : rootNodes[i].attributes.version);
				}
			}
			debug("map loaded: " + imageWidth + "," + imageHeight + "pix ts" + gTileSize + " v" + gVersion + ".");
			if ( isNaN( imageWidth) || isNaN( imageHeight) || isNaN( tileSize)) {
				error("cannot load props file.");
				return;
			}
			gImageHeight = imageHeight;
			gImageWidth = imageWidth;
			gTileSize = tileSize;
			
			gResolution = bounds.width / gImageWidth;
	
			//Set up our heirarchy
	//		debug("img-prop: " + imageWidth + "," + imageHeight);
			gImgInfoLoaded = true;
			gClip = gClipSaved;
			
			buildPyramid();
		}
		
		private function buildPyramid():void {
			debug( "##build pyramid "+gLabelTier_mc+"/"+gLabelTier_mc_labels+" #");
			var tempWidth:Number = gImageWidth;
			var tempHeight:Number = gImageHeight;
	//		var current:Number = (new Date).getTime();
	
			gTierCount = 1;
			while (tempWidth > gTileSize || tempHeight > gTileSize) {
	/*			var consumed:Number = (new Date).getTime() - current;
				if ( consumed > CPU_LIMIT) {
					error( "break after: "+consumed+" ");
					break;
				}
	*/
				tempWidth = int(tempWidth / 2);
				tempHeight = int(tempHeight / 2);
				gTierCount++;
			}
	//		debug( "count tiers: "+gTierCount+"."+gTileSize);
			if (gTierCount < 4) {
				gStartTier = 2;
				gCurrentTier = 2;
				gBackgroundTier = 2;
			}
			tempWidth = gImageWidth;
			tempHeight = gImageHeight;
	
			for ( var j:Number = gTierCount - 1; j >= 0; j--) {
	/*			var consumed:Number = (new Date).getTime() - current;
				if ( consumed > CPU_LIMIT) {
					error( "break after: "+consumed+" ");
					break;
				}
	*/
				gTileCountWidth[j] = int((tempWidth) / gTileSize);
				if (tempWidth % gTileSize) {
					gTileCountWidth[j]++;
				}
				gTileCountHeight[j] = int((tempHeight) / gTileSize);
				if (tempHeight % gTileSize) {
					gTileCountHeight[j]++;
				}
				gTierTileCount[j] = gTileCountWidth[j] * gTileCountHeight[j];
				gTierWidth[j] = tempWidth;
				gTierHeight[j] = tempHeight;
				tempWidth = int(tempWidth / 2);
				tempHeight = int(tempHeight / 2);
	//			debug( "tiles in tier( "+j+") : "+gTierTileCount[j]+".");
			}
			gInitialized = true;
			
			//ms signal "initialized" before updating the screen
			// we can preset the view in init-handler
			///Call the "Init" callback if there is one
			viewerInitialized();
			//ms end
			initView();
			//Ready, update the view
			callLater( postUpdate);
			fillView( false);
			debug( "build pyramid--");
		}
		
		private function postUpdate():void {
			updateView();
		}
		
		private function getFolderTileURL( tier:int, x:int, y:int):String {
			
			var theOffset:Number = y * gTileCountWidth[tier] + x;
	
			for ( var theTier:int = 0; theTier < tier && theTier <= numPremadeLevels; theTier++) {
				theOffset += gTierTileCount[theTier];
			}
			var theCurrentOffsetChunk:int = int( theOffset / 256);
	
			var tilePath:String = _imagePath + "/TileGroup" + theCurrentOffsetChunk + "/" + tier + "-" + x + "-" + y + ".via";
			//ms add this to disbale caching		?id="+(cachekill++);
			//end
			return tilePath;
		}
	}
}
//=================================================================================================
// end of class
//=================================================================================================