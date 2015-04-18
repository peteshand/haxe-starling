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

import haxe.Constraints;
import haxe.Constraints.Function;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.Vector;
import starling.events.Event;
import starling.events.EventDispatcher;

/** A Tween animates numeric properties of objects. It uses different transition functions
 *  to give the animations various styles.
 *  
 *  <p>The primary use of this class is to do standard animations like movement, fading, 
 *  rotation, etc. But there are no limits on what to animate; as long as the property you want
 *  to animate is numeric (<code>Int, UInt, Float</code>), the tween can handle it. For a list 
 *  of available Transition types, look at the "Transitions" class.</p> 
 *  
 *  <p>Here is an example of a tween that moves an object to the right, rotates it, and 
 *  fades it out:</p>
 *  
 *  <listing>
 *  var tween:Tween = new Tween(object, 2.0, Transitions.EASE_IN_OUT);
 *  tween.animate("x", object.x + 50);
 *  tween.animate("rotation", deg2rad(45));
 *  tween.fadeTo(0);    // equivalent to 'animate("alpha", 0)'
 *  Starling.Juggler.add(tween);</listing> 
 *  
 *  <p>Note that the object is added to a juggler at the end of this sample. That's because a 
 *  tween will only be executed if its "advanceTime" method is executed regularly - the 
 *  juggler will do that for you, and will remove the tween when it is finished.</p>
 *  
 *  @see Juggler
 *  @see Transitions
 */ 
class Tween extends EventDispatcher implements IAnimatable
{
	private static var HINT_MARKER:String = '#';

	private var mTarget:Dynamic;
	private var mTransitionFunc:Function;
	private var mTransitionName:String;
	
	private var mProperties:Vector<String>;
	private var mStartValues:Vector<Float>;
	private var mEndValues:Vector<Float>;
	private var mUpdateFuncs:Vector<Function>;

	private var mOnStart:Function;
	private var mOnUpdate:Function;
	private var mOnRepeat:Function;
	private var mOnComplete:Function;
	
	private var mOnStartArgs:Array<Dynamic>;
	private var mOnUpdateArgs:Array<Dynamic>;
	private var mOnRepeatArgs:Array<Dynamic>;
	private var mOnCompleteArgs:Array<Dynamic>;
	
	private var mTotalTime:Float;
	private var mCurrentTime:Float;
	private var mProgress:Float;
	private var mDelay:Float;
	private var mRoundToInt:Bool;
	private var mNextTween:Tween;
	private var mRepeatCount:Int;
	private var mRepeatDelay:Float;
	private var mReverse:Bool;
	private var mCurrentCycle:Int;
	
	public var isComplete(get, null):Bool;
	public var target(get, null):Dynamic;
	public var transition(get, set):String;
	public var transitionFunc(get, set):Function;
	public var totalTime(get, null):Float;
	public var currentTime(get, null):Float;
	public var progress(get, null):Float;
	public var delay(get, set):Float;
	public var repeatCount(get, set):Int;
	public var repeatDelay(get, set):Float;
	public var reverse(get, set):Bool;
	public var roundToInt(get, set):Bool;
	public var onStart(get, set):Function;
	public var onUpdate(get, set):Function;
	public var onRepeat(get, set):Function;
	public var onComplete(get, set):Function;
	public var onStartArgs(get, set):Array<Dynamic>;
	public var onUpdateArgs(get, set):Array<Dynamic>;
	public var onRepeatArgs(get, set):Array<Dynamic>;
	public var onCompleteArgs(get, set):Array<Dynamic>;
	public var nextTween(get, set):Tween;
	
	/** Creates a tween with a target, duration (in seconds) and a transition function.
	 *  @param target the object that you want to animate
	 *  @param time the duration of the Tween (in seconds)
	 *  @param transition can be either a String (e.g. one of the constants defined in the
	 *         Transitions class) or a function. Look up the 'Transitions' class for a   
	 *         documentation about the required function signature. */ 
	public function new(target:Dynamic, time:Float, transition:Dynamic="linear")        
	{
		super();
		reset(target, time, transition);
	}

