package starling.geom;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;

/**
 * ...
 * @author P.J.Shand
 */
class ImmutablePolygon extends Polygon
{
	private var mFrozen:Bool;
	
	public function new(vertices:Array<Float>)
	{
		super(vertices);
		mFrozen = true;
	}

	override public function addVertices(args:Array<Dynamic>):Void
	{
		if (mFrozen) throw getImmutableError();
		else super.addVertices(args);
	}

	override public function setVertex(index:Int, x:Float, y:Float):Void
	{
		if (mFrozen) throw getImmutableError();
		else super.setVertex(index, x, y);
	}

	override public function reverse():Void
	{
		if (mFrozen) throw getImmutableError();
		else super.reverse();
	}

	override private function set_numVertices(value:Int):Int
	{
		if (mFrozen) throw getImmutableError();
		else super.reverse();
		return value;
	}

	private function getImmutableError():Error
	{
		var className:String = Type.getClassName(Type.getClass(this));
		//var className:String = getQualifiedClassName(this).split("::").pop();
		var msg:String = className + " cannot be modified. Call 'clone' to create a mutable copy.";
		return new IllegalOperationError(msg);
	}
	
}