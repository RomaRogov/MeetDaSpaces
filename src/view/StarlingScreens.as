package view 
{
	import flash.display.Stage;
	import flash.events.Event;
	import starling.events.Event;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class StarlingScreens extends Sprite
	{
		private static var _starling : Starling;
		private static var _stage : Stage;
		private static var _instance : StarlingScreens;
		private var currentScreen : Sprite;
		
		public static function Init( stage : Stage ):void
		{
			_starling = new Starling( StarlingScreens, stage, new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
			_starling.start();
			_stage = stage;
			_starling.antiAliasing = 0;
		}
		
		public function StarlingScreens() 
		{
			_instance = this;
			_stage.addEventListener( flash.events.Event.RESIZE, resizeStage );
		}
		
		private function resizeStage( e : flash.events.Event ):void 
		{
			_starling.viewPort = new Rectangle( 0, 0, _stage.stageWidth, _stage.stageHeight );
			_starling.stage.stageWidth = _stage.stageWidth;
			_starling.stage.stageHeight = _stage.stageHeight;
			if ( currentScreen )
				currentScreen.dispatchEvent( new starling.events.Event( starling.events.Event.RESIZE ) );
		}
		
		public static function SetScreen( screen : Sprite ):void
		{
			if ( _instance.currentScreen )
				_instance.removeChild( _instance.currentScreen );
			_instance.addChild( screen );
			_instance.currentScreen = screen;
		}
	}

}