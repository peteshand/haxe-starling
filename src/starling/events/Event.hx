// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.events;

import starling.utils.StarlingUtils;

/** Event objects are passed as parameters to event listeners when an event occurs.  
 *  This is Starling's version of the Flash Event class. 
 *
 *  <p>EventDispatchers create instances of this class and send them to registered listeners. 
 *  An event object contains information that characterizes an event, most importantly the 
 *  event type and if the event bubbles. The target of an event is the object that 
 *  dispatched it.</p>
 * 
 *  <p>For some event types, this information is sufficient; other events may need additional 
 *  information to be carried to the listener. In that case, you can subclass "Event" and add 
 *  properties with all the information you require. The "EnterFrameEvent" is an example for 
 *  this practice; it adds a property about the time that has passed since the last frame.</p>
 * 
 *  <p>Furthermore, the event class contains methods that can stop the event from being 
 *  processed by other listeners - either completely or at the next bubble stage.</p>
 * 
 *  @see EventDispatcher
 */
class Event
{
	/** Event type for a display object that is added to a parent. */
	public static var ADDED:String = "added";
	/** Event type for a display object that is added to the stage */
	public static var ADDED_TO_STAGE:String = "addedToStage";
	/** Event type for a display object that is entering a new frame. */
	public static var ENTER_FRAME:String = "enterFrame";
	/** Event type for a display object that is removed from its parent. */
	public static var REMOVED:String = "removed";
	/** Event type for a display object that is removed from the stage. */
	public static var REMOVED_FROM_STAGE:String = "removedFromStage";
	/** Event type for a triggered button. */
	public static var TRIGGERED:String = "triggered";
	/** Event type for a display object that is being flattened. */
	public static var FLATTEN:String = "flatten";
	/** Event type for a resized Flash Player. */
	public static var RESIZE:String = "resize";
	/** Event type that may be used whenever something finishes. */
	public static var COMPLETE:String = "complete";
	/** Event type for a (re)created stage3D rendering context. */
	public static var CONTEXT3D_CREATE:String = "context3DCreate";
	/** Event type that indicates that the root DisplayObject has been created. */
	public static var ROOT_CREATED:String = "rootCreated";
	/** Event type for an animated object that requests to be removed from the juggler. */
	public static var REMOVE_FROM_JUGGLER:String = "removeFromJuggler";
	/** Event type that is dispatched by the AssetManager after a context loss. */
	public static var TEXTURES_RESTORED:String = "texturesRestored";
	/** Event type that is dispatched by the AssetManager when a file/url cannot be loaded. */
	public static var IO_ERROR:String = "ioError";
	/** Event type that is dispatched by the AssetManager when a file/url cannot be loaded. */
	public static var SECURITY_ERROR:String = "securityError";
	/** Event type that is dispatched by the AssetManager when an xml or json file couldn't
	 *  be parsed. */
	public static var PARSE_ERROR:String = "parseError";
	/** Event type that is dispatched by the Starling instance when it encounters a problem
	 *  from which it cannot recover, e.g. a lost device context. */
	public static var FATAL_ERROR:String = "fatalError";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var CHANGE:String = "change";
	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var CANCEL:String = "cancel";
	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var SCROLL:String = "scroll";
	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var OPEN:String = "open";
	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var CLOSE:String = "close";
	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var SELECT:String = "select";
	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static var READY:String = "ready";
	
	private static var sEventPool = new Array<Event>();
	
	private var mTarget:EventDispatcher;
	private var mCurrentTarget:EventDispatcher;
	private var mType:String;
	private var mBubbles:Bool;
	private var mStopsPropagation:Bool;
	private var mStopsImmediatePropagation:Bool;
	private var mData:Dynamic;
	
	public var bubbles(get, null):Bool;
	public var target(get, null):EventDispatcher;
	public var currentTarget(get, null):EventDispatcher;
	public var type(get, null):String;
	public var data(get, null):Dynamic;
	
	/*internal*/ 
	public var stopsPropagation(get, null):Bool;
	
	/*internal*/
	public var stopsImmediatePropagation(get, null):Bool;
	
	/** Creates an event object that can be passed to listeners. */
	public function new(type:String, bubbles:Bool=false, data:Dynamic=null)
	{
		mType = type;
		mBubbles = bubbles;
		mData = data;
	}
	
	/** Prevents listeners at the next bubble stage from receiving the event. */
	public function stopPropagation():Void
	{
		mStopsPropagation = true;            
	}
	
	/** Prevents any other listeners from receiving the event. */
	public function stopImmediatePropagation():Void
	{
		mStopsPropagation = mStopsImmediatePropagation = true;
	}
	
	/** Returns a description of the event, containing type and bubble information. */
	public function toString():String
	{
		var name:String = Type.getClassName(Type.getClass(this));
		trace("CHECK name = " + name.split(".").pop());
		
		return StarlingUtils.formatString("[{0} type=\"{1}\" bubbles={2}]", 
			[cast name.split(".").pop(), mType, mBubbles]);
	}
	
	/** Indicates if event will bubble. */
	private function get_bubbles():Bool { return mBubbles; }
	
	/** The object that dispatched the event. */
	private function get_target():EventDispatcher { return mTarget; }
	
	/** The object the event is currently bubbling at. */
	private function get_currentTarget():EventDispatcher { return mCurrentTarget; }
	
	/** A string that identifies the event. */
	private function get_type():String { return mType; }
	
	/** Arbitrary data that is attached to the event. */
	private function get_data():Dynamic { return mData; }
	
	// properties for internal use
	
	/** @private */
	/*internal*/
	public function setTarget(value:EventDispatcher):Void { mTarget = value; }
	
	/** @private */
	/*internal*/
	public function setCurrentTarget(value:EventDispatcher):Void { mCurrentTarget = value; } 
	
	/** @private */
	/*internal*/
	public function setData(value:Dynamic):Void { mData = value; }
	
	/** @private */
	/*internal*/
	private function get_stopsPropagation():Bool { return mStopsPropagation; }
	
	/** @private */
	/*internal*/
	private function get_stopsImmediatePropagation():Bool { return mStopsImmediatePropagation; }
	
	// event pooling
	
	/** @private */
	//starling_internal
	public static function fromPool(type:String, bubbles:Bool=false, data:Dynamic=null):Event
	{
		if (sEventPool.length > 0) return sEventPool.pop().reset(type, bubbles, data);
		else return new Event(type, bubbles, data);
	}
	
	/** @private */
	//starling_internal
	public static function toPool(event:Event):Void
	{
		event.mData = event.mTarget = event.mCurrentTarget = null;
		sEventPool[sEventPool.length] = event; // avoiding 'push'
	}
	
	/** @private */
	//starling_internal
	public function reset(type:String, bubbles:Bool=false, data:Dynamic=null):Event
	{
		mType = type;
		mBubbles = bubbles;
		mData = data;
		mTarget = mCurrentTarget = null;
		mStopsPropagation = mStopsImmediatePropagation = false;
		return this;
	}
}