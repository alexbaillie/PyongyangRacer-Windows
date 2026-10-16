import sys, io, os
root = sys.argv[1]
line_file = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(__file__), "plan", "lane_line_as3.txt")
AUTO_LINE = io.open(line_file, encoding="utf-8").read().strip()
extra_file = os.path.join(os.path.dirname(line_file), "lane_extra_as3.txt")
AUTO_EXTRA = io.open(extra_file, encoding="utf-8").read().strip()
assert AUTO_EXTRA.count(",") + 1 == (AUTO_LINE.count(",") + 1) // 2, "AUTO_EXTRA length must equal the number of line points"
AUTO_SPEED = io.open(os.path.join(os.path.dirname(line_file), "lane_speed_as3.txt"), encoding="utf-8").read().strip()
assert AUTO_SPEED.count(",") + 1 == AUTO_EXTRA.count(",") + 1, "AUTO_SPEED length must equal the number of line points"
import json
PARAMS = json.load(io.open(os.path.join(os.path.dirname(line_file), "lane_params.json"), encoding="utf-8"))

def patch(path, edits):
    s = io.open(path, encoding="utf-8").read()
    for old, new in edits:
        n = s.count(old)
        assert n == 1, "anchor count %d in %s:\n%s" % (n, path, old[:160])
        s = s.replace(old, new, 1)
    io.open(path, "w", encoding="utf-8", newline="\n").write(s)

# ---------------- RGameClient ----------------
gc = root + "/scripts/player/RGameClient.as"
fields_old = "      private const minOil:Number = 100;\n"
fields_new = fields_old + """
      public var m_AutoDrive:Boolean = false;

      private var m_CheatBuf:Array = new Array();

      private var m_CheatLastTime:int = 0;

      private var m_FHeld:Boolean = false;

      private var m_CheatMsg:Sprite = null;

      private var m_CheatMsgText:TextField = null;

      private var m_CheatMsgTimer:uint = 0;

      public static const AUTO_LINE:Array = """ + AUTO_LINE + """;

      private var m_AutoIdx:int = 0;

      public var m_AutoTanX:Number = 0;

      public var m_AutoTanZ:Number = 1;

      private var m_AutoT:Number = 0;

      private var m_AutoD:Number = 0;

      private var m_AutoPX:Number = 0;

      private var m_AutoPZ:Number = 0;

      public static const AUTO_EXTRA:Array = """ + AUTO_EXTRA + """;

      private var m_AutoShift:Number = 0;

      private var m_AutoShiftTarget:Number = 0;

      private var m_AutoHold:int = 0;

      private var m_AutoBlockDist:Number = 1e9;

      private var m_AutoBlockSpeed:Number = 0;

      public static const AUTO_SPEED:Array = """ + AUTO_SPEED + """;

      private var m_AutoCool:int = 0;

      private var m_AutoCardShift:Number = 0;

      private var m_AutoPrevTurn:Number = 0;
"""

keydown_old = """      public function KeyDownHandler(param1:KeyboardEvent) : void
      {
         this.preKeyMask = this.KeyMask;
         switch(param1.keyCode)
"""
keydown_new = """      public function KeyDownHandler(param1:KeyboardEvent) : void
      {
         this.preKeyMask = this.KeyMask;
         if(param1.keyCode == 70 && !this.m_FHeld)
         {
            this.m_FHeld = true;
            this.TryToggleAutoDrive();
         }
         switch(param1.keyCode)
"""

input_old = """         if(this.m_RenderMode != RENDER_PLAYING || this.m_CarList[this.m_PlayerID].m_AI.m_CurState != RAI.AI_IDLE)
         {
            return;
         }
"""
input_new = """         if(this.m_RenderMode != RENDER_PLAYING)
         {
            return;
         }
         if(this.m_AutoDrive)
         {
            this.AutoDriveLoop();
            return;
         }
         if(this.m_CarList[this.m_PlayerID].m_AI.m_CurState != RAI.AI_IDLE)
         {
            return;
         }
"""

coll_old = """               if(Boolean(this.m_Object[_loc3_].CollisionTest(this.m_Object[_loc5_])) && Boolean(this.m_Object[_loc5_].CollisionTest(this.m_Object[_loc3_])))
               {
"""
coll_new = """               if(!this.IsAutoDriveGhostPair(this.m_Object[_loc3_],this.m_Object[_loc5_]) && Boolean(this.m_Object[_loc3_].CollisionTest(this.m_Object[_loc5_])) && Boolean(this.m_Object[_loc5_].CollisionTest(this.m_Object[_loc3_])))
               {
"""

