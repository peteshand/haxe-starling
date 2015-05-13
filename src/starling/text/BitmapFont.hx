// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.text;

import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;
import openfl.utils.Dictionary;
import openfl.Vector;
import starling.utils.StarlingUtils;

import starling.text.BitmapChar;
import starling.display.Image;
import starling.display.QuadBatch;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.HAlign;
import starling.utils.VAlign;

/** The BitmapFont class parses bitmap font files and arranges the glyphs 
 *  in the form of a text.
 *
 *  The class parses the Xml format as it is used in the 
 *  <a href="http://www.angelcode.com/products/bmfont/">AngelCode Bitmap Font Generator</a> or
 *  the <a href="http://glyphdesigner.71squared.com/">Glyph Designer</a>. 
 *  This is what the file format looks like:
 *
 *  <pre> 
 *  &lt;font&gt;
 *    &lt;info face="BranchingMouse" size="40" /&gt;
 *    &lt;common lineHeight="40" /&gt;
 *    &lt;pages&gt;  &lt;!-- currently, only one page is supported --&gt;
 *      &lt;page id="0" file="texture.png" /&gt;
 *    &lt;/pages&gt;
 *    &lt;chars&gt;
 *      &lt;char id="32" x="60" y="29" width="1" height="1" xoffset="0" yoffset="27" xadvance="8" /&gt;
 *      &lt;char id="33" x="155" y="144" width="9" height="21" xoffset="0" yoffset="6" xadvance="9" /&gt;
 *    &lt;/chars&gt;
 *    &lt;kernings&gt; &lt;!-- Kerning is optional --&gt;
 *      &lt;kerning first="83" second="83" amount="-4"/&gt;
 *    &lt;/kernings&gt;
 *  &lt;/font&gt;
 *  </pre>
 *  
 *  Pass an instance of this class to the method <code>registerBitmapFont</code> of the
 *  TextField class. Then, set the <code>fontName</code> property of the text field to the 
 *  <code>name</code> value of the bitmap font. This will make the text field use the bitmap
 *  font.  
 */ 
class BitmapFont
{
	/** Use this constant for the <code>fontSize</code> property of the TextField class to 
	 *  render the bitmap font in exactly the size it was created. */ 
	public static var NATIVE_SIZE:Int = -1;
	
	/** The font name of the embedded minimal bitmap font. Use this e.g. for debug output. */
	public static var MINI:String = "mini";
	
	private static var CHAR_SPACE:Int           = 32;
	private static var CHAR_TAB:Int             =  9;
	private static var CHAR_NEWLINE:Int         = 10;
	private static var CHAR_CARRIAGE_RETURN:Int = 13;
	
	private var mTexture:Texture;
	private var mChars:Map<Int, BitmapChar>;
	private var mName:String;
	private var mSize:Float;
	private var mLineHeight:Float = 0;
	private var mBaseline:Float;
	private var mOffsetX:Float;
	private var mOffsetY:Float;
	private var mHelperImage:Image;

	/** Helper objects. */
	private static var sLines = new Vector<Dynamic>();
	
	public var name(get, null):String;
	public var size(get, null):Float;
	public var lineHeight(get, set):Float;
	public var smoothing(get, set):String;
	public var baseline(get, set):Float;
	public var offsetX(get, set):Float;
	public var offsetY(get, set):Float;
	public var texture(get, null):Texture;
	
	/** Creates a bitmap font by parsing an Xml file and uses the specified texture. 
	 *  If you don't pass any data, the "mini" font will be created. */
	public function new(texture:Texture=null, fontXml:Xml=null)
	{
		// if no texture is passed in, we create the minimal, embedded font
		if (texture == null && fontXml == null)
		{
			texture = MiniBitmapFont.texture;
			fontXml = MiniBitmapFont.xml;
		}
		else if (texture != null && fontXml == null)
		{
			throw new ArgumentError("fontXml cannot be null!");
		}
		
		mName = "unknown";
		mLineHeight = mSize = mBaseline = 14;
		mOffsetX = mOffsetY = 0.0;
		mTexture = texture;
		mChars = new Map<Int, BitmapChar>();
		mHelperImage = new Image(texture);
		
		parseFontXml(fontXml);
	}
	
	/** Disposes the texture of the bitmap font! */
	public function dispose():Void
	{
		if (mTexture != null)
			mTexture.dispose();
	}
	
