package starling.geom;

/**
 * ...
 * @author P.J.Shand
 */
class Ellipse extends ImmutablePolygon
{
	private var mX:Float;
	private var mY:Float;
	private var mRadiusX:Float;
	private var mRadiusY:Float;

	public function new(x:Float, y:Float, radiusX:Float, radiusY:Float, numSides:Int = -1)
	{
		trace("new Ellipse");
		mX = x;
		mY = y;
		mRadiusX = radiusX;
		mRadiusY = radiusY;
		
		var vertices:Array<Float> = getVertices(numSides);
		trace("vertices = " + vertices);
		super(vertices);
	}

	private function getVertices(numSides:Int):Array<Float>
	{
		if (numSides < 0) numSides = cast (Math.PI * (mRadiusX + mRadiusY) / 4.0);
		if (numSides < 6) numSides = 6;

		var vertices = new Array<Float>();
		var angleDelta:Float = 2 * Math.PI / numSides;
		var angle:Float = 0;

		for (i in 0...numSides)
		{
			vertices[i * 2    ] = Math.cos(angle) * mRadiusX + mX;
			vertices[i * 2 + 1] = Math.sin(angle) * mRadiusY + mY;
			angle += angleDelta;
		}

		return vertices;
	}

	override public function triangulate(result:Array<UInt> = null):Array<UInt>
	{
		if (result == null) result = new Array<UInt>();

		var from:UInt = 1;
		var to:UInt = numVertices - 1;

		for (i in from...to){
			result.push(0);
			result.push(i);
			result.push(i + 1);
		}

		return result;
	}

	override public function contains(x:Float, y:Float):Bool
	{
		var vx:Float = x - mX;
		var vy:Float = y - mY;

		var a:Float = vx / mRadiusX;
		var b:Float = vy / mRadiusY;

		return a * a + b * b <= 1;
	}

	override private function get_area():Float
	{
		return Math.PI * mRadiusX * mRadiusY;
	}

	override private function get_isSimple():Bool
	{
		return true;
	}

	override private function get_isConvex():Bool
	{
		return true;
	}
}