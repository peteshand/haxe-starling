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
	private static var sBlendFactors(get, null):Array<Map<String, BlendFactor>>;
	
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
	static private var _sBlendFactors:Array<Map<String, BlendFactor>>;
	static private var lastModeName:String;
	static private var lastModeFactors:Array<Context3DBlendFactor>;
	

	static function get_sBlendFactors():Array<Map<String, BlendFactor>>
	{
		if (_sBlendFactors == null){
			_sBlendFactors = new Array<Map<String, BlendFactor>>();
			
			var map1:Map<String, BlendFactor> = new Map<String, BlendFactor>();
			map1.set("none", new BlendFactor("none", [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ]));
			map1.set("normal", new BlendFactor("normal", [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]));
			map1.set("add", new BlendFactor("add", [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]));
			map1.set("multiply", new BlendFactor("multiply", [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]));
			map1.set("screen", new BlendFactor("screen", [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE ]));
			map1.set("erase", new BlendFactor("erase", [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]));
			map1.set("below", new BlendFactor("below", [ Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]));
			_sBlendFactors.push(map1);
			
			var map2:Map<String, BlendFactor> = new Map<String, BlendFactor>();
			map2.set("none", new BlendFactor("none", [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ]));
			map2.set("normal", new BlendFactor("normal", [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]));
			map2.set("add", new BlendFactor("add", [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE ]));
			map2.set("multiply", new BlendFactor("multiply", [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]));
			map2.set("screen", new BlendFactor("screen", [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR ]));
			map2.set("erase", new BlendFactor("erase", [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ]));
			map2.set("below", new BlendFactor("below", [ Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]));
			_sBlendFactors.push(map2);
		}
		
		/*var vec = new Array<Dynamic>();
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
		});*/
		return _sBlendFactors;
	}
	
	// accessing modes
	
	/** Returns the blend factors that correspond with a certain mode and premultiplied alpha
	 *  value. Throws an ArgumentError if the mode does not exist. */
	public static function getBlendFactors(mode:String, premultipliedAlpha:Bool=true):Array<Dynamic>
	{
		//trace("CHECK");
		
		var vec:Array<Map<String, BlendFactor>> = BlendMode.sBlendFactors;
		var modeIndex:Int = 0;//
		if (premultipliedAlpha == true) modeIndex = 1;//cast(premultipliedAlpha, Int);
		var modes:Map<String, BlendFactor> = vec[modeIndex];
		
		
		if (lastModeName != mode) {
			lastModeFactors = modes.get(mode).factors;
		}
		lastModeName = mode;
		
		
		var returnVal:Array<Context3DBlendFactor> = lastModeFactors;
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
		var vec:Array<Map<String, BlendFactor>> = BlendMode.sBlendFactors;
		var modeIndex:Int = cast(premultipliedAlpha);
		var modes:Map<String, BlendFactor> = vec[modeIndex];
		modes.get(name).factors = [cast(sourceFactor, Context3DBlendFactor), cast(destFactor,Context3DBlendFactor)];
		
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
