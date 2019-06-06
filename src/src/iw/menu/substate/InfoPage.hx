package iw.menu.substate;

import com.greensock.TweenMax;
import h2d.Flow;
import h2d.Graphics;
import iw.menu.ui.CreditEntry;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.heaps.ui.PlaceHolder;
import hpp.util.Language;
import hxd.Res;
import iw.Fonts;
import js.Browser;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class InfoPage extends Base2dSubState
{
	var onBackRequest:Void->Void = _;

	var libraryBackground:Graphics;

	var backButton:BaseButton;
	var haxeButton:BaseButton;
	var heapsButton:BaseButton;
	var napeButton:BaseButton;
	var hppButton:BaseButton;
	var tweenmaxButton:BaseButton;
	var coconutButton:BaseButton;

	var devCredit:CreditEntry;
	var soundCredit:CreditEntry;

	override function build():Void
	{
		backButton = new BaseButton(container, {
			onClick: function(_) { onBackRequest(); },
			baseGraphic: Res.image.ui.small_button.toTile(),
			font: Fonts.DEFAULT_M,
			overAlpha: .5
		});
		Language.registerTextHolder(cast backButton.label, "back");
		backButton.x = HppG.stage2d.width / 2 - backButton.getSize().width / 2;
		backButton.y = HppG.stage2d.height - backButton.getSize().height - 30;

		libraryBackground = new Graphics(container);

		var entries:Flow = new Flow(container);
		entries.layout = Vertical;
		entries.horizontalAlign = FlowAlign.Middle;
		entries.verticalSpacing = 20;

		var libraries:Flow = new Flow(entries);
		libraries.layout = Horizontal;
		libraries.horizontalSpacing = 30;

		haxeButton = new BaseButton(libraries, {
			onClick: function(_) { Browser.window.open("https://haxe.org/", "_blank"); },
			baseGraphic: Res.image.ui.haxe_credit.toTile(),
			overAlpha: .5
		});

		heapsButton = new BaseButton(libraries, {
			onClick: function(_) { Browser.window.open("https://heaps.io/", "_blank"); },
			baseGraphic: Res.image.ui.heaps_credit.toTile(),
			overAlpha: .5
		});

		napeButton = new BaseButton(libraries, {
			onClick: function(_) { Browser.window.open("https://github.com/deltaluca/nape", "_blank"); },
			baseGraphic: Res.image.ui.nape_credit.toTile(),
			overAlpha: .5
		});

		hppButton = new BaseButton(libraries, {
			onClick: function(_) { Browser.window.open("https://github.com/NewKrok/HPP-Package", "_blank"); },
			baseGraphic: Res.image.ui.hpp_credit.toTile(),
			overAlpha: .5
		});

		tweenmaxButton = new BaseButton(libraries, {
			onClick: function(_) { Browser.window.open("https://greensock.com/tweenmax", "_blank"); },
			baseGraphic: Res.image.ui.tweenmax_credit.toTile(),
			overAlpha: .5
		});

		coconutButton = new BaseButton(libraries, {
			onClick: function(_) { Browser.window.open("https://lib.haxe.org/p/coconut.data", "_blank"); },
			baseGraphic: Res.image.ui.coconut_credit.toTile(),
			overAlpha: .5
		});

		new PlaceHolder(entries, 1, 20);
		devCredit = new CreditEntry(
			entries,
			function() { Browser.window.open("https://www.linkedin.com/in/krisztian-somoracz-8924b949", "_blank"); },
			"design_and_dev",
			"Krisztian Somoracz",
			"(NewKrok)"
		);

		soundCredit = new CreditEntry(
			entries,
			function() { Browser.window.open("https://soundimage.org/", "_blank"); },
			"sound_by",
			"Eric Matyas",
			"(soundimage.org)"
		);

		entries.y = HppG.stage2d.height / 2 - entries.innerHeight / 2 - 125;

		libraryBackground.y = entries.y + 70;
	}

	override public function onOpen():Void
	{
		// In some reason if I don't redraw it here, it won't be visible after the second opening
		libraryBackground.beginFill(0x000000, 1);
		libraryBackground.drawRect(0, 0, HppG.stage2d.width, 75);
		libraryBackground.endFill();

		var buttons:Array<BaseButton> = [
			haxeButton, heapsButton, napeButton, hppButton, tweenmaxButton, coconutButton
		];

		var index:UInt = 0;
		for (b in buttons)
		{
			b.isEnabled = false;
			b.alpha = 0;
			TweenMax.to(b, .4, {
				alpha: 1,
				delay: index * .2,
				onComplete: function(){ b.isEnabled = true; }
			});
			index++;
		}

		devCredit.refresh();
		//devCredit.disable();
		devCredit.alpha = 0;
		TweenMax.to(devCredit, .4, {
			alpha: 1,
			delay: 1,
			onComplete: function(){ devCredit.enable(); }
		});

		soundCredit.refresh();
		//soundCredit.disable();
		soundCredit.alpha = 0;
		TweenMax.to(soundCredit, .4, {
			alpha: 1,
			delay: 1.2,
			onComplete: function(){ soundCredit.enable(); }
		});
	}
}