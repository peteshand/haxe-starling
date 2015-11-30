package utils;

#if js
import js.Browser;
#end

import openfl.system.Capabilities;

class DeviceInfo 
{
	static private var _checked:Bool;
	static private var _os:String;
	static private var _manufacturer:String;
	
	static private var _isMobile:Bool;
	static private var _isDesktop:Bool;
	static private var _isAndroid:Bool;
	static private var _isIOS:Bool;
	static private var _isTablet:Bool;
	static private var _isPhone:Bool;
	static private var _isCardboardCompatible:Bool;
	
	static private var _tabletScreenMinimumInches:Float = 6.2;
	static private var dpi:Float;
	static private var physicalScreenSize:Float;
	
	static public var screenWidth:Float;
	static public var screenHeight:Float;
	
	public static var isMobile(get, null):Bool;
	public static var isDesktop(get, null):Bool;
	public static var isTablet(get, null):Bool;
	public static var isPhone(get, null):Bool;
	public static var isIOS(get, null):Bool;
	public static var isAndroid(get, null):Bool;
	public static var isCardboardCompatible(get, null):Bool; 
	
	public static function get_isMobile():Bool
	{
		if ( !_checked )
			checkDevice();
			
		return _isMobile;
	}
	
	public static function get_isDesktop():Bool
	{
		if ( !_checked )
			checkDevice();
			
		return _isDesktop;
	}
	
	public static function get_isTablet():Bool
	{
		if ( !_checked )
			checkDevice();
			
		return _isTablet;
	}
	
	public static function get_isPhone():Bool
	{
		if ( !_checked )
			checkDevice();
			
		return _isPhone;
	}
	
	public static function get_isIOS():Bool
	{
		if ( !_checked )
			checkDevice();
			
		return _isIOS;
	}
	
	public static function get_isAndroid():Bool
	{
		if ( !_checked ) checkDevice();
		return _isAndroid;
	}
	
	static public function get_isCardboardCompatible():Bool 
	{
		if ( !_checked ) checkDevice();
		return _isCardboardCompatible;
	}
	
	private static function checkDevice():Void
	{
		_checked = true;
		
		
		
		#if js
			// This class is incomplete!
			var match = ["Android", "BlackBerry", "iPhone", "iPad", "iPod", "Opera Mini", "IEMobile", "WPDesktop"];
			var mobileFound:Bool = false;
			for (i in 0...match.length) 
			{
				if (Browser.navigator.userAgent.indexOf(match[i]) != -1) {
					mobileFound = true;
					break;
				}
			}
			if (mobileFound) {
				_manufacturer = "mobile";
			}
			else {
				_manufacturer = "windows";
			}
		#else
			_os = Capabilities.os.toLowerCase();
			_manufacturer = Capabilities.manufacturer.toLowerCase();
		#end
		
		if (_manufacturer.indexOf("windows") != -1 || _manufacturer.indexOf("osx") != -1 )
			_isMobile = false;
		else
			_isMobile = true;

		_isDesktop = !_isMobile;
			
		screenWidth = Math.max( Capabilities.screenResolutionX, Capabilities.screenResolutionY);
		screenHeight = Math.min( Capabilities.screenResolutionX, Capabilities.screenResolutionY);
		dpi = Capabilities.screenDPI;
		
		var dPixel:Float = Math.sqrt( Math.pow(screenWidth, 2) + Math.pow(screenHeight, 2) );
		physicalScreenSize = dPixel / dpi; 
		
		if (_isMobile)
		{
			if (_manufacturer.indexOf("android") != -1 )
				_isAndroid = true;
				
			//TODO: check if on ios manufacturer returns 'apple'
			if (_manufacturer.indexOf("apple") != -1 )
				_isIOS = true;
			
			
			if ((physicalScreenSize > _tabletScreenMinimumInches) )
				_isTablet = true;
			else
				_isPhone = true;
			
			if (physicalScreenSize < 7){
				_isCardboardCompatible = true;
			}
			else {
				_isCardboardCompatible = false;
			}
		}
		
	}
	
	public function new() 
	{
		
	}
	
}