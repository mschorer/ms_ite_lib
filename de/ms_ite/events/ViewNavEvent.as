package de.ms_ite.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class ViewNavEvent extends Event
	{
		public static var TAB_CLOSE:String	= 'closeTab';
		public static var TAB_NEW:String	= 'newTab';
		
		public var itemIndex:int;
		public var item:DisplayObject;
		 
		public function ViewNavEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}