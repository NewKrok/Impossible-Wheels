package iw.game.substate;

import com.greensock.TweenMax;
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
import iw.game.ui.CoinUi;
import iw.game.ui.LifeUi;
import iw.game.ui.ResultEntry;
import iw.game.ui.TimeUi;
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
	var totalCoinCount:UInt;
	var opponentScore:UInt;

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
	var totalScoreResult:ResultEntry;
	var opponentScoreResult:ResultEntry;

	public function new(
		lifeValue:Observable<UInt>,
		timeValue:Observable<Float>,
		coinValue:Observable<UInt>,
		totalCoinCount:UInt,
		opponentScore:UInt
	){
		this.lifeValue = lifeValue;
		this.timeValue = timeValue;
		this.coinValue = coinValue;
		this.totalCoinCount = totalCoinCount;
		this.opponentScore = opponentScore;

		super();
	}

	override function build():Void
	{
		fullBackground = new Graphics(container);

		content = new Flow(container);
		content.isVertical = true;
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
		flow.isVertical = false;
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
			labelText: Language.get("resume"),
			baseGraphic: Res.image.ui.long_button.toTile(),
			font: Fonts.DEFAULT_M,
			overAlpha: .5
		});
	}

	override public function onOpen():Void
	{
		super.onOpen();

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

		exitButton.alpha = 0;
		exitButton.y = 20;
		TweenMax.killTweensOf(exitButton);
		TweenMax.to(exitButton, .3, { alpha: 1, y: 0, onUpdate: function () { exitButton.y = exitButton.y; } });

		// Really dirty but when I'm using just this: "delay: .1" or ".delay(.1)" it breaks completly the "y tween"
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

		lifeScoreResult.alpha = 0;
		lifeScoreResult.reset();

		timeScoreResult.alpha = 0;
		timeScoreResult.reset();

		coinScoreResult.alpha = 0;
		coinScoreResult.reset();

		totalScoreResult.alpha = 0;
		totalScoreResult.reset();

		opponentScoreResult.alpha = 0;
		opponentScoreResult.reset();

		TweenMax.delayedCall(1, showLifeResult);
		TweenMax.delayedCall(3, showTimeResult);
		TweenMax.delayedCall(5, showCoinResult);
		TweenMax.delayedCall(7, showTotalResult);
		TweenMax.delayedCall(9, showOpponentsResult);

		content.y = HppG.stage2d.height / 2 - content.getSize().height / 2;
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

	function showTotalResult()
	{
		var totalScore = 0;
		totalScore += ScoreCalculator.lifeCountToScore(lifeValue.value);
		totalScore += ScoreCalculator.elapsedTimeToScore(timeValue.value);
		totalScore += ScoreCalculator.collectedCoinsToScore(coinValue.value);
		totalScore += coinValue.value == totalCoinCount ? ScoreCalculator.getCollectedCoinMaxBonus() : 0;

		totalScoreResult.alpha = 1;
		totalScoreResult.setScore(totalScore);
	}

	function showOpponentsResult()
	{
		opponentScoreResult.alpha = 1;
		opponentScoreResult.setScore(opponentScore);
	}

	override public function onClose():Void
	{
		TweenMax.killDelayedCallsTo(showLifeResult);
		TweenMax.killDelayedCallsTo(showTimeResult);
		TweenMax.killDelayedCallsTo(showCoinResult);
		TweenMax.killDelayedCallsTo(showTotalResult);
		TweenMax.killDelayedCallsTo(showOpponentsResult);
	}
}