	/** Resets the tween to its default values. Useful for pooling tweens. */
	public function reset(target:Dynamic, time:Float, transition:Dynamic="linear"):Tween
	{
		mTarget = target;
		mCurrentTime = 0.0;
		mTotalTime = Math.max(0.0001, time);
		mProgress = 0.0;
		mDelay = mRepeatDelay = 0.0;
		mOnStart = mOnUpdate = mOnRepeat = mOnComplete = null;
		mOnStartArgs = mOnUpdateArgs = mOnRepeatArgs = mOnCompleteArgs = null;
		mRoundToInt = mReverse = false;
		mRepeatCount = 1;
		mCurrentCycle = -1;
		mNextTween = null;
		
		if (Std.is(transition, String))
			this.transition = cast transition;
		else if (Reflect.isFunction(transition))
			this.transitionFunc = cast transition;
		else 
			throw new ArgumentError("Transition must be either a string or a function");
		
		if (mProperties != null)  mProperties.length  = 0; else mProperties  = new Vector<String>();
		if (mStartValues != null) mStartValues.length = 0; else mStartValues = new Vector<Float>();
		if (mEndValues != null)   mEndValues.length   = 0; else mEndValues   = new Vector<Float>();
		if (mUpdateFuncs != null) mUpdateFuncs.length = 0; else mUpdateFuncs = new Vector<Function>();
		
		return this;
	}
	
	/** Animates the property of the target to a certain value. You can call this method
	 *  multiple times on one tween.
	 *
	 *  <p>Some property types are handled in a special way:</p>
	 *  <ul>
	 *    <li>If the property contains the string <code>color</code> or <code>Color</code>,
	 *        it will be treated as an unsigned integer with a color value
	 *        (e.g. <code>0xff0000</code> for red). Each color channel will be animated
	 *        individually.</li>
	 *    <li>The same happens if you append the string <code>#rgb</code> to the name.</li>
	 *    <li>If you append <code>#rad</code>, the property is treated as an angle in radians,
	 *        making sure it always uses the shortest possible arc for the rotation.</li>
	 *    <li>The string <code>#deg</code> does the same for angles in degrees.</li>
	 *  </ul>
	 */
	public function animate(property:String, endValue:Float):Void
	{
		if (mTarget == null) return; // tweening null just does nothing.

		var pos:Int = mProperties.length;
		var updateFunc:Function = getUpdateFuncFromProperty(property);

		mProperties[pos] = getPropertyName(property);
		mStartValues[pos] = Math.NaN;
		mEndValues[pos] = endValue;
		mUpdateFuncs[pos] = updateFunc;
	}

	/** Animates the 'scaleX' and 'scaleY' properties of an object simultaneously. */
	public function scaleTo(factor:Float):Void
	{
		animate("scaleX", factor);
		animate("scaleY", factor);
	}
	
	/** Animates the 'x' and 'y' properties of an object simultaneously. */
	public function moveTo(x:Float, y:Float):Void
	{
		animate("x", x);
		animate("y", y);
	}
	
	/** Animates the 'alpha' property of an object to a certain target value. */ 
	public function fadeTo(alpha:Float):Void
	{
		animate("alpha", alpha);
	}

	/** Animates the 'rotation' property of an object to a certain target value, using the
	 *  smallest possible arc. 'type' may be either 'rad' or 'deg', depending on the unit of
	 *  measurement. */
	public function rotateTo(angle:Float, type:String="rad"):Void
	{
		animate("rotation#" + type, angle);
	}
	
