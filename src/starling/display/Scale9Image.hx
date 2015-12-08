package starling.display;

import openfl.geom.Rectangle;

import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class Scale9Image extends Sprite
{
	private var _tl:Image;
	private var _tc:Image;
	private var _tr:Image;
	private var _cl:Image;
	private var _cc:Image;
	private var _cr:Image;
	private var _bl:Image;
	private var _bc:Image;
	private var _br:Image;
	
	private var _grid:Rectangle;
	private var _tW:Float;
	private var _tH:Float;
	private var scaleIfSmaller:Bool;
	
	private var _width:Float;
	private var _height:Float;
	
	
	function getScaleIfSmaller():Bool
	{
		return scaleIfSmaller;
	}

	function setScaleIfSmaller(value:Bool):Void
	{
		if(scaleIfSmaller == value) return;
		
		scaleIfSmaller = value;
	}

	override function get_height():Float
	{
		return _height;
	}
	
	override function set_height(value:Float):Float
	{
		if (_height != value)
		{
			_height = value;
			apply9Scale(_width, _height);
		}
		return _height;
	}
	
	override function get_width():Float
	{
		return _width;
	}
	
	override function set_width(value:Float):Float
	{
		if (_width != value)
		{
			_width = value;
			apply9Scale(_width, _height);
		}
		return _width;
	}
	
	public function new(texture:Texture, centerRect:Rectangle):Void
	{
		super();
		_tW = texture.width;
		_tH = texture.height;
		_grid = centerRect;
		
		_width = _tW;
		_height = _tH;
		
		_tl = new Image(Texture.fromTexture(texture, new Rectangle(0,0,_grid.x,_grid.y)));
		
		_tc = new Image(Texture.fromTexture(texture, new Rectangle(_grid.x,0,_grid.width,_grid.y)));
		
		_tr = new Image(Texture.fromTexture(texture, new Rectangle(_grid.x + _grid.width,0,texture.width - (_grid.x + _grid.width), _grid.y)));
		
		_cl = new Image(Texture.fromTexture(texture, new Rectangle(0,_grid.y,_grid.x,_grid.height)));
		
		_cc = new Image(Texture.fromTexture(texture, new Rectangle(_grid.x,_grid.y,_grid.width,_grid.height)));
		
		_cr = new Image(Texture.fromTexture(texture, new Rectangle(_grid.x + _grid.width,_grid.y,texture.width - (_grid.x + _grid.width),_grid.height)));
		
		_bl = new Image(Texture.fromTexture(texture, new Rectangle(0,_grid.y + _grid.height,_grid.x,texture.height -(_grid.y + _grid.height))));
		
		_bc = new Image(Texture.fromTexture(texture, new Rectangle(_grid.x,_grid.y + _grid.height,_grid.width,texture.height -(_grid.y + _grid.height))));
		
		_br = new Image(Texture.fromTexture(texture, new Rectangle(_grid.x + _grid.width,_grid.y + _grid.height,texture.width -(_grid.x + _grid.width),texture.height -(_grid.y + _grid.height))));

		_tc.x = _cc.x = _bc.x = _grid.x;
		_cl.y = _cc.y = _cr.y = _grid.y;
		
		addChild(_tl);
		addChild(_tc);
		addChild(_tr);
		
		addChild(_cl);
		addChild(_cc);
		addChild(_cr);
		
		addChild(_bl);
		addChild(_bc);
		addChild(_br);
		
		apply9Scale(_tW, _tH);
	}
	
	private function apply9Scale(x:Float, y:Float ):Void
	{	
		var width:Float = x/scaleX;
		var height:Float = y/scaleY;
		
		var bh:Float;
		var lw:Float;
		var rw:Float;
		var pct:Float;
		var rx:Float;
		var cw:Float;
		var tw:Float;
		var by:Float;
		var bx:Float;
		var ch:Float;
		
		if(width < _tW-_grid.width)
		{
			_tc.visible = false;
			_bc.visible = false;
			
			if(!scaleIfSmaller)
			{
				lw = _grid.x;
				
				_tl.width = lw;
				_cl.width = lw;
				_bl.width = lw;
				
				_tr.x = lw;
				_cr.x = lw;
				_br.x = lw;
				
				rw = (_tW - _grid.x - _grid.width);
				_tr.width = rw;
				_cr.width = rw;
				_br.width = rw;
			}
			else
			{
				pct = width / (_tW -_grid.width);
				lw = _grid.x * pct;
				_tl.width = lw;
				_cl.width = lw;
				_bl.width = lw;

				rw = (_tW - _grid.x - _grid.width) * pct;
				_tr.width = rw;
				_cr.width = rw;
				_br.width = rw;
				
				rx = width - rw;
				_tr.x = rx;
				_cr.x = rx;
				_br.x = rx;
				
			}
		}
		else
		{
			_tc.visible = true;
			_bc.visible = true;
							
			lw = _grid.x;
			_tl.width = lw;
			_cl.width = lw;
			_bl.width = lw;
			
			rw = (_tW - _grid.x - _grid.width);
			_tr.width = rw;
			_cr.width = rw;
			_br.width = rw;
			
			rx = width - rw;
			_tr.x = rx;
			_cr.x = rx;
			_br.x = rx;
			
			cw = rx - _grid.x;
			_tc.width = cw;
			_cc.width = cw;
			_bc.width = cw;
		}
		
		if(height < _tH-_grid.height)
		{
			_cl.visible = false;
			_cr.visible = false;
			
			if(!scaleIfSmaller)
			{
				tw = _grid.y;

				_tl.height = tw;
				_tc.height = tw;
				_tr.height = tw;
			
				_br.y = tw;
				_bc.y = tw;
				_bl.y = tw;

				bh = (_tH - _grid.y - _grid.height);
				_br.height = bh;
				_bc.height = bh;
				_bl.height = bh;
			}
			else
			{
				pct = height / (_tH -_grid.height);
				
				tw = _grid.y * pct;
				_tl.height = tw;
				_tc.height = tw;
				_tr.height = tw;
				
				bh = (_tH - _grid.y - _grid.height) * pct;
				_br.height = bh;
				_bc.height = bh;
				_bl.height = bh;
				
				bx = height - bh;
				_br.y = bx;
				_bc.y = bx;
				_bl.y = bx;
				
			}
		}
		else
		{
			_cl.visible = true;
			_cr.visible = true;
			
			_tl.height = _grid.y;
			_tc.height = _grid.y;
			_tr.height = _grid.y;
			
			bh = (_tH - _grid.y - _grid.height);
			
			_bl.height = bh;
			_bc.height = bh;
			_br.height = bh;
			
			by = height - bh;
			_bl.y =	by;
			_bc.y =	by;
			_br.y =	by;

			ch = by - _grid.y;
			_cl.height = ch;
			_cc.height = ch;
			_cr.height = ch;				
		}
		
		_cc.visible = _cl.visible && _tc.visible;
	}
}
