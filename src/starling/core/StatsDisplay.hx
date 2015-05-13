// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.core;

import openfl.system.System;

import starling.display.BlendMode;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;

/** A small, lightweight box that displays the current framerate, memory consumption and
 *  the number of draw calls per frame. The display is updated automatically once per frame. */
/*internal*/
class StatsDisplay extends Sprite
{
	private var UPDATE_INTERVAL:Float = 0.5;
	
	private var mBackground:Quad;
	private var mTextField:TextField;
	
	private var mFrameCount:Int = 0;
	private var mTotalTime:Float = 0;
	
	private var mFps:Float = 0;
	private var mMemory:Float = 0;
	private var mDrawCount:Int = 0;
	
	public var drawCount(get, set):Int;
	public var fps(get, set):Float;
	public var memory(get, set):Float;
	
	/** Creates a new Statistics Box. */
	public function new()
	{
		super();
		mBackground = new Quad(50, 25, 0x0);
		mTextField = new TextField(48, 25, "", BitmapFont.MINI, BitmapFont.NATIVE_SIZE, 0xffffff);
		mTextField.x = 2;
		mTextField.hAlign = HAlign.LEFT;
		mTextField.vAlign = VAlign.TOP;
		
		addChild(mBackground);
		addChild(mTextField);
		
		blendMode = BlendMode.NONE;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	private function onAddedToStage():Void
	{
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		mTotalTime = mFrameCount = 0;
		update();
	}
	
	private function onRemovedFromStage():Void
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(event:EnterFrameEvent):Void
	{
		mTotalTime += event.passedTime;
		mFrameCount++;
		if (mTotalTime > UPDATE_INTERVAL)
		{
			update();
			mFrameCount = 0;
			mTotalTime = 0;
		}
	}
	
	/** Updates the displayed values. */
	public function update():Void
	{
		mFps = mTotalTime > 0 ? mFrameCount / mTotalTime : 0;
		mMemory = System.totalMemory * 0.000000954; // 1.0 / (1024*1024) to convert to MB
		
		mTextField.text = "FPS: " + Math.floor(mFps) + 
						"\nMEM: " + Math.floor(mMemory) +
						"\nDRW: " + (mTotalTime > 0 ? mDrawCount-2 : mDrawCount); // ignore self 
	}
	
	public override function render(support:RenderSupport, parentAlpha:Float):Void
	{
		// The display should always be rendered with two draw calls, so that we can
		// always reduce the draw count by that number to get the number produced by the 
		// actual content.
		
		support.finishQuadBatch();
		super.render(support, parentAlpha);
	}
	
	/** The number of Stage3D draw calls per second. */
	private function get_drawCount():Int { return mDrawCount; }
	private function set_drawCount(value:Int):Int
	{
		mDrawCount = value;
		return value;
	}
	
	/** The current frames per second (updated twice per second). */
	private function get_fps():Float { return mFps; }
	private function set_fps(value:Float):Float
	{
		mFps = value;
		return value;
	}
	
	/** The currently required system memory in MB. */
	private function get_memory():Float { return mMemory; }
	private function set_memory(value:Float):Float
	{
		mMemory = value;
		return value;
	}
}