package iw.menu.substate;

import com.greensock.TweenMax;
import h2d.Flow;
import iw.AppModel;
import iw.menu.ui.SettingsEntry;
import hpp.heaps.Base2dSubState;
import hpp.heaps.HppG;
import hpp.heaps.ui.BaseButton;
import hpp.util.JsFullScreenUtil;
import hpp.util.Language;
import hxd.Res;
import iw.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SettingsPage extends Base2dSubState
{
	var appModel:AppModel;
	var onBackRequest:Void->Void;

	var backButton:BaseButton;

	var languageEntry:SettingsEntry;
	var soundEntry:SettingsEntry;
	var musicEntry:SettingsEntry;
	var effectsEntry:SettingsEntry;
	var fullscreenEntry:SettingsEntry;

	// Manually saved because with @:tink every params will be null in the build function
	public function new(
		appModel:AppModel,
		onBackRequest:Void->Void
	){
		this.appModel = appModel;
		this.onBackRequest = onBackRequest;

		#if js
			untyped __js__('window.addEventListener("resize", ()=>this.updateFullScreenState())');
		#end

		super();
	}

	function updateFullScreenState() fullscreenEntry.chooseOption(JsFullScreenUtil.isFullScreen());

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

		var flow = new Flow(container);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;
		flow.y = 50;

		languageEntry = new SettingsEntry(
			flow,
			"lang",
			"eng",
			"hun",
			function() { appModel.changeLanguage(LangId.En); },
			function() { appModel.changeLanguage(LangId.Hu); },
			appModel.language == LangId.En
		);

		soundEntry = new SettingsEntry(
			flow,
			"sound",
			"on",
			"off",
			appModel.setIsSoundEnabled.bind(true),
			appModel.setIsSoundEnabled.bind(false),
			appModel.isSoundEnabled
		);

		musicEntry = new SettingsEntry(
			flow,
			"music",
			"on",
			"off",
			appModel.setIsMusicEnabled.bind(true),
			appModel.setIsMusicEnabled.bind(false),
			appModel.isMusicEnabled
		);

		effectsEntry = new SettingsEntry(
			flow,
			"effects",
			"on",
			"off",
			appModel.setIsEffectEnabled.bind(true),
			appModel.setIsEffectEnabled.bind(false),
			appModel.isEffectEnabled
		);

		if (!appModel.isMobile)
		{
			fullscreenEntry = new SettingsEntry(
				flow,
				"fullscreen",
				"on",
				"off",
				JsFullScreenUtil.requestFullScreen,
				JsFullScreenUtil.cancelFullScreen,
				JsFullScreenUtil.isFullScreen()
			);
		}
	}

	override public function onOpen():Void
	{
		languageEntry.refresh();
		languageEntry.alpha = 0;
		TweenMax.to(languageEntry, .4, {
			alpha: 1,
		});

		soundEntry.refresh();
		soundEntry.alpha = 0;
		TweenMax.to(soundEntry, .4, {
			alpha: 1,
			delay: .2,
		});

		musicEntry.refresh();
		musicEntry.alpha = 0;
		TweenMax.to(musicEntry, .4, {
			alpha: 1,
			delay: .4,
		});

		effectsEntry.refresh();
		effectsEntry.alpha = 0;
		TweenMax.to(effectsEntry, .4, {
			alpha: 1,
			delay: .6,
		});

		if (fullscreenEntry != null)
		{
			fullscreenEntry.refresh();
			fullscreenEntry.alpha = 0;
			TweenMax.to(fullscreenEntry, .4, {
				alpha: 1,
				delay: .8,
			});
		}
	}

	override public function dispose():Void
	{
		TweenMax.killTweensOf(languageEntry);
		TweenMax.killTweensOf(soundEntry);
		TweenMax.killTweensOf(musicEntry);
		TweenMax.killTweensOf(effectsEntry);
		TweenMax.killTweensOf(fullscreenEntry);

		Language.unregisterTextHolder(cast backButton.label);

		backButton.dispose();
		backButton = null;

		languageEntry.dispose();
		languageEntry = null;
		soundEntry.dispose();
		soundEntry = null;
		musicEntry.dispose();
		musicEntry = null;
		effectsEntry.dispose();
		effectsEntry = null;
		fullscreenEntry.dispose();
		fullscreenEntry = null;

		super.dispose();
	}
}