package Menu
{
   import flash.display.*;
   import flash.events.*;
   import flash.filters.DropShadowFilter;
   import flash.geom.Rectangle;
   import flash.text.*;

   public class StartDlg extends AbstractDlg
   {

      private var m_Gear:Sprite;

      private var m_Panel:Sprite;

      private var m_MusicState:TextField;

      public function StartDlg()
      {
         var _loc1_:Object = {};
         _loc1_.parent = MainMenu._self;
         _loc1_.mcClass = StartDialog;
         super(_loc1_);
         _mc.x = 425;
         _mc.y = 135;
         _mc.BTT_Racenow.addEventListener(MouseEvent.CLICK,this.PlayerMode);
         _mc.addEventListener("startDlgEnd",this.bannerVisible);
         _mc.addEventListener("startDlgEnd",this.OnDlgEnd);
      }

      private function OnDlgEnd(param1:Event) : void
      {
         if(this.m_Gear == null || this.m_Gear.parent != _mc)
         {
            this.CreateSettings();
         }
      }

      private function bannerVisible(param1:Event) : void
      {
         _info.parent.banner.visible = true;
      }

      private function PlayerMode(param1:Event) : void
      {
         _info.parent.ToRace(null);
      }

      protected function Invite(param1:Event) : void
      {
      }

      private function DrawBox(param1:Graphics, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = param3 * 0.17;
         param1.beginFill(14248448);
         param1.drawRoundRect(0,0,param2,param3,_loc4_,_loc4_);
         param1.endFill();
         param1.beginFill(16777215);
         param1.drawRoundRect(param3 * 0.04,param3 * 0.04,param2 - param3 * 0.08,param3 - param3 * 0.08,_loc4_ * 0.8,_loc4_ * 0.8);
         param1.endFill();
         param1.beginFill(16746771);
         param1.drawRoundRect(param3 * 0.08,param3 * 0.08,param2 - param3 * 0.16,param3 - param3 * 0.16,_loc4_ * 0.6,_loc4_ * 0.6);
         param1.endFill();
      }

      private function DrawGear(param1:Graphics, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc5_:Number = param4 * 0.26;
         var _loc6_:Number = param4 * 0.2;
         var _loc7_:Number = param4 * 0.085;
         var _loc8_:Number = 0.2618;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         param1.beginFill(16777215);
         while(_loc9_ < 8)
         {
            _loc10_ = _loc9_ * Math.PI / 4;
            _loc11_ = _loc10_ - _loc8_;
            if(_loc9_ == 0)
            {
               param1.moveTo(param2 + _loc6_ * Math.cos(_loc11_),param3 + _loc6_ * Math.sin(_loc11_));
            }
            else
            {
               param1.lineTo(param2 + _loc6_ * Math.cos(_loc11_),param3 + _loc6_ * Math.sin(_loc11_));
            }
            param1.lineTo(param2 + _loc5_ * Math.cos(_loc10_ - _loc8_ * 0.6),param3 + _loc5_ * Math.sin(_loc10_ - _loc8_ * 0.6));
            param1.lineTo(param2 + _loc5_ * Math.cos(_loc10_ + _loc8_ * 0.6),param3 + _loc5_ * Math.sin(_loc10_ + _loc8_ * 0.6));
            param1.lineTo(param2 + _loc6_ * Math.cos(_loc10_ + _loc8_),param3 + _loc6_ * Math.sin(_loc10_ + _loc8_));
            _loc9_++;
         }
         param1.endFill();
         param1.beginFill(16777215);
         param1.drawCircle(param2,param3,_loc6_ * 1.02);
         param1.endFill();
         param1.beginFill(16746771);
         param1.drawCircle(param2,param3,_loc7_);
         param1.endFill();
      }

      private function CreateSettings() : void
      {
         var _loc1_:Rectangle = null;
         var _loc2_:Number = NaN;
         var _loc3_:Sprite = null;
         var _loc4_:Sprite = null;
         var _loc5_:TextField = null;
         var _loc6_:TextFormat = null;
         _loc1_ = _mc.BTT_Racenow.getBounds(_mc);
         _loc2_ = _loc1_.height;
         this.m_Gear = new Sprite();
         this.DrawBox(this.m_Gear.graphics,_loc2_,_loc2_);
         _loc3_ = new Sprite();
         this.DrawGear(_loc3_.graphics,_loc2_ / 2,_loc2_ / 2,_loc2_);
         _loc3_.filters = [new DropShadowFilter(3,45,9846784,0.6,3,3)];
         _loc3_.mouseEnabled = false;
         this.m_Gear.addChild(_loc3_);
         this.m_Gear.x = _loc1_.x - _loc2_ - 18;
         this.m_Gear.y = _loc1_.y;
         this.m_Gear.buttonMode = true;
         this.m_Gear.addEventListener(MouseEvent.CLICK,this.TogglePanel);
         _mc.addChild(this.m_Gear);
         this.m_Panel = new Sprite();
         this.m_Panel.visible = false;
         this.DrawBox(this.m_Panel.graphics,250,76);
         _loc6_ = new TextFormat("Arial",22,16777215,true);
         _loc5_ = new TextField();
         _loc5_.defaultTextFormat = _loc6_;
         _loc5_.text = "Music";
         _loc5_.selectable = false;
         _loc5_.mouseEnabled = false;
         _loc5_.x = 24;
         _loc5_.y = 22;
         _loc5_.width = 110;
         _loc5_.height = 34;
         _loc5_.filters = [new DropShadowFilter(2,45,9846784,0.7,2,2)];
         this.m_Panel.addChild(_loc5_);
         _loc4_ = new Sprite();
         _loc4_.graphics.beginFill(16777215);
         _loc4_.graphics.drawRoundRect(0,0,92,38,16,16);
         _loc4_.graphics.endFill();
         _loc4_.x = 138;
         _loc4_.y = 19;
         _loc4_.buttonMode = true;
         _loc4_.addEventListener(MouseEvent.CLICK,this.ToggleMusic);
         this.m_Panel.addChild(_loc4_);
         this.m_MusicState = new TextField();
         this.m_MusicState.defaultTextFormat = new TextFormat("Arial",20,14248448,true,null,null,null,null,TextFormatAlign.CENTER);
         this.m_MusicState.selectable = false;
         this.m_MusicState.mouseEnabled = false;
         this.m_MusicState.x = 0;
         this.m_MusicState.y = 5;
         this.m_MusicState.width = 92;
         this.m_MusicState.height = 30;
         _loc4_.addChild(this.m_MusicState);
         this.UpdateMusicLabel();
         this.m_Panel.x = _loc1_.right - 250;
         this.m_Panel.y = _loc1_.y - 92;
         _mc.addChild(this.m_Panel);
      }

      private function TogglePanel(param1:MouseEvent) : void
      {
         this.m_Panel.visible = !this.m_Panel.visible;
      }

      private function ToggleMusic(param1:MouseEvent) : void
      {
         RockRacer.GameCommon.SetMusicOn(!RockRacer.GameCommon.MusicOn());
         this.UpdateMusicLabel();
      }

      private function UpdateMusicLabel() : void
      {
         this.m_MusicState.text = RockRacer.GameCommon.MusicOn() ? "ON" : "OFF";
      }
   }
}
