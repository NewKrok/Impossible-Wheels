package iw.game;

import com.greensock.TweenMax;
import h2d.Bitmap;
import h2d.Layers;
import h2d.Particles;
import h2d.Tile;
import hxd.Res;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EffectHandler
{
	var parent:Layers;
	var particles:Particles;
	var imageCache:Array<Bitmap>;

	public function new(s2d:Layers)
	{
		this.parent = s2d;

		particles = new Particles(s2d);
		imageCache = [];
	}

	public function addCollectCoinEffect(x:Float, y:Float)
	{
		TweenMax.delayedCall(.5, addCollectCoinEffectWithoutDelay, [x, y]);
	}

	function addCollectCoinEffectWithoutDelay(x:Float, y:Float)
	{
		addStarParticles(x, y);
		addCoinExplosion(x, y);
	}

	function addStarParticles(x:Float, y:Float)
	{
		var g = new ParticleGroup(particles);

		g.size = 1;
		g.sizeRand = .5;
		g.life = .3;
		g.lifeRand = .2;
		g.speed = 180;
		g.speedRand = .2;
		g.nparts = 15;
		g.emitMode = PartEmitMode.Point;
		g.emitDist = 0;
		g.fadeIn = 1;
		g.fadeOut = .3;
		g.rotSpeed = Math.PI / 5;
		g.rotSpeedRand = Math.PI / 5;
		g.texture = Res.image.game_asset.star_particle.toTexture();
		g.dx = cast x;
		g.dy = cast y;
		g.emitLoop = false;
		g.animationRepeat = 1;

		particles.addGroup(g);

		TweenMax.delayedCall(.5, function(){ removeEffect(g); });
	}

	public function addCoinExplosion(x:Float, y:Float, scale:Float = 1)
	{
		var image:Bitmap = new Bitmap(Res.image.game_asset.light_explosion.toTile(), parent);
		imageCache.push(image);
		image.x = x;
		image.y = y;
		image.scaleX = image.scaleY = 1;

		var tile:Tile = image.tile;
		tile.dx = cast -tile.width / 2;
		tile.dy = cast -tile.height / 2;

		TweenMax.to(image, .2, {
			scaleX: 3,
			scaleY: 3,
			alpha: .1,
			onComplete: removeBitmap,
			onCompleteParams: [image],
			onUpdate: updateHack,
			onUpdateParams: [image]
		});
	}

	function removeEffect(g:ParticleGroup)
	{
		particles.removeGroup(g);
	}

	function updateHack(img:Bitmap)
	{
		img.x = img.x;
	}

	function removeBitmap(img:Bitmap)
	{
		imageCache.remove(img);
		img.remove();
	}

	public function reset()
	{
		TweenMax.killDelayedCallsTo(addCollectCoinEffectWithoutDelay);

		particles.removeChildren();

		for (i in imageCache) i.remove();
	}
}