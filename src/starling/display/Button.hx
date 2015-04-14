// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display;

#if js
import js.Browser;
#end
import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;

import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

/** Dispatched when the user triggers the button. Bubbles. */
@:meta(Event(name='triggered', type='starling.events.Event'))

/** A simple button composed of an image and, optionally, text.
 *  
 *  <p>You can use different textures for various states of the button. If you're providing
 *  only an up state, the button is simply scaled a little when it is touched.</p>
 *
 *  <p>In addition, you can overlay text on the button. To customize the text, you can use
 *  properties equivalent to those of the TextField class. Move the text to a certain position
 *  by updating the <code>textBounds</code> property.</p>
 *  
 *  <p>To react on touches on a button, there is special <code>Event.TRIGGERED</code> event.
 *  Use this event instead of normal touch events. That way, users can cancel button
 *  activation by moving the mouse/finger away from the button before releasing.</p>
 */
class Button extends DisplayObjectContainer
{
	private static var MAX_DRAG_DIST:Float = 50;
	
	private var mUpState:Texture;
	private var mDownState:Texture;
	private var mOverState:Texture;
	private var mDisabledState:Texture;
	
	private var mContents:Sprite;
	private var mBody:Image;
	private var mTextField:TextField;
	private var mTextBounds:Rectangle;
	private var mOverlay:Sprite;
	
	private var mScaleWhenDown:Float;
	private var mScaleWhenOver:Float;
	private var mAlphaWhenDisabled:Float;
	private var mEnabled:Bool;
	private var mState:String;
	private var mTriggerBounds:Rectangle;

	
	public var state(get, set):String;
	public var scaleWhenDown(get, set):Float;
	public var scaleWhenOver(get, set):Float;
	public var alphaWhenDisabled(get, set):Float;
	public var enabled(get, set):Bool;
	public var text(get, set):String;
	public var fontName(get, set):String;
	public var fontSize(get, set):Float;
	public var fontColor(get, set):UInt;
	public var fontBold(get, set):Bool;
	public var upState(get, set):Texture;
	public var downState(get, set):Texture;
	public var overState(get, set):Texture;
	public var disabledState(get, set):Texture;
	public var textVAlign(get, set):VAlign;
	public var textHAlign(get, set):HAlign;
	public var textBounds(get, set):Rectangle;
	public var color(get, set):UInt;
	public var overlay(get, null):Sprite;
	
	/** Creates a button with a set of state-textures and (optionally) some text.
	 *  Any state that is left 'null' will display the up-state texture. Beware that all
	 *  state textures should have the same dimensions. */
	public function new(upState:Texture, text:String="", downState:Texture=null,
						   overState:Texture=null, disabledState:Texture=null)
	{
		super();
		if (upState == null) throw new ArgumentError("Texture 'upState' cannot be null");
		
		mUpState = upState;
		mDownState = downState;
		mOverState = overState;
		mDisabledState = disabledState;
		
		mState = ButtonState.UP;
		mBody = new Image(upState);
		mScaleWhenDown = downState != null ? 1.0 : 0.9;
		mScaleWhenOver = 1.0;
		mAlphaWhenDisabled = disabledState != null ? 1.0: 0.5;
		mEnabled = true;
		mUseHandCursor = true;
		mTextBounds = new Rectangle(0, 0, mBody.width, mBody.height);
		
		mContents = new Sprite();
		mContents.addChild(mBody);
		addChild(mContents);
		
		addEventListener(TouchEvent.TOUCH, onButtonTouch);
		
		this.touchGroup = true;
		this.text = text;
	}
	
	/** @inheritDoc */
	public override function dispose():Void
	{
		// text field might be disconnected from parent, so we have to dispose it manually
		if (mTextField != null)
			mTextField.dispose();
		
		super.dispose();
	}
	
	/** Readjusts the dimensions of the button according to its current state texture.
	 *  Call this method to synchronize button and texture size after assigning a texture
	 *  with a different size. Per default, this method also resets the bounds of the
	 *  button's text. */
	public function readjustSize(resetTextBounds:Bool=true):Void
	{
		mBody.readjustSize();

		if (resetTextBounds && mTextField != null)
			textBounds = new Rectangle(0, 0, mBody.width, mBody.height);
	}

	private function createTextField():Void
	{
		if (mTextField == null)
		{
			mTextField = new TextField(cast mTextBounds.width, cast mTextBounds.height, "");
			mTextField.vAlign = VAlign.CENTER;
			mTextField.hAlign = HAlign.CENTER;
			mTextField.touchable = false;
			mTextField.autoScale = true;
			mTextField.batchable = true;
		}
		
		mTextField.width  = mTextBounds.width;
		mTextField.height = mTextBounds.height;
		mTextField.x = mTextBounds.x;
		mTextField.y = mTextBounds.y;
	}
	
