package iw.menu.ui;

import h2d.Flow;
import h2d.Graphics;
import h2d.Object;
import h2d.Text;
import hpp.heaps.HppG;
import hpp.heaps.ui.LinkedButton;
import hpp.util.Language;
import hxd.Res;
import iw.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SettingsEntry extends Object
{
	var labelId:String = _;
	var optionALabelId:String = _;
	var optionBLabelId:String = _;
	var onOptionASelected:Void->Void = _;
	var onOptionBSelected:Void->Void = _;
	var isFirstSelected:Bool = _;

	var flow:Flow;
	// It's needed because in some reason after second opening the flow size is different
	var flowWidth:Float;

	var background:Graphics;
	var flowBackground:Graphics;
	var labelBackground:Graphics;

	var labelText:Text;

	var buttonA:LinkedButton;
	var buttonB:LinkedButton;

	public function new(parent:Object)
	{
		super(parent);

		background = new Graphics(this);
		flowBackground = new Graphics(this);

		flow = new Flow(this);
		flow.horizontalSpacing = 10;
		flow.verticalAlign = FlowAlign.Top;

		createLabel(flow);

		buttonA = createOption(flow, optionALabelId, onOptionASelected);
		buttonB = createOption(flow, optionBLabelId, onOptionBSelected);
		buttonA.linkToButton(buttonB);
		if (isFirstSelected) buttonA.isSelected = true;
		else buttonB.isSelected = true;

		flow.x = flowBackground.x = HppG.stage2d.width / 2 - flow.getSize().width / 2;
		flowBackground.x -= 10;
		flowWidth = flow.getSize().width;
	}

	function createLabel(flow)
	{
		var label = new Object(flow);

		labelBackground = new Graphics(label);
		// It was needed because of the proper horizontal position
		labelBackground.drawRect(0, 0, 220, 43);

		labelText = new Text(Fonts.DEFAULT_L, label);
		labelText.smooth = true;
		labelText.textColor = 0x000000;
		labelText.textAlign = Align.Center;
		labelText.maxWidth = 220;
		Language.registerTextHolder(cast labelText, labelId);
		labelText.y = 43 / 2 - labelText.textHeight / 2;
	}

	function createOption(flow, labelId, onClick):LinkedButton
	{
		var button = new LinkedButton(flow, {
			onClick: function(_) {
				SoundManager.playClickSound();
				onClick();
			},
			baseGraphic: Res.image.ui.toggle_button.toTile(),
			overGraphic: Res.image.ui.toggle_button_selected.toTile(),
			selectedGraphic: Res.image.ui.toggle_button_selected.toTile(),
			font: Fonts.DEFAULT_M,
			textOffset: { x: 0, y: -9 },
			overAlpha: .5
		});
		Language.registerTextHolder(cast button.label, labelId);

		return button;
	}

	public function chooseOption(isFirst:Bool):Void
	{
		if (isFirst) buttonA.isSelected = true;
		else buttonB.isSelected = true;
	}

	// In some reason if I don't redraw it here, it won't be visible after the second opening
	public function refresh()
	{
		background.beginFill(0x000000);
		background.drawRect(0, 0, HppG.stage2d.width, 43);
		background.endFill();

		flowBackground.beginFill(0xFFFFFF);
		flowBackground.drawRect(0, 0, flowWidth + 20, 43);
		flowBackground.endFill();

		labelBackground.drawRect(0, 0, 190, 43);
	}

	public function dispose()
	{
		Language.unregisterTextHolder(cast labelText);
		Language.unregisterTextHolder(cast cast buttonA.label);
		Language.unregisterTextHolder(cast cast buttonB.label);

		buttonA.dispose();
		buttonA = null;
		buttonB.dispose();
		buttonB = null;

		background.clear();
		background = null;
		flowBackground.clear();
		flowBackground = null;
		labelBackground.clear();
		labelBackground = null;

		removeChildren();
	}
}