	private function parseFontXml(fontXml:Xml):Void
	{
		var scale:Float = mTexture.scale;
		var frame:Rectangle = mTexture.frame;
		var frameX:Float = frame != null ? frame.x : 0;
		var frameY:Float = frame != null ? frame.y : 0;
		
		for (font in fontXml.elementsNamed("font")) {
			if (font.nodeType == Xml.Element ) {
				for (info in font.elementsNamed("info")) {
					if (info.nodeType == Xml.Element ) {
						mName = info.get("face");
						mSize = Std.parseFloat(info.get("size")) / scale;
						//mSize = Std.parseFloat(info.get("bold")) / scale;
						//mSize = Std.parseFloat(info.get("italic")) / scale;
						if (info.get("smooth") == "0") smoothing = TextureSmoothing.NONE;
						if (mSize <= 0)
						{
							trace("[Starling] Warning: invalid font size in '" + mName + "' font.");
							mSize = (mSize == 0.0 ? 16.0 : mSize * -1.0);
						}
					}
				}
				for (common in font.elementsNamed("common")) {
					if (common.nodeType == Xml.Element ) {
						mLineHeight = Std.parseFloat(common.get("lineHeight")) / scale;
						mBaseline = Std.parseFloat(common.get("base")) / scale;
						//mBaseline = Std.parseFloat(common.get("scaleW")) / scale;
						//mBaseline = Std.parseFloat(common.get("scaleH")) / scale;
						//mBaseline = Std.parseFloat(common.get("pages")) / scale;
						//mBaseline = Std.parseFloat(common.get("packed")) / scale;
						
					}
				}
				for (chars in font.elementsNamed("chars")) {
					if (chars.nodeType == Xml.Element ) {
						for (char in chars.elementsNamed("char")) {
							if (char.nodeType == Xml.Element ) {
								
								var id:Int = Std.parseInt(char.get("id"));
								
								var xOffset:Float  = Std.parseFloat(char.get("xoffset"))  / scale;
								var yOffset:Float  = Std.parseFloat(char.get("yoffset"))  / scale;
								var xAdvance:Float = Std.parseFloat(char.get("xadvance")) / scale;
								
								var region:Rectangle = new Rectangle();
								region.x = Std.parseFloat(char.get("x")) / scale + frameX;
								region.y = Std.parseFloat(char.get("y")) / scale + frameY;
								region.width  = Std.parseFloat(char.get("width"))  / scale;
								region.height = Std.parseFloat(char.get("height")) / scale;
								
								var texture:Texture = Texture.fromTexture(mTexture, region);
								var bitmapChar:BitmapChar = new BitmapChar(id, texture, xOffset, yOffset, xAdvance); 
								addChar(id, bitmapChar);
							}
						}
					}
				}
				for (kernings in font.elementsNamed("kernings")) {
					if (kernings.nodeType == Xml.Element ) {
						for (kerning in kernings.elementsNamed("kerning")) {
							if (kerning.nodeType == Xml.Element ) {
								
								var first:Int  = Std.parseInt(kerning.get("first"));
								var second:Int = Std.parseInt(kerning.get("second"));
								var amount:Float = Std.parseFloat(kerning.get("amount")) / scale;
								if (mChars.exists(second)) {
									getChar(second).addKerning(first, amount);
								}
							}
						}
					}
				}
			}
		}
	}
	
	/** Returns a single bitmap char with a certain character ID. */
	public function getChar(charID:Int):BitmapChar
	{
		return mChars[charID];   
	}
	
	/** Adds a bitmap char with a certain character ID. */
	public function addChar(charID:Int, bitmapChar:BitmapChar):Void
	{
		mChars[charID] = bitmapChar;
	}
	
	/** Returns a vector containing all the character IDs that are contained in this font. */
	public function getCharIDs(result:Array<Int>=null):Array<Int>
	{
		if (result == null) result = new Array<Int>();

		var keys = mChars.keys();
		for (k in keys) {
			var key:Int = k;
			result[result.length] = key;
		}

		return result;
	}

	/** Checks whether a provided string can be displayed with the font. */
	public function hasChars(text:String):Bool
	{
		if (text == null) return true;

		var charID:Int;
		var numChars:Int = text.length;

		for (i in 0...numChars)
		{
			charID = text.charCodeAt(i);

			if (charID != CHAR_SPACE && charID != CHAR_TAB && charID != CHAR_NEWLINE &&
				charID != CHAR_CARRIAGE_RETURN && getChar(charID) == null)
			{
				return false;
			}
		}

		return true;
	}