	private function onButtonTouch(event:TouchEvent):Void
	{
		#if flash
			var cursor:String = (mUseHandCursor && mEnabled && event.interactsWith(this)) ? 'button' : 'auto';
			Mouse.cursor = cursor;
		#end
		#if js
			var cursor:String = (mUseHandCursor && mEnabled && event.interactsWith(this)) ? 'pointer' : 'auto';
			Browser.document.getElementById("openfl-content").style.cursor = cursor;
		#end
		
		var touch:Touch = event.getTouch(this);
		var isWithinBounds:Bool;
		
		if (!mEnabled)
		{
			return;
		}
		else if (touch == null)
		{
			state = ButtonState.UP;
		}
		else if (touch.phase == TouchPhase.HOVER)
		{
			state = ButtonState.OVER;
		}
		else if (touch.phase == TouchPhase.BEGAN && mState != ButtonState.DOWN)
		{
			mTriggerBounds = getBounds(stage, mTriggerBounds);
			mTriggerBounds.inflate(MAX_DRAG_DIST, MAX_DRAG_DIST);

			state = ButtonState.DOWN;
		}
		else if (touch.phase == TouchPhase.MOVED)
		{
			isWithinBounds = mTriggerBounds.contains(touch.globalX, touch.globalY);

			if (mState == ButtonState.DOWN && !isWithinBounds)
			{
				// reset button when finger is moved too far away ...
				state = ButtonState.UP;
			}
			else if (mState == ButtonState.UP && isWithinBounds)
			{
				// ... and reactivate when the finger moves back into the bounds.
				state = ButtonState.DOWN;
			}
		}
		else if (touch.phase == TouchPhase.ENDED && mState == ButtonState.DOWN)
		{
			state = ButtonState.UP;
			dispatchEventWith(Event.TRIGGERED, true);
		}
	}
	
	/** The current state of the button. The corresponding strings are found
	 *  in the ButtonState class. */
	private function get_state():String { return mState; }
	private function set_state(value:String):String
	{
		mState = value;
		mContents.scaleX = mContents.scaleY = 1.0;

		switch (mState)
		{
			case ButtonState.DOWN:
				setStateTexture(mDownState);
				mContents.scaleX = mContents.scaleY = mScaleWhenDown;
				mContents.x = (1.0 - mScaleWhenDown) / 2.0 * mBody.width;
				mContents.y = (1.0 - mScaleWhenDown) / 2.0 * mBody.height;
			case ButtonState.UP:
				setStateTexture(mUpState);
				mContents.x = mContents.y = 0;
			case ButtonState.OVER:
				setStateTexture(mOverState);
				mContents.scaleX = mContents.scaleY = mScaleWhenOver;
				mContents.x = (1.0 - mScaleWhenOver) / 2.0 * mBody.width;
				mContents.y = (1.0 - mScaleWhenOver) / 2.0 * mBody.height;
			case ButtonState.DISABLED:
				setStateTexture(mDisabledState);
				mContents.x = mContents.y = 0;
			default:
				throw new ArgumentError("Invalid button state: " + mState);
		}
		return value;
	}

	private function setStateTexture(texture:Texture):Void
	{
		mBody.texture = texture != null ? texture : mUpState;
	}

	/** The scale factor of the button on touch. Per default, a button without a down state
	 *  texture will be made slightly smaller, while a button with a down state texture
	 *  remains unscaled. */
	private function get_scaleWhenDown():Float { return mScaleWhenDown; }
	private function set_scaleWhenDown(value:Float):Float
	{
		mScaleWhenDown = value;
		return value;
	}

	/** The scale factor of the button while the mouse cursor hovers over it. @default 1.0 */
	private function get_scaleWhenOver():Float { return mScaleWhenOver; }
	private function set_scaleWhenOver(value:Float):Float
	{
		mScaleWhenOver = value;
		return value;
	}

	/** The alpha value of the button when it is disabled. @default 0.5 */
	private function get_alphaWhenDisabled():Float { return mAlphaWhenDisabled; }
	private function set_alphaWhenDisabled(value:Float):Float
	{
		mAlphaWhenDisabled = value;
		return value;
	}
	
	/** Indicates if the button can be triggered. */
	private function get_enabled():Bool { return mEnabled; }
	private function set_enabled(value:Bool):Bool
	{
		if (mEnabled != value)
		{
			mEnabled = value;
			mContents.alpha = value ? 1.0 : mAlphaWhenDisabled;
			state = value ? ButtonState.UP : ButtonState.DISABLED;
		}
		return value;
	}
	
