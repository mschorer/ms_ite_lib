//
//
//  controls for a zoomify map
//  (c) markus schorer, ms@reicheteile.org
//	v 0.1
//
// 0.1: start						(20060427)
//
//

import de.msite.*;
import mx.core.*;
import mx.controls.Slider;
import mx.controls.Label;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.styles.CSSStyleDeclaration;
import flash.filters.*;
import com.quasimondo.geom.ColorMatrix;



class ZfControls extends UIComponent {
	static var symbolName:String = "ZfControls";
	static var symbolOwner:Object = de.msite.ZfControls;
	static var version:String = "0.1";
	
	var className:String = "ZfControls";
	
	private var zoomify:ZfGis;
	private var zfAni:ZfAnimated;
	
	private var panLeft:ButtonIconStates;
	private var panRight:ButtonIconStates;
	private var panUp:ButtonIconStates;
	private var panDown:ButtonIconStates;

	private var zoomIn:ButtonIconStates;
	private var zoomOut:ButtonIconStates;

	private var zoomAll:ButtonIconStates;
	private var zoomWindow:ButtonIconStates;
	
	private var toggleScale:ButtonIconStates;
	private var hideMarker:ButtonIconStates;

	private var lZoom:Label;
	public var zoom:Slider;
	private var zoomThumb:Button;
	
	private var lContrast:Label;
	private var contrast:Slider;
	
	private var lSaturation:Label;
	private var saturation:Slider;
	
	private var cbEnableTweening:CheckBox;
	
	private var depth:Number = 1;
	private var BoundingBox_mc:MovieClip;
	private var mapLayer_mc:MovieClip;

	private var background:MovieClip;
	
	private var delayedUpdTimer:Number;
	
	private var colorMatrix:ColorMatrix;
	private var myFilters:Array;
	
	private var PAN_INCREMENT:Number;
	
	private var zoomFrame:ZfZoomFrame;
	
	private var mouseDown:Boolean;
	
	private var owner;
	
	// object constructor
	// init all variables
	function ZfControls() {
		BoundingBox_mc._visible = false;

		zoomify = null;
		
	//	toolbardummy_mc.winZoom.button.enabled = false;
	
		debug("create");
	}
	
	function init() {
		debug( "init");
		super.init();
	}
	
