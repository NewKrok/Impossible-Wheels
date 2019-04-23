package iw.game.ui;

import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Object;

/**
 * ...
 * @author Krisztian Somoracz
 */
class NotificationUi extends Object
{
	var notifications:Array<Notification> = [];

	public function show(message:String, icon:Bitmap = null)
	{
		var n = new Notification(this, message, icon, onNotificationRemove);
		n.y = getBounds().height + n.getBounds().height;
		notifications.push(n);

		order();
	}

	function onNotificationRemove(n)
	{
		notifications.remove(n);

		TweenMax.killTweensOf(n);
		TweenMax.to(n, .5, {
			x: -n.getBounds().width,
			alpha: 0,
			onUpdate: function(){ n.x = n.x; }
		});

		order();
	}

	function order()
	{
		for (i in 0...notifications.length)
		{
			var n = notifications[i];

			TweenMax.killTweensOf(n);
			TweenMax.to(n, .5, {
				y: i * n.getBounds().height + i * 5,
				delay: i * .2,
				onUpdate: function(){ n.y = n.y; }
			});
		}
	}
}