	/** @inheritDoc */
	public function advanceTime(time:Float):Void
	{
		if (time == 0 || (mRepeatCount == 1 && mCurrentTime == mTotalTime)) return;
		
		var i:Int;
		var previousTime:Float = mCurrentTime;
		var restTime:Float = mTotalTime - mCurrentTime;
		var carryOverTime:Float = time > restTime ? time - restTime : 0.0;
		
		mCurrentTime += time;
		
		if (mCurrentTime <= 0) 
			return; // the delay is not over yet
		else if (mCurrentTime > mTotalTime) 
			mCurrentTime = mTotalTime;
		
		if (mCurrentCycle < 0 && previousTime <= 0 && mCurrentTime > 0)
		{
			mCurrentCycle++;
			if (mOnStart != null) Reflect.callMethod(this, mOnStart, mOnStartArgs);
		}

		var ratio:Float = mCurrentTime / mTotalTime;
		var reversed:Bool = mReverse && (mCurrentCycle % 2 == 1);
		var numProperties:Int = mStartValues.length;
		
		
		
		
		//mProgress = reversed ? mTransitionFunc(1.0 - ratio) : mTransitionFunc(ratio);
		mProgress = reversed ? Reflect.callMethod(this, mTransitionFunc, [1.0 - ratio]) : Reflect.callMethod(this, mTransitionFunc, [ratio]);
		
		for (i in 0...numProperties)
		{
			if (mStartValues[i] != mStartValues[i]) { // isNaN check - "isNaN" causes allocation! 
				mStartValues[i] = cast Reflect.getProperty(mTarget, mProperties[i]);
				
			}
			updateFunc = cast mUpdateFuncs[i];
			Reflect.callMethod(this, updateFunc, [mProperties[i], mStartValues[i], mEndValues[i]]);
		}
		
		if (mOnUpdate != null) 
			Reflect.callMethod(this, mOnUpdate, mOnUpdateArgs);
		
		if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
		{
			if (mRepeatCount == 0 || mRepeatCount > 1)
			{
				mCurrentTime = -mRepeatDelay;
				mCurrentCycle++;
				if (mRepeatCount > 1) mRepeatCount--;
				if (mOnRepeat != null) Reflect.callMethod(this, mOnRepeat, mOnRepeatArgs);
			}
			else
			{
				// save callback & args: they might be changed through an event listener
				var onComplete:Function = mOnComplete;
				var onCompleteArgs:Array<Dynamic> = mOnCompleteArgs;
				
				// in the 'onComplete' callback, people might want to call "tween.reset" and
				// add it to another juggler; so this event has to be dispatched *before*
				// executing 'onComplete'.
				dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
				if (onComplete != null) Reflect.callMethod(this, onComplete, onCompleteArgs);
			}
		}
		
		//trace("CHECK");
		#if js
		if (carryOverTime != null) // if (carryOverTime)
		#else
		if (Math.isNaN(carryOverTime)) 
		#end
		{
			advanceTime(carryOverTime);
		}
	}

	// animation hints

	private function getUpdateFuncFromProperty(property:String):Function
	{
		var updateFunc:Function;
		var hint:String = getPropertyHint(property);

		switch (hint)
		{
			case null:  updateFunc = updateStandard;
			case "rgb": updateFunc = updateRgb;
			case "rad": updateFunc = updateRad;
			case "deg": updateFunc = updateDeg;
			default:
				trace("[Starling] Ignoring unknown property hint:", hint);
				updateFunc = updateStandard;
		}

		return updateFunc;
	}

	/** @private */
	/*internal*/
	public static function getPropertyHint(property:String):String
	{
		// colorization is special; it does not require a hint marker, just the word 'color'.
		if (property.indexOf("color") != -1 || property.indexOf("Color") != -1)
			return "rgb";

		var hintMarkerIndex:Int = property.indexOf(HINT_MARKER);
		if (hintMarkerIndex != -1) return property.substr(hintMarkerIndex+1);
		else return null;
	}

	/** @private */
	/*internal*/
	public static function getPropertyName(property:String):String
	{
		var hintMarkerIndex:Int = property.indexOf(HINT_MARKER);
		if (hintMarkerIndex != -1) return property.substring(0, hintMarkerIndex);
		else return property;
	}

	private function updateStandard(property:String, startValue:Float, endValue:Float):Void
	{
		var newValue:Float = startValue + mProgress * (endValue - startValue);
		if (mRoundToInt) newValue = Math.round(newValue);
		try {
			Reflect.setProperty(mTarget, property, newValue); //mTarget[property] = newValue; 
		}
		catch (e:Error) {}
	}

