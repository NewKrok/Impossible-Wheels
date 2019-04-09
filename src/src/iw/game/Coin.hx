package iw.game;

import com.greensock.TweenMax;
import h2d.Anim;
import h2d.Object;
import hpp.heaps.util.TileUtil;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Coin extends Object
{
	public var isCollected(default, null):Bool = false;

	var anim:Anim;

	public function new(parent:Object)
	{
		super(parent);

		anim = new Anim(
			TileUtil.getHorizontalTile(Res.image.game_asset.coin_tile.toTile(), 40, 40),
			10,
			this
		);
		anim.loop = true;

		anim.x = -20;
		anim.y = -20;
	}

	public function collect()
	{
		isCollected = true;
		anim.speed = 60;

		TweenMax.to(anim, 1, {
			y: -120,
			onUpdate: function()
			{
				anim.y = anim.y;
			},
			onComplete: function()
			{
				anim.speed = 0;
			}
		});

		TweenMax.to(this, .4, { alpha: 0 }).delay(.6);
	}

	public function reset()
	{
		alpha = 1;
		isCollected = false;
		anim.speed = 10;
		anim.y = -20;

		TweenMax.killTweensOf(this);
		TweenMax.killTweensOf(anim);
	}
}