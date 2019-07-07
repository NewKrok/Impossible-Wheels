package iw;

import h2d.Object;
import h2d.Text;
import h3d.Engine;
import hpp.heaps.ui.PlaceHolder;
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

		new PlaceHolder(this, 75, 30, 0x0, 1);

		fpsText = new Text(Fonts.DEFAULT_S, this);
		fpsText.textColor = 0xFFFF00;
		fpsText.x = 9;
		fpsText.y = 2;
	}

	public function update()
	{
		var fps = Engine.getCurrent().fps;

		fpsText.text = Math.floor(fps) + " fps" + "\n";
		fpsText.textColor = fps < 40 ? 0xFF0000 : 0xFFFF00;
	}
}