	/** The text that is displayed on the button. */
	private function get_text():String { return mTextField != null ? mTextField.text : ""; }
	private function set_text(value:String):String
	{
		if (value.length == 0)
		{
			if (mTextField != null)
			{
				mTextField.text = value;
				mTextField.removeFromParent();
			}
		}
		else
		{
			createTextField();
			mTextField.text = value;
			
			if (mTextField.parent == null)
				mContents.addChild(mTextField);
		}
		return value;
	}
	
	/** The name of the font displayed on the button. May be a system font or a registered
	 *  bitmap font. */
	private function get_fontName():String { return mTextField != null ? mTextField.fontName : "Verdana"; }
	private function set_fontName(value:String):String
	{
		createTextField();
		mTextField.fontName = value;
		return value;
	}
	
	/** The size of the font. */
	private function get_fontSize():Float { return mTextField != null ? mTextField.fontSize : 12; }
	private function set_fontSize(value:Float):Float
	{
		createTextField();
		mTextField.fontSize = value;
		return value;
	}
	
	/** The color of the font. */
	private function get_fontColor():UInt { return mTextField != null ? mTextField.color : 0x0; }
	private function set_fontColor(value:UInt):UInt
	{
		createTextField();
		mTextField.color = value;
		return value;
	}
	
	/** Indicates if the font should be bold. */
	private function get_fontBold():Bool { return mTextField != null ? mTextField.bold : false; }
	private function set_fontBold(value:Bool):Bool
	{
		createTextField();
		mTextField.bold = value;
		return value;
	}
	
	/** The texture that is displayed when the button is not being touched. */
	private function get_upState():Texture { return mUpState; }
	private function set_upState(value:Texture):Texture
	{
		if (value == null)
			throw new ArgumentError("Texture 'upState' cannot be null");

		if (mUpState != value)
		{
			mUpState = value;
			if ( mState == ButtonState.UP ||
				(mState == ButtonState.DISABLED && mDisabledState == null) ||
				(mState == ButtonState.DOWN && mDownState == null) ||
				(mState == ButtonState.OVER && mOverState == null))
			{
				setStateTexture(value);
			}
		}
		return value;
	}
	
	/** The texture that is displayed while the button is touched. */
	private function get_downState():Texture { return mDownState; }
	private function set_downState(value:Texture):Texture
	{
		if (mDownState != value)
		{
			mDownState = value;
			if (mState == ButtonState.DOWN) setStateTexture(value);
		}
		return value;
	}

	/** The texture that is displayed while mouse hovers over the button. */
	private function get_overState():Texture { return mOverState; }
	private function set_overState(value:Texture):Texture
	{
		if (mOverState != value)
		{
			mOverState = value;
			if (mState == ButtonState.OVER) setStateTexture(value);
		}
		return value;
	}

	/** The texture that is displayed when the button is disabled. */
	private function get_disabledState():Texture { return mDisabledState; }
	private function set_disabledState(value:Texture):Texture
	{
		if (mDisabledState != value)
		{
			mDisabledState = value;
			if (mState == ButtonState.DISABLED) setStateTexture(value);
		}
		return value;
	}
	
	/** The vertical alignment of the text on the button. */
	private function get_textVAlign():VAlign
	{
		return mTextField != null ? mTextField.vAlign : VAlign.CENTER;
	}
	
	private function set_textVAlign(value:VAlign):VAlign
	{
		createTextField();
		mTextField.vAlign = value;
		return value;
	}
	
	/** The horizontal alignment of the text on the button. */
	private function get_textHAlign():HAlign
	{
		return mTextField != null ? mTextField.hAlign : HAlign.CENTER;
	}
	
	private function set_textHAlign(value:HAlign):HAlign
	{
		createTextField();
		mTextField.hAlign = value;
		return value;
	}
	
	/** The bounds of the textfield on the button. Allows moving the text to a custom position. */
	private function get_textBounds():Rectangle { return mTextBounds.clone(); }
	private function set_textBounds(value:Rectangle):Rectangle
	{
		mTextBounds = value.clone();
		createTextField();
		return value;
	}
	
	/** The color of the button's state image. Just like every image object, each pixel's
	 *  color is multiplied with this value. @default white */
	private function get_color():UInt { return mBody.color; }
	private function set_color(value:UInt):UInt
	{
		mBody.color = value;
		return value;
	}

	/** The overlay sprite is displayed on top of the button contents. It scales with the
	 *  button when pressed. Use it to add additional objects to the button (e.g. an icon). */
	private function get_overlay():Sprite
	{
		if (mOverlay == null)
			mOverlay = new Sprite();

		mContents.addChild(mOverlay); // make sure it's always on top
		return mOverlay;
	}

	/** Indicates if the mouse cursor should transform into a hand while it's over the button. 
	 *  @default true */
	private override function get_useHandCursor():Bool { return mUseHandCursor; }
	private override function set_useHandCursor(value:Bool):Bool
	{
		mUseHandCursor = value;
		return value;
	}
}