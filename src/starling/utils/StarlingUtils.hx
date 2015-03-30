package starling.utils;

import openfl.geom.Matrix;
import openfl.geom.Point;

class StarlingUtils
{

	public function new() 
	{
		
	}
	
	/** Replaces a string's "master string" — the string it was built from —
     *  with a single character to save memory. Find more information about this AS3 oddity
     *  <a href="http://jacksondunstan.com/articles/2260">here</a>.
     *
     *  @param  str String to clean
     *  @return The input string, but with a master string only one character larger than it.
     *  @author Jackson Dunstan, JacksonDunstan.com
     */
    public static function cleanMasterString(str:String):String
    {
        return ("_" + str).substr(1);
    }
	
	/** Converts an angle from degrees into radians. */
    public static function deg2rad(deg:Float):Float
    {
        return deg / 180.0 * Math.PI;   
    }
	
	/** Executes a function with the specified arguments. If the argument count does not match
     *  the function, the argument list is cropped / filled up with <code>null</code> values. */
    public static function execute(func:Dynamic, args:Array<Dynamic>):Void
    {
        if (func != null)
        {
            var i:Int;
            var maxNumArgs:Int = func.length;

            for (i in args.length...maxNumArgs)
                args[i] = null;

            // In theory, the 'default' case would always work,
            // but we want to avoid the 'slice' allocations.

            switch (maxNumArgs)
            {
                case 0:  func(); break;
                case 1:  func(args[0]); break;
                case 2:  func(args[0], args[1]); break;
                case 3:  func(args[0], args[1], args[2]); break;
                case 4:  func(args[0], args[1], args[2], args[3]); break;
                case 5:  func(args[0], args[1], args[2], args[3], args[4]); break;
                case 6:  func(args[0], args[1], args[2], args[3], args[4], args[5]); break;
                case 7:  func(args[0], args[1], args[2], args[3], args[4], args[5], args[6]); break;
                default: func.apply(null, args.slice(0, maxNumArgs)); break;
            }
        }
    }
	
	// TODO: add number formatting options
    
    /** Formats a String in .Net-style, with curly braces ("{0}"). Does not support any 
     *  number formatting options yet. */
    public static function formatString(format:String, args:Array<Dynamic>):String
    {
        for (i in 0...args.length)
            format = format.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
        
        return format;
    }
	
	/** Returns the next power of two that is equal to or bigger than the specified number. */
    public static function getNextPowerOfTwo(number:Float):Int
    {
        if (Std.is(number, Int) && number > 0 && (number & (number - 1)) == 0) // see: http://goo.gl/D9kPj
            return cast number;
        else
        {
            var result:Int = 1;
            number -= 0.000000001; // avoid floating point rounding errors

            while (result < number) result <<= 1;
            return result;
        }
    }
	
	/** Converts an angle from radians into degrees. */
    public static function rad2deg(rad:Float):Float
    {
        return rad / Math.PI * 180.0;            
    }
	
	

	private static var deprecationNotified:Bool = false;
	
    /** Uses a matrix to transform 2D coordinates into a different space. If you pass a 
     *  'resultPoint', the result will be stored in this point instead of creating a new object.*/
    public static function transformCoords(matrix:Matrix, x:Float, y:Float, resultPoint:Point=null):Point
    {
        if (!deprecationNotified)
        {
            deprecationNotified = true;
            trace("[Starling] The method 'transformCoords' is deprecated. " + 
                  "Please use 'MatrixUtil.transformCoords' instead.");
        }
        
        if (resultPoint == null) resultPoint = new Point();   
        
        resultPoint.x = matrix.a * x + matrix.c * y + matrix.tx;
        resultPoint.y = matrix.d * y + matrix.b * x + matrix.ty;
        
        return resultPoint;
    }
}