keyup_old = """      public function KeyUpHandler(param1:KeyboardEvent) : void
      {
         this.preKeyMask = this.KeyMask;
         switch(param1.keyCode)
"""
keyup_new = """      public function KeyUpHandler(param1:KeyboardEvent) : void
      {
         this.preKeyMask = this.KeyMask;
         if(param1.keyCode == 70)
         {
            this.m_FHeld = false;
         }
         switch(param1.keyCode)
"""

deact_old = """         this.KeyMask = 0;
         this.preKeyMask = this.KeyMask;
         if(RockRacer.GameCommon.g_SingleGame)
         {
            this.QuitWindowFunc();
         }
         else
"""
deact_new = """         this.KeyMask = 0;
         this.preKeyMask = this.KeyMask;
         if(RockRacer.GameCommon.g_SingleGame)
         {
         }
         else
"""

restart_old = """         this.oil = this.maxOil;
         this.m_scMask.gotoAndStop(0);
"""
restart_new = """         this.oil = this.maxOil;
         this.ResetAutoDrive();
         this.m_scMask.gotoAndStop(0);
"""

initgo_old = """         this.oil = this.maxOil;
         addEventListener(Event.ENTER_FRAME,this.Loop);
"""
initgo_new = """         this.oil = this.maxOil;
         this.ResetAutoDrive();
         addEventListener(Event.ENTER_FRAME,this.Loop);
"""

destroy_old = """      public function DestroyScene() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = this.m_View.scene.numChildren;
"""
destroy_new = """      public function DestroyScene() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = this.m_View.scene.numChildren;
         this.ResetAutoDrive();
"""