	private function updateRgb(property:String, startValue:Float, endValue:Float):Void
	{
		var startColor:UInt = cast startValue;
		var endColor:UInt   = cast endValue;

		var startA:UInt = (startColor >> 24) & 0xff;
		var startR:UInt = (startColor >> 16) & 0xff;
		var startG:UInt = (startColor >>  8) & 0xff;
		var startB:UInt = (startColor      ) & 0xff;

		var endA:UInt = (endColor >> 24) & 0xff;
		var endR:UInt = (endColor >> 16) & 0xff;
		var endG:UInt = (endColor >>  8) & 0xff;
		var endB:UInt = (endColor      ) & 0xff;

		var newA:UInt = cast (startA + (endA - startA) * mProgress);
		var newR:UInt = cast (startR + (endR - startR) * mProgress);
		var newG:UInt = cast (startG + (endG - startG) * mProgress);
		var newB:UInt = cast (startB + (endB - startB) * mProgress);
		
		trace("CHECK");
		Reflect.setProperty(mTarget, property, (newA << 24) | (newR << 16) | (newG << 8) | newB);// mTarget[property] = (newA << 24) | (newR << 16) | (newG << 8) | newB;
	}

	private function updateRad(property:String, startValue:Float, endValue:Float):Void
	{
		updateAngle(Math.PI, property, startValue, endValue);
	}

	private function updateDeg(property:String, startValue:Float, endValue:Float):Void
	{
		updateAngle(180, property, startValue, endValue);
	}

	private function updateAngle(pi:Float, property:String, startValue:Float, endValue:Float):Void
	{
		while (Math.abs(endValue - startValue) > pi)
		{
			if (startValue < endValue) endValue -= 2.0 * pi;
			else                       endValue += 2.0 * pi;
		}

		updateStandard(property, startValue, endValue);
	}
	
	/** The end value a certain property is animated to. Throws an ArgumentError if the 
	 *  property is not being animated. */
	public function getEndValue(property:String):Float
	{
		var index:Int = mProperties.indexOf(property);
		if (index == -1) throw new ArgumentError("The property '" + property + "' is not animated");
		else return cast mEndValues[index];
	}
	
	/** Indicates if the tween is finished. */
	private function get_isComplete():Bool 
	{ 
		return mCurrentTime >= mTotalTime && mRepeatCount == 1; 
	}        
	
	/** The target object that is animated. */
	private function get_target():Dynamic { return mTarget; }
	
	/** The transition method used for the animation. @see Transitions */
	private function get_transition():String { return mTransitionName; }
	private function set_transition(value:String):String 
	{ 
		mTransitionName = value;
		mTransitionFunc = Transitions.getTransition(value);
		
		if (mTransitionFunc == null)
			throw new ArgumentError("Invalid transiton: " + value);
		return value;
	}
	
	/** The actual transition function used for the animation. */
	private function get_transitionFunc():Function { return mTransitionFunc; }
	private function set_transitionFunc(value:Function):Function
	{
		mTransitionName = "custom";
		mTransitionFunc = value;
		return value;
	}
	
	/** The total time the tween will take per repetition (in seconds). */
	private function get_totalTime():Float { return mTotalTime; }
	
	/** The time that has passed since the tween was created (in seconds). */
	private function get_currentTime():Float { return mCurrentTime; }
	
	/** The current progress between 0 and 1, as calculated by the transition function. */
	private function get_progress():Float { return mProgress; } 
	
	/** The delay before the tween is started (in seconds). @default 0 */
	private function get_delay():Float { return mDelay; }
	private function set_delay(value:Float):Float 
	{ 
		mCurrentTime = mCurrentTime + mDelay - value;
		mDelay = value;
		return value;
	}
	
	/** The number of times the tween will be executed. 
	 *  Set to '0' to tween indefinitely. @default 1 */
	private function get_repeatCount():Int { return mRepeatCount; }
	private function set_repeatCount(value:Int):Int
	{
		mRepeatCount = value;
		return value;
	}
	
