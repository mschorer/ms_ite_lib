package de.ms_ite.components {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.controls.tabBarClasses.Tab;
	
	import mx.controls.Button;
	import mx.core.*;
	import mx.core.mx_internal;
	
	import de.ms_ite.events.ViewNavEvent;
	
//	[Style(name="viewNavCloseButtonStyleName", type="String", inherit="no")]
	[Style(name="indicatorClass", type="String", inherit="no")]

	public class ViewTab extends Tab {
		
		public static const CLOSE_ALWAYS:String = "close_always";
		public static const CLOSE_SELECTED:String = "close_selected";
		public static const CLOSE_ROLLOVER:String = "close_rollover";
		public static const CLOSE_NEVER:String = "close_never";

		private var _rolledOver:Boolean = false;
		
		protected var closeButton:Button;
		private var indicator:DisplayObject;
		private var _closePolicy:String;

		private var _showIndicator:Boolean = false;
		private var _indicatorOffset:Number = 0;		

		use namespace mx_internal;
		
		public function ViewTab(){
			super();
			this.mouseChildren = true;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
			// Here the width and height of the closeButton are hardcoded.
			// To make the component more customizable I suppoose the width and
			// height could be controlled by either a button skin, or by a property 
			closeButton = new Button();
			closeButton.width = 12;
			closeButton.height = 12;
			
			// We have to listen for the click event so we know to close the tab
			closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler); 
		
			// This allows someone to specify a CSS style for the close button
			closeButton.styleName = getStyle("viewNavCloseButtonStyleName");
			
			var indicatorClass:Class = getStyle("indicatorClass") as Class;
			if(indicatorClass) {
				indicator = new indicatorClass() as DisplayObject;
			} else {
				indicator = new UIComponent();
			}
			
			addChild(indicator);
			addChild(closeButton);
		}

		override protected function measure():void{
			super.measure();
			measuredMinWidth+=20
			measuredWidth+=20;
		}
		
		public function get closePolicy():String {
			return _closePolicy;
		}
		
		public function set closePolicy(value:String):void {
			this._closePolicy = value;
			this.invalidateDisplayList();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// We need to make sure that the closeButton and the indicator are
			// above all other display items for this button. Otherwise the button
			// skin or icon or text are placed over the closeButton and indicator.
			// That's no good because then we can't get clicks and it looks funky.
			setChildIndex(closeButton, numChildren - 2);
			setChildIndex(indicator, numChildren - 1);			
			
			closeButton.visible = false;
			indicator.visible = false;
			
			// Depedning on the closePolicy we might be showing the closeButton
			// and it may or may not be enabled.
			if(_closePolicy == ViewTab.CLOSE_SELECTED) {
				if(selected) {
					closeButton.visible = true;
					closeButton.enabled = true;
				}
			}
			else {
				if(!_rolledOver) {
					if(_closePolicy == ViewTab.CLOSE_ALWAYS){
						closeButton.visible = true;
						closeButton.enabled = false;
					}
					else if(_closePolicy == ViewTab.CLOSE_ROLLOVER) {
						closeButton.visible = false;
						closeButton.enabled = false;
					}
				}
				else {
					if(_closePolicy != ViewTab.CLOSE_NEVER) {
						closeButton.visible = true;
						closeButton.enabled = true;
					}
				}
			}
			
			if(_showIndicator) {
				indicator.visible = true;
				indicator.x = _indicatorOffset - indicator.width/2;
				indicator.y = 0;
			}
			
			if(closeButton.visible) {
				// Resize the text if we're showing the closeIcon, so the
				// closeIcon won't overlap the text. This means the text may
				// have to truncate using the "..." differently.
				/*
				this.textField.width -= closeButton.width;
				this.textField.truncateToFit();
				*/
				// We place the closeButton 4 pixels from the top and 4 pixels from the left.
				// Why 4 pixels? Because I said so. 
				closeButton.x = unscaledWidth-closeButton.width - 4;
				closeButton.y = 4;
			}
		}
		

		private function closeClickHandler(event:MouseEvent):void {
			
			dispatchEvent( new ViewNavEvent( ViewNavEvent.TAB_CLOSE));
			
			event.stopImmediatePropagation();
		}
		
		override protected function rollOverHandler(event:MouseEvent):void{
			_rolledOver = true;
			super.rollOverHandler(event);	
		}
		
		override protected function rollOutHandler(event:MouseEvent):void{
			_rolledOver = false;
			super.rollOutHandler(event);	
		}
	}
}