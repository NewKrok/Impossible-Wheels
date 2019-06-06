package iw.menu.substate;

import com.greensock.TweenMax;
import com.greensock.easing.Quad;
import h2d.Bitmap;
import h2d.Flow;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hxd.Res;
import js.Browser;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class WelcomePage extends Base2dSubState
{
	var openSettingsPage:Void->Void = _;
	var openInfoPage:Void->Void = _;
	var openLevelSelectorPage:Void->Void = _;

	var logo:Bitmap;
	var leftFlow:Flow;
	var rightFlow:Flow;

	var startButton:BaseButton;
	var fppButton:BaseButton;
	var githubButton:BaseButton;
	var facebookButton:BaseButton;
	var youtubeButton:BaseButton;
	var settingsButton:BaseButton;
	var infoButton:BaseButton;

	override function build():Void
	{
		logo = new Bitmap(Res.image.ui.game_logo.toTile(), container);
		logo.smooth = true;
		logo.tile.dx = cast -logo.tile.width / 2;
		logo.tile.dy = cast -logo.tile.height / 2;
		logo.x = HppG.stage2d.width / 2;
		logo.y = 115;

		startButton = new BaseButton(container, {
			onClick: function(_) { openLevelSelectorPage(); },
			baseGraphic: Res.image.ui.start_button.toTile(),
			overAlpha: .5
		});
		startButton.x = HppG.stage2d.width / 2 - startButton.getSize().width / 2;
		startButton.y = HppG.stage2d.height / 2 - startButton.getSize().height / 2 + 50;

		buildLeftFlow();
		buildRightFlow();
	}

	function buildLeftFlow()
	{
		leftFlow = new Flow(container);
		leftFlow.layout = Horizontal;
		leftFlow.horizontalSpacing = 20;

		fppButton = new BaseButton(leftFlow, {
			onClick: function(_) { Browser.window.open("https://flashplusplus.net/", "_blank"); },
			baseGraphic: Res.image.ui.fpp_button.toTile(),
			overAlpha: .5
		});

		githubButton = new BaseButton(leftFlow, {
			onClick: function(_) { Browser.window.open("https://github.com/NewKrok/Impossible-Wheels", "_blank"); },
			baseGraphic: Res.image.ui.github_logo.toTile(),
			overAlpha: .5
		});

		facebookButton = new BaseButton(leftFlow, {
			onClick: function(_) { Browser.window.open("https://www.facebook.com/flashplusplus", "_blank"); },
			baseGraphic: Res.image.ui.fb_logo.toTile(),
			overAlpha: .5
		});

		youtubeButton = new BaseButton(leftFlow, {
			onClick: function(_) { Browser.window.open("https://www.youtube.com/channel/UCw3dGeqWx24LyRi4BnpDwCg/featured", "_blank"); },
			baseGraphic: Res.image.ui.youtube_logo.toTile(),
			overAlpha: .5
		});

		leftFlow.x = 20;
		leftFlow.y = HppG.stage2d.height - leftFlow.innerHeight - 20;
	}

	function buildRightFlow()
	{
		rightFlow = new Flow(container);
		rightFlow.layout = Horizontal;
		rightFlow.horizontalSpacing = 20;

		settingsButton = new BaseButton(rightFlow, {
			onClick: function(_) { openSettingsPage(); },
			baseGraphic: Res.image.ui.settings_button.toTile(),
			overAlpha: .5
		});

		infoButton = new BaseButton(rightFlow, {
			onClick: function(_) { openInfoPage(); },
			baseGraphic: Res.image.ui.info_button.toTile(),
			overAlpha: .5
		});

		rightFlow.x = HppG.stage2d.width - rightFlow.innerWidth - 20;
		rightFlow.y = HppG.stage2d.height - rightFlow.innerHeight - 20;
	}

	override public function onOpen():Void
	{
		logo.alpha = 0;
		TweenMax.to(logo, 1, { alpha: 1, onComplete: function() {
			TweenMax.to(logo, 2, {
				y: 125,
				alpha: 1,
				onUpdate: function(){ logo.y = logo.y; },
				ease: Quad.easeOut
			})
			.yoyo(true)
			.repeat( -1)
			.repeatDelay(.2);
		}});

		leftFlow.enableInteractive = true;
		rightFlow.enableInteractive = true;

		leftFlow.alpha = 0;
		leftFlow.y += 20;
		rightFlow.alpha = 0;
		rightFlow.y += 20;

		TweenMax.to(leftFlow, .5, {
			alpha: 1,
			y: leftFlow.y - 20,
			onUpdate: function() {
				leftFlow.y = rightFlow.y = leftFlow.y;
				rightFlow.alpha = leftFlow.alpha;
			},
			delay: 1,
			onComplete: function() {
				leftFlow.enableInteractive = false;
				rightFlow.enableInteractive = false;
			}
		});

		startButton.alpha = 0;
		startButton.y += 20;
		startButton.isEnabled = false;
		TweenMax.to(startButton, .5, {
			alpha: 1,
			y: startButton.y - 20,
			onUpdate: function() {
				startButton.y = startButton.y;
			},
			delay: 1.2,
			onComplete: function() {
				startButton.isEnabled = true;
			}
		});
	}

	override public function onClose():Void
	{
		TweenMax.killTweensOf(logo);
	}
}