	/** The amount of time to wait between repeat cycles (in seconds). @default 0 */
	private function get_repeatDelay():Float { return mRepeatDelay; }
	private function set_repeatDelay(value:Float):Float
	{
		mRepeatDelay = value;
		return value;
	}
	
	/** Indicates if the tween should be reversed when it is repeating. If enabled, 
	 *  every second repetition will be reversed. @default false */
	private function get_reverse():Bool { return mReverse; }
	private function set_reverse(value:Bool):Bool
	{
		mReverse = value;
		return value;
	}
	
	/** Indicates if the numeric values should be cast to Integers. @default false */
	private function get_roundToInt():Bool { return mRoundToInt; }
	private function set_roundToInt(value:Bool):Bool {
		mRoundToInt = value;
		return value;        
	}
	
	/** A function that will be called when the tween starts (after a possible delay). */
	private function get_onStart():Function { return mOnStart; }
	private function set_onStart(value:Function):Function
	{
		mOnStart = value;
		return value;
	}
	
	/** A function that will be called each time the tween is advanced. */
	private function get_onUpdate():Function { return mOnUpdate; }
	private function set_onUpdate(value:Function):Function
	{
		mOnUpdate = value;
		return value;
	}
	
	/** A function that will be called each time the tween finishes one repetition
	 *  (except the last, which will trigger 'onComplete'). */
	private function get_onRepeat():Function { return mOnRepeat; }
	private function set_onRepeat(value:Function):Function
	{
		mOnRepeat = value;
		return value;
	}
	
	/** A function that will be called when the tween is complete. */
	private function get_onComplete():Function { return mOnComplete; }
	private function set_onComplete(value:Function):Function
	{
		mOnComplete = value;
		return value;
	}
	
	/** The arguments that will be passed to the 'onStart' function. */
	private function get_onStartArgs():Array<Dynamic> { return mOnStartArgs; }
	private function set_onStartArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		mOnStartArgs = value;
		return value;
	}
	
	/** The arguments that will be passed to the 'onUpdate' function. */
	private function get_onUpdateArgs():Array<Dynamic> { return mOnUpdateArgs; }
	private function set_onUpdateArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		mOnUpdateArgs = value;
		return value;
	}
	
	/** The arguments that will be passed to the 'onRepeat' function. */
	private function get_onRepeatArgs():Array<Dynamic> { return mOnRepeatArgs; }
	private function set_onRepeatArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		mOnRepeatArgs = value;
		return value;
	}
	
	/** The arguments that will be passed to the 'onComplete' function. */
	private function get_onCompleteArgs():Array<Dynamic> { return mOnCompleteArgs; }
	private function set_onCompleteArgs(value:Array<Dynamic>):Array<Dynamic>
	{
		mOnCompleteArgs = value;
		return value;
	}
	
	/** Another tween that will be started (i.e. added to the same juggler) as soon as 
	 *  this tween is completed. */
	private function get_nextTween():Tween
	{
		return mNextTween;
	}
	
	private function set_nextTween(value:Tween):Tween
	{
		mNextTween = value;
		return value;
	}
	
	// tween pooling
	
	private static var sTweenPool = new Vector<Tween>();
	var updateFunc:Function;
	
	/** @private */
	//starling_internal
	public static function fromPool(target:Dynamic, time:Float, transition:Dynamic="linear"):Tween
	{
		if (sTweenPool.length > 0) return sTweenPool.pop().reset(target, time, transition);
		else return new Tween(target, time, transition);
	}
	
	/** @private */
	//starling_internal
	public static function toPool(tween:Tween):Void
	{
		// reset any object-references, to make sure we don't prevent any garbage collection
		tween.mOnStart = tween.mOnUpdate = tween.mOnRepeat = tween.mOnComplete = null;
		tween.mOnStartArgs = tween.mOnUpdateArgs = tween.mOnRepeatArgs = tween.mOnCompleteArgs = null;
		tween.mTarget = null;
		tween.mTransitionFunc = null;
		tween.removeEventListeners();
		sTweenPool.push(tween);
	}
}

//typedef Function = Dynamic;