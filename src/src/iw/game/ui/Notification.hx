package iw.game.ui;

import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Object;
import h2d.Text;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Notification extends Flow
{
	public function new(p:Object, message:String, icon:Bitmap, onRemove:Notification->Void)
	{
		super(p);

		layout = Horizontal;
		horizontalSpacing = 10;

		if (icon != null) addChild(icon);

		var label = new Text(Fonts.DEFAULT_M, this);
		label.smooth = true;
		label.textColor = 0x000000;
		label.textAlign = Align.Left;
		label.text = message;

		TweenMax.delayedCall(1, onRemove.bind(this));
	}
}