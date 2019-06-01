package iw.game.substate;

import com.greensock.TweenMax;
import h2d.Flow;
import h2d.Graphics;
import h2d.Object;
import h2d.Text;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.util.Language;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelCompletePage extends Base2dSubState
{
	var onExitRequest:Void->Void;
	var onRestartRequest:Void->Void;
	var onNextLevelRequest:Void->Void;

	var exitButton:BaseButton;
	var restartButton:BaseButton;
	var nextLevelButton:BaseButton;

	var fullBackground:Graphics;
	var titleBackground:Graphics;

	public function new(
		onExitRequest:Void->Void,
		onRestartRequest:Void->Void,
		onNextLevelRequest:Void->Void
	){
		this.onExitRequest = onExitRequest;
		this.onRestartRequest = onRestartRequest;
		this.onNextLevelRequest = onNextLevelRequest;

		super();
	}

	override function build():Void
	{
		fullBackground = new Graphics(container);

		var content = new Flow(container);
		content.isVertical = true;
		content.verticalSpacing = 20;
		content.horizontalAlign = FlowAlign.Middle;

		var title = new Object(content);

		titleBackground = new Graphics(title);
		var titleText = new Text(Fonts.DEFAULT_M, title);
		titleText.smooth = true;
		titleText.textColor = 0xFFFFFF;
		titleText.textAlign = Align.Center;
		titleText.text = Language.get("completed");
		titleText.maxWidth = titleText.calcTextWidth(titleText.text);
		titleText.x = HppG.stage2d.width / 2 - titleText.textWidth / 2;
		titleText.y = 43 / 2 - titleText.textHeight / 2;

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

		content.y = HppG.stage2d.height / 2 - content.getSize().height / 2;
	}

	override public function onOpen():Void
	{
		super.onOpen();

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
	}
}