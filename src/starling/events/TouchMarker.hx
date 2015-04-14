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

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Point;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

/** The TouchMarker is used internally to mark touches created through "simulateMultitouch". */
/*internal*/
class TouchMarker extends Sprite
{
	private var mCenter:Point;
	private var mTexture:Texture;
	
	private var realMarker(get, null):Image;
	private var mockMarker(get, null):Image;
	
	public var realX(get, null):Float;
	public var realY(get, null):Float;
	public var mockX(get, null):Float;
	public var mockY(get, null):Float;
	
	public function new()
	{
		super();
		
		mCenter = new Point();
		mTexture = createTexture();
		
		for (i in 0...2)
		{
			var marker:Image = new Image(mTexture);
			marker.pivotX = mTexture.width / 2;
			marker.pivotY = mTexture.height / 2;
			marker.touchable = false;
			addChild(marker);
		}
	}
	
	public override function dispose():Void
	{
		mTexture.dispose();
		super.dispose();
	}
	
	public function moveMarker(x:Float, y:Float, withCenter:Bool=false):Void
	{
		if (withCenter)
		{
			mCenter.x += x - realMarker.x;
			mCenter.y += y - realMarker.y;
		}
		
		realMarker.x = x;
		realMarker.y = y;
		mockMarker.x = 2*mCenter.x - x;
		mockMarker.y = 2*mCenter.y - y;
	}
	
	public function moveCenter(x:Float, y:Float):Void
	{
		mCenter.x = x;
		mCenter.y = y;
		moveMarker(realX, realY); // reset mock position
	}
	
	private function createTexture():Texture
	{
		var scale:Float = Starling.ContentScaleFactor;
		var radius:Float = 12 * scale;
		var width:Int = Std.int (32 * scale);
		var height:Int = Std.int (32 * scale);
		var thickness:Float = 1.5 * scale;
		var shape:Shape = new Shape();
		
		// draw dark outline
		shape.graphics.lineStyle(thickness, 0x0, 0.3);
		shape.graphics.drawCircle(width/2, height/2, radius + thickness);
		
		// draw white inner circle
		shape.graphics.beginFill(0xffffff, 0.4);
		shape.graphics.lineStyle(thickness, 0xffffff);
		shape.graphics.drawCircle(width/2, height/2, radius);
		shape.graphics.endFill();
		
		var bmpData:BitmapData = new BitmapData(width, height, true, 0x0);
		bmpData.draw(shape);
		
		return Texture.fromBitmapData(bmpData, false, false, scale);
	}
	
	private function get_realMarker():Image { return cast getChildAt(0); }
	private function get_mockMarker():Image { return cast getChildAt(1); }
	
	private function get_realX():Float { return realMarker.x; }
	private function get_realY():Float { return realMarker.y; }
	
	private function get_mockX():Float { return mockMarker.x; }
	private function get_mockY():Float { return mockMarker.y; }
}