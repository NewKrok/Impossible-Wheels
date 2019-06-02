package iw.game.ui;

import com.greensock.TweenMax;
import h2d.Graphics;
import h2d.Object;
import h2d.Text;
import h2d.Text.Align;
import hpp.heaps.HppG;
import hpp.util.Language;
import hpp.util.NumberUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class ResultEntry extends Object
{
	var objectUi:Object = _;

	var g:Graphics;
	var scoreText:Text;
	var bonusText:Text;
	var scoreHelper:Float;

	public function new(p:Object)
	{
		super(p);

		g = new Graphics(this);
		g.beginFill();
		g.drawRect(0, 0, 1136, 43);
		g.endFill();

		objectUi.x = HppG.stage2d.width / 2 - objectUi.getSize().width - 20;
		addChild(objectUi);

		scoreText = new Text(Fonts.DEFAULT_M, this);
		scoreText.smooth = true;
		scoreText.textColor = 0xFFFFFF;
		scoreText.textAlign = Align.Left;
		scoreText.x = HppG.stage2d.width / 2 + 20;
		scoreText.y = g.getSize().height / 2 - scoreText.textHeight / 2;

		bonusText = new Text(Fonts.DEFAULT_S, this);
		bonusText.smooth = true;
		bonusText.textColor = 0xFFFFFF;
		bonusText.textAlign = Align.Left;
		bonusText.x = HppG.stage2d.width / 2 + 20;
		bonusText.y = g.getSize().height / 2 - scoreText.textHeight / 2;
		Language.registerTextHolder(cast bonusText, "bonus_score", ["$score" => 0]);
	}

	public function setScore(s:UInt, bonus:UInt = 0)
	{
		TweenMax.killTweensOf(this);
		scoreHelper = 0;
		objectUi.x = HppG.stage2d.width / 2 - objectUi.getSize().width - 20;
		objectUi.y = g.getSize().height / 2 - objectUi.getSize().height / 2;
		scoreText.text = "0";
		bonusText.visible = false;

		TweenMax.to(this, 1, {
			scoreHelper: s,
			delay: .5,
			onUpdate: function()
			{
				scoreText.text = NumberUtil.formatNumber(Math.floor(scoreHelper));
			},
			onComplete: function()
			{
				if (bonus > 0)
				{
					bonusText.visible = true;
					Language.updateTextHolderParams(cast bonusText, ["$score" => bonus]);
					bonusText.x = scoreText.x + scoreText.textWidth + 20;
					bonusText.y = g.getSize().height / 2 - bonusText.textHeight / 2;
				}

			}
		});
	}

	public function reset()
	{
		g.beginFill();
		g.drawRect(0, 0, 1136, 43);
		g.endFill();

		TweenMax.killTweensOf(this);
		scoreHelper = 0;
		scoreText.text = "";
	}
}