	function createChildren() {		
		super.createChildren();

		var vstr:String = System.capabilities.version;
		var vm:Array = vstr.split( " ");
		var aver:Array = vm[1].split( ",");

		debug( "VCHECKX: "+aver.join( " - "));
		var canSlider:Boolean = aver[0] >= 7 && ( aver[1] > 0 || aver[2] > 14);
		
		var nspace = 5;
		var lspace = 10;
		var bwidth = 30;
		var bheight = 30;
		var bx = 10;
		var by = 3;
		var ty = -2;
		var sy = 12;
		
		colorMatrix = new ColorMatrix();

		background = attachMovie( 'iconsZfControlBackground', 'background', depth++, {/* _width:width*/});
		background.useHandCursor = false;
		background.onPress = function() {
		}
		background.onRelease = function() {
		}

			lZoom = Label( createClassObject( mx.controls.Label, "lZoom", depth++, { text:"Zoom:", color:0x000000}));
			lZoom.move( bx, ty); 
/*	
			zoomOut = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "zoomOut", depth++, { autorepeat:true, icon:"iconsZfControlZoomMinus", tooltip:I18N.gettext( "verkleinern", _root.i18n.tooltips.mapnav.zoom_out)}));
			zoomOut.move( bx, sy+4);
			zoomOut.setSize( 12, 12);
			setParms( zoomOut);
			bx += zoomOut.width + nspace;
*/			
			zoom = Slider( createClassObject( mx.controls.Slider, "zoom", depth++, { value:0, minValue:0, maxValue:100, tickHeight:5}));
			zoom.setSize( 100, 20);
			zoom.minValue=0;
			zoom.maxValue=100;
			zoom.tickFrequency=10;
	//		contrast.showTicks=true;
			zoom.snapToTicks=false;
			zoom.move( bx, sy);
			zoom.addEventListener( "change", this);
			zoom.addEventListener( 'click', this);
			bx += zoom.width + nspace;
/*			
			zoomIn = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "zoomIn", depth++, { autorepeat:true, icon:"iconsZfControlZoomPlus", tooltip:I18N.gettext( "vergrössern", _root.i18n.tooltips.mapnav.zoom_in)}));
			zoomIn.move( bx, sy+4);
			zoomIn.setSize( 12, 12);
			setParms( zoomIn);
			bx += zoomIn.width + nspace;
*/	
			zoomThumb = Button( zoom.thumb);
			zoomThumb.addEventListener( 'click', this);

		bx += lspace;
/*
		panLeft = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "panLeft", depth++, { autorepeat:true, icon:"iconsZfControlPanLeft", tooltip:I18N.gettext( "nach links verschieben", _root.i18n.tooltips.mapnav.move_left)}));
		panLeft.move( bx, by);
		panLeft.setSize( bwidth, bheight);
		setParms( panLeft);
		bx += panLeft.width + nspace;

		panUp = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "panUp", depth++, { autorepeat:true, icon:"iconsZfControlPanUp", tooltip:I18N.gettext( "nach oben verschieben", _root.i18n.tooltips.mapnav.move_up)}));
		panUp.move( bx, by);
		panUp.setSize( bwidth, bheight);
		setParms( panUp);
		bx += panUp.width + nspace;

		panDown = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "panDown", depth++, { autorepeat:true, icon:"iconsZfControlPanDown", tooltip:I18N.gettext( "nach unten verschieben", _root.i18n.tooltips.mapnav.move_down)}));
		panDown.move( bx, by);
		panDown.setSize( bwidth, bheight);
		setParms( panDown);
		bx += panDown.width + nspace;

		panRight = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "panRight", depth++, { autorepeat:true, icon:"iconsZfControlPanRight", tooltip:I18N.gettext( "nach rechts verschieben", _root.i18n.tooltips.mapnav.move_right)}));
		panRight.move( bx, by);
		panRight.setSize( bwidth, bheight);
		setParms( panRight);
		bx += panRight.width + nspace;

		bx += lspace;
*/
		zoomWindow = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "zoomWindow", depth++, { autorepeat:true, icon:"iconsZfControlZoomWindow", tooltip:I18N.gettext( "Fensterzoom", _root.i18n.tooltips.mapnav.zoom_window)}));
		zoomWindow.move( bx, by);
		zoomWindow.setSize( bwidth, bheight);
		zoomWindow.addEventListener( "click", this);
		bx += zoomWindow.width + nspace;

		zoomAll = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "zoomAll", depth++, { autorepeat:true, icon:"iconsZfControlZoomAll", tooltip:I18N.gettext( "gesamte Karte anzeigen", _root.i18n.tooltips.mapnav.zoom_all)}));
		zoomAll.move( bx, by);
		zoomAll.setSize( bwidth, bheight);
		zoomAll.addEventListener( "click", this);
		bx += zoomAll.width + nspace;

		bx += lspace;

		toggleScale = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "toggleScale", depth++, { autorepeat:true, icon:"iconsZfControlToggleScale", tooltip:I18N.gettext( "Maßstab ein-/ausblenden", _root.i18n.tooltips.mapnav.toggle_scale)}));
		toggleScale.move( bx, by);
		toggleScale.setSize( 50, bheight);
		toggleScale.addEventListener( "click", this);
		bx += toggleScale.width + nspace;

		bx += lspace;

		hideMarker = ButtonIconStates( createClassObject( de.msite.ButtonIconStates, "hideMarker", depth++, { autorepeat:true, icon:"iconsZfControlHideMarker", tooltip:I18N.gettext( "Suchmarkierung ausblenden", _root.i18n.tooltips.mapnav.unmark)}));
		hideMarker.move( bx, by);
		hideMarker.setSize( bwidth, bheight);
		hideMarker.addEventListener( "click", this);
		bx += hideMarker.width + nspace;

		bx += lspace;


		lContrast = Label( createClassObject( mx.controls.Label, "lContrast", depth++, { text:I18N.gettext( "Helligkeit:", _root.i18n.tooltips.mapnav.contrast), color:0x000000}));
		lContrast.move( bx, ty); 

		contrast = Slider( createClassObject( mx.controls.Slider, "contrast", depth++, { value:0, minValue:0, maxValue:0}));
		contrast.minValue=0;
		contrast.maxValue=80;
		contrast.tickFrequency=contrast.maxValue/4;
		contrast.setSize( 80, contrast.height);
