package iw.game.substate;

import com.greensock.TweenMax;
import com.greensock.easing.Back;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Graphics;
import h2d.Object;
import h2d.Text;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.heaps.ui.PlaceHolder;
import hpp.util.Language;
import hxd.Res;
import iw.game.GameCompletedPage;
import iw.game.ui.CoinUi;
import iw.game.ui.LifeUi;
import iw.game.ui.ResultEntry;
import iw.game.ui.TimeUi;
import iw.menu.ui.StarView;
import iw.util.ScoreCalculator;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class LevelCompletePage extends Base2dSubState
{
	var lifeValue:Observable<UInt>;
	var timeValue:Observable<Float>;
	var coinValue:Observable<UInt>;
	var trickValue:Observable<UInt>;
	var totalCoinCount:UInt;
	var opponentScore:UInt;
	var totalScore:Observable<UInt>;

	var onExitRequest:Void->Void = _;
	var onRestartRequest:Void->Void = _;
	var onNextLevelRequest:Void->Void = _;

	var content:Flow;

	var exitButton:BaseButton;
	var restartButton:BaseButton;
	var nextLevelButton:BaseButton;

	var fullBackground:Graphics;
	var titleBackground:Graphics;
	var placeHolder1:Graphics;
	var placeHolder2:Graphics;
	var placeHolder3:Graphics;

	var lifeScoreResult:ResultEntry;
	var timeScoreResult:ResultEntry;
	var coinScoreResult:ResultEntry;
	var trickScoreResult:ResultEntry;
	var totalScoreResult:ResultEntry;
	var opponentScoreResult:ResultEntry;

	var failBadge:Object;

	var successBadge:Object;
	var successBadgeFlow:Flow;
	var starView:StarView;
	var isNewHighScore:Bool = false;

	public var needShowGameCompletedWindow:Bool = false;
	public var isLastLevel:Bool = false;
	public var isNextLevelEnabled:Bool = false;

	public function new(
		lifeValue:Observable<UInt>,
		timeValue:Observable<Float>,
		coinValue:Observable<UInt>,
		trickValue:Observable<UInt>,
		totalCoinCount:UInt,
		opponentScore:UInt,
		totalScore:Observable<UInt>
	){
		this.lifeValue = lifeValue;
		this.timeValue = timeValue;
		this.coinValue = coinValue;
		this.trickValue = trickValue;
		this.totalCoinCount = totalCoinCount;
		this.opponentScore = opponentScore;
		this.totalScore = totalScore;

		super();
	}

	override function build():Void
	{
		fullBackground = new Graphics(container);

		content = new Flow(container);
		content.layout = Vertical;
		content.verticalSpacing = 10;
		content.horizontalAlign = FlowAlign.Middle;

		var title = new Object(content);

		titleBackground = new Graphics(title);
		var titleText = new Text(Fonts.DEFAULT_L, title);
		titleText.smooth = true;
		titleText.textColor = 0xFFFFFF;
		titleText.textAlign = Align.Center;
		titleText.text = Language.get("your_score");
		titleText.maxWidth = titleText.calcTextWidth(titleText.text);
		titleText.x = HppG.stage2d.width / 2 - titleText.textWidth / 2;
		titleText.y = 43 / 2 - titleText.textHeight / 2;

		placeHolder1 = new Graphics(content);

		lifeScoreResult = new ResultEntry(
			content,
			new LifeUi(null, lifeValue)
		);

		timeScoreResult = new ResultEntry(
			content,
			new TimeUi(null, timeValue)
		);

		coinScoreResult = new ResultEntry(
			content,
			new CoinUi(null, coinValue, totalCoinCount)
		);

		var trickIcon = new Bitmap(Res.image.ui.tricks.toTile());
		trickIcon.smooth = true;
		trickScoreResult = new ResultEntry(
			content,
			trickIcon
		);

		var totalScoreLabel = new Text(Fonts.DEFAULT_M);
		totalScoreLabel.smooth = true;
		totalScoreLabel.textColor = 0xFFFFFF;
		totalScoreLabel.textAlign = Align.Left;
		totalScoreLabel.text = Language.get("total_score");
		totalScoreResult = new ResultEntry(
			content,
			totalScoreLabel
		);

		placeHolder2 = new Graphics(content);

		var opponentScoreLabel = new Text(Fonts.DEFAULT_M);
		opponentScoreLabel.smooth = true;
		opponentScoreLabel.textColor = 0xFFFFFF;
		opponentScoreLabel.textAlign = Align.Left;
		opponentScoreLabel.text = Language.get("opponent_score");
		opponentScoreResult = new ResultEntry(
			content,
			opponentScoreLabel
		);

		placeHolder3 = new Graphics(content);

		var flow = new Flow(content);
		flow.layout = Horizontal;
		flow.horizontalSpacing = 20;

		exitButton = new BaseButton(flow, {
			onClick: function(_) { onExitRequest(); },
			labelText: Language.get("exit"),
			baseGraphic: Res.image.ui.long_button.toTile(),
			font: Fonts.DEFAULT_M,
			overAlpha: .5
		});

		restartButton = new BaseButton(flow, {
			onClick: function(_) { onRestartRequest(); },
			labelText: Language.get("restart"),
			baseGraphic: Res.image.ui.long_button.toTile(),
			font: Fonts.DEFAULT_M,
			overAlpha: .5
		});

		nextLevelButton = new BaseButton(flow, {
			onClick: function(_) { onNextLevelRequest(); },
			labelText: Language.get("next_level"),
			baseGraphic: Res.image.ui.long_button.toTile(),
			font: Fonts.DEFAULT_M,
			overAlpha: .5
		});

		failBadge = new Object(container);
		var failBadgeBmp = new Bitmap(Res.image.ui.level_result_badge_failed.toTile(), failBadge);
		failBadgeBmp.smooth = true;
		var failBadgeLabel = new Text(Fonts.DEFAULT_L, failBadge);
		failBadgeLabel.smooth = true;
		failBadgeLabel.textColor = 0xFFFFFF;
		failBadgeLabel.textAlign = Align.Center;
		failBadgeLabel.text = Language.get("level_failed");
		failBadgeLabel.maxWidth = 200;
		failBadgeLabel.x = failBadge.getSize().width / 2 - 100;
		failBadgeLabel.y = failBadge.getSize().height / 2 - failBadgeLabel.textHeight / 2;

		successBadge = new Object(container);

		var successBadgeBmp = new Bitmap(Res.image.ui.level_result_badge_completed.toTile(), successBadge);
		successBadgeBmp.smooth = true;

		successBadgeFlow = new Flow(successBadge);
		successBadgeFlow.layout = Vertical;
		successBadgeFlow.verticalSpacing = 10;
		successBadgeFlow.horizontalAlign = FlowAlign.Middle;

		// Force offset because the horizontal flow align with centered text is a magic
		var forceOffsetContainer = new Object(successBadgeFlow);
		var successBadgeLabel = new Text(Fonts.DEFAULT_L, forceOffsetContainer);
		successBadgeLabel.smooth = true;
		successBadgeLabel.textColor = 0x000000;
		successBadgeLabel.textAlign = Align.Center;
		successBadgeLabel.text = Language.get("level_completed");
		successBadgeLabel.maxWidth = 200;
		successBadgeLabel.x = -10;

		starView = new StarView(successBadgeFlow);
	}

	public function setStarCount(c) starView.setCount(c);
	public function setIsNewHighScore(v) isNewHighScore = v;

	override public function onOpen():Void
	{
		super.onOpen();

		successBadgeFlow.reflow();
		successBadgeFlow.x = successBadge.getSize().width / 2 - successBadgeFlow.getSize().width / 2;
		successBadgeFlow.y = successBadge.getSize().height / 2 - successBadgeFlow.getSize().height / 2;

		placeHolder1.beginFill(0x000000, 0);
		placeHolder1.drawRect(0, 0, 1, 10);
		placeHolder1.endFill();

		placeHolder2.beginFill(0x000000, 0);
		placeHolder2.drawRect(0, 0, 1, 20);
		placeHolder2.endFill();

		placeHolder3.beginFill(0x000000, 0);
		placeHolder3.drawRect(0, 0, 1, 20);
		placeHolder3.endFill();

		fullBackground.beginFill(0x000000, .5);
		fullBackground.drawRect(0, 0, HppG.stage2d.width, HppG.stage2d.height);
		fullBackground.endFill();

		titleBackground.beginFill(0x000000, 1);
		titleBackground.drawRect(0, 0, HppG.stage2d.width, 43);
		titleBackground.endFill();

		exitButton.visible = false;
		restartButton.visible = false;
		nextLevelButton.visible = false;

		lifeScoreResult.alpha = 0;
		lifeScoreResult.reset();

		timeScoreResult.alpha = 0;
		timeScoreResult.reset();

		coinScoreResult.alpha = 0;
		coinScoreResult.reset();

		trickScoreResult.alpha = 0;
		trickScoreResult.reset();

		totalScoreResult.alpha = 0;
		totalScoreResult.reset();

		opponentScoreResult.alpha = 0;
		opponentScoreResult.reset();

		TweenMax.delayedCall(1, showLifeResult);
		TweenMax.delayedCall(3, showTimeResult);
		TweenMax.delayedCall(5, showCoinResult);
		TweenMax.delayedCall(7, showTrickResult);
		TweenMax.delayedCall(9, showTotalResult);
		TweenMax.delayedCall(11, showOpponentsResult);

		content.y = HppG.stage2d.height / 2 - content.getSize().height / 2;
		failBadge.y = successBadge.y = content.y + 55;

		TweenMax.killTweensOf(failBadge);
		failBadge.alpha = 0;

		TweenMax.killTweensOf(successBadge);
		successBadge.alpha = 0;

		TweenMax.delayedCall(13, function()
		{
			if (totalScore > opponentScore) handleWin();
			else handleLoose();

			exitButton.visible = true;
			exitButton.alpha = 0;
			exitButton.y = 20;
			TweenMax.killTweensOf(exitButton);
			TweenMax.to(exitButton, .3, { alpha: 1, y: 0, onUpdate: function () { exitButton.y = exitButton.y; } });

			// Really dirty but when I'm using just this: "delay: .1" or ".delay(.1)" it breaks completly the "y tween"
			restartButton.visible = true;
			restartButton.alpha = 0;
			TweenMax.killTweensOf(restartButton);
			TweenMax.to(restartButton, .1, {
				onComplete: function ()
				{
					restartButton.y = 20;
					TweenMax.to(restartButton, .3, {
						alpha: 1,
						y: 0,
						onUpdate: function () { restartButton.y = restartButton.y; }
					});
				}
			});

			content.y = HppG.stage2d.height / 2 - content.getSize().height / 2;
			failBadge.y = successBadge.y = content.y + 55;
		});
	}

	function showLifeResult()
	{
		lifeScoreResult.alpha = 1;
		lifeScoreResult.setScore(ScoreCalculator.lifeCountToScore(lifeValue.value));
	}

	function showTimeResult()
	{
		timeScoreResult.alpha = 1;
		timeScoreResult.setScore(ScoreCalculator.elapsedTimeToScore(timeValue.value));
	}

	function showCoinResult()
	{
		coinScoreResult.alpha = 1;
		coinScoreResult.setScore(
			ScoreCalculator.collectedCoinsToScore(coinValue.value),
			coinValue.value == totalCoinCount ? ScoreCalculator.getCollectedCoinMaxBonus() : 0
		);
	}

	function showTrickResult()
	{
		trickScoreResult.alpha = 1;
		trickScoreResult.setScore(trickValue.value);
	}

	function showTotalResult()
	{
		totalScoreResult.alpha = 1;
		totalScoreResult.setScore(totalScore, 0, isNewHighScore);
	}

	function showOpponentsResult()
	{
		opponentScoreResult.alpha = 1;
		opponentScoreResult.setScore(opponentScore);
	}

	function handleWin()
	{
		SoundManager.playLevelCompletedSound();

		successBadge.scaleX = successBadge.scaleY = 1.4;
		successBadge.x = HppG.stage2d.width - 220 - 60;
		TweenMax.to(successBadge, .5, {
			alpha: 1,
			scaleX: 1,
			scaleY: 1,
			x: HppG.stage2d.width - 220 - 80,
			onUpdate: function()
			{
				successBadge.x = successBadge.x;
				successBadge.scaleX = successBadge.scaleX;
				successBadge.scaleY = successBadge.scaleY;
			},
			onComplete: needShowGameCompletedWindow ? function()
			{
				new GameCompletedPage(container);
			} : null,
			ease: Back.easeOut
		});

		updateNextLevelButton();
	}

	function handleLoose()
	{
		SoundManager.playLevelFailedSound();

		failBadge.scaleX = failBadge.scaleY = 1.4;
		failBadge.x = 90;
		TweenMax.to(failBadge, .5, {
			alpha: 1,
			scaleX: 1,
			scaleY: 1,
			x: 70,
			onUpdate: function() {
				failBadge.x = failBadge.x;
				failBadge.scaleX = failBadge.scaleX;
				failBadge.scaleY = failBadge.scaleY;
			},
			ease: Back.easeOut
		});

		updateNextLevelButton();
	}

	function updateNextLevelButton()
	{
		if (isNextLevelEnabled)
		{
			nextLevelButton.visible = true;
			nextLevelButton.alpha = 0;
			TweenMax.killTweensOf(nextLevelButton);
			TweenMax.to(nextLevelButton, .2, {
				onComplete: function ()
				{
					nextLevelButton.y = 20;
					TweenMax.to(nextLevelButton, .3, {
						alpha: 1,
						y: 0,
						onUpdate: function () { nextLevelButton.y = nextLevelButton.y; }
					});
				}
			});
		}
	}

	override public function onClose():Void
	{
		TweenMax.killDelayedCallsTo(showLifeResult);
		TweenMax.killDelayedCallsTo(showTimeResult);
		TweenMax.killDelayedCallsTo(showCoinResult);
		TweenMax.killDelayedCallsTo(showTrickResult);
		TweenMax.killDelayedCallsTo(showTotalResult);
		TweenMax.killDelayedCallsTo(showOpponentsResult);
		TweenMax.killDelayedCallsTo(handleWin);
		TweenMax.killDelayedCallsTo(handleLoose);
	}
}