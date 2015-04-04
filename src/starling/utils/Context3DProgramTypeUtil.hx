package starling.utils;

import openfl.display3D.Context3DProgramType;

/**
 * ...
 * @author P.J.Shand
 */
class Context3DProgramTypeUtil
{
	public static var FRAGMENT:String = "fragment";
	public static var VERTEX:String = "vertex";
	
	public function new() 
	{
		
	}
	
	public static function getString(value:Context3DProgramType):String
	{
		if (value == Context3DProgramType.FRAGMENT) return Context3DProgramTypeUtil.FRAGMENT;
		if (value == Context3DProgramType.VERTEX) return Context3DProgramTypeUtil.VERTEX;
		return "";
	}
	
	public static function getEnum(value:String):Context3DProgramType
	{
		if (value == Context3DProgramTypeUtil.FRAGMENT) return Context3DProgramType.FRAGMENT;
		if (value == Context3DProgramTypeUtil.VERTEX) return Context3DProgramType.VERTEX;
		return null;
	}
}