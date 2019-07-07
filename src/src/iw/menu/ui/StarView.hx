package iw.menu.ui;

import h2d.Bitmap;
import h2d.Flow;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StarView extends Flow
{
	var stars:Array<Bitmap> = [];

	public function new(parent)
	{
		super(parent);

		for (i in 0...3)
		{
			var s = new Bitmap(Res.image.ui.star_icon.toTile());
			s.smooth = true;
			stars.push(s);
		}
	}

	public function setCount(count:UInt)
	{
		for (i in 0...3) removeChild(stars[i]);
		for (i in 0...count) addChild(stars[i]);
	}
}