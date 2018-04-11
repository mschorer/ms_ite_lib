package de.ms_ite.components {
	import de.ms_ite.events.ViewNavEvent;
	
	import flash.display.*;
	import flash.events.MouseEvent;
	import mx.controls.tabBarClasses.Tab;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.TabNavigator;
	import mx.controls.*;
	import mx.core.EdgeMetrics;
	import mx.events.*;
	
	[Style(name="popupButtonStyleName", type="String", inherit="no")]
	[Style(name="newTabButtonStyleName", type="String", inherit="no")]
	[Style(name="viewNavPopupButtonStyleName", type="String", inherit="no")]

	public class ViewNavigator extends TabNavigator {
		
		protected var topNav:HBox;
		protected var bNewSheet:Button;
		protected var canvas:Canvas;
		protected var bTabSel:PopUpButton;
		protected var menu:Menu;
		protected var spacer:Spacer;
		
		public function ViewNavigator():void {
			debug( "create");
			super();
		}
		/*
		Use the ViewBar instance as the tabBar as the tabBar.
		Since ViewBar extends TabBar, the cooercion succeeds
		*/
		override protected function createChildren():void {
			debug( "create: "+this);
	        if (!tabBar){
				tabBar = new ViewBar();
				tabBar.name = "tabBar";
				tabBar.focusEnabled = false;
				tabBar.styleName = this;
				tabBar.addEventListener( ViewNavEvent.TAB_CLOSE, handleClose);
	
				tabBar.setStyle("borderStyle", "none");
				tabBar.setStyle("paddingTop", 0);
				tabBar.setStyle("paddingBottom", 0);
				
//				rawChildren.addChild(tabBar);
			}
			super.createChildren();
			
			if ( !topNav) {
				topNav = new HBox();
	        	topNav.setStyle("horizontalGap", 0);
	        	topNav.setStyle("borderStyle", "none");
	        	topNav.setStyle("paddingTop", 0);
				topNav.setStyle("paddingBottom", 0);

				rawChildren.addChild( topNav);
				debug( "topNav");
			}

			if ( !bNewSheet) {
				bNewSheet = new Button();
				bNewSheet.label = '*';
				bNewSheet.width = 20;
				bNewSheet.toolTip = 'Create new sheet';
				bNewSheet.styleName = getStyle("newTabButtonStyleName");
				
				bNewSheet.addEventListener( MouseEvent.CLICK, handleAddSheet);
				topNav.addChild( bNewSheet);
				debug( "new");
			}
	        
	        if ( !canvas) {
	        	canvas = new Canvas();
	        	canvas.styleName = this;
	        	canvas.setStyle("borderStyle", "none");
	        	canvas.setStyle("backgroundAlpha", 0);
	        	canvas.setStyle("paddingTop", 0);
				canvas.setStyle("paddingBottom", 0);
				canvas.horizontalScrollPolicy = "off";
				
	        	topNav.addChild( canvas);
	        	canvas.addChild( tabBar);
	        	debug( "canvas");
	        }
/*			
			spacer = new Spacer();
			spacer.percentWidth = 100;
			topNav.addChild( spacer);
			*/
	        if(!menu) {
	        	menu = new Menu();
	        	
	        	menu.addEventListener(MenuEvent.ITEM_CLICK, changeTabs);
	        }
	        
			if ( !bTabSel) {
				bTabSel = new PopUpButton();
				bTabSel.toolTip = 'Select sheet';
				bTabSel.enabled = false;
	        	bTabSel.popUp = menu;
	        	bTabSel.width = 18;
	        	
	        	bTabSel.styleName = getStyle("viewNavPopupButtonStyleName");
				
//				pTabSel.addEventListener( MouseEvent.CLICK, handleAddSheet);
				topNav.addChild( bTabSel);
				debug( "tabsel");
			}
	        tabBar.addEventListener( ChildExistenceChangedEvent.CHILD_ADD, tabsChanged);
	        tabBar.addEventListener( ChildExistenceChangedEvent.CHILD_REMOVE, tabsChanged);
	        
			this.addEventListener(IndexChangedEvent.CHANGE,tabChangedEvent); 
			invalidateSize();
			
			debug( "createChildren done.");
		}
		
		protected function handleClose( evt:ViewNavEvent):void {
			debug( "viewNavi close: "+evt.itemIndex);
			
			var temp:ViewNavEvent = new ViewNavEvent( ViewNavEvent.TAB_CLOSE);
			temp.itemIndex = evt.itemIndex;
			temp.item = getChildAt( evt.itemIndex);
			
			dispatchEvent( temp);
		}

		protected function handleAddSheet( evt:MouseEvent):void {
			debug( "viewNavi new");
			
			var temp:ViewNavEvent = new ViewNavEvent( ViewNavEvent.TAB_NEW);
			
			dispatchEvent( temp);
		}

	    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        
	        var vm:EdgeMetrics = viewMetrics;
	        var w:Number = unscaledWidth - vm.left - vm.right;

			var tabBarHeight:Number = Math.max( bNewSheet.height, tabBar.getExplicitOrMeasuredHeight());	
			debug( "tabbarheight: "+tabBarHeight);
	        var th:Number = tabBarHeight;
	        var pw:Number = tabBar.getExplicitOrMeasuredWidth();
	        	        
	        topNav.move(0, 1);
	        topNav.setActualSize( unscaledWidth, th);

           	var canvasWidth:Number = unscaledWidth;
			
			canvasWidth -= bTabSel.width;
			canvasWidth -= bNewSheet.width;
			
			canvas.width = canvasWidth;
			canvas.height = th;
           
			tabBar.setActualSize(pw, th);
	    }

		private function changeTabs(event:MenuEvent):void {
			debug( "changeTbas");
	    	
	    	this.selectedIndex = event.index;
//	    	if (this.selectedIndex == event.index) {
	    		ensureTabIsVisible();
//	    	}
	    }
	    
	    /**
	    * The tabs can be changed any number of ways (via drop-down menu, via AS, etc)
	    * so this listener function will make sure that the tab that gets selected is 
	    * visible.
	    */
	    private function tabChangedEvent(event:IndexChangedEvent):void {
	    	callLater(ensureTabIsVisible);
	    }
	    
	    /**
	    * Check to make sure that the currently selected tab is viaible. This means
	    * that we might have to scroll the canvas component so the tab comes into view
	    */
	    private function ensureTabIsVisible():void {
	    	debug( "sel: "+selectedIndex);
	    	var tab:DisplayObject = tabBar.getChildAt( selectedIndex);
	    	
	    	var newHorizontalPosition:Number;
	    	
	    	debug( tab.x+" + "+tab.width+" > "+this.canvas.horizontalScrollPosition+" + "+this.canvas.width);
	    	if( tab.x + tab.width > this.canvas.horizontalScrollPosition + this.canvas.width) {
	    		newHorizontalPosition = tab.x + tab.width - canvas.width;
	    		debug( "new1: "+newHorizontalPosition);
	    	}
	    	else if ( this.canvas.horizontalScrollPosition > tab.x) {
	    		newHorizontalPosition = tab.x;
	    		debug( "new2: "+newHorizontalPosition);
	    	}
	    	else {
	    		newHorizontalPosition = canvas.horizontalScrollPosition;
	    		debug( "new3: "+newHorizontalPosition);
	    	}
    	
	    	if ( newHorizontalPosition != canvas.horizontalScrollPosition) {
	    		// We tween the motion so it looks super sweet
//	    		var tween:Tween = new Tween(this, canvas.horizontalScrollPosition, newHorizontalPosition, 500);

	    		canvas.horizontalScrollPosition = newHorizontalPosition;
	    		debug( "scroll to: "+newHorizontalPosition);
	    	}
    		debug( "scroll!");
	    }

	    private function tabsChanged(event:ChildExistenceChangedEvent):void {
	    	bTabSel.enabled = tabBar.numChildren > 0;
	    	debug( "tabs: "+tabBar.numChildren);
	    	
	    	if ( bTabSel.enabled) callLater(reorderTabList);
	    	else menu.dataProvider = null;
	    }
	    
	    /**
	    * reorderTabList loops over all the tabs and makes sure that the drop-down
	    * list is correct. This should get called every time tabs are added, removed,
	    * or re-ordered.
	    */
	    public function reorderTabList():void {
	    	var popupMenuDP:ArrayCollection = new ArrayCollection();
			
			for(var i:int=0; i<tabBar.numChildren; i++) {
				var child:DisplayObject = tabBar.getChildAt(i);
				
				var item:Object = new Object();
				item.label = "Untitled Tab";
				if( child is Tab && (child as Tab).label != "") {
					item.label = (child as Tab).label;
				}
				item.type = 'radio';
				item.groupName = 'tabGroup';
				item.toggled = ( i == selectedIndex);
				
				popupMenuDP.addItem( item);
			}
				
			menu.dataProvider = popupMenuDP;	
	    }
	    protected function debug( txt:String):void {
	    	trace( "DBG VN: "+txt);
	    }
	}
}