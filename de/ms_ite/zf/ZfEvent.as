package de.ms_ite.zf
{
	import flash.events.Event;

	public class ZfEvent extends Event
	{
		public static var FOCUS:String = 'zf_focus';
		public static var INIT:String = 'zf_init';
		public static var CLIP:String = 'zf_clip';
		public static var VIEW:String = 'zf_view';
		public static var DISPLAY:String = 'zf_display';
		public static var STATUS:String = 'zf_status';
		
		public function ZfEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}