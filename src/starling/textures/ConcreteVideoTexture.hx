// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2015 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.textures;

import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.textures.TextureBase;
import openfl.errors.ArgumentError;

/** A concrete texture that may only be used for a 'VideoTexture' base.
 *  For internal use only. */
/*internal*/
class ConcreteVideoTexture extends ConcreteTexture
{
	/** Creates a new VideoTexture. 'base' must be of type 'VideoTexture'. */
	public function new(base:TextureBase, scale:Float = 1)
	{
		// we must not reference the "VideoTexture" class directly
		// because it's only available in AIR.

		var format = Context3DTextureFormat.BGRA;
		
		trace("CHECK");
		var width:Float  = 0; // var width:Float  = "videoWidth"  in base ? base["videoWidth"]  : 0;
		var height:Float = 0; //var height:Float = "videoHeight" in base ? base["videoHeight"] : 0;
		if (Reflect.hasField(base, "videoWidth")) width = Reflect.getProperty( base, "videoWidth");
		if (Reflect.hasField(base, "videoHeight")) height = Reflect.getProperty( base, "videoHeight");
		
		super(base, format, cast width, cast height, false, false, false, scale, false);
		
		var name:String = Type.getClassName(Type.getClass(base));
		trace("CHECK name = " + name);
		if (name != "flash.display3D.textures.VideoTexture") {
			throw new ArgumentError("'base' must be VideoTexture");
		}
	}

	/** The actual width of the video in pixels. */
	override private function get_nativeWidth():Float
	{
		return Reflect.getProperty(base, "videoWidth");
	}

	/** The actual height of the video in pixels. */
	override private function get_nativeHeight():Float
	{
		return Reflect.getProperty(base, "videoHeight");
	}

	/** inheritDoc */
	override private function get_width():Float
	{
		return nativeWidth / scale;
	}

	/** inheritDoc */
	override private function get_height():Float
	{
		return nativeHeight / scale;
	}
}