	/** Creates a sprite that contains a certain text, made up by one image per char. */
	public function createSprite(width:Float, height:Float, text:String,
								 fontSize:Float=-1, color:UInt=0xffffff, 
								 hAlign:HAlign=null, vAlign:VAlign=null,      
								 autoScale:Bool=true, 
								 kerning:Bool=true):Sprite
	{
		if (hAlign == null) hAlign = HAlign.CENTER;
		if (vAlign == null) vAlign = VAlign.CENTER;
		
		var charLocations:Array<CharLocation> = arrangeChars(width, height, text, fontSize, 
															   hAlign, vAlign, autoScale, kerning);
		var numChars:Int = charLocations.length;
		var sprite:Sprite = new Sprite();
		
		for (i in 0...numChars)
		{
			var charLocation:CharLocation = charLocations[i];
			var char:Image = charLocation.char.createImage();
			char.x = charLocation.x;
			char.y = charLocation.y;
			char.scaleX = char.scaleY = charLocation.scale;
			char.color = color;
			sprite.addChild(char);
		}
		
		CharLocation.rechargePool();
		return sprite;
	}
	
	/** Draws text into a QuadBatch. */
	public function fillQuadBatch(quadBatch:QuadBatch, width:Float, height:Float, text:String,
								  fontSize:Float=-1, color:UInt=0xffffff, 
								  hAlign:HAlign=null, vAlign:VAlign=null,      
								  autoScale:Bool=true, 
								  kerning:Bool=true):Void
	{
		if (hAlign == null) hAlign = HAlign.CENTER;
		if (vAlign == null) vAlign = VAlign.CENTER;
		
		var charLocations:Array<CharLocation> = arrangeChars(width, height, text, fontSize, 
															   hAlign, vAlign, autoScale, kerning);
		var numChars:Int = charLocations.length;
		mHelperImage.color = color;
		
		for (i in 0...numChars)
		{
			var charLocation:CharLocation = charLocations[i];
			mHelperImage.texture = charLocation.char.texture;
			mHelperImage.readjustSize();
			mHelperImage.x = charLocation.x;
			mHelperImage.y = charLocation.y;
			mHelperImage.scaleX = mHelperImage.scaleY = charLocation.scale;
			quadBatch.addImage(mHelperImage);
		}

		CharLocation.rechargePool();
	}
	
	/** Arranges the characters of a text inside a rectangle, adhering to the given settings. 
	 *  Returns a Vector of CharLocations. */
	private function arrangeChars(width:Float, height:Float, text:String, fontSize:Float=-1,
								  hAlign:HAlign=null, vAlign:VAlign=null,
								  autoScale:Bool=true, kerning:Bool=true):Array<CharLocation>
	{
		if (hAlign == null) hAlign = HAlign.CENTER;
		if (vAlign == null) vAlign = VAlign.CENTER;
		
		if (text == null || text.length == 0) return CharLocation.vectorFromPool();
		if (fontSize < 0) fontSize *= -mSize;
		
		var finished:Bool = false;
		var charLocation:CharLocation;
		var numChars:Int;
		var containerWidth:Float = 0;
		var containerHeight:Float = 0;
		var scale:Float = 1;
		
		var currentX:Float = 0;
		var currentY:Float = 0;
		
		while (!finished)
		{
			sLines.length = 0;
			scale = fontSize / mSize;
			containerWidth  = width / scale;
			containerHeight = height / scale;
			
			if (mLineHeight <= containerHeight)
			{
				var lastWhiteSpace:Int = -1;
				var lastCharID:Int = -1;
				currentX = 0;
				currentY = 0;
				var currentLine:Array<CharLocation> = CharLocation.vectorFromPool();
				
				numChars = text.length;
				for (i in 0...numChars) 
				{
					var lineFull:Bool = false;
					var charID:Int = text.charCodeAt(i);
					var char:BitmapChar = getChar(charID);
					
					if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
					{
						lineFull = true;
					}
					else if (char == null)
					{
						trace("[Starling] Missing character: " + charID);
					}
					else
					{
						if (charID == CHAR_SPACE || charID == CHAR_TAB)
							lastWhiteSpace = i;
						
						if (kerning)
							currentX += char.getKerning(lastCharID);
						
						charLocation = CharLocation.instanceFromPool(char);
						charLocation.x = currentX + char.xOffset;
						charLocation.y = currentY + char.yOffset;
						currentLine[currentLine.length] = charLocation; // push
						
						currentX += char.xAdvance;
						lastCharID = charID;
						
						if (charLocation.x + char.width > containerWidth)
						{
							// when autoscaling, we must not split a word in half -> restart
							if (autoScale && lastWhiteSpace == -1)
								break;

							// remove characters and add them again to next line
							var numCharsToRemove:Int = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
							var removeIndex:Int = currentLine.length - numCharsToRemove;
							
							currentLine.splice(removeIndex, numCharsToRemove);
							
							if (currentLine.length == 0)
								break;
							
							//i -= numCharsToRemove;
							lineFull = true;
						}
					}
					
					if (i == numChars - 1)
					{
						sLines[sLines.length] = currentLine; // push
						finished = true;
					}
					else if (lineFull)
					{
						sLines[sLines.length] = currentLine; // push
						if (lastWhiteSpace == i)
							currentLine.pop();
						
						if (currentY + 2*mLineHeight <= containerHeight)
						{
							currentLine = CharLocation.vectorFromPool();
							currentX = 0;
							currentY += mLineHeight;
							lastWhiteSpace = -1;
							lastCharID = -1;
						}
						else
						{
							break;
						}
					}
				} // for each char
			} // if (mLineHeight <= containerHeight)
			
			if (autoScale && !finished && fontSize > 3)
				fontSize -= 1;
			else
				finished = true; 
		} // while (!finished)
		
		var finalLocations:Array<CharLocation> = CharLocation.vectorFromPool();
		var numLines:Int = sLines.length;
		var bottom:Float = currentY + mLineHeight;
		var yOffset:Int = 0;
		
		if (vAlign == VAlign.BOTTOM)      yOffset =  Std.int (containerHeight - bottom);
		else if (vAlign == VAlign.CENTER) yOffset = Std.int ((containerHeight - bottom) / 2);
		
		for (lineID in 0...numLines)
		{
			var line:Array<CharLocation> = sLines[lineID];
			numChars = line.length;
			
			if (numChars == 0) continue;
			
			var xOffset:Int = 0;
			var lastLocation:CharLocation = line[line.length-1];
			var right:Float = lastLocation.x - lastLocation.char.xOffset 
											  + lastLocation.char.xAdvance;
			
			if (hAlign == HAlign.RIGHT)       xOffset = Std.int (containerWidth - right);
			else if (hAlign == HAlign.CENTER) xOffset = Std.int ((containerWidth - right) / 2);
			
			for (c in 0...numChars)
			{
				charLocation = line[c];
				charLocation.x = scale * (charLocation.x + xOffset + mOffsetX);
				charLocation.y = scale * (charLocation.y + yOffset + mOffsetY);
				charLocation.scale = scale;
				
				if (charLocation.char.width > 0 && charLocation.char.height > 0)
					finalLocations[finalLocations.length] = charLocation;
			}
		}
		
		return finalLocations;
	}
	
