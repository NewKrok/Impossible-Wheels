package iw;

import h2d.Object;
import h2d.filter.Glow;
import h3d.Engine;
import iw.util.SaveUtil;
import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Interactive;
import h2d.Text;
import iw.util.SaveUtil.LevelState;
import iw.util.StarCountUtil;
import hpp.util.Language;
import hpp.util.NumberUtil;
import hxd.Cursor;
import hxd.Res;
import iw.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class FPSView extends Object
{
	var fpsText:Text;

	public function new(parent)
	{
		super(parent);

		fpsText = new Text(Fonts.DEFAULT_L, this);
		fpsText.textColor = 0xFFFF00;
		fpsText.filter = new Glow(0x0);
		fpsText.x = 10;
		fpsText.y = 10;
	}

	public function update()
	{
		// Just for debugging
		if (true)
		{
			var fps = Engine.getCurrent().fps;
			fpsText.text = Math.floor(fps) + " fps";
			fpsText.textColor = fps < 40 ? 0xFF0000 : 0xFFFF00;
		}
	}
}