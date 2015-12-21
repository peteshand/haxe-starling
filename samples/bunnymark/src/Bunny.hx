package;

import starling.display.Image;
import starling.textures.Texture;

/**
 * ...
 * @author P.J.Shand
 */
class Bunny extends Image
{
	public var speedX:Float;
	public var speedY:Float;
		
	public function new(texture:Texture) 
	{
		super(texture);
		speedX = 0;
		speedY = 0;
	}
}