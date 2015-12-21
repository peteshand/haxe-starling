package;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;

class EmbeddedAssets
{
	/** ATTENTION: Naming conventions!
	 *  
	 *  - Classes for embedded IMAGES should have the exact same name as the file,
	 *    without extension. This is required so that references from XMLs (atlas, bitmap font)
	 *    won't break.
	 *    
	 *  - Atlas and Font XML files can have an arbitrary name, since they are never
	 *    referenced by file name.
	 * 
	 */
	
	// Texture Atlas
	
	//public static var atlas_xml:String = "assets/textures/1x/atlas.xml";
	public static var atlas_xml(get, null):Xml;
	
	//public static var atlas:String = "assets/textures/1x/atlas.png";
	public static var atlas(get, null):BitmapData;

	// Bitmap textures

	//public static var background:String = "assets/textures/1x/background.jpg";
	public static var background(get, null):BitmapData;

	// Compressed textures
	
	//public static var compressed_texture:String = "assets/textures/1x/compressed_texture.atf";
	public static var compressed_texture(get, null):ByteArray;
	
	// Bitmap Fonts
	
	//public static var desyrel_fnt:String = "assets/fonts/1x/desyrel.fnt";
	public static var desyrel_fnt(get, null):Xml;
	
	//public static var desyrel:String = "assets/fonts/1x/desyrel.png";
	public static var desyrel(get, null):BitmapData;
	
	// Sounds
	
	//public static var wing_flap:String = "assets/audio/wing_flap.mp3";
	public static var wing_flap(get, null):Sound;
	
	static function get_atlas_xml():Xml 
	{
		return Xml.parse(Assets.getText("assets/textures/2x/atlas.xml"));
	}
	
	static function get_atlas():BitmapData 
	{
		return Assets.getBitmapData("assets/textures/2x/atlas.png");
	}
	
	static function get_background():BitmapData 
	{
		return Assets.getBitmapData("assets/textures/2x/background.jpg");
	}
	
	static function get_compressed_texture():ByteArray 
	{
		return Assets.getBytes("assets/textures/2x/compressed_texture.atf");
	}
	
	static function get_desyrel_fnt():Xml 
	{
		return Xml.parse(Assets.getText("assets/fonts/2x/desyrel.fnt"));
	}
	
	static function get_desyrel():BitmapData 
	{
		return Assets.getBitmapData("assets/fonts/2x/desyrel.png");
	}
	
	static function get_wing_flap():Sound 
	{
		return Assets.getSound("assets/audio/wing_flap.mp3");
	}
}