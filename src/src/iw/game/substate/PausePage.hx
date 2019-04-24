package iw.game.substate;

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
class PausePage extends Base2dSubState
{
	var onResumeRequest:Void->Void;
	var onRestartRequest:Void->Void;
	var onExitRequest:Void->Void;

	var resumeButton:BaseButton;
	var restartButton:BaseButton;
	var exitButton:BaseButton;

	var fullBackground:Graphics;
	var titleBackground:Graphics;

	public function new(
		onResumeRequest:Void->Void,
		onRestartRequest:Void->Void,
		onExitRequest:Void->Void
	){
		this.onResumeRequest = onResumeRequest;
		this.onRestartRequest = onRestartRequest;
		this.onExitRequest = onExitRequest;

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
		titleText.text = Language.get("paused");
		titleText.maxWidth = titleText.calcTextWidth(titleText.text);
		titleText.x = HppG.stage2d.width / 2 - titleText.textWidth / 2;
		titleText.y = 43 / 2 - titleText.textHeight / 2;

		var flow = new Flow(content);
		flow.isVertical = false;
		flow.horizontalSpacing = 20;

		resumeButton = new BaseButton(flow, {
			onClick: function(_) { onResumeRequest(); },
			labelText: Language.get("resume"),
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

		exitButton = new BaseButton(flow, {
			onClick: function(_) { onExitRequest(); },
			labelText: Language.get("exit"),
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
	}
}