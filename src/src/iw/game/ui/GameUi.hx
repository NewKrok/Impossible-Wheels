package iw.game.ui;

import h2d.Bitmap;
import h2d.Flow;
import h2d.Layers;
import h2d.Text;
import hpp.util.TimeUtil;
import hxd.Res;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class GameUi extends Layers
{
	var resumeRequest:Void->Void = _;
	var pauseRequest:Void->Void = _;
	var gameTime:Observable<Float> = _;

	var info:Layers;

	public function new(parent:Layers)
	{
		super(parent);

		this.resumeRequest = resumeRequest;
		this.pauseRequest = pauseRequest;

		build();
	}

	function build()
	{
		info = new Layers(this);
		info.x = 20;
		info.y = 20;

		new Bitmap(Res.image.ui.game_info_back.toTile(), info);

		var scoreText = new Text(Fonts.DEFAULT_M, info);
		scoreText.smooth = true;
		scoreText.textColor = 0xFFFFFF;
		scoreText.textAlign = Align.Center;
		scoreText.x = 58;
		scoreText.y = 18;
		scoreText.text = "99 999";

		var timeText = new Text(Fonts.DEFAULT_M, info);
		timeText.smooth = true;
		timeText.textColor = 0xFFFFFF;
		timeText.textAlign = Align.Right;
		timeText.x = 214;
		timeText.y = 18;

		var timeSmallText = new Text(Fonts.DEFAULT_S, info);
		timeSmallText.smooth = true;
		timeSmallText.textColor = 0xFFFFFF;
		timeSmallText.textAlign = Align.Left;
		timeSmallText.x = 214;
		timeSmallText.y = 24;
		timeSmallText.text = "999";

		var cointText = new Text(Fonts.DEFAULT_M, info);
		cointText.smooth = true;
		cointText.textColor = 0xFFFFFF;
		cointText.textAlign = Align.Center;
		cointText.x = 316;
		cointText.y = 18;
		cointText.text = "99/99";

		gameTime.bind(function(v) {
			var time:Array<String> = TimeUtil.timeStampToFormattedTime(v, TimeUtil.TIME_FORMAT_MM_SS_MS).split(".");
			timeText.text = time[0] + ".";
			timeSmallText.text = time[1];
		});
	}
}