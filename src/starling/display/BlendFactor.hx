package starling.display;
import openfl.display3D.Context3DBlendFactor;

/**
 * ...
 * @author P.J.Shand
 */
class BlendFactor
{
	public var factors:Array<Context3DBlendFactor>;
	public var name:String;
	
	public function new(name:String, factors:Array<Context3DBlendFactor>) 
	{
		this.factors = factors;
		this.name = name;
		
	}
	
}