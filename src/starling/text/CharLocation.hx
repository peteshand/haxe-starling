package starling.text;

/**
 * ...
 * @author P.J.Shand
 */
class CharLocation
{
	public var char:BitmapChar;
	public var scale:Float;
	public var x:Float;
	public var y:Float;

	function new(char:BitmapChar)
	{
		reset(char);
	}

	private function reset(char:BitmapChar):CharLocation
	{
		this.char = char;
		return this;
	}

	// pooling

	private static var sInstancePool = new Array<CharLocation>();
	private static var sVectorPool = new Array<Dynamic>();

	private static var sInstanceLoan = new Array<CharLocation>();
	private static var sVectorLoan = new Array<Dynamic>();

	public static function instanceFromPool(char:BitmapChar):CharLocation
	{
		var instance:CharLocation = sInstancePool.length > 0 ?
			sInstancePool.pop() : new CharLocation(char);

		instance.reset(char);
		sInstanceLoan[sInstanceLoan.length] = instance;

		return instance;
	}

	public static function vectorFromPool():Array<CharLocation>
	{
		var vector:Array<CharLocation> = sVectorPool.length > 0 ?
			sVectorPool.pop() : [];

		vector = [];
		sVectorLoan[sVectorLoan.length] = vector;

		return vector;
	}

	public static function rechargePool():Void
	{
		var instance:CharLocation;
		var vector:Array<CharLocation>;

		while (sInstanceLoan.length > 0)
		{
			instance = sInstanceLoan.pop();
			instance.char = null;
			sInstancePool[sInstancePool.length] = instance;
		}

		while (sVectorLoan.length > 0)
		{
			vector = sVectorLoan.pop();
			vector = [];
			sVectorPool[sVectorPool.length] = vector;
		}
	}
}