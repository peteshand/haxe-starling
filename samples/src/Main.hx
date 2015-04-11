package;

import haxe.Timer;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display3D.Context3DProfile;
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
	
	public function new() 
	{
		super();
		
		if (stage != null) start();
		else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Dynamic):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		start();
	}

	private function start():Void
	{
		// We develop the game in a *fixed* coordinate system of 320x480. The game might
		// then run on a device with a different resolution; for that case, we zoom the
		// viewPort to the optimal size for any display and load the optimal textures.

		Starling.multitouchEnabled = true; // for Multitouch Scene
		Starling.handleLostContext = true; // recommended everywhere when using AssetManager
		RenderTexture.optimizePersistentBuffers = true; // should be safe on Desktop

		mStarling = new Starling(Game, stage, null, null, "auto", "baselineExtended");
		mStarling.antiAliasing = 2;
		mStarling.simulateMultitouch = true;
		//mStarling.enableErrorChecking = Capabilities.isDebugger;
		mStarling.addEventListener(Event.ROOT_CREATED, function():Void
		{
			loadAssets(startGame);
		});

		mStarling.start();
	}

	private function loadAssets(onComplete:Function):Void
	{
		// Our assets are loaded and managed by the 'AssetManager'. To use that class,
		// we first have to enqueue pointers to all assets we want it to load.
		var assets:AssetManager = new AssetManager();
		
		//assets.verbose = Capabilities.isDebugger;
		//assets.enqueue(EmbeddedAssets);
		assets.enqueueWithName(EmbeddedAssets.atlas, "atlas");
		assets.enqueueWithName(EmbeddedAssets.atlas_xml, "atlas_xml");
		assets.enqueueWithName(EmbeddedAssets.background, "background");
		assets.enqueueWithName(EmbeddedAssets.compressed_texture, "compressed_texture");
		assets.enqueueWithName(EmbeddedAssets.desyrel, "desyrel");
		assets.enqueueWithName(EmbeddedAssets.desyrel_fnt, "desyrel_fnt");
		//assets.enqueueWithName(EmbeddedAssets.wing_flap, "wing_flap");
		
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
}

typedef Function = Dynamic -> Void;