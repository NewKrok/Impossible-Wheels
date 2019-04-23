package iw.game.ui;

import h2d.Bitmap;
import h2d.Object;
import h2d.Text;
import h2d.Text.Align;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StartCounterEntry extends Object
{
	public function new(p:Object, labelText:String)
	{
		super(p);

		new Bitmap(Res.image.ui.counter_background.toTile(), this);

		var label = new Text(Fonts.DEFAULT_L, this);
		label.smooth = true;
		label.textColor = 0xFFFFFF;
		label.textAlign = Align.Left;
		label.text = labelText;
		label.x = 20;
		label.y = getBounds().height / 2 - label.textHeight / 2;
	}
}