package;

import js.Browser;

/**
 * ...
 * @author P.J.Shand
 */
class DeviceInfo
{
	private static var _isMobile:Bool;
	private static var _isDesktop:Bool;
	
	private static var _isIOS:Bool;
	private static var _isAndroid:Bool;
	private static var _isBlackBerry:Bool;
	private static var _isOpera:Bool;
	private static var _isWindowsMobile:Bool;
	
	private static var checked:Bool = false;
	
	public static var isMobile(get, null):Bool;
	public static var isDesktop(get, null):Bool;
	public static var isIOS(get, null):Bool;
	public static var isAndroid(get, null):Bool;
	public static var isBlackBerry(get, null):Bool;
	public static var isOpera(get, null):Bool;
	public static var isWindowsMobile(get, null):Bool;
	
	public function new() 
	{
		
	}
	
	static function get_isMobile():Bool 
	{
		check();
		return _isMobile;
	}
	
	static function get_isDesktop():Bool 
	{
		check();
		return _isDesktop;
	}
	
	
	static function get_isIOS():Bool 
	{
		check();
		return _isIOS;
	}
	
	static function get_isAndroid():Bool 
	{
		check();
		return _isAndroid;
	}
	
	static function get_isBlackBerry():Bool 
	{
		check();
		return _isBlackBerry;
	}
	
	static function get_isOpera():Bool 
	{
		check();
		return _isOpera;
	}
	
	static function get_isWindowsMobile():Bool 
	{
		check();
		return _isWindowsMobile;
	}
	
	static private function check() 
	{
		if (checked == true) return;
		#if js
			var userAgent = Browser.navigator.userAgent;
			if (userAgent.indexOf("Android") != -1) {
				_isIOS = _isBlackBerry = _isOpera = _isWindowsMobile = _isDesktop = false;
				_isAndroid = _isMobile = true;
			}
			else if (userAgent.indexOf("BlackBerry") != -1) {
				_isIOS = _isAndroid = _isOpera = _isWindowsMobile = _isDesktop = false;
				_isBlackBerry = _isMobile = true;
			}
			else if (userAgent.indexOf("iPhone") != -1 || userAgent.indexOf("iPad") != -1 || userAgent.indexOf("iPod") != -1) {
				_isAndroid = _isBlackBerry = _isOpera = _isWindowsMobile = _isDesktop = false;
				_isIOS = _isMobile = true;
			}
			else if (userAgent.indexOf("Opera Mini") != -1) {
				_isIOS = _isBlackBerry = _isAndroid = _isWindowsMobile = _isDesktop = false;
				_isOpera = _isMobile = true;
			}
			else if (userAgent.indexOf("IEMobile") != -1) {
				_isIOS = _isBlackBerry = _isOpera = _isAndroid = _isDesktop = false;
				_isWindowsMobile = _isMobile = true;
			}
			else {
				_isIOS = _isBlackBerry = _isOpera = _isWindowsMobile = _isAndroid = _isMobile = false;
				_isDesktop = true;
			}
		#end
	}
}

/*
var isMobile = {
    Android: function() {
        return navigator.userAgent.match(/Android/i);
    },
    BlackBerry: function() {
        return navigator.userAgent.match(/BlackBerry/i);
    },
    iOS: function() {
        return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    },
    Opera: function() {
        return navigator.userAgent.match(/Opera Mini/i);
    },
    Windows: function() {
        return navigator.userAgent.match(/IEMobile/i);
    },
    any: function() {
        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
    }
};

if(isMobile.any()){
    // Mobile!
} else {
    // Not mobile
}*/