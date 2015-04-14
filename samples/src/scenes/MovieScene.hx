package scenes;

import flash.media.Sound;
import openfl.Vector;

import starling.core.Starling;
import starling.display.MovieClip;
import starling.events.Event;
import starling.textures.Texture;

class MovieScene extends Scene
{
	private var mMovie:MovieClip;
	
	public function new()
	{
		super();
		
		var frames:Vector<Texture> = Game.assets.getTextures("flight");
		trace("frames = " + frames);
		mMovie = new MovieClip(frames, 15);
		
		// add sounds
		var stepSound:Sound = Game.assets.getSound("wing_flap");
		mMovie.setFrameSound(2, stepSound);
		
		// move the clip to the center and add it to the stage
		mMovie.x = Constants.CenterX - cast(mMovie.width / 2);
		mMovie.y = Constants.CenterY - cast(mMovie.height / 2);
		addChild(mMovie);
		
		// like any animation, the movie needs to be added to the juggler!
		// this is the recommended way to do that.
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	private function onAddedToStage():Void
	{
		Starling.Juggler.add(mMovie);
	}
	
	private function onRemovedFromStage():Void
	{
		trace("onRemovedFromStage");
		Starling.Juggler.remove(mMovie);
	}
	
	public override function dispose():Void
	{
		if (mMovie != null) {
			onRemovedFromStage();
		}
		trace("MovieScene dispose");
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		super.dispose();
	}
}