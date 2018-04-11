package de.ms_ite.tools {
	
	public interface IServiceCache {
		function insertCall( svTag:String, parms:Array, res:Object):void;
		function getCached( svTag:String, parms:Array):void;
		function getResult():Array;
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
}