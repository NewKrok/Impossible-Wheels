package iw;

import hxd.Res;
import hxd.res.Sound;
import tink.state.Observable;

/**
 * ...
 * @author Krisztian Somoracz
 */
@:tink class SoundManager
{
	static var instance:SoundManager;

	var isSoundEnabled:Observable<Bool> = _;
	var isMusicEnabled:Observable<Bool> = _;

	var clickSfx:Sound;

	public function new()
	{
		clickSfx = if (Sound.supportedFormat(Mp3)) Res.sound.Interior_Door_Close else null;
	}

	public static function init(isSoundEnabled:Observable<Bool>, isMusicEnabled:Observable<Bool>)
	{
		instance = new SoundManager(isSoundEnabled, isMusicEnabled);
	}

	public static function playClickSound()
	{
		if (instance.clickSfx != null && instance.isSoundEnabled.value) instance.clickSfx.play(false, .6);
	}
}