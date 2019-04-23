package iw.game.ui;

import h2d.Bitmap;
import h2d.Flow;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LifeUi extends Flow
{
	var icons:Array<Bitmap> = [];

	public function new(p, lifeCount:Observable<UInt>)
	{
		super(p);

		isVertical = false;
		horizontalSpacing = 10;

		for (i in 0...3)
		{
			var icon = new Bitmap(Res.image.ui.hearth_icon.toTile(), this);
			icons.push(icon);
		}

		lifeCount.bind(function(v)
		{
			for (i in 0...3) icons[i].alpha = (i >= v) ? .3 : 1;
		});
	}
}