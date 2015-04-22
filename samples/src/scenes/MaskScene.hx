package scenes;

import flash.geom.Point;

import starling.core.Starling;
import starling.display.Canvas;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.filters.ColorMatrixFilter;
import starling.text.TextField;

class MaskScene extends Scene
{
	private var mContents:Sprite;
	//private var mMask:Canvas;
	private var mMaskDisplay:Canvas;
	var flightImage:Image;
	
	public function new()
	{
		super();
		mContents = new Sprite();
		addChild(mContents);
		
		var stageWidth:Float  = Starling.current.stage.stageWidth;
		var stageHeight:Float = Starling.current.stage.stageHeight;
		
		var touchQuad:Quad = new Quad(stageWidth, stageHeight, 0xFFFFFFFF);
		touchQuad.alpha = 0.2; // only used to get touch events
		addChildAt(touchQuad, 0);
		
		flightImage = new Image(Game.assets.getTexture("flight_00"));
		flightImage.x = (stageWidth - flightImage.width) / 2;
		flightImage.y = 80;
		mContents.addChild(flightImage);

		// just to prove it works, use a filter on the image.
		var cm:ColorMatrixFilter = new ColorMatrixFilter();
		cm.adjustHue(-0.5);
		//flightImage.filter = cm;
		
		var maskText:TextField = new TextField(256, 128,
			"Move the mouse (or a finger) over the screen to move the mask.");
		maskText.x = (stageWidth - maskText.width) / 2;
		maskText.y = 260;
		maskText.fontSize = 20;
		mContents.addChild(maskText);
		
		trace("MaskScene");
		
		mMaskDisplay = createCircle();
		//mMaskDisplay.alpha = 0.1;
		mMaskDisplay.touchable = false;
		addChild(mMaskDisplay);
		
		mMask = createCircle();
		//mContents.mask = mMask;
		
		addEventListener(TouchEvent.TOUCH, onMaskTouch);
	}
	
	private function onMaskTouch(event:TouchEvent):Void
	{
		var touch:Touch = null;
		var hoverTouch:Touch = event.getTouch(this, TouchPhase.HOVER);
		if (hoverTouch != null) touch = hoverTouch;
		var beginTouch:Touch = event.getTouch(this, TouchPhase.BEGAN);
		if (beginTouch != null) touch = beginTouch;
		var moveTouch:Touch = event.getTouch(this, TouchPhase.MOVED);
		if (moveTouch != null) touch = moveTouch;
		
		if (touch != null)
		{
			var localPos:Point = touch.getLocation(this);
			mMask.x = mMaskDisplay.x = flightImage.x = localPos.x;
			mMask.y = mMaskDisplay.y = flightImage.y = localPos.y;
		}
	}

	private function createCircle():Canvas
	{
		var circle:Canvas = new Canvas();
		circle.beginFill(0xff0000);
		circle.drawCircle(0, 0, 100);
		circle.endFill();
		return circle;
	}
}