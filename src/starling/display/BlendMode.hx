// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display;

import openfl.display3D.Context3DBlendFactor;
import openfl.errors.ArgumentError;

import starling.errors.AbstractClassError;

/** A class that provides constant values for visual blend mode effects. 
 *   
 *  <p>A blend mode is always defined by two 'Context3DBlendFactor' values. A blend factor 
 *  represents a particular four-value vector that is multiplied with the source or destination
 *  color in the blending formula. The blending formula is:</p>
 * 
 *  <pre>result = source × sourceFactor + destination × destinationFactor</pre>
 * 
 *  <p>In the formula, the source color is the output color of the pixel shader program. The 
 *  destination color is the color that currently exists in the color buffer, as set by 
 *  previous clear and draw operations.</p>
 *  
 *  <p>Beware that blending factors produce different output depending on the texture type.
 *  Textures may contain 'premultiplied alpha' (pma), which means that their RGB values were 
 *  multiplied with their alpha value (to save processing time). Textures based on 'BitmapData'
 *  objects have premultiplied alpha values, while ATF textures haven't. For this reason, 
 *  a blending mode may have different factors depending on the pma value.</p>
 *  
 *  @see flash.display3D.Context3DBlendFactor
 */
class BlendMode
{
	private static var sBlendFactors(get, null):Array<Dynamic>;
	
	// predifined modes
	
	/** @private */
	public function new() { throw new AbstractClassError(); }
	
	/** Inherits the blend mode from this display object's parent. */
	public static var AUTO:String = "auto";

	/** Deactivates blending, i.e. disabling any transparency. */
	public static var NONE:String = "none";
	
	/** The display object appears in front of the background. */
	public static var NORMAL:String = "normal";
	
	/** Adds the values of the colors of the display object to the colors of its background. */
	public static var ADD:String = "add";
	
	/** Multiplies the values of the display object colors with the the background color. */
	public static var MULTIPLY:String = "multiply";
	
	/** Multiplies the complement (inverse) of the display object color with the complement of 
	  * the background color, resulting in a bleaching effect. */
	public static var SCREEN:String = "screen";
	
	/** Erases the background when drawn on a RenderTexture. */
	public static var ERASE:String = "erase";
	
	/** Draws under/below existing objects; useful especially on RenderTextures. */
	public static var BELOW:String = "below";
	

	static function get_sBlendFactors():Array<Dynamic>
	{
		var vec = new Array<Dynamic>();
		vec.push({ 
			"none"     : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ],
			"normal"   : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"add"      : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ],
			"multiply" : [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"screen"   : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE ],
			"erase"    : [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"below"    : [ Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]
		});
		// premultiplied alpha
		vec.push({ 
			"none"     : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ],
			"normal"   : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"add"      : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE ],
			"multiply" : [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"screen"   : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR ],
			"erase"    : [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
			"below"    : [ Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]
		});
		return vec;
	}
	
	// accessing modes
	
	/** Returns the blend factors that correspond with a certain mode and premultiplied alpha
	 *  value. Throws an ArgumentError if the mode does not exist. */
	public static function getBlendFactors(mode:String, premultipliedAlpha:Bool=true):Array<Dynamic>
	{
		//trace("CHECK");
		
		var vec:Array<Dynamic> = BlendMode.sBlendFactors;
		var modeIndex:Int = 0;//
		if (premultipliedAlpha == true) modeIndex = 1;//cast(premultipliedAlpha, Int);
		var modes:Dynamic = vec[modeIndex];
		
		var returnVal:Array<Dynamic> = Reflect.getProperty(modes, mode);
		if (returnVal == null) throw new ArgumentError("Invalid blend mode");
		return returnVal;
		
		/*if (mode in modes) return modes[mode];
		else {
			throw new ArgumentError("Invalid blend mode");
		}
		return null;*/
	}
	
	/** Registeres a blending mode under a certain name and for a certain premultiplied alpha
	 *  (pma) value. If the mode for the other pma value was not yet registered, the factors are
	 *  used for both pma settings. */
	public static function register(name:String, sourceFactor:String, destFactor:String,
									premultipliedAlpha:Bool=true):Void
	{
		var vec:Array<Dynamic> = BlendMode.sBlendFactors;
		var modeIndex:Int = cast(premultipliedAlpha);
		var modes:Dynamic = vec[modeIndex];
		//modes[name] = [sourceFactor, destFactor];
		Reflect.setProperty(modes, name, [sourceFactor, destFactor]);
		
		
		trace("CHECK");
		//var otherModes:Dynamic = vec[cast(!premultipliedAlpha, Int)];
		//if (!(name in otherModes)) otherModes[name] = [sourceFactor, destFactor];
		var otherModes:Dynamic = vec[cast(!premultipliedAlpha, Int)];
		var returnVal:Array<Dynamic> = Reflect.getProperty(otherModes, name);
		if (returnVal == null) {
			Reflect.setProperty(otherModes, name, [sourceFactor, destFactor]);
		}
	}
}