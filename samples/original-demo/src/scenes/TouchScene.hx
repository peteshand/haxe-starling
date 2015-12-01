package scenes;

import openfl.Assets;
import starling.display.Image;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.StarlingUtils;

import utils.TouchSheet;

class TouchScene extends Scene
{
	public function new()
	{
		super();
		
		var description:String = "[use Ctrl/Cmd & Shift to simulate multi-touch]";
		
		var infoText:TextField = new TextField(300, 25, description);
		infoText.x = infoText.y = 10;
		addChild(infoText);
		
		// to find out how to react to touch events have a look at the TouchSheet class! 
		// It's part of the demo.
		
		var texture:Texture = Game.assets.getTexture("starling_sheet");
		//var texture:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/textures/Untitled.png"));
		//var texture:Texture = Texture.fromColor(256, 256, 0xFFFF0055);
		var image = new Image(texture);
		
		//image.smoothing = TextureSmoothing.TRILINEAR;
		
		var sheet:TouchSheet = new TouchSheet(image);
		sheet.x = Constants.CenterX;
		sheet.y = Constants.CenterY;
		
		addChild(sheet);
	}
}