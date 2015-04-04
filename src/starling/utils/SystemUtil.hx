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

import openfl.display3D.Context3D;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.system.Capabilities;

import starling.errors.AbstractClassError;

/** A utility class with methods related to the current platform and runtime. */
class SystemUtil
{
	private static var sInitialized:Bool = false;
	private static var sApplicationActive:Bool = true;
	private static var sWaitingCalls = new Array<Array<Dynamic>>();
	private static var sPlatform:String;
	private static var sVersion:String;
	private static var sAIR:Bool;
	private static var sSupportsDepthAndStencil:Bool = true;
	
	public static var isApplicationActive(get, null):Bool;
	public static var isAIR(get, null):Bool;
	public static var isDesktop(get, null):Bool;
	public static var platform(get, null):String;
	public static var version(get, null):String;
	public static var supportsRelaxedTargetClearRequirement(get, null):Bool;
	public static var supportsDepthAndStencil(get, null):Bool;
	public static var supportsVideoTexture(get, null):Bool;
	
	/** @private */
	public function new() { throw new AbstractClassError(); }
	
	/** Initializes the <code>ACTIVATE/DEACTIVATE</code> event handlers on the native
	 *  application. This method is automatically called by the Starling constructor. */
	public static function initialize():Void
	{
		if (sInitialized) return;
		
		sInitialized = true;
		sPlatform = Capabilities.version.substr(0, 3);
		sVersion = Capabilities.version.substr(4);
		
		trace("FIX");
		/*try
		{
			var nativeAppClass:Dynamic = getDefinitionByName("flash.desktop::NativeApplication");
			var nativeApp:EventDispatcher = nativeAppClass["nativeApplication"] as EventDispatcher;

			nativeApp.addEventListener(Event.ACTIVATE, onActivate, false, 0, true);
			nativeApp.addEventListener(Event.DEACTIVATE, onDeactivate, false, 0, true);

			var appDescriptor:Xml = nativeApp["applicationDescriptor"];
			var ns:Namespace = appDescriptor.namespace();
			var ds:String = appDescriptor.ns::initialWindow.ns::depthAndStencil.toString().toLowerCase();

			sSupportsDepthAndStencil = (ds == "true");
			sAIR = true;
		}
		catch (e:Error)
		{*/
			sAIR = false;
		//}
	}
	
	private static function onActivate(event:Dynamic):Void
	{
		sApplicationActive = true;
		
		for (call in sWaitingCalls)
			call[0].apply(null, call[1]);
		
		sWaitingCalls = new Array<Array<Dynamic>>();
	}
	
	private static function onDeactivate(event:Dynamic):Void
	{
		sApplicationActive = false;
	}
	
	/** Executes the given function with its arguments the next time the application is active.
	 *  (If it <em>is</em> active already, the call will be executed right away.) */
	public static function executeWhenApplicationIsActive(call:Dynamic, args:Array<Dynamic>):Void
	{
		initialize();
		
		if (sApplicationActive) call.apply(null, args);
		else sWaitingCalls.push([call, args]);
	}

	/** Indicates if the application is currently active. On Desktop, this means that it has
	 *  the focus; on mobile, that it is in the foreground. In the Flash Plugin, always
	 *  returns true. */
	public static function get_isApplicationActive():Bool
	{
		initialize();
		return sApplicationActive;
	}

	/** Indicates if the code is executed in an Adobe AIR runtime (true)
	 *  or Flash plugin/projector (false). */
	public static function get_isAIR():Bool
	{
		initialize();
		return sAIR;
	}
	
	/** Indicates if the code is executed on a Desktop computer with Windows, OS X or Linux
	 *  operating system. If the method returns 'false', it's probably a mobile device
	 *  or a Smart TV. */
	public static function get_isDesktop():Bool
	{
		initialize();
		return ~/(WIN|MAC|LNX)/.match(sPlatform);
	}
	
	/** Returns the three-letter platform string of the current system. These are
	 *  the most common platforms: <code>WIN, MAC, LNX, IOS, AND, QNX</code>. Except for the
	 *  last one, which indicates "Blackberry", all should be self-explanatory. */
	public static function get_platform():String
	{
		initialize();
		return sPlatform;
	}

	/** Returns the Flash Player/AIR version string. The format of the version number is:
	 *  <em>majorVersion,minorVersion,buildNumber,internalBuildNumber</em>. */
	public static function get_version():String
	{
		initialize();
		return sVersion;
	}

	/** Prior to Flash/AIR 15, there was a restriction that the clear function must be
	 *  called on a render target before drawing. This requirement was removed subsequently,
	 *  and this property indicates if that's the case in the current runtime. */
	public static function get_supportsRelaxedTargetClearRequirement():Bool
	{
		trace("FIX");
		return true;
		//return Std.parseInt(~/\d+/.exec(sVersion)[0]) >= 15;
	}

	/** Returns the value of the 'initialWindow.depthAndStencil' node of the application
	 *  descriptor, if this in an AIR app; otherwise always <code>true</code>. */
	public static function get_supportsDepthAndStencil():Bool
	{
		return sSupportsDepthAndStencil;
	}

	/** Indicates if Context3D supports video textures. At the time of this writing,
	 *  video textures are only supported on Windows, OS X and iOS, and only in AIR
	 *  applications (not the Flash Player). */
	public static function get_supportsVideoTexture():Bool
	{
		return Reflect.hasField(Context3D, "supportsVideoTexture");
	}
}