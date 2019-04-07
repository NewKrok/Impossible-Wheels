package iw.menu.ui;

import h2d.Flow;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Layers;
import h2d.Object;
import h2d.Text.Align;
import hxd.Cursor;
import hpp.heaps.HppG;
import hpp.heaps.ui.TextWithSize;
import hpp.util.Language;
import iw.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class CreditEntry extends Layers
{
	var onClick:Void->Void = _;
	var labelId:String = _;
	var firstInfo:String = _;
	var secondaryInfo:String = _;

	var flow:Flow;
	// It's needed because in some reason after second opening the flow size is different
	var flowWidth:Float;

	var label:Object;
	var firstInfoLabel:Object;

	var background:Graphics;
	var flowBackground:Graphics;
	var infoBackground:Graphics;

	var interactive:Interactive;

	public function new(parent:Object)
	{
		super(parent);

		background = new Graphics(this);
		flowBackground = new Graphics(this);

		flow = new Flow(this);
		flow.horizontalSpacing = 10;
		flow.verticalAlign = FlowAlign.Top;

		label = createLabel(flow, false, null, labelId);
		firstInfoLabel = createLabel(flow, true, firstInfo);
		createLabel(flow, false, secondaryInfo);

		flow.x = flowBackground.x = HppG.stage2d.width / 2 - flow.getSize().width / 2;
		flowBackground.x -= 10;

		interactive = new Interactive(HppG.stage2d.width, 43, this);
		interactive.cursor = Cursor.Button;
		interactive.onClick = function(_) { onClick(); };
		interactive.onOver = function(_) { alpha = .5; };
		interactive.onOut = function(_) { alpha = 1; };
	}

	function createLabel(flow, isReversed:Bool, content:String, contentId:String = null)
	{
		var label = new Object(flow);

		if (isReversed) infoBackground = new Graphics(label);

		var labelText = new TextWithSize(Fonts.DEFAULT_L, label);
		labelText.smooth = true;
		labelText.textColor = isReversed ? 0xFFFFFF : 0x000000;
		labelText.textAlign = Align.Center;

		if (content == null) Language.registerTextHolder(cast labelText, contentId);
		else labelText.text = content;

		// It's really-really strange, but without it, it's potision is totally wrong
		labelText.maxWidth = labelText.calcTextWidth(labelText.text);

		if (isReversed)
		{
			labelText.x = 10;
			infoBackground.drawRect(0, 0, labelText.maxWidth + 20, 43);
		}

		labelText.y = 43 / 2 - labelText.textHeight / 2;

		return label;
	}

	public function enable():Void interactive.visible = true;
	public function disable():Void interactive.visible = false;

	// In some reason if I don't redraw it here, it won't be visible after the second opening
	public function refresh()
	{
		background.beginFill(0x000000);
		background.drawRect(0, 0, HppG.stage2d.width, 43);
		background.endFill();

		// It looks there are some serious issues with text size calculation after content change so I need to use this hack
		var labelText:TextWithSize = cast label.getChildAt(0);
		labelText.maxWidth = HppG.stage2d.width;
		labelText.maxWidth = labelText.textWidth;

		var infoText:TextWithSize = cast firstInfoLabel.getChildAt(1);
		infoText.maxWidth = HppG.stage2d.width;
		infoText.maxWidth = infoText.textWidth;

		flowBackground.beginFill(0xFFFFFF);
		flowBackground.drawRect(0, 0, flow.getSize().width + 20, 43);
		flowBackground.endFill();

		infoBackground.beginFill(0x000000);
		infoBackground.drawRect(0, 0, infoText.maxWidth + 20, 43);
		infoBackground.endFill();

		flow.reflow();
	}
}