funcs_old = "      public function addOil() : void\n"
funcs_new = """      private function TryToggleAutoDrive() : void
      {
         if(this.m_RenderMode == RENDER_PLAYING && !this.pause && this.m_CarList.length > this.m_PlayerID)
         {
            this.ToggleAutoDrive();
         }
      }

      public function ToggleAutoDrive() : void
      {
         var _loc1_:RCar = this.m_CarList[this.m_PlayerID];
         this.m_AutoDrive = !this.m_AutoDrive;
         if(this.m_AutoDrive)
         {
            this.oil = this.maxOil;
            this.mc_InfoWnd.mc_Oil.gotoAndStop(100);
            this.m_AutoIdx = this.AutoFindNearest(_loc1_.currState.loc.x,_loc1_.currState.loc.z);
            _loc1_.m_AutoLastGood = null;
            this.m_AutoShift = 0;
            this.m_AutoShiftTarget = 0;
            this.m_AutoCool = 0;
            this.m_AutoCardShift = 0;
            this.m_AutoPrevTurn = 0;
            this.m_AutoHold = 0;
            this.SetAutoBoost(true);
            this.ShowCheatMessage("Autodrive + unlimited fuel + 50% speed enabled");
         }
         else
         {
            _loc1_.StopAccel();
            _loc1_.ReturnCenter();
            this.SetAutoBoost(false);
            this.ShowCheatMessage("Autodrive + unlimited fuel + 50% speed disabled");
         }
      }

      private function AutoX(param1:int) : Number
      {
         var _loc2_:int = AUTO_LINE.length / 2;
         param1 = (param1 % _loc2_ + _loc2_) % _loc2_;
         return AUTO_LINE[param1 * 2];
      }

      private function AutoZ(param1:int) : Number
      {
         var _loc2_:int = AUTO_LINE.length / 2;
         param1 = (param1 % _loc2_ + _loc2_) % _loc2_;
         return AUTO_LINE[param1 * 2 + 1];
      }

      private function AutoProject(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = this.AutoX(param1);
         var _loc5_:Number = this.AutoZ(param1);
         var _loc6_:Number = this.AutoX(param1 + 1) - _loc4_;
         var _loc7_:Number = this.AutoZ(param1 + 1) - _loc5_;
         var _loc8_:Number = _loc6_ * _loc6_ + _loc7_ * _loc7_;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(_loc8_ == 0)
         {
            this.m_AutoT = 0;
            this.m_AutoD = 0;
            return;
         }
         _loc9_ = ((param2 - _loc4_) * _loc6_ + (param3 - _loc5_) * _loc7_) / _loc8_;
         _loc10_ = _loc4_ + _loc6_ * _loc9_;
         _loc11_ = _loc5_ + _loc7_ * _loc9_;
         this.m_AutoT = _loc9_;
         this.m_AutoD = Math.sqrt((param2 - _loc10_) * (param2 - _loc10_) + (param3 - _loc11_) * (param3 - _loc11_));
      }

      private function AutoPointAhead(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int = param1;
         var _loc5_:Number = Math.max(0,Math.min(1,param2));
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         while(_loc6_ < 400)
         {
            _loc7_ = this.AutoX(_loc4_);
            _loc8_ = this.AutoZ(_loc4_);
            _loc9_ = this.AutoX(_loc4_ + 1);
            _loc10_ = this.AutoZ(_loc4_ + 1);
            _loc11_ = Math.sqrt((_loc9_ - _loc7_) * (_loc9_ - _loc7_) + (_loc10_ - _loc8_) * (_loc10_ - _loc8_));
            _loc12_ = _loc11_ * (1 - _loc5_);
            if(param3 <= _loc12_ || _loc11_ == 0)
            {
               _loc13_ = _loc11_ == 0 ? 1 : (_loc11_ - _loc12_ + param3) / _loc11_;
               this.m_AutoPX = _loc7_ + (_loc9_ - _loc7_) * _loc13_;
               this.m_AutoPZ = _loc8_ + (_loc10_ - _loc8_) * _loc13_;
               return;
            }
            param3 -= _loc12_;
            _loc5_ = 0;
            _loc4_++;
            _loc6_++;
         }
         this.m_AutoPX = this.AutoX(_loc4_);
         this.m_AutoPZ = this.AutoZ(_loc4_);
      }

      private function AutoFindNearest(param1:Number, param2:Number) : int
      {
         var _loc3_:int = AUTO_LINE.length / 2;
         var _loc4_:int = 0;
         var _loc5_:Number = 1e18;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         while(_loc6_ < _loc3_)
         {
            this.AutoProject(_loc6_,param1,param2);
            _loc7_ = this.m_AutoD;
            if(this.m_AutoT < 0 || this.m_AutoT > 1)
            {
               _loc8_ = this.m_AutoT < 0 ? this.AutoX(_loc6_) : this.AutoX(_loc6_ + 1);
               _loc9_ = this.m_AutoT < 0 ? this.AutoZ(_loc6_) : this.AutoZ(_loc6_ + 1);
               _loc7_ = Math.sqrt((param1 - _loc8_) * (param1 - _loc8_) + (param2 - _loc9_) * (param2 - _loc9_));
            }
            if(_loc7_ < _loc5_)
            {
               _loc5_ = _loc7_;
               _loc4_ = _loc6_;
            }
            _loc6_++;
         }
         return _loc4_;
      }

      private function AutoSignedAngle(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = Math.sqrt(param3 * param3 + param4 * param4);
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(_loc5_ == 0)
         {
            return 0;
         }
         param3 /= _loc5_;
         param4 /= _loc5_;
         _loc6_ = Math.max(-1,Math.min(1,param1 * param3 + param2 * param4));
         _loc7_ = Math.acos(_loc6_) * 180 / Math.PI;
         _loc8_ = param2 * param3 - param1 * param4;
         return _loc8_ > 0 ? _loc7_ : -_loc7_;
      }

      private function AutoScanCars(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:int = 0;
         var _loc10_:RCar = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Boolean = false;
         this.m_AutoBlockDist = 1e9;
         this.m_AutoBlockSpeed = 0;
         while(_loc9_ < this.m_CarList.length)
         {
            _loc10_ = this.m_CarList[_loc9_];
            if(_loc9_ != this.m_PlayerID && _loc10_ != null && !_loc10_.m_isDelete)
            {
               _loc11_ = _loc10_.currState.loc.x - param1;
               _loc12_ = _loc10_.currState.loc.z - param2;
               _loc13_ = _loc11_ * param3 + _loc12_ * param4;
               _loc14_ = _loc11_ * param4 - _loc12_ * param3;
               if(_loc13_ > param6 && _loc13_ < param7 && Math.abs(_loc14_ - param5) < param8)
               {
                  _loc15_ = true;
                  if(_loc13_ < this.m_AutoBlockDist)
                  {
                     this.m_AutoBlockDist = _loc13_;
                     this.m_AutoBlockSpeed = _loc10_.currState.vel.length;
                  }
               }
            }
            _loc9_++;
         }
         return _loc15_;
      }

      private function AutoCardShift(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:int = 0;
         var _loc5_:RGameEnt = null;
         var _loc6_:Number = 1e9;
         var _loc7_:Number = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         while(_loc4_ < this.m_Object.length)
         {
            _loc5_ = this.m_Object[_loc4_];
            if(_loc5_.m_ObjType == RObjectType.TREE1 && _loc5_.hit)
            {
               _loc8_ = _loc5_.currState.loc.x - param1;
               _loc9_ = _loc5_.currState.loc.z - param2;
               _loc10_ = _loc8_ * this.m_AutoTanX + _loc9_ * this.m_AutoTanZ;
               _loc11_ = _loc8_ * this.m_AutoTanZ - _loc9_ * this.m_AutoTanX;
               if(_loc10_ > -300 && _loc10_ < 5200 && Math.abs(_loc11_) < 950 && _loc10_ < _loc6_)
               {
                  _loc6_ = _loc10_;
                  _loc7_ = param3 + _loc11_;
               }
            }
            _loc4_++;
         }
         if(_loc6_ > 100000000)
         {
            return 0;
         }
         if(_loc7_ > 90)
         {
            _loc7_ -= 90;
         }
         else if(_loc7_ < -90)
         {
            _loc7_ += 90;
         }
         else
         {
            _loc7_ = 0;
         }
         return Math.max(-420,Math.min(420,_loc7_ - this.m_AutoShift));
      }

      private function AutoDriveLoop() : void
      {
         var _loc1_:RCar = this.m_CarList[this.m_PlayerID];
         var _loc2_:int = AUTO_LINE.length / 2;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         this.oil = this.maxOil;
         this.mc_InfoWnd.mc_Oil.gotoAndStop(100);
         this.preKeyMask = this.KeyMask;
         this.m_StartFlag = true;
         if(_loc1_.isCarStop || _loc1_.isCarOut)
         {
            return;
         }
         _loc3_ = _loc1_.currState.loc.x;
         _loc4_ = _loc1_.currState.loc.z;
         while(_loc5_ < 6)
         {
            this.AutoProject(this.m_AutoIdx,_loc3_,_loc4_);
            if(this.m_AutoT >= 1)
            {
               this.m_AutoIdx = (this.m_AutoIdx + 1) % _loc2_;
               _loc5_++;
            }
            else
            {
               break;
            }
         }
         this.AutoProject(this.m_AutoIdx,_loc3_,_loc4_);
         if(this.m_AutoD > 2500)
         {
            this.m_AutoIdx = this.AutoFindNearest(_loc3_,_loc4_);
            this.AutoProject(this.m_AutoIdx,_loc3_,_loc4_);
         }
         _loc6_ = this.m_AutoT;
         _loc7_ = this.AutoX(this.m_AutoIdx + 1) - this.AutoX(this.m_AutoIdx);
         _loc8_ = this.AutoZ(this.m_AutoIdx + 1) - this.AutoZ(this.m_AutoIdx);
         _loc9_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_);
         if(_loc9_ > 0)
         {
            this.m_AutoTanX = _loc7_ / _loc9_;
            this.m_AutoTanZ = _loc8_ / _loc9_;
         }
         _loc10_ = _loc1_.currState.vel.length;
         if(this.m_AutoCool > 0)
         {
            this.m_AutoCool--;
         }
         _loc18_ = AUTO_EXTRA[this.m_AutoIdx] == 1 && AUTO_EXTRA[(this.m_AutoIdx + 1) % _loc2_] == 1 && AUTO_EXTRA[(this.m_AutoIdx + 2) % _loc2_] == 1 && AUTO_SPEED[this.m_AutoIdx] >= 150;
         _loc19_ = this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,this.m_AutoShift + this.m_AutoCardShift,0,2200,230);
         _loc20_ = this.m_AutoBlockDist;
         _loc21_ = this.m_AutoBlockSpeed;
         if(this.m_AutoShiftTarget == 0)
         {
            if(_loc19_ && _loc21_ < _loc10_ - 15 && _loc18_ && !this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,600,-500,1700,240))
            {
               this.m_AutoShiftTarget = 600;
               this.m_AutoHold = 45;
            }
         }
         else if(!_loc18_)
         {
            this.m_AutoShiftTarget = 0;
         }
         else if(this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,0,-500,1000,260))
         {
            this.m_AutoHold = 30;
         }
         else if(this.m_AutoHold > 0)
         {
            this.m_AutoHold--;
         }
         else
         {
            this.m_AutoShiftTarget = 0;
         }
         if(this.m_AutoShift < this.m_AutoShiftTarget)
         {
            this.m_AutoShift = Math.min(this.m_AutoShiftTarget,this.m_AutoShift + 36);
         }
         else if(this.m_AutoShift > this.m_AutoShiftTarget)
         {
            this.m_AutoShift = Math.max(this.m_AutoShiftTarget,this.m_AutoShift - 36);
         }
         _loc24_ = this.AutoCardShift(_loc3_,_loc4_,this.m_AutoShift + this.m_AutoCardShift);
         if(this.m_AutoCardShift < _loc24_)
         {
            this.m_AutoCardShift = Math.min(_loc24_,this.m_AutoCardShift + 40);
         }
         else if(this.m_AutoCardShift > _loc24_)
         {
            this.m_AutoCardShift = Math.max(_loc24_,this.m_AutoCardShift - 40);
         }
         _loc22_ = this.m_AutoTanZ * (this.m_AutoShift + this.m_AutoCardShift);
         _loc23_ = -this.m_AutoTanX * (this.m_AutoShift + this.m_AutoCardShift);
         _loc11_ = Math.max(@LA_MIN@,Math.min(@LA_MAX@,_loc10_ * @LA_K@));
         _loc12_ = _loc1_.m_Direction.x;
         _loc13_ = _loc1_.m_Direction.z;
         _loc14_ = Math.sqrt(_loc12_ * _loc12_ + _loc13_ * _loc13_);
         if(_loc14_ < 0.0001)
         {
            _loc12_ = Math.sin(_loc1_.currState.pose.y * Math.PI / 180);
            _loc13_ = Math.cos(_loc1_.currState.pose.y * Math.PI / 180);
         }
         else
         {
            _loc12_ /= _loc14_;
            _loc13_ /= _loc14_;
         }
         this.AutoPointAhead(this.m_AutoIdx,_loc6_,_loc11_);
         _loc15_ = this.AutoSignedAngle(_loc12_,_loc13_,this.m_AutoPX + _loc22_ - _loc3_,this.m_AutoPZ + _loc23_ - _loc4_);
         _loc17_ = Math.max(-@TCAP@,Math.min(@TCAP@,_loc15_ * @GAIN@));
         _loc17_ = this.m_AutoPrevTurn + Math.max(-3,Math.min(3,_loc17_ - this.m_AutoPrevTurn));
         this.m_AutoPrevTurn = _loc17_;
         _loc1_.currState.pose.y += _loc17_;
         if(Math.abs(_loc15_) > 70 && _loc10_ > 100)
         {
            _loc1_.SpeedDown();
         }
         else if(Math.abs(_loc15_) > 35 && _loc10_ > 150)
         {
            _loc1_.StopAccel();
         }
         else
         {
            _loc1_.SpeedUp();
         }
         if(_loc19_ && _loc21_ < _loc10_ && this.m_AutoShiftTarget == 0 && this.m_AutoShift == 0 && _loc20_ < 180)
         {
            _loc1_.StopAccel();
         }
      }
      
      private function IsAutoDriveGhostPair(param1:RGameEnt, param2:RGameEnt) : Boolean
      {
         var _loc3_:RGameEnt = null;
         if(!this.m_AutoDrive || this.m_CarList.length <= this.m_PlayerID)
         {
            return false;
         }
         _loc3_ = this.m_CarList[this.m_PlayerID];
         if(param1 != _loc3_ && param2 != _loc3_)
         {
            return false;
         }
         if(param1.m_ObjType != RObjectType.AICAR && param1.m_ObjType != RObjectType.PLAYERCAR)
         {
            return false;
         }
         if(param2.m_ObjType != RObjectType.AICAR && param2.m_ObjType != RObjectType.PLAYERCAR)
         {
            return false;
         }
         return true;
      }

      private function SetAutoBoost(param1:Boolean) : void
      {
         var _loc2_:RCar = null;
         if(this.m_CarList != null && this.m_PlayerID >= 0 && this.m_CarList.length > this.m_PlayerID)
         {
            _loc2_ = this.m_CarList[this.m_PlayerID];
            if(_loc2_ != null)
            {
               _loc2_.m_MaxVel = param1 ? 300 * 1.5 : 300;
               _loc2_.m_Accel = param1 ? 20 * 1.5 : 20;
            }
         }
      }

      private function ResetAutoDrive() : void
      {
         this.SetAutoBoost(false);
         this.m_AutoDrive = false;
         this.m_CheatBuf.splice(0);
         this.HideCheatMessage();
      }

      private function ShowCheatMessage(param1:String) : void
      {
         var _loc2_:TextFormat = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.m_CheatMsg == null)
         {
            this.m_CheatMsg = new Sprite();
            this.m_CheatMsgText = new TextField();
            _loc2_ = new TextFormat("_sans",22,16777215,true);
            this.m_CheatMsgText.defaultTextFormat = _loc2_;
            this.m_CheatMsgText.autoSize = TextFieldAutoSize.LEFT;
            this.m_CheatMsgText.selectable = false;
            this.m_CheatMsgText.mouseEnabled = false;
            this.m_CheatMsg.mouseEnabled = false;
            this.m_CheatMsg.mouseChildren = false;
            this.m_CheatMsg.addChild(this.m_CheatMsgText);
         }
         this.m_CheatMsgText.text = param1;
         _loc3_ = this.m_CheatMsgText.width + 40;
         _loc4_ = this.m_CheatMsgText.height + 20;
         this.m_CheatMsg.graphics.clear();
         this.m_CheatMsg.graphics.lineStyle(2,65280,1);
         this.m_CheatMsg.graphics.beginFill(0,0.75);
         this.m_CheatMsg.graphics.drawRoundRect(0,0,_loc3_,_loc4_,16,16);
         this.m_CheatMsg.graphics.endFill();
         this.m_CheatMsgText.x = 20;
         this.m_CheatMsgText.y = 10;
         this.m_CheatMsg.x = (m_ViewportWidth - _loc3_) / 2;
         this.m_CheatMsg.y = 150;
         addChild(this.m_CheatMsg);
         if(this.m_CheatMsgTimer != 0)
         {
            clearTimeout(this.m_CheatMsgTimer);
         }
         this.m_CheatMsgTimer = setTimeout(this.HideCheatMessage,5000);
      }

      private function HideCheatMessage() : void
      {
         if(this.m_CheatMsgTimer != 0)
         {
            clearTimeout(this.m_CheatMsgTimer);
            this.m_CheatMsgTimer = 0;
         }
         if(this.m_CheatMsg != null && this.m_CheatMsg.parent != null)
         {
            this.m_CheatMsg.parent.removeChild(this.m_CheatMsg);
         }
      }

      public function addOil() : void
"""

