package iw.game;

import h2d.Flow;
import h2d.Graphics;
import h2d.Object;
import h2d.Text;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.heaps.ui.PlaceHolder;
import hpp.util.Language;
import hxd.Res;
import js.Browser;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameCompletedPage extends Object
{
	var fullBackground:Graphics;
	var titleBackground:Graphics;

	var closeButton:BaseButton;
	var fppButton:BaseButton;
	var githubButton:BaseButton;
	var facebookButton:BaseButton;
	var youtubeButton:BaseButton;

	public function new(p:Object)
	{
		super(p);

		fullBackground = new Graphics(this);
		fullBackground.beginFill(0x000000, 1);
		fullBackground.drawRect(0, 0, HppG.stage2d.width, HppG.stage2d.height);
		fullBackground.endFill();

		createFlag();

		var content = new Flow(this);
		content.layout = Vertical;
		content.verticalSpacing = 30;
		content.horizontalAlign = FlowAlign.Middle;

		var title = new Object(content);

		titleBackground = new Graphics(title);
		titleBackground.beginFill(0xFFFFFF, 1);
		titleBackground.drawRect(0, 0, HppG.stage2d.width, 43);
		titleBackground.endFill();

		var titleText = new Text(Fonts.DEFAULT_M, title);
		titleText.smooth = true;
		titleText.textColor = 0x000000;
		titleText.textAlign = Align.Center;
		titleText.text = Language.get("game_completed");
		titleText.maxWidth = titleText.calcTextWidth(titleText.text);
		titleText.x = HppG.stage2d.width / 2 - titleText.textWidth / 2;
		titleText.y = 43 / 2 - titleText.textHeight / 2;

		closeButton = new BaseButton(content, {
			onClick: function(_) { destroy(); },
			labelText: Language.get("im_the_king"),
			baseGraphic: Res.image.ui.long_button_white.toTile(),
			font: Fonts.DEFAULT_M,
			textColor: 0x000000,
			overAlpha: .5
		});

		new PlaceHolder(content, 1, 20);

		var shareText = new Text(Fonts.DEFAULT_S, content);
		shareText.smooth = true;
		shareText.textColor = 0xFFFFFF;
		shareText.text = Language.get("please_share");

		var contactBlock = new Object(content);

		var contactBackground = new Graphics(contactBlock);
		contactBackground.beginFill(0xFFFFFF, 1);
		contactBackground.drawRect(0, 0, HppG.stage2d.width, 63);
		contactBackground.endFill();

		var flow = new Flow(contactBlock);
		flow.layout = Horizontal;
		flow.horizontalSpacing = 20;

		fppButton = new BaseButton(flow, {
			onClick: function(_) { Browser.window.open("https://flashplusplus.net/", "_blank"); },
			baseGraphic: Res.image.ui.fpp_button.toTile(),
			overAlpha: .5
		});

		githubButton = new BaseButton(flow, {
			onClick: function(_) { Browser.window.open("https://github.com/NewKrok/Impossible-Wheels", "_blank"); },
			baseGraphic: Res.image.ui.github_logo.toTile(),
			overAlpha: .5
		});

		facebookButton = new BaseButton(flow, {
			onClick: function(_) { Browser.window.open("https://www.facebook.com/flashplusplus", "_blank"); },
			baseGraphic: Res.image.ui.fb_logo.toTile(),
			overAlpha: .5
		});

		youtubeButton = new BaseButton(flow, {
			onClick: function(_) { Browser.window.open("https://www.youtube.com/channel/UCw3dGeqWx24LyRi4BnpDwCg/featured", "_blank"); },
			baseGraphic: Res.image.ui.youtube_logo.toTile(),
			overAlpha: .5
		});

		flow.x = HppG.stage2d.width / 2 - flow.getSize().width / 2;
		flow.y = 63 / 2 - flow.getSize().height / 2;

		content.y = HppG.stage2d.height / 2 - content.getSize().height / 2;
	}

	function createFlag()
	{
		var f = new Graphics(this);
		f.beginFill(0xFFFFFF, 1);
		var blockSize = 29;

		for (i in 0...Math.floor(HppG.stage2d.width / blockSize))
		{
			if (i % 2 == 0)
			{
				f.drawRect(i * blockSize, 0, blockSize, blockSize);
				f.drawRect(i * blockSize, blockSize * 2, blockSize, blockSize);
				f.drawRect(i * blockSize, HppG.stage2d.height - blockSize, blockSize, blockSize);
				f.drawRect(i * blockSize, HppG.stage2d.height - blockSize * 3, blockSize, blockSize);
			}
			if (i % 2 == 1)
			{
				f.drawRect(i * blockSize, blockSize, blockSize, blockSize);
				f.drawRect(i * blockSize, HppG.stage2d.height - blockSize * 2, blockSize, blockSize);
			}
		}

		f.endFill();
	}

	function destroy()
	{
		closeButton.isEnabled = false;
		closeButton = null;

		fppButton.isEnabled = false;
		fppButton = null;

		githubButton.isEnabled = false;
		githubButton = null;

		facebookButton.isEnabled = false;
		facebookButton = null;

		youtubeButton.isEnabled = false;
		youtubeButton = null;

		this.remove();
	}
}