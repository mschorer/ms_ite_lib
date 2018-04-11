package de.ms_ite.components {
	import mx.controls.Image;
	import mx.controls.treeClasses.*;
	import mx.core.*;

	public class CategoryTreeItemrenderer extends TreeItemRenderer {
		
		protected var image:Image;
		
		public function CategoryTreeItemrenderer() {
			super();
		}
		
		override protected function createChildren():void {
			
			image = new Image();
			image.x = 0;
			image.y = 0;
			image.width = 25;
			image.height = 25;
			image.scaleContent = true;
			addChild( image);

			super.createChildren();
		}

        override public function set data(value:Object):void {
			if( value != null) {
			    super.data = value;
			    
			    if ( image != null) {
			    	image.source = findRoot().iconMapList[ value.@iconid];	//findRoot().getIconClassFromLib( value.@iconid);
			    }

//			    trace( "img: "+XML( TreeListData( listData).item).@icon.toString());

			    if( XML( TreeListData( listData).item).@hidden.toString() == '1') {
			        setStyle("color", 0xa0a0a0);
			        setStyle("fontWeight", 'bold');
				} else {
				    setStyle("color", 0x000000);
				    setStyle("fontWeight", 'bold');
				}
			}
		}	 
	
		protected function findRoot():Object {
			var temp:Object = this;
			while( temp != null) {
				if ( temp is Application) return temp;
				temp = temp.parent;
			}
			return null;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var startx:Number = label.x;
			
			if ( image.source != null) {
				image.x = startx;
				startx += image.width;	// + 4;
			}
			
			label.x = startx;

		}
	}
}
