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
	var counterSfx:Sound;
	var startGameSfx:Sound;
	var coinSfx:Sound;
	var trickSfx:Sound;
	var winSfx:Sound;
	var looseSfx:Sound;
	var looseLifeSfx:Sound;
	var levelCompletedSfx:Sound;
	var levelFailedSfx:Sound;
	var scoreSfx:Sound;

	public function new()
	{
		clickSfx = if (Sound.supportedFormat(Mp3)) Res.sound.Interior_Door_Close else null;
		counterSfx = if (Sound.supportedFormat(Wav)) Res.sound.Score_chord_1_a else null;
		startGameSfx = if (Sound.supportedFormat(Wav)) Res.sound.Score_chord_2_a else null;
		coinSfx = if (Sound.supportedFormat(Wav)) Res.sound.Score_bell_1_a else null;
		trickSfx = if (Sound.supportedFormat(Wav)) Res.sound.Score_swap_1_a else null;
		winSfx = if (Sound.supportedFormat(Wav)) Res.sound.Increase_chord_1 else null;
		looseSfx = if (Sound.supportedFormat(Wav)) Res.sound.Decrease_chord_1 else null;
		looseLifeSfx = if (Sound.supportedFormat(Wav)) Res.sound.Score_sin_1_a else null;
		levelCompletedSfx = if (Sound.supportedFormat(Wav)) Res.sound.power_1_a else null;
		levelFailedSfx = if (Sound.supportedFormat(Wav)) Res.sound.laser_1_a else null;
		scoreSfx = if (Sound.supportedFormat(Wav)) Res.sound.coin_1_e else null;
	}

	public static function init(isSoundEnabled:Observable<Bool>, isMusicEnabled:Observable<Bool>)
	{
		instance = new SoundManager(isSoundEnabled, isMusicEnabled);
	}

	public static function playClickSound()
	{
		if (instance.clickSfx != null && instance.isSoundEnabled.value) instance.clickSfx.play(false, .6);
	}

	public static function playCounterSound()
	{
		if (instance.counterSfx != null && instance.isSoundEnabled.value) instance.counterSfx.play(false, 1);
	}

	public static function playStartGameSound()
	{
		if (instance.startGameSfx != null && instance.isSoundEnabled.value) instance.startGameSfx.play(false, 1);
	}

	public static function playCoinSound()
	{
		if (instance.coinSfx != null && instance.isSoundEnabled.value) instance.coinSfx.play(false, .3);
	}

	public static function playTrickSound()
	{
		if (instance.trickSfx != null && instance.isSoundEnabled.value) instance.trickSfx.play(false, .5);
	}

	public static function playWinSound()
	{
		if (instance.winSfx != null && instance.isSoundEnabled.value) instance.winSfx.play(false, 1);
	}

	public static function playLooseSound()
	{
		if (instance.looseSfx != null && instance.isSoundEnabled.value) instance.looseSfx.play(false, 1);
	}

	public static function playLooseLifeSound()
	{
		if (instance.looseLifeSfx != null && instance.isSoundEnabled.value) instance.looseLifeSfx.play(false, 1);
	}

	public static function playLevelCompletedSound()
	{
		if (instance.levelCompletedSfx != null && instance.isSoundEnabled.value) instance.levelCompletedSfx.play(false, 1);
	}

	public static function playLevelFailedSound()
	{
		if (instance.levelFailedSfx != null && instance.isSoundEnabled.value) instance.levelFailedSfx.play(false, 1);
	}

	public static function playScoreSound()
	{
		if (instance.scoreSfx != null && instance.isSoundEnabled.value) instance.scoreSfx.play(true, .1);
	}

	public static function stopScoreSound()
	{
		if (instance.scoreSfx != null && instance.isSoundEnabled.value) instance.scoreSfx.stop();
	}
}