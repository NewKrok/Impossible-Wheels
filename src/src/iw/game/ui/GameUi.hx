package iw.game.ui;

import h2d.Bitmap;
import h2d.Flow;
import h2d.Layers;
import h2d.Text;
import hpp.util.TimeUtil;
import hxd.Res;
import iw.game.TrickCalculator.TrickType;
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
	var collectedCoins:Observable<UInt> = _;
	var lifeCount:Observable<UInt> = _;

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

		var lifeUi = new Life(info, lifeCount);
		lifeUi.x = 13;
		lifeUi.y = 24;

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
		cointText.text = "0/99";

		gameTime.bind(function(v) {
			var time:Array<String> = TimeUtil.timeStampToFormattedTime(v, TimeUtil.TIME_FORMAT_MM_SS_MS).split(".");
			timeText.text = time[0] + ".";
			timeSmallText.text = time[1];
		});

		collectedCoins.bind(function(v) {
			cointText.text = v + "/99";
		});
	}

	public function onTrick(t) switch (t)
	{
		case TrickType.Flip(d, m): trace("Flip", d, m);
		case TrickType.Wheelie(d, l): trace("Wheelie", d, l);
	}
}