	/** The name of the font as it was parsed from the font file. */
	private function get_name():String { return mName; }
	
	/** The native size of the font. */
	private function get_size():Float { return mSize; }
	
	/** The height of one line in points. */
	private function get_lineHeight():Float { return mLineHeight; }
	private function set_lineHeight(value:Float):Float
	{
		mLineHeight = value;
		return value;
	}
	
	/** The smoothing filter that is used for the texture. */ 
	private function get_smoothing():String { return mHelperImage.smoothing; }
	private function set_smoothing(value:String):String
	{
		mHelperImage.smoothing = value;
		return value; 
	}
	
	/** The baseline of the font. This property does not affect text rendering;
	 *  it's just an information that may be useful for exact text placement. */
	private function get_baseline():Float { return mBaseline; }
	private function set_baseline(value:Float):Float
	{
		mBaseline = value;
		return value;
	}
	
	/** An offset that moves any generated text along the x-axis (in points).
	 *  Useful to make up for incorrect font data. @default 0. */ 
	private function get_offsetX():Float { return mOffsetX; }
	private function set_offsetX(value:Float):Float
	{
		mOffsetX = value;
		return value;
	}
	
	/** An offset that moves any generated text along the y-axis (in points).
	 *  Useful to make up for incorrect font data. @default 0. */
	private function get_offsetY():Float { return mOffsetY; }
	private function set_offsetY(value:Float):Float
	{
		mOffsetY = value;
		return value;
	}

	/** The underlying texture that contains all the chars. */
	private function get_texture():Texture { return mTexture; }
}



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

	public static function vectorFromPool():Vector<CharLocation>
	{
		var vector:Vector<CharLocation> = sVectorPool.length > 0 ?
			sVectorPool.pop() : [];

		vector.length = 0;
		sVectorLoan[sVectorLoan.length] = vector;

		return vector;
	}

	public static function rechargePool():Void
	{
		var instance:CharLocation;
		var vector:Vector<CharLocation>;

		while (sInstanceLoan.length > 0)
		{
			instance = sInstanceLoan.pop();
			instance.char = null;
			sInstancePool[sInstancePool.length] = instance;
		}

		while (sVectorLoan.length > 0)
		{
			vector = sVectorLoan.pop();
			vector.length = 0;
			sVectorPool[sVectorPool.length] = vector;
		}
	}
}