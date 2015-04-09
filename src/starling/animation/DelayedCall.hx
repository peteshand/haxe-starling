// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.animation;

import starling.events.Event;
import starling.events.EventDispatcher;

/** A DelayedCall allows you to execute a method after a certain time has passed. Since it 
 *  implements the IAnimatable interface, it can be added to a juggler. In most cases, you 
 *  do not have to use this class directly; the juggler class contains a method to delay
 *  calls directly. 
 * 
 *  <p>DelayedCall dispatches an Event of type 'Event.REMOVE_FROM_JUGGLER' when it is finished,
 *  so that the juggler automatically removes it when its no longer needed.</p>
 * 
 *  @see Juggler
 */ 
class DelayedCall extends EventDispatcher implements IAnimatable
{
	private var mCurrentTime:Float;
	private var mTotalTime:Float;
	private var mCall:Function;
	private var mArgs:Array<Dynamic>;
	private var mRepeatCount:Int;
	
	public var isComplete(get, null):Bool;
	public var totalTime(get, null):Float;
	public var currentTime(get, null):Float;
	public var repeatCount(get, set):Int;
	
	/** Creates a delayed call. */
	public function new(call:Function, delay:Float, args:Array<Dynamic>=null)
	{
		super();
		reset(call, delay, args);
	}
	
	/** Resets the delayed call to its default values, which is useful for pooling. */
	public function reset(call:Function, delay:Float, args:Array<Dynamic>=null):DelayedCall
	{
		mCurrentTime = 0;
		mTotalTime = Math.max(delay, 0.0001);
		mCall = call;
		mArgs = args;
		mRepeatCount = 1;
		
		return this;
	}
	
	/** @inheritDoc */
	public function advanceTime(time:Float):Void
	{
		var previousTime:Float = mCurrentTime;
		mCurrentTime += time;

		if (mCurrentTime > mTotalTime)
			mCurrentTime = mTotalTime;
		
		if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
		{
			var maxNumArgs = mArgs.length;
			trace("mArgs = " + mArgs);
			if (mRepeatCount == 0 || mRepeatCount > 1)
			{
				switch (maxNumArgs)
				{
					case 0:  mCall();
					case 1:  mCall(mArgs[0]);
					case 2:  mCall(mArgs[0], mArgs[1]);
					case 3:  mCall(mArgs[0], mArgs[1], mArgs[2]);
					case 4:  mCall(mArgs[0], mArgs[1], mArgs[2], mArgs[3]);
					case 5:  mCall(mArgs[0], mArgs[1], mArgs[2], mArgs[3], mArgs[4]);
					case 6:  mCall(mArgs[0], mArgs[1], mArgs[2], mArgs[3], mArgs[4], mArgs[5]);
					case 7:  mCall(mArgs[0], mArgs[1], mArgs[2], mArgs[3], mArgs[4], mArgs[5], mArgs[6]);
					//default: mCall.apply(null, mArgs.slice(0, maxNumArgs));
				}
				
				if (mRepeatCount > 0) mRepeatCount -= 1;
				mCurrentTime = 0;
				advanceTime((previousTime + time) - mTotalTime);
			}
			else
			{
				// save call & args: they might be changed through an event listener
				var call:Function = mCall;
				var args:Array<Dynamic> = mArgs;
				
				// in the callback, people might want to call "reset" and re-add it to the
				// juggler; so this event has to be dispatched *before* executing 'call'.
				dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				
				switch (maxNumArgs)
				{
					case 0:  call();
					case 1:  call(args[0]);
					case 2:  call(args[0], args[1]);
					case 3:  call(args[0], args[1], args[2]);
					case 4:  call(args[0], args[1], args[2], args[3]);
					case 5:  call(args[0], args[1], args[2], args[3], args[4]);
					case 6:  call(args[0], args[1], args[2], args[3], args[4], args[5]);
					case 7:  call(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
					//default: call.apply(null, args.slice(0, maxNumArgs));
				}
			}
		}
	}

	/** Advances the delayed call so that it is executed right away. If 'repeatCount' is
	  * anything else than '1', this method will complete only the current iteration. */
	public function complete():Void
	{
		var restTime:Float = mTotalTime - mCurrentTime;
		if (restTime > 0) advanceTime(restTime);
	}
	
	/** Indicates if enough time has passed, and the call has already been executed. */
	private function get_isComplete():Bool 
	{ 
		return mRepeatCount == 1 && mCurrentTime >= mTotalTime; 
	}
	
	/** The time for which calls will be delayed (in seconds). */
	private function get_totalTime():Float { return mTotalTime; }
	
	/** The time that has already passed (in seconds). */
	private function get_currentTime():Float { return mCurrentTime; }
	
	/** The number of times the call will be repeated. 
	 *  Set to '0' to repeat indefinitely. @default 1 */
	private function get_repeatCount():Int { return mRepeatCount; }
	private function set_repeatCount(value:Int):Int
	{
		mRepeatCount = value;
		return value;
	}
	
	// delayed call pooling
	
	private static var sPool = new Array<DelayedCall>();
	
	/** @private */
	//starling_internal
	public static function fromPool(call:Function, delay:Float, args:Array<Dynamic>=null):DelayedCall
	{
		if (sPool.length > 0) return sPool.pop().reset(call, delay, args);
		else return new DelayedCall(call, delay, args);
	}
	
	/** @private */
	//starling_internal
	public static function toPool(delayedCall:DelayedCall):Void
	{
		// reset any object-references, to make sure we don't prevent any garbage collection
		delayedCall.mCall = null;
		delayedCall.mArgs = null;
		delayedCall.removeEventListeners();
		sPool.push(delayedCall);
	}
}

typedef Function = Dynamic;