for _k, _v in (("@LA_MIN@", PARAMS["la_min"]), ("@LA_MAX@", PARAMS["la_max"]), ("@LA_K@", PARAMS["la_k"]), ("@TCAP@", PARAMS["tcap"]), ("@GAIN@", PARAMS["gain"])):
    funcs_new = funcs_new.replace(_k, str(_v))

patch(gc, [
    (fields_old, fields_new),
    (keydown_old, keydown_new),
    (keyup_old, keyup_new),
    (deact_old, deact_new),
    (input_old, input_new),
    (coll_old, coll_new),
    (restart_old, restart_new),
    (initgo_old, initgo_new),
    (destroy_old, destroy_new),
    (funcs_old, funcs_new),
])

# ---------------- RCar ----------------
car = root + "/scripts/player/RCar.as"
car_fields_old = "      public var m_isAutoPilot:Boolean = false;\n"
car_fields_new = car_fields_old + "      \n      public var m_AutoLastGood:Vector3D = null;\n"

act_old = """      public function SetAction(param1:int) : void
      {
         var _loc2_:REffectData = null;
         switch(param1)
         {
            case RActionState.AUTOPILOT_PLAY:
"""
act_new = """      public function IsAutoDriven() : Boolean
      {
         var _loc1_:Object = null;
         if(this.m_ObjType != RObjectType.PLAYERCAR)
         {
            return false;
         }
         _loc1_ = RockRacer.GameCommon.GameClient;
         return _loc1_ != null && _loc1_.m_AutoDrive == true;
      }

      private function AutoDrivable(param1:int) : Boolean
      {
         switch(param1)
         {
            case RTerrainType.START_LINE:
            case RTerrainType.ASPHALT_ROAD:
            case RTerrainType.OIL_ROAD:
            case RTerrainType.GRASS:
            case RTerrainType.ACCELENT_ROAD:
            case RTerrainType.SAND_ROAD:
            case RTerrainType.MUD_ROAD:
            case RTerrainType.MOUNT:
            case RTerrainType.WATER:
               return true;
         }
         return false;
      }

      private function AutoDriveGuard() : void
      {
         var _loc1_:Object = RockRacer.GameCommon.GameClient;
         var _loc2_:RTerrain = _loc1_.m_Terrain;
         var _loc3_:Number = currState.loc.x;
         var _loc4_:Number = currState.loc.z;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this.AutoDrivable(int(_loc2_.GetTerrainType(_loc3_,_loc4_))))
         {
            if(this.m_AutoLastGood == null)
            {
               this.m_AutoLastGood = new Vector3D();
            }
            this.m_AutoLastGood.x = _loc3_;
            this.m_AutoLastGood.y = currState.loc.y;
            this.m_AutoLastGood.z = _loc4_;
            return;
         }
         if(this.m_AutoLastGood == null)
         {
            return;
         }
         _loc5_ = _loc1_.m_AutoTanX;
         _loc6_ = _loc1_.m_AutoTanZ;
         _loc7_ = currState.vel.x * _loc5_ + currState.vel.z * _loc6_;
         _loc8_ = this.m_AutoLastGood.x + _loc5_ * _loc7_;
         _loc9_ = this.m_AutoLastGood.z + _loc6_ * _loc7_;
         if(_loc7_ > 0 && this.AutoDrivable(int(_loc2_.GetTerrainType(_loc8_,_loc9_))))
         {
            currState.loc.x = _loc8_;
            currState.loc.z = _loc9_;
            currState.vel.x = _loc5_ * _loc7_ * 0.8;
            currState.vel.z = _loc6_ * _loc7_ * 0.8;
         }
         else
         {
            currState.loc.x = this.m_AutoLastGood.x;
            currState.loc.z = this.m_AutoLastGood.z;
            currState.vel.x *= 0.3;
            currState.vel.z *= 0.3;
         }
         currState.loc.y = _loc2_.GetHeightInfo(currState.loc.x,currState.loc.z);
         this.m_AutoLastGood.x = currState.loc.x;
         this.m_AutoLastGood.y = currState.loc.y;
         this.m_AutoLastGood.z = currState.loc.z;
         this.SetRenderObjectLoc();
      }

      public function SetAction(param1:int) : void
      {
         var _loc2_:REffectData = null;
         if(this.IsAutoDriven())
         {
            switch(param1)
            {
               case RActionState.COLLISION_WALL:
               case RActionState.COLLISION_CAR:
               case RActionState.FAKE_BEATEN:
               case RActionState.JELLY_BEATEN:
               case RActionState.LIGHT_BEATEN:
               case RActionState.MUD_BEATEN:
               case RActionState.CAKE_BEATEN:
               case RActionState.BEATEN:
                  return;
            }
         }
         switch(param1)
         {
            case RActionState.AUTOPILOT_PLAY:
"""

tick_old = """         this.SetCarPose();
         var _loc4_:RResourcePath = RockRacer.GameCommon.GameClient.m_Terrain.m_path;
"""
tick_new = """         this.SetCarPose();
         if(!this.isCarStop && !this.isCarOut && this.IsAutoDriven())
         {
            this.AutoDriveGuard();
         }
         var _loc4_:RResourcePath = RockRacer.GameCommon.GameClient.m_Terrain.m_path;
"""

rtt_old = """      public function ReturnToTrack() : void
      {
         var dir:Vector3D = null;
         var prev:int = 0;
         var angle:Number = NaN;
         if(m_ObjType == RObjectType.AICAR)
         {
            return;
         }
"""
rtt_new = """      public function ReturnToTrack() : void
      {
         var dir:Vector3D = null;
         var prev:int = 0;
         var angle:Number = NaN;
         if(m_ObjType == RObjectType.AICAR || this.IsAutoDriven())
         {
            return;
         }
"""
patch(car, [(car_fields_old, car_fields_new), (act_old, act_new), (tick_old, tick_new), (rtt_old, rtt_new)])
print("patched RGameClient.as and RCar.as (lane follower, %d line numbers)" % (AUTO_LINE.count(",") + 1))
