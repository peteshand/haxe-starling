package;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.Lib;
import openfl.Vector;
import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.core.Starling;
import starling.display.Sprite;
import starling.textures.Texture;

/**
 * ...
 * @author P.J.Shand
 */
@:keepSub
class BunnyMark extends Sprite
{
	public static var instance:BunnyMark;
	
	private var countTextfield:TextField;
    private var pressTextfield:TextField;
    private var bunnyContainer:Sprite;
	private var numBunnies:Int;
	private var incBunnies:Int;
	private var smooth:Bool;
	private var gravity:Float;
	private var bunnies:Vector<Bunny>;
	private var maxX:Int;
	private var minX:Int;
	private var maxY:Int;
	private var minY:Int;
	private var bunnyAsset:BitmapData;
	private var texture:Texture;
	private var pressingAdd:Bool = false;
	private var addCount:Int = -1;
	private var header:Quad;
	private var bunnyColour:UInt = 0xFFFFFF;
	
	public function new() 
	{
		super();
		instance = this;
	}
	
	public function init():Void
	{
		gravity = 0.1;
        incBunnies = 25;
        
		bunnyAsset = Assets.getBitmapData("img/wabbit_alpha.png");
		texture = Texture.fromBitmapData(bunnyAsset);
		
		bunnies = new Vector<Bunny>();
		
		bunnyContainer = new Sprite();
		addChild(bunnyContainer);
		
		header = new Quad(stage.stageWidth, 40, 0xF9F9F9);
		addChild(header);
		
		header.addEventListener(TouchEvent.TOUCH, OnTouch);
		
		createCounter();
        AddBunnies();
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
		OnReize(null);
    }
	
	private function OnMouseUp(e:MouseEvent):Void 
	{
		pressingAdd = false;
	}

    function createCounter()
    {
		countTextfield = new TextField(300, 60, "Bunny Count", "_sans", 12, 0x000000);
		countTextfield.x = maxX - countTextfield.width - 10;
		countTextfield.y = 10;
		countTextfield.hAlign = HAlign.RIGHT;
		countTextfield.vAlign = VAlign.TOP;
		countTextfield.touchable = false;
		addChild(countTextfield);
		
		pressTextfield = new TextField(300, 60, "Press to add more bunnies", "_sans", 12, 0x000000);
		pressTextfield.x = (stage.stageWidth -  pressTextfield.width) / 2;
		pressTextfield.y = 10;
		pressTextfield.hAlign = HAlign.CENTER;
		pressTextfield.vAlign = VAlign.TOP;
		pressTextfield.touchable = false;
		addChild(pressTextfield);
    }
	
	private function OnTouch(e:TouchEvent):Void 
	{
		var touches:Vector<Touch> = e.getTouches(header);
		for (i in 0...touches.length) 
		{
			if (touches[i].phase == TouchPhase.BEGAN) {
				bunnyColour = cast(0xFFFFFF * Math.random());
				pressingAdd = true;
			}
			else if (touches[i].phase == TouchPhase.ENDED) {
				pressingAdd = false;
			}
		}
	}

    private function AddBunnies()
    {
        if (numBunnies >= 1500) incBunnies = 50;
        var more = numBunnies + incBunnies;
		
        var bunny; 
		
        for (i in numBunnies...more)
        {
            bunny = new Bunny(texture);
			bunny.color = bunnyColour;
            bunny.speedX = Math.random() * 2;
            bunny.speedY = (Math.random() * 4) - 2;
            bunny.scale = 0.3 + Math.random();
            bunny.rotation = 15 - Math.random() * 30;
			bunnyContainer.addChild(bunny);
            bunnies.push (bunny);
        }
        numBunnies = more;
		
        OnReize(null);
    }
    
    private function OnReize(e:Event):Void 
    {
        maxX = stage.stageWidth;
		minY = 40;
        maxY = stage.stageHeight;
        countTextfield.text = "Bunnies: " + numBunnies;
        countTextfield.x = maxX - countTextfield.width - 10;
    }
    
    private function enterFrame(e:Event):Void
    {    
		if (pressingAdd) addCount++;
		if (addCount % 10 == 0) {
			AddBunnies();
			addCount++;
		}
		
        var bunny;
        for (i in 0...numBunnies)
        {
            bunny = bunnies[i];
            bunny.x += bunny.speedX;
            bunny.y += bunny.speedY;
            bunny.speedY += gravity;
            
            if (bunny.x > maxX)
            {
                bunny.speedX *= -1;
                bunny.x = maxX;
            }
            else if (bunny.x < minX)
            {
                bunny.speedX *= -1;
                bunny.x = minX;
            }
            if (bunny.y > maxY)
            {
                bunny.speedY *= -0.8;
                bunny.y = maxY;
                if (Math.random() > 0.5) bunny.speedY -= 3 + Math.random() * 4;
            } 
            else if (bunny.y < minY)
            {
                bunny.speedY = 0;
                bunny.y = minY;
            }
        }
	}
}