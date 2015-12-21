package;

import flash.system.System;
import flash.ui.Keyboard;
import openfl.Assets;
import scenes.AnimationScene;
import scenes.BatchBenchmarkScene;
import scenes.BenchmarkScene;
import scenes.BlendModeScene;
import scenes.CustomHitTestScene;
import scenes.FilterScene;
import scenes.MaskScene;
import scenes.MovieScene;
import scenes.RenderTextureScene;
import scenes.Sprite3DScene;
import scenes.TextScene;
import scenes.TextureScene;
import scenes.TouchScene;
import starling.textures.Texture;

import scenes.Scene;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.utils.AssetManager;

class Game extends Sprite
{
	// Embed the Ubuntu Font. Beware: the 'embedAsCFF'-part IS REQUIRED!!!
	//[Embed(source="../../demo/assets/fonts/Ubuntu-R.ttf", embedAsCFF="false", fontFamily="Ubuntu")]
	//private static var UbuntuRegular:Class;
	
	private var mMainMenu:MainMenu;
	private var mCurrentScene:Scene;
	
	private static var sAssets:AssetManager;
	public static var assets(get, null):AssetManager;
	
	private var sceneMap:Map<String, Class<Dynamic>>;
	private var sceneInstanceMap:Map<String, Scene>;
	
	public function new()
	{
		super();
		
		sceneMap = new Map<String, Class<Dynamic>>();
		sceneMap["Textures"] = TextureScene;
		sceneMap["Multitouch"] = TouchScene;
		sceneMap["TextFields"] = TextScene;
		sceneMap["Animations"] = AnimationScene;
		sceneMap["Custom hit-test"] = CustomHitTestScene;
		sceneMap["Movie Clip"] = MovieScene;
		sceneMap["Filters"] = FilterScene;
		sceneMap["Blend Modes"] = BlendModeScene;
		sceneMap["Render Texture"] = RenderTextureScene;
		sceneMap["Benchmark"] = BenchmarkScene;
		sceneMap["Batch Benchmark"] = BatchBenchmarkScene;
		sceneMap["Masks"] = MaskScene;
		sceneMap["Sprite 3D"] = Sprite3DScene;
		
		sceneInstanceMap = new Map<String, Scene>();
		
		// nothing to do here -- Startup will call "start" immediately.
		
	}
	
	public function start(assets:AssetManager):Void
	{
		sAssets = assets;
		
		//this.stage.color = 0xFFFF0000;
		var texture:starling.textures.Texture = assets.getTexture('background');
		var backgroundImage:Image = new Image(texture);
		addChild(backgroundImage);
		showMainMenu();
		
		backgroundImage.scaleX = Starling.current.nativeStage.stageWidth / 320;
		backgroundImage.scaleY = Starling.current.nativeStage.stageHeight / 480;
		
		/*var bmd:BitmapData = Assets.getBitmapData("assets/textures/1x/background.jpg");
		var texture:starling.textures.Texture = starling.textures.Texture.fromBitmapData(bmd);
		addChild(new Image(texture));
		showMainMenu();*/
		
		addEventListener(Event.TRIGGERED, onButtonTriggered);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
	}
	
	private function showMainMenu():Void
	{
		// now would be a good time for a clean-up 
		#if flash
			System.pauseForGCIfCollectionImminent(0);
		#end
		System.gc();
		
		if (mMainMenu == null)
			mMainMenu = new MainMenu();
		
		addChild(mMainMenu);
		
		mMainMenu.scaleX = mMainMenu.scaleY = Starling.current.nativeStage.stageWidth / 320;
	}
	
	private function onKey(event:KeyboardEvent):Void
	{
		if (event.keyCode == Keyboard.SPACE)
			Starling.current.showStats = !Starling.current.showStats;
		else if (event.keyCode == Keyboard.X)
			Starling.current.context.dispose();
	}
	
	private function onButtonTriggered(event:Event):Void
	{
		var button:Button = cast event.target;
		
		if (button.name == "backButton")
			closeScene();
		else if (button.name != "modeDraw" && button.name != "startBenchmark" && button.name != "switchBlend" && button.name != "switchFilers" && button.name != "startAnimation" && button.name != "delayedCall" && button.name != "customHit")
			showScene(button.name);
	}
	
	private function closeScene():Void
	{
		if (mCurrentScene.parent != null) {
			mCurrentScene.parent.removeChild(mCurrentScene);
		}
		//mCurrentScene.removeFromParent(true);
		//mCurrentScene = null;
		showMainMenu();
	}
	
	private function showScene(name:String):Void
	{
		if (sceneInstanceMap.get(name) == null) {
			var sceneClass:Class<Dynamic> = sceneMap.get(name);
			mCurrentScene = Type.createInstance(sceneClass, []);
			sceneInstanceMap[name] = mCurrentScene;
		}
		else {
			mCurrentScene = sceneInstanceMap.get(name);
		}
		mMainMenu.removeFromParent();
		addChild(mCurrentScene);
		mCurrentScene.scaleX = mCurrentScene.scaleY = Starling.current.nativeStage.stageWidth / 320;
	}
	
	public static function get_assets():AssetManager { return sAssets; }
}