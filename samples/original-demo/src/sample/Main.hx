package sample;

import haxe.Timer;
import openfl.display.BitmapData;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import starling.events.EventDispatcher;
import starling.textures.TextureOptions;
import utils.DeviceInfo;

#if js
import js.Browser;
import js.html.CanvasElement;
import js.html.Element;
import js.html.Node;
import js.html.NodeList;
#end

import openfl.events.Event;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display3D.Context3DProfile;
import openfl.events.MouseEvent;
import openfl.Lib;

import starling.core.Starling;
import starling.events.Event;
import starling.textures.RenderTexture;
import starling.utils.AssetManager;

import utils.ProgressBar;

/**
 * ...
 * @author P.J.Shand
 */

class Main extends Sprite 
{
	private var mStarling:Starling;
	public static var _mouseOnStage:Bool = false;
	public static var mouseOnStageDispatcher:EventDispatcher;
	public static var _root:Sprite;
	
	private var mouseOnStage(get, set):Bool;
	
	public function new() 
	{
		super();
		
		Main._root = this;
		Main.mouseOnStageDispatcher = new EventDispatcher();
		
		if (stage != null) start();
		else addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Dynamic):Void
	{
		removeEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
		start();
		
		//var bm:Bitmap = new Bitmap(MiniBitmapFont.getBitmapData());
		//addChild(bm);
	}

	private function start():Void
	{
		// We develop the game in a *fixed* coordinate system of 320x480. The game might
		// then run on a device with a different resolution; for that case, we zoom the
		// viewPort to the optimal size for any display and load the optimal textures.
		
		/*var bmd:BitmapData = Assets.getBitmapData("assets/textures/1x/background.jpg");
		var bm:Bitmap = new Bitmap(bmd);
		addChild(bm);*/
		
		Starling.multitouchEnabled = true; // for Multitouch Scene
		Starling.handleLostContext = true; // recommended everywhere when using AssetManager
		RenderTexture.optimizePersistentBuffers = true; // should be safe on Desktop

		mStarling = new Starling(Game, stage, null, null, "auto", "baselineExtended");
		mStarling.antiAliasing = 2;
		mStarling.simulateMultitouch = false;
		//mStarling.enableErrorChecking = Capabilities.isDebugger;
		mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function():Void
		{
			loadAssets(startGame);
			switchRendering();
		});
		
		mStarling.start();
		
		#if js
		trace("DeviceInfo.isMobile = " + DeviceInfo.isMobile);	
		if (DeviceInfo.isMobile) {
				mouseOnStage = true;
			}
			else {
				var firstElementChild:Element = Browser.document.body.firstElementChild.firstElementChild;
				firstElementChild.onmousemove = onMouseMove;
				firstElementChild.onmouseout = onLeaveHandler;
			}
		#else
			stage.addEventListener(openfl.events.Event.MOUSE_LEAVE, onLeaveHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		#end
	}
	
	private function onMouseMove(e:MouseEvent):Void 
	{
		mouseOnStage = true;
		
	}
	
	private function onLeaveHandler(e:openfl.events.Event):Void 
	{
		mouseOnStage = false;
	}

	private function loadAssets(onComplete:Function):Void
	{
		// Our assets are loaded and managed by the 'AssetManager'. To use that class,
		// we first have to enqueue pointers to all assets we want it to load.
		var assets:AssetManager = new AssetManager();
		
		//assets.verbose = Capabilities.isDebugger;
		//assets.enqueue(EmbeddedAssets);
		assets.enqueueWithName(EmbeddedAssets.atlas, "atlas", new TextureOptions(2));
		assets.enqueueWithName(EmbeddedAssets.atlas_xml, "atlas_xml");
		assets.enqueueWithName(EmbeddedAssets.background, "background");
		assets.enqueueWithName(EmbeddedAssets.compressed_texture, "compressed_texture");
		assets.enqueueWithName(EmbeddedAssets.desyrel, "desyrel", new TextureOptions(2));
		assets.enqueueWithName(EmbeddedAssets.desyrel_fnt, "desyrel_fnt");
		assets.enqueueWithName(EmbeddedAssets.wing_flap, "wing_flap");
		
		// Now, while the AssetManager now contains pointers to all the assets, it actually
		// has not loaded them yet. This happens in the "loadQueue" method; and since this
		// will take a while, we'll update the progress bar accordingly.

		assets.loadQueue(function(ratio:Float):Void
		{
			if (ratio == 1) onComplete(assets);
		});
	}

	private function startGame(assets:AssetManager):Void
	{
		var game:Game = cast mStarling.root;
		game.start(assets);
	}
	
	public function get_mouseOnStage():Bool 
	{
		return Main._mouseOnStage;
	}
	
	public function set_mouseOnStage(value:Bool):Bool 
	{
		if (mouseOnStage == value) return value;
		Main._mouseOnStage = value;
		switchRendering();
		Main.mouseOnStageDispatcher.dispatchEvent(new starling.events.Event(starling.events.Event.CHANGE));
		return value;
	}
	
	private function switchRendering():Void
	{
		if (mouseOnStage) {
			mStarling.start();
			this.graphics.clear();
		}
		else {
			mStarling.stop();
			this.graphics.beginFill(0x000000, 0.8);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
	}
}

typedef Function = Dynamic -> Void;