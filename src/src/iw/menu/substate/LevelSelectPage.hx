package iw.menu.substate;

import h2d.Flow;
import iw.AppModel;
import iw.menu.ui.LevelButton;
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
class LevelSelectPage extends Base2dSubState
{
	var startLevel:UInt->Void;
	var appModel:AppModel;
	var onBackRequest:Void->Void;

	var backButton:BaseButton;
	var levelButtons:Array<LevelButton> = [];

	// Manually saved because with @:tink every params will be null in the build function
	public function new(
		startLevel:UInt->Void,
		appModel:AppModel,
		onBackRequest:Void->Void
	){
		this.startLevel = startLevel;
		this.appModel = appModel;
		this.onBackRequest = onBackRequest;

		super();
	}

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
		flow.layout = Horizontal;
		flow.horizontalSpacing = 20;
		flow.verticalSpacing = 20;
		flow.multiline = true;
		flow.maxWidth = HppG.stage2d.width;

		// +1 because demo level is the first level
		for (i in 0...12) levelButtons.push(new LevelButton(flow, startLevel.bind(i + 1), i + 1, appModel.getLevelData(i + 1).levelData.starValues));

		flow.x = HppG.stage2d.width / 2 - flow.getSize().width / 2;
		flow.y = 50;
	}

	override public function onOpen():Void
	{
		for (button in levelButtons) button.refresh(appModel.levelStates.get(button.id));
	}
}