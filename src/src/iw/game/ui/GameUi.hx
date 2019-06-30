package iw.game.ui;

import h2d.Bitmap;
import h2d.Flow;
import h2d.Object;
import h2d.Text;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.util.DeviceData;
import hpp.util.Language;
import hxd.Res;
import iw.game.TrickCalculator.TrickDirection;
import iw.game.TrickCalculator.TrickType;
import iw.game.World.Controller;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class GameUi extends Object
{
	var pauseRequest:Void->Void = _;
	var level:UInt = _;
	var gameTime:Observable<Float> = _;
	var collectedCoins:Observable<UInt> = _;
	var totalCoinCount:UInt = _;
	var lifeCount:Observable<UInt> = _;
	var isGamePaused:Observable<Bool> = _;
	var isGameStarted:Observable<Bool> = _;

	var info:Object;
	var notificationUi:NotificationUi;
	var startCounterUi:StartCounterUi;
	var levelInfoUi:LevelInfoUi;
	var pauseButton:BaseButton;

	var touchControlLeft:BaseButton;
	var touchControlRight:BaseButton;
	var touchControlUp:BaseButton;
	var touchControlDown:BaseButton;

	public var touchState:Controller = {
		up: false,
		down: false,
		left: false,
		right: false
	};

	public function new(parent:Object)
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
		info = new Object(this);
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
		levelInfoUi.y = 12;

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

		if (DeviceData.isMobile())
		{
			var rightBlock = new Flow(this);
			rightBlock.layout = Horizontal;
			rightBlock.horizontalSpacing = 20;
			var t = Res.image.ui.touch_accelerate.toTile();
			t.dx = -t.width;
			t.flipX();
			touchControlDown = new BaseButton(rightBlock, {
				onPush: function(_) { touchState.down = true; },
				onRelease: function(_) { touchState.down = false; },
				baseGraphic: t,
				overScale: .95
			});
			touchControlUp = new BaseButton(rightBlock, {
				onPush: function(_) { touchState.up = true; },
				onRelease: function(_) { touchState.up = false; },
				baseGraphic: Res.image.ui.touch_accelerate.toTile(),
				overScale: .95
			});
			rightBlock.x = HppG.stage2d.width - rightBlock.getSize().width - 10;
			rightBlock.y = HppG.stage2d.height - rightBlock.getSize().height - 10;

			var leftBlock = new Flow(this);
			leftBlock.layout = Horizontal;
			leftBlock.horizontalSpacing = 20;
			t = Res.image.ui.touch_rotate.toTile();
			t.dx = -t.width;
			t.flipX();
			touchControlLeft = new BaseButton(leftBlock, {
				onPush: function(_) { touchState.left = true; },
				onRelease: function(_) { touchState.left = false; },
				baseGraphic: t,
				overScale: .95
			});
			touchControlRight = new BaseButton(leftBlock, {
				onPush: function(_) { touchState.right = true; },
				onRelease: function(_) { touchState.right = false; },
				baseGraphic: Res.image.ui.touch_rotate.toTile(),
				overScale: .95
			});
			leftBlock.x = 10;
			leftBlock.y = HppG.stage2d.height - leftBlock.getSize().height - 10;
		}
	}

	public function onTrick(t)
	{
		SoundManager.playTrickSound();

		switch (t)
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
	}

	public function showCounter()
	{
		startCounterUi.start();
	}

	public function reset()
	{
		notificationUi.reset();

		touchState.up = false;
		touchState.down = false;
		touchState.left = false;
		touchState.right = false;
	}

	public function dispose()
	{
		notificationUi.dispose();
		notificationUi = null;
	}
}