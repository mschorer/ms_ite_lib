/*

(c) 2004, 2005 by ms@reicheteile.org

v1.61

v1.61: removed label-code					 					(20050327)
v1.60: converted to as2.0 subclasss of ZfImage 					(20050218)

builds GIS-functionality ontop of zfimage

*/

package de.ms_ite.zf {
	
	import de.ms_ite.*;
	import de.ms_ite.maptech.*;
	
	import flash.xml.*;
	
	public class ZfGis extends ZfImage {
		
//		private var depth:int = 1;
		
//		private var tconv:de.msite.DatumConv;
		
		private var initViewBounds:Bounds = null;
	
		//===========================================================================
	
		function ZfGis() {
			super();
			debug( "GIS constructor");
//			tconv = new de.msite.DatumConv();
		}
	
		public function getGisXYZ(xs:Number, ys:Number, xe:Number, ye:Number):Object {
			debug( "mapb: "+bounds);
			if ( ! bounds.isValid()) {
				error("no georef in " + _imagePath + "/ImageProperties.xml !");
				return null ;
			}
			if (gImageWidth <= 0 || gImageHeight <= 0) {
				error("viewport not created !");
				return null;
			}
			// get the viewport-size in pixels
			var vp_width:Number = gViewWidth;
			var vp_height:Number = gViewHeight;
			// get the image-size in pixels
			var img_width:Number = gImageWidth;
			var img_height:Number = gImageHeight;
			debug("viewport: " + img_width + "x" + img_height + "    " + vp_width + "," + vp_height);
			// calculate the center of the area to show
			var xmid:Number = (xs + xe) / 2;
			var ymid:Number = (ys + ye) / 2;
			debug( "aspect view: "+Math.abs(xs-xe)+"="+xmid+"  "+Math.abs(ys-ye)+"="+ymid);
			// calculate dispolay-area- ans viewport-aspect ratios
			var aspshow:Number = (ys != ye) ? (Math.abs(xs - xe) / Math.abs(ys - ye)) : 1;
			var aspview:Number = vp_width / vp_height;
			var fx:Number = 0;
			var zf:Number = 0;
			debug("aspect view: " + aspview + "   show: " + aspshow);
			//	debug( "aspect x: "+(xs-xe)+"/"+bounds.width+"   y: "+(ys-ye)+"/"+bounds.height);
			// determine what we need to limit to fit into viewport
			if (aspview > aspshow) {
				// limiting y
				// calculate pixels of base image to show
				if (ys == ye) {
					fx = vp_height;
				} else {
					fx = img_height * Math.abs(ye - ys) / Math.abs( bounds.height);
				}
				debug("pix y: " + fx);
				// calculate scaling to fit it into viewport
				zf = vp_height / fx;
				debug("zf: " + zf);
			} else {
				// limiting x
				// calculate pixels of base image to show
				if (xs == xe) {
					fx = vp_width;
				} else {
					fx = img_width * Math.abs(xe - xs) / Math.abs( bounds.width);
				}
				debug("pix x: " + fx);
				// calculate scaling to fit it into viewport
				zf = vp_width / fx;
				debug("zf: " + zf);
			}
			//	zf = 50;
			debug("siz: " + bounds.width + " x " + bounds.height);
			//	debug( "pos: "++(_global.bmx-x_show)+","+(_global.bmy-y_show));
			// calculate offset values for display-area to map-center
			var obj:Object = new Object();
			var xoff:Number = (bounds.right + bounds.left) / 2 - xmid;
			var yoff:Number = (ymid - (bounds.top + bounds.bottom) / 2);
			debug("???: "+bounds.right+","+bounds.left+","+xmid+".");
			obj._x = ( xoff == 0) ? 0 : (xoff / Math.abs( bounds.width));
			obj._y = ( yoff == 0) ? 0 : (yoff / Math.abs( bounds.height));
			obj._z = (zf > _maxZoom) ? _maxZoom : zf;
			debug("show: " + obj._x + "," + obj._y + " @ " + obj._z);
			return obj;
		}
		public function setGisMapInitial( xs:Number, ys:Number, xe:Number, ye:Number):void {
			debug( "gis ini: "+typeof(xs)+" = "+xs);
			var o:Object = getGisXYZ(xs, ys, xe, ye);
			setInitialView( o._x, o._y, o._z);
		}
		
		public function setGisMap( xs:Number, ys:Number, xe:Number, ye:Number):void {
			var o:Object = getGisXYZ(xs, ys, xe, ye);
			setView(o._x, o._y, o._z);
		}
		
		public function showGisMap(xs:Number, ys:Number, xe:Number, ye:Number):void {
			setGisMap(xs, ys, xe, ye);
			updateView();
		}
		
		public function showGisView( xs:Number, ys:Number, z:Number):void {
			var o:Object = getGisXYZ(xs, ys, xs, ys);
			setView(o._x, o._y, z);
			updateView();
		}
		
		public function getGisMapBounds():Bounds {
			return Bounds( bounds.clone());
		}
		
		public function getGisViewportBounds():Bounds {
			var b:Bounds = new Bounds();
			
			var xmid:Number = getX();
			var ymid:Number = getY();
			var zoom:Number = getZoom();
			
			debug("ggvb: " + xmid + ", " + ymid + " @ " + zoom + ".");
			debug("ggvb map: " + bounds.left + ", " + bounds.bottom + ", " + bounds.right + ", " + bounds.top + ".");
			var vp_width:Number = gViewWidth;
			var vp_height:Number = gViewHeight;
			// get the image-size in pixels
			var img_width:int = gImageWidth;
			var img_height:int = gImageHeight;
			
			if ( ! gInitialized) return null;
			
			var gmidx:Number = (bounds.left + bounds.right) / 2;
			var gmidy:Number = (bounds.bottom + bounds.top) / 2;
			
			var gwid:Number = bounds.width;
			var gsx:Number = gwid / img_width;
			
			var ghgt:Number = bounds.height;
			var gsy:Number = ghgt / img_height;
			
	//		debug("gv mid: " + gmidx + ", " + gmidy + "  " + gwid + " x " + ghgt + ".");
			var cx:Number = gmidx - xmid * gwid;
			var cy:Number = gmidy + ymid * ghgt;
			var vx:Number = (vp_width * gsx / zoom) / 2;
			var vy:Number = (vp_height * gsy / zoom) / 2;
	//		debug("gv viewport: " + cx + ", " + cy + "   " + vx + " x " + vy + ".");
	
			b.mbrAddCoord( cx - vx, cy - vy);
			b.mbrAddCoord( cx + vx, cy + vy);
			
			debug("rv: " + b.toString());
			return b;
		}
	
		// return the screen center in gis-coordinates
		public function getGisX():Number {
			var gmidx:Number = (bounds.left + bounds.right) / 2;
	
			return ( gmidx - getX() * bounds.width);
		}
	
		// return the screen center in gis-coordinates
		public function getGisY():Number {
			var gmidy:Number = (bounds.bottom + bounds.top) / 2;
	
			return ( gmidy + getY() * bounds.height);
		}
	
		// convert gis to zoomify coordinates
		public function getGis2MapX( x:Number):Number {
			return ( ( bounds.left + bounds.right) / ( 2 * bounds.width) - x / bounds.width);
		}
		
		// convert gis to zoomify coordinates
		public function getGis2MapY( y:Number):Number {
			return ( y / bounds.height - ( bounds.bottom + bounds.top) / ( 2* bounds.height));
		}
		
		// convert gis to zoomify coordinates
		public function getMapY2Gis( y:Number):Number {
			return bounds.top - bounds.height * ( y + gImageHeight / 2) / gImageHeight;
		}
		
		// convert gis to zoomify coordinates
		public function getMapX2Gis( x:Number):Number {
			return bounds.left + bounds.width * ( x + gImageWidth / 2) / gImageWidth;
		}
		
		public function setGisClip( left:Number, top:Number, right:Number, bottom:Number):void {
			
			setClip( getGis2MapX( left), getGis2MapY( bottom), getGis2MapX( right), getGis2MapY( top));
		}
		
		public function getGisInitViewBounds():Bounds {
			return Bounds( initViewBounds.clone());
		}
	
		//===========================================================================
	
		override protected function parseImagePropertiesData( xml:XML):void {
			debug("parse xml in " + xml + ".");
	
			var georef:XMLList = xml.georef;
			var initview:XMLList = xml.initview;
			
			bounds.left =  parseFloat( georef.@xmin);
			bounds.bottom = parseFloat( georef.@ymin);
			bounds.right = parseFloat( georef.@xmax);
			bounds.top = parseFloat( georef.@ymax);
			debug( "gref: "+bounds.left+","+bounds.bottom+"/"+bounds.right+","+bounds.top);

			if ( initview.attributes().length() > 0 ) {
				initViewBounds = new Bounds();
				initViewBounds.left = parseFloat( initview.@xmin);
				initViewBounds.bottom = parseFloat( initview.@ymin);
				initViewBounds.right = parseFloat( initview.@xmax);
				initViewBounds.top = parseFloat( initview.@ymax);
				debug( "initView: "+initViewBounds.toString());
			}
		
			super.parseImagePropertiesData( xml);
		}
	
		
		//===========================================================================
	}
}