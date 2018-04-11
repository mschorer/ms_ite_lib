package de.ms_ite.events
{
	import flash.events.Event;

	public class TableSheetEvent extends Event
	{
		public static var TS_ZOOM_ALL:String	= 'tsZoomAll';
		public static var TS_ZOOM_ITEM:String	= 'tsZoomItem';
		public static var TS_DELETE_ITEM:String	= 'tsRemoveItem';
		
		public var item:Object = null;
		public var index:int = -1;
		 
		public function TableSheetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super( type, bubbles, cancelable);
		}
	}
}