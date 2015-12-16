package starling.openfl; #if (!flash)

@:native("openfl.display3D.Context3DBufferUsage") enum Context3DBufferUsage {
	
	STATIC_DRAW;
	DYNAMIC_DRAW;
	
}
#else
typedef Context3DBufferUsage = openfl.display3D.Context3DBufferUsage;
#end