//		contrast.showTicks=true;

		contrast.snapToTicks=true;
		contrast.move( bx, sy);
		
		contrast.value = 0;
		
		contrast.addEventListener( "change", this);
		bx += contrast.width + lspace;

		
		bx += lspace;
		
		lSaturation = Label( createClassObject( mx.controls.Label, "lSaturation", depth++, { text:I18N.gettext( "Sättigung:", _root.i18n.tooltips.mapnav.saturation), color:0x000000}));
		lSaturation.move( bx, ty); 

		saturation = Slider( createClassObject( mx.controls.Slider, "saturation", depth++, { value:0, minValue:0, maxValue:0}));
		saturation.minValue=0;
		saturation.maxValue=2;
		saturation.tickFrequency=10;
		saturation.setSize( 80, contrast.height);

		saturation.snapToTicks=true;
		saturation.move( bx, sy);
		saturation.addEventListener( "change", this);
		bx += contrast.width + lspace;
		
		saturation.value = 1;
		
		bx += lspace;
		
		cbEnableTweening = CheckBox( createClassObject(mx.controls.CheckBox, "cbEnableTweening", depth++, {label:'SmartMap!'}));
		cbEnableTweening.move( bx, sy);
		cbEnableTweening.addEventListener("click", this);

	}

	function setParms( bt:Button):Void {
		bt.addEventListener( "click", this);
		bt.addEventListener( "buttonDown", this);
		bt.autoRepeat = true;
		bt.setStyle( 'repeatDelay', 1);
		bt.setStyle( 'repeatInterval', 1);
	}
	
	function change( evt):Void {
		debug( "change: "+evt.target);
		
		if ( evt.target == contrast || evt.target == saturation) {
			doFilters();
		} else if ( evt.target == zoom) {

			zfAni.tweenZoom( zoom.value);
			/*if ( delayedUpdTimer != 0) {
				clearInterval( delayedUpdTimer);
			}
			delayedUpdTimer = setInterval( this, "delayedUpdate", 500);*/
		}
		else if ( evt.target == zoomFrame) {
			var bounds:Rectangle = evt.detail.clone();
			var o:Object = zoomify.getGisXYZ(bounds.left, bounds.bottom, bounds.right, bounds.top);
			zfAni.tweenView(o._x, o._y, o._z);
		}
	}

	private function delayedUpdate() {
		clearInterval( delayedUpdTimer);
		delayedUpdTimer = 0;
		
		zoomify.updateView();
	}
	
	private function buttonDown( evt):Void {
		debug( "buttonDown: "+evt.type+" @ "+evt.target);

		PAN_INCREMENT = zoomify.getSize().width/54;
		
		switch( evt.target) {
			case panLeft: zoomify.panLeft( PAN_INCREMENT);
			break;
			case panRight: zoomify.panRight( PAN_INCREMENT);
			break;
			case panUp: zoomify.panUp( PAN_INCREMENT);
			break;
			case panDown: zoomify.panDown( PAN_INCREMENT);
			break;

			case zoomIn:
				zoomify.setZoom(zoomify.getZoom() * 1.02);
				zoom.value = zoomify.getZoom();
			break;
			case zoomOut:
				zoomify.setZoom(zoomify.getZoom() * 0.98);
				zoom.value = zoomify.getZoom();
			break;
		}
	}
	
	private function click( evt):Void {
		debug( "button clicked: "+evt.type+" @ "+evt.target);

		if ( evt.target == zoomThumb) { 
			delayedUpdate();
			return;
		}
		if ( evt.target == cbEnableTweening){
			zfAni.tweeningEnabled = cbEnableTweening.selected;
		}
		// update zoomify when buttons are released
		switch( evt.target) {
			case panLeft:
				zfAni.tweenPanX( PAN_INCREMENT);
			break;
			case panRight:
				zfAni.tweenPanX( -PAN_INCREMENT);
			break;
			case panUp:
				zfAni.tweenPanY( PAN_INCREMENT);
			break;
			case panDown:
				zfAni.tweenPanY( -PAN_INCREMENT);
			break;

			case zoomIn:
				zfAni.tweenZoom( zoomify.getZoom() * 1.1);
				//zoom.value = zoomify.getZoom();
			break;	
			case zoomOut:
				zfAni.tweenZoom( zoomify.getZoom() * 0.9);
				//zoom.value = zoomify.getZoom();
			break;	
			
			case zoomAll: //owner.maxView();
				zfAni.tweenView( 0, 0, zoomify.getMinZoom());
			break;
			
			case zoomWindow: zoomFrame.setEnabled( true);
			break;

			case toggleScale: owner.toggleScale();
			break;
			case hideMarker: owner.clearSearch();
			break;
		}
	}

	private function onMouseWheel( delta:Number, target:String) {
			if ( delta > 0) zfAni.tweenZoom(zoomify.getZoom() * 1.2);
			else zfAni.tweenZoom(zoomify.getZoom() * 0.8);
	}
	
	public function onMouseDown():Void{
		mouseDown = true;
	}
	
	public function onMouseUp():Void{
		mouseDown = false;
	}

	private function doFilters():Void{
		colorMatrix = new ColorMatrix();
		
		var tmp:Number = 0;
		
		//tmp = -1 / contrast.maxValue * contrast.value;
		//colorMatrix.adjustContrast(tmp, tmp, tmp);
		
		//tmp = contrast.value;
		//colorMatrix.adjustBrightness(tmp, tmp, tmp);
		
		zoomify.setMapContrast(80 / contrast.maxValue * contrast.value);
		
		colorMatrix.adjustSaturation(saturation.value);
				
		myFilters = new Array();
		myFilters.push(colorMatrix.filter);

		zoomify.mapfilters = myFilters;
	}

	function zfview( evt:Object):Void{
		if (!mouseDown){
			zoom.removeEventListener( 'change', this);
			zoom.value = evt.detail.zoom;
			zoom.addEventListener( 'change', this);
		}
	}
	
	function size():Void {
		super.size();
//		background._width = width;
	}
	
	function debug( txt:String) {
		_root.debug( "DBG LCTRL: "+txt);
	}
	
	function attach( zmfy:ZfGis):Void {
		debug( "attach "+zoomify+"/"+zmfy);
		
		zoomify = zmfy;
		
		debug( "getScaledMapLayer "+mapLayer_mc);
				
		zoomify.addEventListener( 'zfview', this);
		zoomify.addEventListener( 'onMouseWheel', this);
		
		zoomFrame = ZfZoomFrame( zoomify.createClassObject( de.msite.ZfZoomFrame, "zoomFrame", 1048575, {}));
		zoomFrame.attach( zoomify);
		zoomFrame.addEventListener( 'change', this);
		zoomFrame.move( 0, 0);
		zoomFrame.setEnabled( false);
		
		zfAni = new ZfAnimated(zoomify);
		zfAni.tweeningEnabled = false;
		cbEnableTweening.selected = zfAni.tweeningEnabled;

	//	zoomify.registerCallback( "View", this+".mapChanged");
	}
	
	function detach() {
		debug( "detach "+this+"/"+zoomify+".");
		
		zoomify.removeEventListener( 'zfview', this);
		zoomify.removeEventListener( 'onMouseWheel', this);
		
	//	zoomify.unregisterCallback( "View", this+".mapChanged");
		
		zoomify = null;
	}
	
}
//==================================================
