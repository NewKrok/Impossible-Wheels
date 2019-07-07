package iw.menu.ui;

import h2d.Object;
import iw.util.SaveUtil;
import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Interactive;
import h2d.Text;
import iw.util.SaveUtil.LevelState;
import iw.util.StarCountUtil;
import hpp.util.Language;
import hpp.util.NumberUtil;
import hxd.Cursor;
import hxd.Res;
import iw.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class LevelButton extends Object
{
	public var onClick:Void->Void = _;
	public var id(default, null):UInt = _;
	var starValues:Array<UInt> = _;

	var interactive:Interactive;
	var background:Bitmap;
	var playIcon:Bitmap;
	var starView:StarView;

	var levelDetailsFlow:Flow;
	var levelLabel:Text;
	var scoreText:Text;

	var unlockedFlow:Flow;
	var unlockText:Text;

	public function new(parent)
	{
		super(parent);

		background = new Bitmap(Res.image.ui.level_button_background.toTile(), this);
		background.smooth = true;
		background.y = 15;

		playIcon = new Bitmap(Res.image.ui.play_icon.toTile(), this);
		playIcon.smooth = true;
		playIcon.visible = false;
		playIcon.x = background.tile.width / 2 - playIcon.tile.width / 2;
		playIcon.y = 65;

		starView = new StarView(this);

		createLevelDetailsFlow();
		createUnlockedFlow();

		interactive = new Interactive(background.tile.width, background.tile.height, this);
		interactive.cursor = Cursor.Button;
		interactive.onClick = function(_) { onClick(); };
		interactive.onOver = function(_) {
			alpha = .5;
			levelDetailsFlow.visible = false;
			playIcon.visible = true;
		};
		interactive.onOut = function(_) {
			alpha = 1;
			levelDetailsFlow.visible = true;
			playIcon.visible = false;
		};
	}

	function createLevelDetailsFlow()
	{
		levelDetailsFlow = new Flow(this);
		levelDetailsFlow.layout = Vertical;
		levelDetailsFlow.verticalSpacing = 5;
		levelDetailsFlow.y = 53;

		levelLabel = new Text(Fonts.DEFAULT_S, levelDetailsFlow);
		levelLabel.smooth = true;
		levelLabel.textColor = 0xFFFFFF;
		levelLabel.textAlign = Align.Center;
		Language.registerTextHolder(cast levelLabel, "level", ["$id" => id]);

		scoreText = new Text(Fonts.DEFAULT_L, levelDetailsFlow);
		scoreText.smooth = true;
		scoreText.textColor = 0xFFFFFF;
		scoreText.textAlign = Align.Center;
	}

	function createUnlockedFlow()
	{
		unlockedFlow = new Flow(this);
		unlockedFlow.layout = Vertical;
		unlockedFlow.verticalSpacing = 5;
		unlockedFlow.horizontalAlign = FlowAlign.Middle;

		var icon = new Bitmap(Res.image.ui.locked_icon.toTile(), unlockedFlow);
		icon.tile.dx = 20;

		unlockText = new Text(Fonts.DEFAULT_S, unlockedFlow);
		unlockText.smooth = true;
		unlockText.textColor = 0xFFFFFF;
		unlockText.textAlign = Align.Center;
		unlockText.maxWidth = background.tile.width - 20;
		Language.registerTextHolder(cast unlockText, "unlock_info");

		unlockedFlow.x = 10;
	}

	public function refresh(levelState:LevelState)
	{
		alpha = 0;
		TweenMax.to(this, .4, {
			alpha: 1
		}).delay((id - 1) * .1);

		if (levelState == null || !levelState.isUnlocked)
		{
			levelDetailsFlow.visible = false;
			unlockedFlow.visible = true;
			interactive.visible = false;
		}
		else
		{
			starView.setCount(StarCountUtil.scoreToStarCount(levelState.score, starValues));
			starView.x = getSize().width / 2 - starView.getSize().width / 2;

			levelDetailsFlow.visible = true;
			unlockedFlow.visible = false;
			interactive.visible = true;

			scoreText.text = levelState.score == 0 ? Language.get("start_level") : NumberUtil.formatNumber(levelState.score);

			levelDetailsFlow.reflow();
			levelDetailsFlow.x = getSize().width / 2;
		}
	}

	public function dispose()
	{
		interactive.onClick = null;
		interactive.onOver = null;
		interactive.onOut = null;
		interactive.remove();
		interactive = null;

		Language.unregisterTextHolder(cast levelLabel);
		Language.unregisterTextHolder(cast unlockText);

		removeChildren();
	}
}