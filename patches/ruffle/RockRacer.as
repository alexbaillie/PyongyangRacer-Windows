package
{
   import Menu.*;
   import common.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import player.*;
   
   [SWF(width="760", height="500", backgroundColor="#006600", frameRate="20")]
   public class RockRacer extends Sprite
   {
      
      public static var GameCommon:RGameCommon;
      
      protected static var backImage:MovieClip;
      
      protected static var temp:Stage;
      
      public static var parameters:Object;
      
      public static var base:String;
      
      public static var _stage:*;
      
      public static var isBrowser:int = 1;
      
      public function RockRacer()
      {
         super();
         _stage = stage;
         parameters = root.loaderInfo.parameters;
         if(parameters.base)
         {
            base = "http://" + parameters.base;
         }
         else
         {
            base = "";
         }
         with(stage)
         {
            backImage = new TopPage();
            addChild(backImage);
            backImage.name = "backImage1";
            frameRate = 20;
            showDefaultContextMenu = false;
            scaleMode = StageScaleMode.SHOW_ALL;
            tabChildren = false;
            stageFocusRect = false;
            temp = stage;
         }
         this.CreatePlay(stage);
         new Client();
         stage.addEventListener("END_LOGO",this.endLogo);
      }
      
      public static function updateProgress(param1:int) : void
      {
      }
      
      public static function DeleteBackImage() : void
      {
         if(temp.getChildByName("backImage1") == null)
         {
            return;
         }
         temp.removeChild(backImage);
      }
      
      public function endLogo(param1:Event) : void
      {
         GameCommon.ResourceLoadComplete(null);
      }
      
      public function CreatePlay(param1:Stage) : void
      {
         GameCommon = new RGameCommon();
         addChild(GameCommon);
         GameCommon.Initialize();
      }
   }
}

