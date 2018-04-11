package de.ms_ite.events {

	import flash.events.Event;

	public class LoginEvent extends Event {
		
		public static var LOGIN_CLICKED:String	= 'loginClicked';
		public static var LOGIN_CANCELLED:String	= 'loginCancelled';
		
		public var login:String;
		public var password:String;
		
		public function LoginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}