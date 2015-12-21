package;


import openfl.Assets;
import openfl.display.BitmapData;
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
import starling.events.Touch;

import starling.core.Starling;
import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.VAlign;

class MainMenu extends Sprite
{
	public function new()
	{
		super();
		init();
	}
	
	private function init():Void
	{
		var logo:Image = new Image(Game.assets.getTexture("logo"));
		addChild(logo);
		
		#if flash
			var scenesToCreate:Array<Dynamic> = [
				["Textures", TextureScene, true],
				["Multitouch", TouchScene, true],
				["TextFields", TextScene, true],
				["Animations", AnimationScene, true],
				["Custom hit-test", CustomHitTestScene, true],
				["Movie Clip", MovieScene, true],
				["Filters", FilterScene, true],
				["Blend Modes", BlendModeScene, true],
				["Render Texture", RenderTextureScene, true],
				["Benchmark", BenchmarkScene, true],
				//["Batch Benchmark", BatchBenchmarkScene, true],
				["Masks", MaskScene, true],
				["Sprite 3D", Sprite3DScene, true]
			];
		#elseif html5
			var scenesToCreate:Array<Dynamic> = [
				["Textures", TextureScene, true],
				["Multitouch", TouchScene, true],
				["TextFields", TextScene, true],
				["Animations", AnimationScene, true],
				["Custom hit-test", CustomHitTestScene, true],
				["Movie Clip", MovieScene, true],
				["Filters", FilterScene, true],
				["Blend Modes", BlendModeScene, true],
				["Render Texture", RenderTextureScene, true],
				["Benchmark", BenchmarkScene, true],
				//["Batch Benchmark", BatchBenchmarkScene, true],
				["Masks", MaskScene, true],
				["Sprite 3D", Sprite3DScene, true]
			];
		#elseif cpp
			var scenesToCreate:Array<Dynamic> = [
				["Textures", TextureScene, true],
				["Multitouch", TouchScene, true],
				["TextFields", TextScene, true],
				["Animations", AnimationScene, true],
				["Custom hit-test", CustomHitTestScene, true],
				["Movie Clip", MovieScene, true],
				["Filters", FilterScene, false],
				["Blend Modes", BlendModeScene, true],
				["Render Texture", RenderTextureScene, false],
				["Benchmark", BenchmarkScene, true],
				["Masks", MaskScene, true],
				["Sprite 3D", Sprite3DScene, true]
			];
		#end
		
		
		
		var buttonTexture:Texture = Game.assets.getTexture("button_medium");
		
		var count:Int = 0;
		
		for (sceneToCreate in scenesToCreate)
		{
			var sceneTitle:String = sceneToCreate[0];
			//var sceneClass:Class<Dynamic>  = sceneToCreate[1];
			var active:Bool = sceneToCreate[2];
			
			var button:Button = new Button(buttonTexture, sceneTitle);
			button.x = Math.round(count % 2 == 0 ? 28 : 167);
			button.y = Math.round(155 + Math.floor(count / 2) * 46);
			button.name = sceneTitle;
			addChild(button);
			button.touchable = active;
			if (active == false) button.alpha = 0.4;
			
			if (scenesToCreate.length % 2 != 0 && count % 2 == 1)
				button.y += 24;
			
			++count;
		}
		
		// show information about rendering method (hardware/software)
		
		
		var driverInfo:String = Starling.current.context.driverInfo;
		#if html5
		// uncomment once lime has made pull request https://github.com/openfl/lime/pull/434
		if (driverInfo == null) driverInfo = "OpenGL";
		#end
		var infoText:TextField = new TextField(310, 64, driverInfo, "Verdana", 10);
		infoText.x = 5;
		infoText.y = 475 - infoText.height;
		infoText.vAlign = VAlign.BOTTOM;
		infoText.addEventListener(TouchEvent.TOUCH, onInfoTextTouched);
		addChildAt(infoText, 0);
	}
	
	private function onInfoTextTouched(event:TouchEvent):Void
	{
		#if !html5
		var endTouch:Touch = event.getTouch(this, TouchPhase.BEGAN);
		if (endTouch != null) {
			Starling.current.showStats = !Starling.current.showStats;
		}
		#end
	}
}
