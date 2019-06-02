package iw.game.ui;

import h2d.Bitmap;
import h2d.Layers;
import h2d.Text;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.util.Language;
import hxd.Res;
import iw.game.TrickCalculator.TrickDirection;
import iw.game.TrickCalculator.TrickType;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class GameUi extends Layers
{
	var pauseRequest:Void->Void = _;
	var level:UInt = _;
	var gameTime:Observable<Float> = _;
	var collectedCoins:Observable<UInt> = _;
	var totalCoinCount:UInt = _;
	var lifeCount:Observable<UInt> = _;
	var isGamePaused:Observable<Bool> = _;
	var isGameStarted:Observable<Bool> = _;

	var info:Layers;
	var notificationUi:NotificationUi;
	var startCounterUi:StartCounterUi;
	var levelInfoUi:LevelInfoUi;
	var pauseButton:BaseButton;

	public function new(parent:Layers)
	{
		super(parent);

		this.pauseRequest = pauseRequest;

		build();

		isGamePaused.bind(function(v)
		{
			if (v && isGameStarted.value) startCounterUi.stop();
			pauseButton.visible = pauseButton.isEnabled = isGameStarted.value && !v;
		});

		isGameStarted.bind(function(v)
		{
			pauseButton.visible = pauseButton.isEnabled = isGamePaused.value ? false : v;

			if (v) levelInfoUi.hide();
			else levelInfoUi.reset();
		});
	}

	function build()
	{
		info = new Layers(this);
		info.x = 20;
		info.y = 20;

		new Bitmap(Res.image.ui.game_info_back.toTile(), info);

		var lifeUi = new LifeUi(info, lifeCount);
		lifeUi.x = 13;
		lifeUi.y = 24;

		var timeUi = new TimeUi(info, gameTime);
		timeUi.x = 130;
		timeUi.y = 18;

		var cointText = new Text(Fonts.DEFAULT_M, info);
		cointText.smooth = true;
		cointText.textColor = 0xFFFFFF;
		cointText.textAlign = Align.Center;
		cointText.x = 316;
		cointText.y = 18;
		cointText.text = "0/" + totalCoinCount;

		collectedCoins.bind(function(v) {
			cointText.text = v + "/" + totalCoinCount;
		});

		levelInfoUi = new LevelInfoUi(info, level);
		levelInfoUi.y = 1200;

		pauseButton = new BaseButton(this, {
			onClick: function(_) { pauseRequest(); },
			baseGraphic: Res.image.ui.pause_button.toTile(),
			overAlpha: .5
		});
		pauseButton.x = HppG.stage2d.width - pauseButton.getSize().width - 20;
		pauseButton.y = 20;

		notificationUi = new NotificationUi(this);
		notificationUi.x = 20;
		notificationUi.y = info.y + info.getSize().height + 15;

		startCounterUi = new StartCounterUi(this);
	}

	public function onTrick(t) switch (t)
	{
		case TrickType.Flip(d, m): notificationUi.show(
			(m > 1 ? m + "x " : "") + Language.get(d == TrickDirection.Front ? "frontflip" : "backflip"),
			new Bitmap(d == TrickDirection.Front ? Res.image.ui.frontflip_icon.toTile() : Res.image.ui.backflip_icon.toTile())
		);

		case TrickType.Wheelie(d, l): notificationUi.show(
			(Math.floor(l / 100) / 10) + "s " + Language.get("wheelie"),
			new Bitmap(d == TrickDirection.Front ? Res.image.ui.front_wheelie_icon.toTile() : Res.image.ui.back_wheelie_icon.toTile())
		);
	}

	public function showCounter()
	{
		startCounterUi.start();
	}
}