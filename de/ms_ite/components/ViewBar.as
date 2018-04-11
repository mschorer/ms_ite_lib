package de.ms_ite.components {
	
	import de.ms_ite.events.ViewNavEvent;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.controls.TabBar;
	import mx.core.ClassFactory;
	import mx.core.DragSource;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;	
	
	public class ViewBar extends TabBar{
		
		use namespace mx_internal;
		
		public function ViewBar(){
			super();

			navItemFactory = new ClassFactory(ViewTab);
			this.addEventListener(DragEvent.DRAG_ENTER, onDragEnter);
			this.addEventListener(DragEvent.DRAG_DROP, onDragDrop);
		}
		
		override protected function createNavItem(
										label:String,
										icon:Class = null):IFlexDisplayObject{
											
			var ifdo:IFlexDisplayObject = super.createNavItem(label,icon);
			ifdo.addEventListener( ViewNavEvent.TAB_CLOSE, onCloseTabClicked);
			ifdo.addEventListener( MouseEvent.MOUSE_DOWN, tryDrag);
			ifdo.addEventListener( MouseEvent.MOUSE_UP, removeDrag);
			return ifdo;
		}
		
		private function tryDrag(e:MouseEvent):void{
			e.target.addEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}
		
		private function removeDrag(e:MouseEvent):void{
			e.target.removeEventListener(MouseEvent.MOUSE_MOVE,doDrag);
		}
		public function onCloseTabClicked(event:ViewNavEvent):void{
			
			var index:int = getChildIndex(DisplayObject(event.currentTarget));
			debug( "viewBar close: "+index);
			
			var temp:ViewNavEvent = new ViewNavEvent( ViewNavEvent.TAB_CLOSE);
			temp.itemIndex = index;
			
			dispatchEvent( temp);
		}
		
		private function doDrag(event:MouseEvent):void{
				var ds:DragSource = new DragSource();
				ds.addData( event.currentTarget,'tabDrag');
				DragManager.doDrag(IUIComponent(event.target),ds,event);						
		}
		
		private function onDragEnter(event:DragEvent):void{
			if(event.dragSource.hasFormat('tabDrag')){
				DragManager.acceptDragDrop(IUIComponent(event.target));
			}
		}
		
		private function onDragDrop(event:DragEvent):void{
			var d:ViewTab = ViewTab(event.dragSource.dataForFormat('tabDrag'));
			var childrenArr:Array = new Array();
			d.x = mouseX;
			//d.x = DragManager.dragProxy.x;
			for(var i:Number=0; i<numChildren; i++){
				var childRef:DisplayObject = getChildAt(i);
				childrenArr.push(childRef);	
			}
			childrenArr.sortOn("x",Array.NUMERIC);
			childrenArr[0].x=0;
			for(var c:Number = 1; c<childrenArr.length; c++){
				childrenArr[c].x = childrenArr[c-1].x+childrenArr[c-1].width;
			}
		}
		
		protected function debug( txt:String):void {
//			trace( "DBG VB: "+txt);
		}
	}
}