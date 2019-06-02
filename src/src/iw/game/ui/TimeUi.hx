package iw.game.ui;

import h2d.Object;
import h2d.Text;
import hpp.util.TimeUtil;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
class TimeUi extends Object
{
	public function new(p, time:Observable<Float>)
	{
		super(p);

		var timeText = new Text(Fonts.DEFAULT_M, this);
		timeText.smooth = true;
		timeText.textColor = 0xFFFFFF;
		timeText.textAlign = Align.Left;

		var timeSmallText = new Text(Fonts.DEFAULT_S, this);
		timeSmallText.smooth = true;
		timeSmallText.textColor = 0xFFFFFF;
		timeSmallText.textAlign = Align.Left;
		timeSmallText.y = 6;

		time.bind(function(v)
		{
			var time:Array<String> = TimeUtil.timeStampToFormattedTime(v, TimeUtil.TIME_FORMAT_MM_SS_MS).split(".");
			timeText.text = time[0] + ".";
			timeSmallText.text = time[1];
			timeSmallText.x = timeText.textWidth + 3;
		});
	}
}