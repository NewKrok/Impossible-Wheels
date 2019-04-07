package iw.game;

import coconut.data.Model;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameModel implements Model
{
	@:external var levelId:UInt;

	@:editable var gameTime:Float = 0;
}