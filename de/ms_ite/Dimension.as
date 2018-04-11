/*
 *
 * a rectangle class for bounds, rectangles
 *
 */

package de.ms_ite {
	
	public class Dimension {
		public var width:Number;
		public var height:Number;
		
		public function Dimension( w:Number=0, h:Number=0):void {
			width = w;
			height = h;
		}
		
		public function clone():Dimension {
			return new Dimension( width, height);
		}
		
		public function toString():String {
			return 'DIM( '+width+' '+height+')';
		}
	}
}