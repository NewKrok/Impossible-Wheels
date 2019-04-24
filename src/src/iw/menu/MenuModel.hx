package iw.menu;

import coconut.data.Model;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MenuModel implements Model
{
	@:observable var subState:MenuSubState = MenuSubState.Init;
	@:transition function setSubState(value:MenuSubState) return { subState: value };

	@:editable var isLoaded:Bool = false;
	@:editable var isInFocus:Bool = false;

	@:computed var isNotInFocus:Bool = !isInFocus;
}

enum MenuSubState
{
	Init;
	Intro;
	Welcome;
	Settings;
	Info;
	LevelSelect;
}