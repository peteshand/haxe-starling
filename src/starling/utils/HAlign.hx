// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.utils;

import starling.errors.AbstractClassError;

/** A class that provides constant values for horizontal alignment of objects. */
@:final
class HAlign
{
	/** @private */
	public function new() { throw new AbstractClassError(); }
	
	/** Left alignment. */
	public static var LEFT:String   = "left";
	
	/** Centered alignement. */
	public static var CENTER:String = "center";
	
	/** Right alignment. */
	public static var RIGHT:String  = "right";
	
	/** Indicates whether the given alignment string is valid. */
	public static function isValid(hAlign:String):Bool
	{
		return hAlign == LEFT || hAlign == CENTER || hAlign == RIGHT;
	}
}