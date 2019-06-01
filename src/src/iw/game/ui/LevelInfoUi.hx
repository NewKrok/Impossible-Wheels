package iw.game.ui;

import com.greensock.TweenMax;
import com.greensock.easing.Back;
import h2d.Graphics;
import h2d.Mask;
import h2d.Object;
import h2d.Text;
import hpp.util.Language;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelInfoUi extends Object
{
	var container:Object;

	public function new(p, level:UInt)
	{
		super(p);

		var mask = new Mask(cast 366, 44, this);

		container = new Object(mask);

		var g = new Graphics(container);
		g.beginFill();
		g.drawRect(0, 0, mask.width, mask.height + 10);
		g.endFill();

		var label = new Text(Fonts.DEFAULT_M, container);
		label.smooth = true;
		label.textColor = 0xFFFFFF;
		label.textAlign = Align.Center;
		label.text = Language.get("level", ["$id" => level + 1]);
		label.x = mask.width / 2;
		label.y = mask.height / 2 - label.textHeight / 2;
	}

	public function hide()
		TweenMax.to(container, .5, {
			y: container.getSize().height,
			onUpdate: function () { container.y = container.y; },
			ease: Back.easeIn
		});

	public function reset() container.y = 0;
}