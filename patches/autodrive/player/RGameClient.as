package player
{
   import AI.*;
   import Const.*;
   import Effect.*;
   import Menu.*;
   import common.*;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.geom.*;
   import flash.media.SoundTransform;
   import flash.net.*;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.text.*;
   import flash.ui.Keyboard;
   import flash.utils.*;
   import object.*;
   import org.papervision3d.cameras.*;
   import org.papervision3d.core.math.*;
   import org.papervision3d.core.render.data.*;
   import org.papervision3d.objects.DisplayObject3D;
   import org.papervision3d.render.*;
   import org.papervision3d.view.BasicView;
   import resourcemgr.*;
   import ui.*;
   
   public class RGameClient extends Sprite
   {
      
      public static var userTotal:int;
      
      public static var m_sendTime:Number;
      
      public static const CARCOUNT:int = 1;
      
      public static const RENDER_LOADING:int = 0;
      
      public static const RENDER_READY:int = 1;
      
      public static const RENDER_PLAYING:int = 2;
      
      public static const RENDER_SCORE:int = 3;
      
      public static const RENDER_END:int = 4;
      
      public static const RENDER_ABORT:int = 5;
      
      public static var m_ViewportWidth:int = 760;
      
      public static var m_ViewportHeight:int = 500;
      
      public static const KEY_UP:Number = 1;
      
      public static const KEY_DOWN:Number = 2;
      
      public static const KEY_LEFT:Number = 4;
      
      public static const KEY_RIGHT:Number = 8;
      
      public static const KEY_SPACE:Number = 16;
      
      public static const READY:int = 0;
      
      public static const GO:int = 1;
      
      public static const FALLING:int = 2;
      
      private var preticktime:int = 0;
      
      private const FPS:int = 12;
      
      private const TIMEPERFRAME:int = int(1000 / this.FPS);
      
      public var m_ReadyCounter:MovieClip;
      
      private var m_CloseButton:MovieClip;
      
      private var m_RankView:MovieClip;
      
      public var m_LapView:RLapView;
      
      public var m_TimerView:RTimerView;
      
      public var m_mudman:MovieClip;
      
      public var m_lightman:MovieClip;
      
      public var cellID:int = 0;
      
      public var m_RenderMode:int = 0;
      
      private var m_FadeEndScreen:int = 0;
      
      public var f_angle:Number = new Number(20);
      
      public var f_elas:Number = new Number(0.3);
      
      public var o_elas:Number = new Number(0.75);
      
      public var o_fric:Number = new Number(0.8);
      
      public var o_limvel:Number = new Number(5);
      
      public var m_StartFlag:Boolean = false;
      
      public var m_View:BasicView;
      
      public var m_scMask:MovieClip;
      
      public var m_TrackID:int;
      
      public var m_PlayerID:int;
      
      public var m_PlayerObjID:int;
      
      public var KeyMask:Number = 0;
      
      private var preKeyMask:Number = 0;
      
      public var m_LevelRsr:RResourceMgr;
      
      public var m_Object:Array;
      
      public var m_CarList:Array;
      
      public var m_Terrain:RTerrain;
      
      public var m_Boundary:RBoundary;
      
      public var m_Sky:RSky;
      
      public var m_CollisionWall:RCollisionWall;
      
      public var m_Sea:RSea;
      
      public var m_CurrCellID:int;
      
      public var m_CurrViewCells:Array;
      
      public var outputTri_txt:TextField = new TextField();
      
      public var outputCollision_txt:TextField = new TextField();
      
      public var Str:String = new String("");
      
      public var m_CameraMode:int = 0;
      
      protected var m_CameraRate:Number = 1.3;
      
      public var miniCars:Array = new Array();
      
      public var weaponView:RWeaponView;
      
      public var BonusUseFlag:Boolean = false;
      
      public var Squirrel:MovieClip;
      
      public var m_LoadFile:FileReference = new FileReference();
      
      public var m_SpecialEffect:RSpecialEffect;
      
      protected var MiddleDist:Number = 500;
      
      protected var LowDist:Number = 3000;
      
      public var m_GameSWfLoader:Loader = new Loader();
      
      public var m_DeletePage:Boolean = false;
      
      public var m_miniMap:RMinimap = new RMinimap();
      
      protected var m_minMapWidth:int;
      
      protected var m_minMapHeight:int;
      
      public var m_QuitWindow:QuitWindow = new QuitWindow();
      
      public var m_QuitWindowEnable:Boolean = false;
      
      private var _pause:Boolean = false;
      
      public var Tutorial_Space:MovieClip;
      
      public var Tutorial_Box:MovieClip;
      
      public var m_TutorialSpace:Array = new Array();
      
      public var timeoutTime:int = -1;
      
      private var timeoutFunction:Function = new Function();
      
      private var timeoutArg:Boolean;
      
      private var m_isQuitEnable:Boolean;
      
      public var aa:int = 0;
      
      public var mc_MarkDirection:mc_MarkDir = new mc_MarkDir();
      
      public var mc_GuideWnd:RGuideWindow = new RGuideWindow();
      
      public var mc_InfoWnd:RInfoWindow = new RInfoWindow();
      
      private var oil:Number;
      
      private const maxOil:Number = 1000;
      
      private const minOil:Number = 100;

      public var m_AutoDrive:Boolean = false;

      private var m_CheatBuf:Array = new Array();

      private var m_CheatLastTime:int = 0;

      private var m_CheatMsg:Sprite = null;

      private var m_CheatMsgText:TextField = null;

      private var m_CheatMsgTimer:uint = 0;

      public static const AUTO_LINE:Array = [61848.1,-81646.1,51169,-139158,50781.8,-141120,48960.9,-149417,48344.6,-151287,46165.8,-157411,44953,-160686,43829.4,-163455,41177.6,-169390,38678.4,-174273,36204.7,-178618,33038,-183698,30203.1,-187797,27809.3,-191002,25968.5,-193357,23064.7,-196763,21730.7,-198254,19337.3,-200808,17245.3,-202945,14716.4,-205337,10558,-208936,7056.3,-211736,2158.2,-215194,-357.8,-216829,-2462.4,-218146,-4622.4,-219393,-6386.5,-220337,-10839.9,-222611,-15410.3,-224631,-20066.1,-226427,-22905.4,-227396,-25772.3,-228284,-28644.2,-229072,-33035.1,-230023,-35002.2,-230385,-37964.3,-230862,-41427,-231344,-43891.2,-231567,-48884.1,-231849,-53375.7,-231877,-55864.8,-231809,-58862,-231656,-61853.1,-231426,-63843.9,-231229,-66794.4,-230819,-70710.7,-230027,-74587.9,-229043,-78415.9,-227892,-82589.9,-226228,-84428.7,-225441,-86694.5,-224383,-90232.6,-222543,-94071.1,-220206,-96572,-218548,-98203.5,-217391,-99804.6,-216189,-102518,-214026,-105885,-211046,-108769,-208271,-110495,-206462,-111824,-204965,-113443,-203062,-114968,-201105,-117690,-197515,-118541,-196279,-119880,-194166,-121144,-192002,-121638,-191140,-122775,-188934,-124076,-186230,-125098,-183949,-126240,-181172,-126761,-179772,-128306,-175038,-129095,-172143,-129671,-169710,-130446,-165791,-131027,-161330,-131174,-159837,-131340,-157342,-131410,-154840,-131358,-150876,-131135,-147888,-130812,-144905,-130360,-141939,-129762,-139010,-128958,-136165,-128639,-135216,-127801,-132860,-126288,-129156,-125047,-126427,-123535,-123276,-122850,-121946,-120683,-118003,-119638,-116298,-116355,-111271,-98767,-87640.7,-93683.2,-81463.3,-68429.7,-51085.2,-62424.8,-43715.3,-58452.4,-38561.6,-53499.3,-31641.4,-50163.3,-26636.1,-48309.5,-23667.4,-46316.2,-20160.6,-44506.7,-16551,-44101.7,-15635.6,-42674,-11899,-42190,-10477.7,-41580.3,-7964.3,-41385.2,-6440.3,-41225.3,-3945.2,-41311.4,-1938.1,-41210.1,-897,-41309.6,-297.8,-41878,479.2,-41908.2,1287.4,-42036.9,2336.6,-43103,5203.4,-43700.5,6631.5,-44514.6,7975.7,-44812.3,8379.5,-51690.4,16313.1,-52406.7,17015.3,-53202.5,17692.8,-55847,19290.4,-57620.8,20214.5,-86199.8,34624.1,-104069,43570.1,-104474,43805.3,-106884,45510.5,-108343,45451.4,-108865,45753.6,-109417,46495.8,-109840,46495.2,-110361,46727.7,-111552,48424.7,-111731,48882.6,-111554,50383.9,-111432,50876.5,-111220,52321.5,-109163,56261.2,-88735.8,96362,-65416.7,142274,-64728.8,143608,-63491.4,145213,-63237.1,146212,-62902.2,147167,-60483.8,151544,-58146.7,155373,-52185.7,164605,-44849.9,174710,-43022.8,177090,-40504.9,180198,-36359.8,185199,-33432.8,188617,-31411.8,190835,-26609,195905,-25189.6,197315,-23007.9,199374,-19294.9,202724,-16001.1,205783,-13353,208066,-9498,211251,-6747.1,213416,-4357.6,215233,-1117,217510,957.5,218907,3903.8,220797,7727.5,223170,9870,224411,13396,226272,16112.8,227546,18409.3,228535,21199.4,229643,22556.8,230267,23023.3,230417,34136.4,233377,35116.7,233578,37593.2,233894,40573.5,234033,42075.2,234020,47066.4,233723,48557.9,233531,50044.9,233262,51013.9,233159,53368.5,232379,61163.6,228990,62925.8,228061,63267.4,227739,64884.5,225841,65573,225114,66184.5,224321,71701.7,217871,71940.2,217507,72389.8,216102,72634.9,215131,74226.9,206272,74382.2,204791,74360,200789,73822.2,193309,73196.7,188845,72126.2,182446,65289.9,145569,64704.1,141612,63813,133132,63558.8,129640,63409.4,126644,63298.7,120623,63527.6,114606,63761.2,111113,64330.9,105641,64622.6,103634,65214.7,100169,65915.3,96739.6,67462.6,89896.9,68818.4,85038.1,69995.2,81741.8,72045.8,76635.1,72863.8,74759.6,74079.1,72498.3,74598.3,71642.1,78255.3,66268.4,83670.9,59671.7,84581.4,58477.2,88483.5,52665.4,88969.2,51786.6,89088.5,51342.2,88114.5,42403.1,87972.7,41413.2,81061.6,4031.1,80076.4,-1456.3,79970.1,-2295.2,79460.3,-4237.2,79659.2,-5147.4,81196.9,-6820,81731.1,-7197.9,82769.6,-7541.4,84307,-7868.4,159163,-20997.2,159557,-21105.3,159951,-21428.7,160493,-21492.5,162522,-21303.8,163259,-21968.4,163596,-22105.3,164037,-22034.4,164537,-22022.3,166559,-22279.9,168534,-25166.8,168662,-25501.9,149123,-136162,146672,-150261,145829,-152594,145998,-153504,145988,-154004,145805,-155540,145490,-156536,145067,-157465,144747,-157885,143333,-159327,142915,-159476,140955,-159272,74483.2,-147535,73142.5,-147355,72415.1,-146758,71920.5,-146678,71418.5,-146796,70918.5,-146844,70418.5,-146832,69897.3,-146755,69547.4,-146414,67784,-143589,67879.3,-143270,68488.2,-139844,83588.2,-54174.6,83891.7,-52679.8,83943.8,-52152.2,84477.9,-49129.2,84514.9,-48627.4,84480.5,-48356.7,85103.9,-47210.4,85092,-46453.8,84989.4,-45418.4,84834.7,-44710.6,84360.9,-44204.1,82056.9,-42111.8,79510.6,-41663.5,78505.9,-41321.2,77404.1,-41248,76519.9,-41334.2,76267,-41158.5,75764.9,-40673.5,75054.3,-40582.8,74016.8,-40648.9,72516.8,-40544.2,70988.2,-40598.5,70289.4,-40751.9,69908.1,-41338,68921.3,-43134.6,68781.2,-43677.9,68160.3,-47648.9];

      private var m_AutoIdx:int = 0;

      public var m_AutoTanX:Number = 0;

      public var m_AutoTanZ:Number = 1;

      private var m_AutoT:Number = 0;

      private var m_AutoD:Number = 0;

      private var m_AutoPX:Number = 0;

      private var m_AutoPZ:Number = 0;

      public static const AUTO_EXTRA:Array = [1,0,0,0,1,1,1,0,0,1,1,1,1,1,0,0,0,0,0,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,0,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,0,0,0,1,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

      private var m_AutoShift:Number = 0;

      private var m_AutoShiftTarget:Number = 0;

      private var m_AutoHold:int = 0;

      private var m_AutoBlockDist:Number = 1e9;

      private var m_AutoBlockSpeed:Number = 0;
      
      public function RGameClient()
      {
         super();
         this.m_LevelRsr = new RResourceMgr();
         this.m_Object = new Array();
         this.m_CarList = new Array();
         this.m_Terrain = new RTerrain();
         this.m_Boundary = new RBoundary();
         this.m_CollisionWall = new RCollisionWall();
         this.m_Sky = new RSky();
         RBonusType.CreateInstance();
         RPlayerType.CreateInstance();
         this.LoadSWF("symbol.dat");
      }
      
      public static function GetClassInSWF(param1:String) : Class
      {
         return getDefinitionByName(param1) as Class;
      }
      
      public static function MsgNum(param1:Number) : Number
      {
         return Number(int(param1 * 100)) / 100;
      }
      
      public function set pause(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this._pause = param1;
         if(this._pause)
         {
            this.m_TimerView.pauseTime();
            this.weaponView.pause = true;
            this.m_mudman.stop();
            this.m_lightman.stop();
            this.Squirrel.stop();
            this.m_ReadyCounter.stop();
            this.m_RankView.stop();
            this.m_LapView.pause = true;
         }
         else
         {
            _loc4_ = this.m_TimerView.resumeTime();
            _loc2_ = 0;
            while(_loc2_ < this.m_CarList.length)
            {
               _loc3_ = 0;
               while(_loc3_ < this.m_CarList[_loc2_].m_LapTimes.length)
               {
                  this.m_CarList[_loc2_].m_LapTimes[_loc3_] += _loc4_;
                  _loc3_++;
               }
               _loc2_++;
            }
            this.m_LapView.pause = false;
            this.weaponView.pause = false;
            if(this.m_mudman.visible)
            {
               this.m_mudman.play();
            }
            if(this.m_lightman.visible)
            {
               this.m_lightman.play();
            }
            if(this.Squirrel.visible)
            {
               this.Squirrel.play();
            }
            if(this.m_ReadyCounter.parent)
            {
               this.m_ReadyCounter.play();
            }
         }
      }
      
      public function get pause() : Boolean
      {
         return this._pause;
      }
      
      public function addItem(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(param1[2]);
         param1.splice(0,3);
         _loc3_ = 0;
         while(_loc3_ < this.m_CarList.length)
         {
            if(this.m_CarList[_loc3_].m_userId == _loc2_)
            {
               this.m_CarList[_loc3_].m_BonusID = int(param1[0]);
               this.m_CarList[_loc3_].UseBonus({"m_CurrLoc":{
                  "x":int(param1[1]),
                  "y":int(param1[2]),
                  "z":int(param1[3])
               }});
            }
            _loc3_++;
         }
      }
      
      public function getItem(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(param1[2]);
         param1.splice(0,3);
         if(_loc2_ != Client.myUserId)
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_CarList.length)
            {
               if(this.m_CarList[_loc3_].m_userId == _loc2_)
               {
                  if(this.m_Object[int(param1[0])] != null)
                  {
                     this.m_CarList[_loc3_].CollisionProc(this.m_Object[int(param1[0])]);
                     this.m_Object[int(param1[0])].CollisionProc(this.m_CarList[_loc3_]);
                  }
               }
               _loc3_++;
            }
         }
      }
      
      public function setLap(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(param1[2]);
         param1.splice(0,3);
         if(_loc2_ != Client.myUserId)
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_CarList.length)
            {
               if(this.m_CarList[_loc3_].m_userId == _loc2_)
               {
                  this.m_CarList[_loc3_].m_Lap = int(param1[0]);
               }
               _loc3_++;
            }
         }
      }
      
      public function setMoveState(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc2_:int = int(param1[2]);
         param1.splice(0,3);
         var _loc3_:Object = {
            "x":Number(param1[0]),
            "y":Number(param1[1]),
            "z":Number(param1[2])
         };
         var _loc4_:Object = {
            "x":Number(param1[3]),
            "y":Number(param1[4]),
            "z":Number(param1[5])
         };
         var _loc5_:Object = {
            "x":Number(param1[10]),
            "y":Number(param1[11]),
            "z":Number(param1[12])
         };
         var _loc6_:int = Number(param1[2]);
         var _loc7_:Object = {
            "id":_loc2_,
            "count":int(param1[9]),
            "keyMask":Number(param1[8]),
            "loc":_loc3_,
            "pose":_loc4_,
            "vel":_loc5_,
            "actionState":Number(param1[6]),
            "animState":Number(param1[7]),
            "destPath":int(param1[14])
         };
         if(_loc2_ != Client.myUserId)
         {
            _loc8_ = 0;
            while(_loc8_ < this.m_CarList.length)
            {
               if(this.m_CarList[_loc8_].m_userId == _loc2_)
               {
                  if(this.m_CarList[_loc8_].m_msgCount <= int(param1[9]))
                  {
                     this.otherHandleInputLoop(Number(param1[8]),_loc8_);
                     this.m_CarList[_loc8_].SetAction(RActionState.NONE);
                     this.m_CarList[_loc8_].SetCarPose(_loc7_);
                     this.m_CarList[_loc8_].m_msgCount = int(param1[9]);
                  }
                  return;
               }
               _loc8_++;
            }
         }
      }
      
      public function LoadSWF(param1:String) : void
      {
         var _loc2_:URLRequest = new URLRequest(RockRacer.base + param1);
         var _loc3_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         this.m_GameSWfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSWFLoadComplete);
         this.m_GameSWfLoader.load(_loc2_,_loc3_);
      }
      
      public function onSWFLoadComplete(param1:Event) : void
      {
         var _loc2_:Class = GetClassInSWF("ScreenMask");
         this.m_scMask = MovieClip(new _loc2_());
         _loc2_ = GetClassInSWF("Squirrel_inc");
         this.Squirrel = MovieClip(new _loc2_());
         this.m_SpecialEffect = new RSpecialEffect();
         this.weaponView = new RWeaponView();
         _loc2_ = GetClassInSWF("ReadyCounter");
         this.m_ReadyCounter = MovieClip(new _loc2_());
         _loc2_ = GetClassInSWF("PlayerRankView");
         this.m_RankView = MovieClip(new _loc2_());
         _loc2_ = GetClassInSWF("CloseButton");
         this.m_CloseButton = MovieClip(new _loc2_());
         _loc2_ = GetClassInSWF("Wrongway_Character");
         _loc2_ = GetClassInSWF("Lighteman");
         this.m_lightman = MovieClip(new _loc2_());
         _loc2_ = GetClassInSWF("Mudman");
         this.m_mudman = MovieClip(new _loc2_());
         this.m_LapView = new RLapView();
         this.m_TimerView = new RTimerView();
      }
      
      public function Initialize() : void
      {
         this.m_LevelRsr.LoadLevel(this.m_TrackID);
         this.aa = 0;
         this.m_View = new BasicView(m_ViewportWidth,m_ViewportHeight,false,true,CameraType.FREE);
         this.m_View.camera.zoom = 10;
         this.m_View.camera.focus = 50;
         this.m_View.scene.addChild(this.m_Terrain);
         this.m_View.scene.addChild(this.m_Boundary);
         this.m_Sea = new RSea();
         this.m_View.scene.addChild(this.m_Sea);
         this.m_View.scene.addChild(this.m_Sky);
         this.m_View.scene.addChild(this.m_SpecialEffect.m_ParticleManager);
         with(this.outputTri_txt)
         {
            text = "*\n\n";
            width = 200;
            height = outputTri_txt.textHeight;
            textColor = 255;
            x = 20;
            y = 10;
            visible = true;
         }
         this.m_RenderMode = RENDER_LOADING;
         this.m_FadeEndScreen = 0;
         this.m_LevelRsr.addEventListener("LOAD_COMPLETE",this.LoadRsrComplete);
         this.m_isQuitEnable = false;
      }
      
      public function DestroyScene() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = this.m_View.scene.numChildren;
         this.ResetAutoDrive();
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            this.m_View.scene.removeChild(this.m_View.scene.objects[0]);
            _loc2_++;
         }
         this.m_Object.splice(0);
         this.m_CarList.splice(0);
         this.miniCars.splice(0);
         this.m_TimerView.stopTime();
         this.m_TimerView.time = 0;
         this.m_LapView.setPlayerLab(1);
         while(this.m_miniMap.numChildren > 0)
         {
            this.m_miniMap.removeChildAt(0);
         }
         _loc1_ = this.numChildren;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            removeChildAt(0);
            _loc2_++;
         }
         if(RockRacer.GameCommon.g_SingleGame)
         {
            removeEventListener(Event.ENTER_FRAME,this.Loop);
         }
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.KeyDownHandler);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.KeyUpHandler);
         stage.removeEventListener(Event.DEACTIVATE,this.Deactive);
         this.m_ReadyCounter.gotoAndStop(1);
      }
      
      public function SetTrack(param1:int) : void
      {
         this.m_TrackID = param1;
      }
      
      public function SetPlayer(param1:int) : void
      {
         this.m_PlayerID = param1;
      }
      
      public function LoadRsrComplete(param1:Event) : void
      {
         addEventListener("INIT_COMPLATE",this.initTerrain);
         addEventListener(Event.ENTER_FRAME,this.initTerrainLoop);
         this.m_Terrain.startInitTerrain();
      }
      
      public function initTerrainLoop(param1:Event) : void
      {
         this.m_Terrain.loopInit(param1);
         dispatchEvent(new ProgressEvent("progress",false,false,int(this.m_Terrain.getInitProgress() * 40 / 100),100));
      }
      
      public function initTerrain(param1:Event) : void
      {
         this.m_Boundary.InitBoundary();
         this.m_Sky.InitSky();
         this.m_Sea.InitSea();
         this.m_CollisionWall.InitCollisionWall();
         this.InitCarObject();
         removeEventListener(Event.ENTER_FRAME,this.initTerrainLoop);
         removeEventListener("INIT_COMPLATE",this.initTerrain);
         dispatchEvent(new Event("LOAD_FINISH"));
      }
      
      public function InitGo() : void
      {
         var _loc1_:MovieClip = null;
         var _loc3_:RMinicar = null;
         var _loc4_:int = 0;
         var _loc5_:SoundTransform = null;
         addChild(this.m_View);
         this.Squirrel.visible = false;
         this.Squirrel.x = 350;
         this.Squirrel.y = 150;
         this.Squirrel.stop();
         addChild(this.Squirrel);
         addChild(this.m_SpecialEffect);
         this.mc_MarkDirection.x = 348;
         this.mc_MarkDirection.y = 80;
         this.mc_MarkDirection.gotoAndStop("blank");
         addChild(this.mc_MarkDirection);
         this.mc_GuideWnd.x = 0;
         this.mc_GuideWnd.y = 0;
         this.mc_GuideWnd.gotoAndStop(1);
         addChild(this.mc_GuideWnd);
         this.mc_InfoWnd.x = 0;
         this.mc_InfoWnd.y = 0;
         this.mc_InfoWnd.gotoAndStop(1);
         this.mc_InfoWnd.initCounter();
         addChild(this.mc_InfoWnd);
         var _loc2_:Class = getDefinitionByName("mini_mapPY") as Class;
         _loc1_ = MovieClip(new _loc2_());
         _loc1_.x = 0;
         _loc1_.y = 50;
         this.m_minMapWidth = _loc1_.width;
         this.m_minMapHeight = _loc1_.height;
         this.m_miniMap.Init();
         this.m_miniMap.addChild(_loc1_);
         _loc3_ = new RMinicar(RMinicar.TYPE_PYCAR);
         this.miniCars.push(_loc3_);
         this.m_miniMap.addChild(_loc3_);
         addChild(this.m_miniMap);
         addChild(this.m_scMask);
         this.m_scMask.visible = true;
         this.m_scMask.gotoAndStop(0);
         this.m_CloseButton.x = m_ViewportWidth - this.m_CloseButton.width - 25;
         this.m_CloseButton.y = 0;
         this.m_RankView.x = m_ViewportWidth - this.m_RankView.width - 10;
         this.m_RankView.y = m_ViewportHeight - this.m_RankView.height - 10;
         this.m_LapView.setPlayerLab(1);
         this.m_TimerView.time = 0;
         addChild(this.m_CloseButton);
         addChild(this.m_TimerView);
         this.m_mudman.x = 370;
         this.m_mudman.y = 150;
         this.m_mudman.visible = false;
         addChild(this.m_mudman);
         this.m_lightman.x = 370;
         this.m_lightman.y = 150;
         this.m_lightman.visible = false;
         addChild(this.m_lightman);
         addChild(this.m_ReadyCounter);
         this.m_ReadyCounter.x = m_ViewportWidth / 2;
         this.m_ReadyCounter.y = m_ViewportHeight / 2;
         setTimeout(this.startReadyCount,3000);
         if(!RockRacer.GameCommon.m_SoundOnOff)
         {
            _loc5_ = this.m_ReadyCounter.soundTransform;
            _loc5_.volume = 0;
            this.m_ReadyCounter.soundTransform = _loc5_;
         }
         this.m_RenderMode = RENDER_READY;
         this.m_DeletePage = true;
         this.preticktime = getTimer();
         this.weaponView.stopSelecting();
         this.m_CameraMode = READY;
         this.oil = this.maxOil;
         this.ResetAutoDrive();
         addEventListener(Event.ENTER_FRAME,this.Loop);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.KeyDownHandler);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.KeyUpHandler);
         stage.addEventListener(Event.DEACTIVATE,this.Deactive);
         this.m_CloseButton.addEventListener(MouseEvent.CLICK,this.EscapeFunc);
         this._pause = false;
         this.m_QuitWindowEnable = false;
      }
      
      private function startReadyCount() : void
      {
         if(!this.pause)
         {
            this.m_ReadyCounter.gotoAndStop(2);
         }
      }
      
      protected function Deactive(param1:Event) : void
      {
         this.KeyMask = 0;
         this.preKeyMask = this.KeyMask;
         if(RockRacer.GameCommon.g_SingleGame)
         {
            this.QuitWindowFunc();
         }
         else
         {
            Client.sendState([MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.z),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.z),this.m_CarList[this.m_PlayerID].currState.actionState,this.m_CarList[this.m_PlayerID].currState.animState,this.KeyMask,this.m_CarList[this.m_PlayerID].m_msgCount++,MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.z),this.m_CarList[this.m_PlayerID].m_bBA,this.m_CarList[this.m_PlayerID].m_DestPath]);
            m_sendTime = getTimer();
         }
      }
      
      public function InitCarObject() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Vector3D = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:ROBJECTINFO = null;
         if(RockRacer.GameCommon.g_SingleGame)
         {
            _loc1_ = 0;
            while(_loc1_ < CARCOUNT)
            {
               _loc8_ = new ROBJECTINFO();
               _loc4_ = new Vector3D();
               _loc4_ = this.m_Terrain.m_path.m_lPath[1].subtract(this.m_Terrain.m_path.m_lPath[0]);
               _loc5_ = Math.atan(_loc4_.x / _loc4_.z);
               _loc6_ = Math.cos(_loc5_);
               _loc7_ = Math.sin(_loc5_);
               _loc5_ = _loc5_ * 180 / Math.PI;
               if(_loc4_.z < 0)
               {
                  _loc5_ += 180;
               }
               if(_loc5_ < 0)
               {
                  _loc5_ += 360;
                  _loc6_ = -_loc6_;
                  _loc7_ = -_loc7_;
               }
               _loc8_.m_CurrLoc = new Vector3D(this.m_Terrain.m_path.m_lPath[0].x + (_loc1_ - 2) * 150 * (_loc7_ + _loc6_),this.m_Terrain.GetHeightInfo(this.m_Terrain.m_path.m_lPath[0].x,this.m_Terrain.m_path.m_lPath[0].z),this.m_Terrain.m_path.m_lPath[0].z + _loc1_ * 150 * (_loc6_ - _loc7_));
               _loc8_.m_CurrPose = new Vector3D(0,_loc5_,0);
               _loc8_.m_CurrState = RObjectStateType.NEWOBJECT;
               if(_loc1_ == this.m_PlayerID)
               {
                  _loc8_.m_ObjectType = RObjectType.PLAYERCAR;
                  _loc8_.m_ObjectProperty = 2;
               }
               else
               {
                  _loc8_.m_ObjectType = RObjectType.AICAR;
                  _loc8_.m_ObjectProperty = _loc1_;
               }
               RockRacer.GameCommon.AddObject(_loc8_);
               _loc1_++;
            }
         }
         else
         {
            _loc1_ = 0;
            while(_loc1_ < Client.multiInfo.ps.length)
            {
               _loc8_ = new ROBJECTINFO();
               _loc4_ = new Vector3D();
               _loc4_ = this.m_Terrain.m_path.m_lPath[1].subtract(this.m_Terrain.m_path.m_lPath[0]);
               _loc5_ = Math.atan(_loc4_.x / _loc4_.z);
               _loc6_ = Math.cos(_loc5_);
               _loc7_ = Math.sin(_loc5_);
               _loc5_ = _loc5_ * 180 / Math.PI;
               if(_loc4_.z < 0)
               {
                  _loc5_ += 180;
               }
               if(_loc5_ < 0)
               {
                  _loc5_ += 360;
                  _loc6_ = -_loc6_;
                  _loc7_ = -_loc7_;
               }
               _loc8_.m_CurrLoc = new Vector3D(this.m_Terrain.m_path.m_lPath[0].x + (_loc1_ - 2) * 150 * (_loc7_ + _loc6_),this.m_Terrain.GetHeightInfo(this.m_Terrain.m_path.m_lPath[0].x,this.m_Terrain.m_path.m_lPath[0].z),this.m_Terrain.m_path.m_lPath[0].z + _loc1_ * 150 * (_loc6_ - _loc7_));
               _loc8_.m_CurrPose = new Vector3D(0,_loc5_,0);
               _loc8_.m_CurrState = RObjectStateType.NEWOBJECT;
               if(Client.multiInfo.ps[_loc1_] == Client.myUserId)
               {
                  _loc8_.m_ObjectType = RObjectType.PLAYERCAR;
                  _loc8_.m_ObjectProperty = int(Client.multiInfo["p_" + Client.multiInfo.ps[_loc1_]].dt);
                  _loc8_.m_userId = Client.multiInfo.ps[_loc1_];
               }
               else
               {
                  _loc8_.m_ObjectType = RObjectType.AICAR;
                  _loc8_.m_ObjectProperty = int(Client.multiInfo["p_" + Client.multiInfo.ps[_loc1_]].dt);
                  _loc8_.m_userId = Client.multiInfo.ps[_loc1_];
               }
               RockRacer.GameCommon.AddObject(_loc8_);
               _loc1_++;
            }
         }
         this.RenderObjectLoop();
      }
      
      public function RenderObjectLoop() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Array = RockRacer.GameCommon.g_ObjectInfo;
         var _loc2_:int = RGameCommon.g_ObjectCount;
         _loc3_ = 0;
         while(_loc3_ < _loc1_.length)
         {
            switch(_loc1_[_loc3_].m_CurrState)
            {
               case RObjectStateType.NEWOBJECT:
                  this.CreateObject(_loc1_[_loc3_]);
                  _loc1_[_loc3_].m_CurrState = RObjectStateType.USEOBJECT;
                  break;
               case RObjectStateType.USEOBJECT:
                  this.UpdateObject(_loc1_[_loc3_]);
                  break;
               case RObjectStateType.DELETEOBJECT:
                  this.DeleteObject(_loc1_[_loc3_]);
                  RockRacer.GameCommon.RemoveObject(_loc1_[_loc3_].m_ObjectID);
            }
            _loc3_++;
         }
      }
      
      public function CreateObject(param1:ROBJECTINFO) : void
      {
         var _loc2_:DisplayObject3D = null;
         var _loc3_:RPlayerCar = null;
         var _loc4_:RAICar = null;
         var _loc5_:RTreasure = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         switch(param1.m_ObjectType)
         {
            case RObjectType.PLAYERCAR:
               _loc3_ = new RPlayerCar(param1);
               _loc3_.BuildGeom();
               _loc3_.m_CollisionType = true;
               this.m_View.scene.addChild(_loc3_.m_renderObject);
               this.m_View.scene.addChild(_loc3_.m_FLWheelObject);
               this.m_View.scene.addChild(_loc3_.m_FRWheelObject);
               this.m_View.scene.addChild(_loc3_.m_BLWheelObject);
               this.m_View.scene.addChild(_loc3_.m_BRWheelObject);
               this.m_Object.push(_loc3_);
               this.m_CarList.push(_loc3_);
               this.m_PlayerID = this.m_CarList.length - 1;
               this.m_PlayerObjID = _loc3_.m_ObjID;
               _loc3_.m_Rank = this.m_CarList.length;
               break;
            case RObjectType.AICAR:
               _loc4_ = new RAICar(param1);
               _loc4_.BuildGeom();
               _loc4_.m_CollisionType = true;
               this.m_View.scene.addChild(_loc4_.m_renderObject);
               this.m_View.scene.addChild(_loc4_.m_FLWheelObject);
               this.m_View.scene.addChild(_loc4_.m_FRWheelObject);
               this.m_View.scene.addChild(_loc4_.m_BLWheelObject);
               this.m_View.scene.addChild(_loc4_.m_BRWheelObject);
               if(!RockRacer.GameCommon.g_SingleGame)
               {
                  _loc7_ = 0;
                  while(_loc7_ < RLoadingCourse.m_multiUsers.length)
                  {
                     if(RLoadingCourse.m_multiUsers[_loc7_].uid == param1.m_userId)
                     {
                        _loc6_ = RLoadingCourse.m_multiUsers[_loc7_];
                     }
                     _loc7_++;
                  }
                  _loc8_ = 0;
                  while(_loc8_ < RockRacer.GameCommon.m_PlayerPictureMgr.Pic.length)
                  {
                     if(_loc6_.picsquare == RockRacer.GameCommon.m_PlayerPictureMgr.Pic[_loc8_].url)
                     {
                        _loc4_.SetPicture(RockRacer.GameCommon.m_PlayerPictureMgr.Pic[_loc8_].material);
                        this.m_View.scene.addChild(_loc4_.m_PlayerPicture);
                        break;
                     }
                     _loc8_++;
                  }
                  this.m_View.scene.addChild(_loc4_.m_photoFrame1);
                  this.m_View.scene.addChild(_loc4_.m_photoFrame2);
                  this.m_View.scene.addChild(_loc4_.m_photoFrame3);
                  this.m_View.scene.addChild(_loc4_.m_photoFrame4);
               }
               this.m_Object.push(_loc4_);
               this.m_CarList.push(_loc4_);
               _loc4_.m_Rank = this.m_CarList.length;
               break;
            case RObjectType.TREE1:
            case RObjectType.TREE2:
            case RObjectType.TREE3:
               _loc5_ = new RTreasure(param1);
               _loc5_.BuildGeom();
               _loc5_.m_CollisionType = true;
               this.m_View.scene.addChild(_loc5_.m_renderObject);
               this.m_Object.push(_loc5_);
         }
      }
      
      public function UpdateObject(param1:ROBJECTINFO) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_Object.length)
         {
            if(this.m_Object[_loc2_].m_ObjID == param1.m_ObjectID)
            {
               this.m_Object[_loc2_].UpdateObjInfo(param1);
            }
            _loc2_++;
         }
      }
      
      public function DeleteObject(param1:ROBJECTINFO) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_Object.length)
         {
            if(this.m_Object[_loc2_].m_ObjID == param1.m_ObjectID)
            {
               this.m_View.scene.removeChild(this.m_Object[_loc2_].m_renderObject);
               this.m_Object.splice(_loc2_,1);
            }
            _loc2_++;
         }
      }
      
      public function GetObjectID(param1:int) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_Object.length)
         {
            if(this.m_Object[_loc2_].m_ObjID == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function KeyDownHandler(param1:KeyboardEvent) : void
      {
         this.preKeyMask = this.KeyMask;
         if(param1.keyCode == Keyboard.UP && !(this.KeyMask & KEY_UP))
         {
            this.RecordCheatKey(KEY_UP);
         }
         else if(param1.keyCode == Keyboard.DOWN && !(this.KeyMask & KEY_DOWN))
         {
            this.RecordCheatKey(KEY_DOWN);
         }
         switch(param1.keyCode)
         {
            case Keyboard.UP:
               this.KeyMask |= KEY_UP;
               break;
            case Keyboard.DOWN:
               this.KeyMask |= KEY_DOWN;
               break;
            case Keyboard.LEFT:
               this.KeyMask |= KEY_LEFT;
               break;
            case Keyboard.RIGHT:
               this.KeyMask |= KEY_RIGHT;
               break;
            case Keyboard.SPACE:
               if(this.weaponView.currentState != RWeaponView.STATE_COMPLETVIEW && this.m_RenderMode == RENDER_PLAYING)
               {
                  this.m_CarList[this.m_PlayerID].PlayHornkSound();
               }
         }
      }
      
      public function KeyUpHandler(param1:KeyboardEvent) : void
      {
         this.preKeyMask = this.KeyMask;
         switch(param1.keyCode)
         {
            case Keyboard.UP:
               this.KeyMask &= ~KEY_UP;
               break;
            case Keyboard.DOWN:
               this.KeyMask &= ~KEY_DOWN;
               break;
            case Keyboard.LEFT:
               this.KeyMask &= ~KEY_LEFT;
               break;
            case Keyboard.RIGHT:
               this.KeyMask &= ~KEY_RIGHT;
               break;
            case Keyboard.SPACE:
               if(!this.pause)
               {
                  if(this.weaponView.currentState == RWeaponView.STATE_COMPLETVIEW)
                  {
                     if(!this.m_CarList[this.m_PlayerID].UseBonus())
                     {
                        return;
                     }
                     this.BonusUseFlag = true;
                     this.weaponView.stopSelecting();
                  }
               }
               break;
            case Keyboard.ESCAPE:
               if(this.m_isQuitEnable == true)
               {
                  if(RockRacer.GameCommon.g_SingleGame)
                  {
                     if(!this.m_QuitWindowEnable)
                     {
                        if(this.m_RenderMode != RENDER_READY)
                        {
                           this.QuitWindowFunc();
                        }
                     }
                     else
                     {
                        this.CancelFunc(param1);
                     }
                  }
               }
         }
      }
      
      public function HandleInputLoop() : void
      {
         if(this.m_RenderMode != RENDER_PLAYING)
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
         if(this.m_RenderMode == RENDER_SCORE)
         {
            return;
         }
         if(this.oil < 1)
         {
            this.m_CarList[this.m_PlayerID].StopAccel();
            if(this.m_CarList[this.m_PlayerID].currState.vel.length < 10)
            {
               this.QuitWindowFunc(2);
            }
            return;
         }
         if(this.preKeyMask != this.KeyMask && !RockRacer.GameCommon.g_SingleGame && this.m_CarList[this.m_PlayerID].isCarStop == false && this.m_CarList[this.m_PlayerID].isCarOut == false)
         {
            Client.sendState([MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.z),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.z),this.m_CarList[this.m_PlayerID].currState.actionState,this.m_CarList[this.m_PlayerID].currState.animState,this.KeyMask,this.m_CarList[this.m_PlayerID].m_msgCount++,MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.z),this.m_CarList[this.m_PlayerID].m_bBA,this.m_CarList[this.m_PlayerID].m_DestPath]);
            m_sendTime = getTimer();
         }
         this.preKeyMask = this.KeyMask;
         if(Boolean(this.KeyMask & KEY_UP) && !(this.KeyMask & KEY_DOWN))
         {
            this.m_CarList[this.m_PlayerID].SpeedUp();
            this.m_StartFlag = true;
            --this.oil;
            this.mc_InfoWnd.mc_Oil.gotoAndStop(Math.round(this.oil / this.maxOil * 100));
         }
         if(Boolean(this.KeyMask & KEY_DOWN) && !(this.KeyMask & KEY_UP))
         {
            this.m_CarList[this.m_PlayerID].SpeedDown();
            this.m_StartFlag = true;
            --this.oil;
            this.mc_InfoWnd.mc_Oil.gotoAndStop(Math.round(this.oil / this.maxOil * 100));
         }
         if(Boolean(this.KeyMask & KEY_LEFT) && !(this.KeyMask & KEY_RIGHT))
         {
            this.m_CarList[this.m_PlayerID].TurnLeft();
            this.m_StartFlag = true;
         }
         if(Boolean(this.KeyMask & KEY_RIGHT) && !(this.KeyMask & KEY_LEFT))
         {
            this.m_CarList[this.m_PlayerID].TurnRight();
            this.m_StartFlag = true;
         }
         if(!(this.KeyMask & (KEY_UP | KEY_DOWN)))
         {
            this.m_CarList[this.m_PlayerID].StopAccel();
         }
         if(!(this.KeyMask & (KEY_LEFT | KEY_RIGHT)))
         {
            this.m_CarList[this.m_PlayerID].ReturnCenter();
         }
         if(!(this.KeyMask & (KEY_LEFT | KEY_RIGHT | KEY_UP | KEY_DOWN)))
         {
            this.m_CarList[this.m_PlayerID].Idle();
         }
      }
      
      public function otherHandleInputLoop(param1:Number, param2:int) : void
      {
         if(Boolean(param1 & KEY_UP) && !(param1 & KEY_DOWN))
         {
            this.m_CarList[param2].SpeedUp();
         }
         if(Boolean(param1 & KEY_DOWN) && !(param1 & KEY_UP))
         {
            this.m_CarList[param2].SpeedDown();
         }
         if(Boolean(param1 & KEY_LEFT) && !(param1 & KEY_RIGHT))
         {
            this.m_CarList[param2].TurnLeft();
         }
         if(Boolean(param1 & KEY_RIGHT) && !(param1 & KEY_LEFT))
         {
            this.m_CarList[param2].TurnRight();
         }
         if(!(param1 & (KEY_UP | KEY_DOWN)))
         {
            this.m_CarList[param2].StopAccel();
         }
         if(!(param1 & (KEY_LEFT | KEY_RIGHT)))
         {
            this.m_CarList[param2].ReturnCenter();
         }
         if(!(param1 & (KEY_LEFT | KEY_RIGHT | KEY_UP | KEY_DOWN)))
         {
            this.m_CarList[param2].Idle();
         }
      }
      
      protected function AllTickLoop() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_Object.length)
         {
            this.m_Object[_loc1_].Tick();
            _loc1_++;
         }
         this.m_SpecialEffect.m_ParticleManager.Tick();
      }
      
      protected function CollisionLoop() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:Vector3D = null;
         var _loc8_:REffectData = null;
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_Object.length - 1)
         {
            _loc4_ = _loc3_ + 1;
            while(_loc4_ < this.m_Object.length)
            {
               if(!RockRacer.GameCommon.g_SingleGame && this.m_Object[_loc2_].m_AI != null && this.m_Object[_loc4_].m_AI != null)
               {
                  if(this.m_Object[_loc2_] is RPlayerCar && Boolean(this.m_Object[_loc4_].m_AI.m_Hit))
                  {
                     if(this.m_Object[_loc2_] == this.m_Object[_loc4_].m_AI.m_DestObject)
                     {
                        this.m_Object[_loc4_].currState.loc.x = this.m_Object[_loc2_].currState.loc.x;
                        this.m_Object[_loc4_].currState.loc.y = this.m_Object[_loc2_].currState.loc.y;
                        this.m_Object[_loc4_].currState.loc.z = this.m_Object[_loc2_].currState.loc.z;
                        this.m_Object[_loc2_].CollisionProc(this.m_Object[_loc4_]);
                        this.m_Object[_loc4_].CollisionProc(this.m_Object[_loc2_]);
                        this.DeleteObject(this.m_Object[_loc4_]);
                        _loc1_ = true;
                     }
                  }
               }
               if(_loc1_)
               {
                  break;
               }
               _loc4_++;
            }
            if(_loc1_)
            {
               break;
            }
            _loc2_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this.m_Object.length - 1)
         {
            _loc5_ = _loc3_ + 1;
            while(_loc5_ < this.m_Object.length)
            {
               if(!this.IsAutoDriveGhostPair(this.m_Object[_loc3_],this.m_Object[_loc5_]) && Boolean(this.m_Object[_loc3_].CollisionTest(this.m_Object[_loc5_])) && Boolean(this.m_Object[_loc5_].CollisionTest(this.m_Object[_loc3_])))
               {
                  if(!(RockRacer.GameCommon.g_SingleGame == false && !(this.m_Object[_loc3_] is RPlayerCar) && !(this.m_Object[_loc5_] is RPlayerCar)))
                  {
                     if(RockRacer.GameCommon.g_SingleGame == false)
                     {
                        if(!(this.m_Object[_loc3_] is RPlayerCar) && !(this.m_Object[_loc3_] is RAICar))
                        {
                           Client.getItem([_loc3_]);
                        }
                        if(!(this.m_Object[_loc5_] is RPlayerCar) && !(this.m_Object[_loc5_] is RAICar))
                        {
                           Client.getItem([_loc5_]);
                        }
                     }
                     this.m_Object[_loc3_].CollisionProc(this.m_Object[_loc5_]);
                     this.m_Object[_loc5_].CollisionProc(this.m_Object[_loc3_]);
                  }
               }
               _loc5_++;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this.m_Object.length)
         {
            if(this.m_Object[_loc3_].m_ObjType == RObjectType.AICAR || this.m_Object[_loc3_].m_ObjType == RObjectType.PLAYERCAR)
            {
               _loc7_ = this.m_CollisionWall.CollisionProc(this.m_Object[_loc3_],0);
               if(_loc7_ != null)
               {
                  this.m_Object[_loc3_].SetAction(RActionState.COLLISION_WALL);
                  _loc8_ = new REffectData(RSpecialEffectType.OBJECT_COLLISION_EFFECT,this.m_Object[_loc3_].currState,null);
                  _loc8_.m_car = this.m_Object[_loc3_];
                  _loc8_.collpos = _loc7_;
                  this.m_SpecialEffect.EffectProcess(_loc8_);
               }
            }
            else
            {
               _loc7_ = this.m_CollisionWall.CollisionProc(this.m_Object[_loc3_],1);
            }
            _loc3_++;
         }
      }
      
      protected function UpdateSceneLoop() : void
      {
         this.m_Terrain.UpdateScene(0,this.m_CarList[this.m_PlayerID].currState.loc.x,this.m_CarList[this.m_PlayerID].currState.loc.z);
         this.m_Boundary.UpdateScene(0,this.m_CarList[this.m_PlayerID].currState.loc.x,this.m_CarList[this.m_PlayerID].currState.loc.z);
         if(this.m_Sea != null)
         {
            this.m_Sea.UpdateScene(0,this.m_CarList[this.m_PlayerID].currState.loc.x,this.m_CarList[this.m_PlayerID].currState.loc.z);
         }
         this.m_Sky.UVAnimation();
      }
      
      protected function CameraControlLoop() : void
      {
         var _loc1_:RCar = null;
         var _loc2_:Vector3D = null;
         var _loc3_:Vector3D = null;
         var _loc4_:Number = NaN;
         _loc1_ = this.m_CarList[this.m_PlayerID];
         switch(this.m_CameraMode)
         {
            case READY:
               _loc2_ = new Vector3D(_loc1_.m_renderObject.transform.n13,_loc1_.m_renderObject.transform.n23,_loc1_.m_renderObject.transform.n33);
               _loc2_.y = 0;
               _loc2_.scaleBy(-(200 + _loc1_.currState.vel.length * 3));
               _loc2_ = _loc2_.add(_loc1_.currState.loc);
               this.m_View.camera.x = _loc2_.x;
               this.m_View.camera.y = _loc1_.currState.loc.y + 200;
               this.m_View.camera.z = _loc2_.z;
               _loc1_.m_renderObject.y += 150;
               this.m_View.camera.lookAt(_loc1_.m_renderObject);
               _loc1_.m_renderObject.y -= 150;
               break;
            case FALLING:
               _loc2_ = new Vector3D(_loc1_.m_renderObject.transform.n13,_loc1_.m_renderObject.transform.n23,_loc1_.m_renderObject.transform.n33);
               _loc2_.y = 0;
               _loc2_.scaleBy(-(500 + _loc1_.currState.vel.length * 3));
               _loc2_ = _loc2_.add(_loc1_.currState.loc);
               this.m_View.camera.x = _loc2_.x;
               this.m_View.camera.y = _loc1_.currState.loc.y + 200;
               this.m_View.camera.z = _loc2_.z;
               _loc1_.m_renderObject.y += 150;
               this.m_View.camera.lookAt(_loc1_.m_renderObject);
               _loc1_.m_renderObject.y -= 150;
               break;
            case GO:
               _loc3_ = new Vector3D();
               _loc3_.x = this.m_View.camera.x;
               _loc3_.y = _loc1_.currState.loc.y;
               _loc3_.z = this.m_View.camera.z;
               _loc3_ = _loc1_.currState.loc.subtract(_loc3_);
               _loc4_ = _loc3_.length;
               if(_loc4_ < (150 + _loc1_.currState.vel.length) * this.m_CameraRate)
               {
                  _loc1_.m_renderObject.y += 150;
                  this.m_View.camera.lookAt(_loc1_.m_renderObject);
                  _loc1_.m_renderObject.y -= 150;
                  return;
               }
               if(_loc4_ != 0)
               {
                  _loc3_.scaleBy((_loc4_ - (150 + _loc1_.currState.vel.length) * this.m_CameraRate) / _loc4_);
               }
               this.m_View.camera.x += _loc3_.x;
               this.m_View.camera.z += _loc3_.z;
               this.m_View.camera.y = _loc1_.preState.loc.y + 200;
               _loc1_.m_renderObject.y += 150;
               this.m_View.camera.lookAt(_loc1_.m_renderObject);
               _loc1_.m_renderObject.y -= 150;
         }
      }
      
      protected function ParticleRefreshLoop() : void
      {
         this.m_SpecialEffect.m_ParticleManager.removeAllParticles();
      }
      
      public function VisibleLoop() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc1_ = int(this.m_CarList[this.m_PlayerID].currState.loc.x);
         _loc2_ = int(this.m_CarList[this.m_PlayerID].currState.loc.z);
         if(_loc1_ < this.m_Terrain.m_MinLoc.x || _loc1_ > this.m_Terrain.m_MaxLoc.x || _loc2_ < this.m_Terrain.m_MinLoc.z || _loc2_ > this.m_Terrain.m_MaxLoc.z)
         {
            return;
         }
         _loc3_ = Math.abs(_loc1_ - this.m_Terrain.m_resMap.m_GridMin.x) / this.m_Terrain.m_resMap.m_GrideSpaceX;
         _loc4_ = Math.abs(_loc2_ - this.m_Terrain.m_resMap.m_GridMin.z) / this.m_Terrain.m_resMap.m_GrideSpaceZ;
         this.cellID = _loc4_ * this.m_Terrain.m_resMap.m_GrideDivision + _loc3_;
         var _loc5_:int = 0;
         while(_loc5_ < this.m_Object.length)
         {
            this.m_Object[_loc5_].SetVisibleState(this.m_Terrain.m_resMap,this.cellID);
            _loc5_++;
         }
      }
      
      public function RefreshGame() : void
      {
         this.HandleInputLoop();
         this.AllTickLoop();
         this.CollisionLoop();
      }
      
      public function Loop(param1:Event) : void
      {
         var rs2:RenderStatistics;
         var rs3:Number;
         var curTime:int;
         var tTime:int;
         var totalTime:int;
         var i:int = 0;
         var e:Event = param1;
         if(getTimer() - m_sendTime >= 500 && this.m_RenderMode == RENDER_PLAYING)
         {
            if(this.m_CarList[this.m_PlayerID].currState.actionState != RActionState.AUTOPILOT_PLAY && this.m_CarList[this.m_PlayerID].isCarStop == false && this.m_CarList[this.m_PlayerID].isCarOut == false)
            {
               Client.sendState([MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.z),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.z),this.m_CarList[this.m_PlayerID].currState.actionState,this.m_CarList[this.m_PlayerID].currState.animState,this.KeyMask,this.m_CarList[this.m_PlayerID].m_msgCount++,MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.z),this.m_CarList[this.m_PlayerID].m_bBA,this.m_CarList[this.m_PlayerID].m_DestPath]);
               m_sendTime = getTimer();
            }
         }
         try
         {
            this.RenderObjectLoop();
            while(getTimer() - this.preticktime > this.TIMEPERFRAME)
            {
               if(!this.pause)
               {
                  this.RefreshGame();
               }
               this.preticktime += this.TIMEPERFRAME;
            }
            this.CameraControlLoop();
            this.UpdateSceneLoop();
            this.VisibleLoop();
            if(!this.pause)
            {
               this.decidePosInMap();
            }
            this.LODLoop();
         }
         catch(err:Error)
         {
            trace("RGameClient->" + err);
         }
         rs2 = this.m_View.renderer.renderScene(this.m_View.scene,this.m_View.camera,this.m_View.viewport);
         rs3 = rs2.triangles;
         curTime = getTimer();
         tTime = curTime - RLoadingCourse.gameStartTime - RLoadingCourse.gameReadyTime;
         totalTime = 5000;
         this.m_ReadyCounter.gotoAndStop(2 + int(65 * tTime / totalTime));
         if(this.m_RenderMode == RENDER_READY && this.m_ReadyCounter.currentFrame >= 65)
         {
            i = 0;
            while(i < this.m_CarList.length)
            {
               this.m_CarList[i].m_LapTimes.splice(0);
               this.m_CarList[i].m_LapTimes.push(getTimer());
               this.m_CarList[i].hit = true;
               if(this.m_CarList[i].m_ObjType == RObjectType.AICAR)
               {
                  this.m_CarList[i].SetAIState(RAI.AI_FOLLOWPATH);
               }
               i++;
            }
            this.m_RenderMode = RENDER_PLAYING;
            if(!RockRacer.GameCommon.g_SingleGame && this.m_CarList[this.m_PlayerID].isCarStop == false && this.m_CarList[this.m_PlayerID].isCarOut == false)
            {
               Client.sendState([MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.loc.z),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.pose.z),this.m_CarList[this.m_PlayerID].currState.actionState,this.m_CarList[this.m_PlayerID].currState.animState,this.KeyMask,this.m_CarList[this.m_PlayerID].m_msgCount++,MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.x),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.y),MsgNum(this.m_CarList[this.m_PlayerID].currState.vel.z),this.m_CarList[this.m_PlayerID].m_bBA,this.m_CarList[this.m_PlayerID].m_DestPath]);
               m_sendTime = getTimer();
            }
            setTimeout(this.rmvObj,3000,this.m_ReadyCounter);
            this.m_TimerView.startTime();
            this.m_CameraMode = GO;
            this.m_LapView.setPlayerLab(1,true);
         }
         else if(this.m_RenderMode != RENDER_PLAYING)
         {
            if(this.m_RenderMode == RENDER_SCORE)
            {
               this.m_TimerView.stopTime();
               this.timeoutTime = -1;
               this.m_scMask.play();
               ++this.m_FadeEndScreen;
               if(this.m_scMask.currentFrame > 10)
               {
                  this.m_scMask.stop();
                  this.m_RenderMode = RENDER_END;
                  RockRacer.GameCommon.createPage(RCongrate);
                  this.DestroyScene();
                  if(!RockRacer.GameCommon.g_SingleGame)
                  {
                     removeEventListener(Event.ENTER_FRAME,this.Loop);
                  }
               }
            }
            else if(this.m_RenderMode == RENDER_END)
            {
               this.m_CarList[this.m_PlayerID].StopEngineSound();
            }
         }
         if(this.timeoutTime > 0 && this.timeoutTime < this.m_TimerView.time)
         {
            this.timeoutTime = -1;
            this.timeoutFunction(this.timeoutArg);
         }
      }
      
      private function rmvObj(param1:MovieClip) : void
      {
         removeChild(param1);
         this.m_isQuitEnable = true;
      }
      
      protected function LODLoop() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_CarList.length)
         {
            if(this.m_CarList[_loc1_].m_isDelete == false)
            {
               if(this.m_CarList[_loc1_].currState.actionState != RActionState.AUTOPILOT_PLAY)
               {
                  _loc2_ = Vector3D.distance(this.m_CarList[_loc1_].currState.loc,this.m_CarList[this.m_PlayerID].currState.loc);
                  if(this.MiddleDist > _loc2_)
                  {
                     this.m_CarList[_loc1_].VisibleHighModel();
                  }
                  else if(this.LowDist > _loc2_)
                  {
                     this.m_CarList[_loc1_].VisibleMiddleModel();
                  }
                  else
                  {
                     this.m_CarList[_loc1_].VisibleLowModel();
                  }
               }
            }
            _loc1_++;
         }
      }
      
      private function decidePosInMap() : void
      {
         var _loc1_:Number = Math.abs(this.m_Terrain.m_gridMinLoc.x);
         var _loc2_:Number = Math.abs(this.m_Terrain.m_gridMinLoc.z);
         var _loc3_:int = 0;
         while(_loc3_ < this.m_CarList.length)
         {
            RMinicar(this.miniCars[_loc3_]).x = (this.m_CarList[_loc3_].currState.loc.x + _loc1_) / 2809;
            RMinicar(this.miniCars[_loc3_]).y = this.m_minMapHeight - (this.m_CarList[_loc3_].currState.loc.z + _loc2_) / 2809 + 50;
            if(this.m_CarList[_loc3_].currState.actionState == RActionState.BEATEN)
            {
               RMinicar(this.miniCars[_loc3_]).character.play();
            }
            else if(_loc3_ == this.m_PlayerID)
            {
               RMinicar(this.miniCars[_loc3_]).character.gotoAndStop(6);
            }
            else
            {
               RMinicar(this.miniCars[_loc3_]).character.gotoAndStop(1);
            }
            _loc3_++;
         }
      }
      
      public function Snap(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 < param2)
         {
            param1 = param2;
         }
         if(param1 > param3)
         {
            param1 = param3;
         }
         return param1;
      }
      
      public function UpdateUI() : void
      {
         var _loc1_:String = null;
         if(this.m_CarList.length > this.m_PlayerID)
         {
            _loc1_ = "$GAME_RANK_INGAME" + String(this.m_CarList[this.m_PlayerID].m_Rank);
            this.m_RankView.txtText.htmlText = RockRacer.GameCommon.GetTextFunc(_loc1_);
         }
      }
      
      protected function EscapeFunc(param1:Event) : void
      {
         if(this.m_isQuitEnable == true)
         {
            if(RockRacer.GameCommon.g_SingleGame)
            {
               if(this.m_RenderMode != RENDER_READY)
               {
                  this.QuitWindowFunc();
               }
            }
            else
            {
               this.QuitFunc(new Event("quit"));
               removeEventListener(Event.ENTER_FRAME,this.Loop);
               Client.gameOver([]);
               Client.funcs = {};
            }
         }
      }
      
      public function QuitWindowFunc(param1:int = 1) : void
      {
         var flag:int = param1;
         if(this.m_RenderMode == RGameClient.RENDER_SCORE || this.m_RenderMode == RGameClient.RENDER_END)
         {
            return;
         }
         if(this.pause)
         {
            return;
         }
         this.pause = true;
         if(!this.m_QuitWindowEnable)
         {
            RockRacer.GameCommon.SetBackSoundVolume(0);
            this.StopEngineSound();
            with(this.m_QuitWindow)
            {
               
               x = 0;
               y = 0;
            }
            this.m_QuitWindow.gotoAndStop(flag);
            addChild(this.m_QuitWindow);
            this.m_QuitWindow.BTT_Cancel.addEventListener(MouseEvent.CLICK,this.CancelFunc);
            this.m_QuitWindow.BTT_Quit.addEventListener(MouseEvent.CLICK,this.QuitFunc);
            this.m_QuitWindow.BTT_Restart.addEventListener(MouseEvent.CLICK,this.RestartFunc);
            this.m_QuitWindowEnable = true;
         }
      }
      
      protected function QuitFunc(param1:Event) : void
      {
         this.timeoutTime = -1;
         this.m_TutorialSpace.splice(0);
         RockRacer.GameCommon.EmptyScores();
         this.m_LapView.setPlayerLab(1);
         this.CancelFunc(null);
         this.DestroyScene();
         this.m_RenderMode = RENDER_ABORT;
         this.m_ReadyCounter.gotoAndStop(1);
      }
      
      protected function RestartFunc(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc5_:Vector3D = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         RockRacer.GameCommon.EmptyScores();
         _loc2_ = 0;
         while(_loc2_ < this.m_CarList.length)
         {
            _loc5_ = new Vector3D();
            _loc5_ = this.m_Terrain.m_path.m_lPath[1].subtract(this.m_Terrain.m_path.m_lPath[0]);
            _loc6_ = Math.atan(_loc5_.x / _loc5_.z);
            _loc7_ = Math.cos(_loc6_);
            _loc8_ = Math.sin(_loc6_);
            _loc6_ = _loc6_ * 180 / Math.PI;
            if(_loc5_.z < 0)
            {
               _loc6_ += 180;
            }
            if(_loc6_ < 0)
            {
               _loc6_ += 360;
               _loc7_ = -_loc7_;
               _loc8_ = -_loc8_;
            }
            this.m_CarList[_loc2_].currState.pose.x = 0;
            this.m_CarList[_loc2_].currState.pose.y = _loc6_;
            this.m_CarList[_loc2_].currState.pose.z = 0;
            this.m_CarList[_loc2_].m_BonusID = RObjectType.NONE_BONUS;
            this.m_CarList[_loc2_].m_Lap = 0;
            this.m_CarList[_loc2_].m_LapTimes.splice(0);
            this.m_CarList[_loc2_].m_DestPath = 1;
            this.m_CarList[_loc2_].m_passPath = false;
            this.m_CarList[_loc2_].isCarStop = false;
            this.m_CarList[_loc2_].SetLoc(this.m_Terrain.m_path.m_lPath[0].x + (_loc2_ - 2) * 150 * (_loc8_ + _loc7_),this.m_Terrain.GetHeightInfo(this.m_Terrain.m_path.m_lPath[0].x,this.m_Terrain.m_path.m_lPath[0].z),this.m_Terrain.m_path.m_lPath[0].z + _loc2_ * 150 * (_loc7_ - _loc8_));
            this.m_CarList[_loc2_].ReleaseAction();
            this.m_CarList[_loc2_].StopAccel();
            this.m_CarList[_loc2_].m_BonusAcc = 0;
            this.m_CarList[_loc2_].m_BoosterAcc = 0;
            this.m_CarList[_loc2_].m_AIAcc = 0;
            this.m_CarList[_loc2_].currState.vel.scaleBy(0);
            this.m_CarList[_loc2_].currState.actionState = RActionState.NONE;
            this.m_CarList[_loc2_].currState.animState = RPlayerAnimState.CarIsIdle;
            this.m_CarList[_loc2_].SetAIState(RAI.AI_IDLE);
            this.m_CarList[_loc2_].m_bGuideDir = false;
            this.m_CarList[_loc2_].m_bGuideWrong = false;
            this.m_CarList[_loc2_].m_bInfo = false;
            _loc2_++;
         }
         var _loc3_:int = this.m_CarList[this.m_CarList.length - 1].m_ObjID + 1;
         var _loc4_:int = int(this.m_Object.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            switch(this.m_Object[_loc2_].m_ObjType)
            {
               case RObjectType.TREE1:
               case RObjectType.TREE2:
               case RObjectType.TREE3:
               case RObjectType.HOUSE1:
                  this.m_Object[_loc2_].hit = true;
            }
            _loc2_++;
         }
         _loc2_ = _loc3_;
         while(_loc2_ < _loc4_)
         {
            this.m_Object[_loc2_].DeleteObject();
            _loc2_++;
         }
         this.m_CameraMode = READY;
         this.oil = this.maxOil;
         this.ResetAutoDrive();
         this.m_scMask.gotoAndStop(0);
         this.m_mudman.visible = false;
         this.m_mudman.gotoAndStop(0);
         this.m_lightman.visible = false;
         this.m_lightman.gotoAndStop(0);
         this.Squirrel.visible = false;
         this.Squirrel.gotoAndStop(0);
         this.weaponView.stopSelecting();
         this.m_TimerView.stopTime();
         this.m_TimerView.time = 0;
         this.m_LapView.setPlayerLab(1);
         addChild(this.m_ReadyCounter);
         this.m_ReadyCounter.x = m_ViewportWidth / 2;
         this.m_ReadyCounter.y = m_ViewportHeight / 2;
         setTimeout(this.m_ReadyCounter.gotoAndPlay,40,2);
         this.m_RenderMode = RENDER_READY;
         this.m_ReadyCounter.gotoAndStop(1);
         this.mc_GuideWnd.gotoAndStop(1);
         this.mc_InfoWnd.initCounter();
         this.mc_InfoWnd.gotoAndStop(1);
         this.timeoutTime = -1;
         this.CancelFunc(null);
         RLoadingCourse.gameStartTime = getTimer() - RLoadingCourse.gameReadyTime;
         this.m_isQuitEnable = false;
      }
      
      protected function CancelFunc(param1:Event) : void
      {
         if(RockRacer.GameCommon.m_SoundOnOff)
         {
            RockRacer.GameCommon.SetBackSoundVolume(1);
         }
         if(RockRacer.GameCommon.g_SingleGame)
         {
            removeChild(this.m_QuitWindow);
            this.m_QuitWindowEnable = false;
            this.m_QuitWindow.BTT_Cancel.removeEventListener(MouseEvent.CLICK,this.CancelFunc);
            this.m_QuitWindow.BTT_Quit.removeEventListener(MouseEvent.CLICK,this.QuitFunc);
            this.m_QuitWindow.BTT_Restart.removeEventListener(MouseEvent.CLICK,this.RestartFunc);
            this.pause = false;
         }
      }
      
      protected function StopEngineSound() : void
      {
         if(this.m_CarList.length > this.m_PlayerID)
         {
            this.m_CarList[this.m_PlayerID].StopEngineSound();
         }
      }
      
      public function setTimeoutFunction(param1:Function, param2:int, param3:Boolean) : void
      {
         this.timeoutTime = this.m_TimerView.time + param2;
         this.timeoutFunction = param1;
         this.timeoutArg = param3;
      }
      
      private function RecordCheatKey(param1:Number) : void
      {
         var _loc2_:int = getTimer();
         if(_loc2_ - this.m_CheatLastTime > 2000)
         {
            this.m_CheatBuf.splice(0);
         }
         this.m_CheatLastTime = _loc2_;
         this.m_CheatBuf.push(param1);
         while(this.m_CheatBuf.length > 6)
         {
            this.m_CheatBuf.shift();
         }
         if(this.m_CheatBuf.length == 6 && this.m_CheatBuf[0] == KEY_UP && this.m_CheatBuf[1] == KEY_DOWN && this.m_CheatBuf[2] == KEY_UP && this.m_CheatBuf[3] == KEY_UP && this.m_CheatBuf[4] == KEY_DOWN && this.m_CheatBuf[5] == KEY_DOWN)
         {
            this.m_CheatBuf.splice(0);
            if(this.m_RenderMode == RENDER_PLAYING && !this.pause && this.m_CarList.length > this.m_PlayerID)
            {
               this.ToggleAutoDrive();
            }
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
            this.m_AutoHold = 0;
            this.ShowCheatMessage("Autodrive + unlimited fuel enabled");
         }
         else
         {
            _loc1_.StopAccel();
            _loc1_.ReturnCenter();
            this.ShowCheatMessage("Autodrive + unlimited fuel disabled");
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
         _loc18_ = AUTO_EXTRA[this.m_AutoIdx] == 1 && AUTO_EXTRA[(this.m_AutoIdx + 1) % _loc2_] == 1 && AUTO_EXTRA[(this.m_AutoIdx + 2) % _loc2_] == 1;
         _loc19_ = this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,this.m_AutoShift,0,1700,240);
         _loc20_ = this.m_AutoBlockDist;
         _loc21_ = this.m_AutoBlockSpeed;
         if(this.m_AutoShiftTarget == 0)
         {
            if(_loc19_ && _loc21_ < _loc10_ + 15 && _loc21_ >= 30 && _loc18_ && !this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,460,-500,1500,260))
            {
               this.m_AutoShiftTarget = 460;
               this.m_AutoHold = 36;
            }
         }
         else if(!_loc18_)
         {
            this.m_AutoShiftTarget = 0;
         }
         else if(this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,0,-450,900,260))
         {
            this.m_AutoHold = 24;
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
            this.m_AutoShift = Math.min(this.m_AutoShiftTarget,this.m_AutoShift + 35);
         }
         else if(this.m_AutoShift > this.m_AutoShiftTarget)
         {
            this.m_AutoShift = Math.max(this.m_AutoShiftTarget,this.m_AutoShift - 35);
         }
         _loc22_ = this.m_AutoTanZ * this.m_AutoShift;
         _loc23_ = -this.m_AutoTanX * this.m_AutoShift;
         _loc11_ = Math.max(450,Math.min(1000,_loc10_ * 3));
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
         this.AutoPointAhead(this.m_AutoIdx,_loc6_,2000);
         _loc16_ = Math.abs(this.AutoSignedAngle(_loc12_,_loc13_,this.m_AutoPX + _loc22_ - _loc3_,this.m_AutoPZ + _loc23_ - _loc4_));
         _loc17_ = Math.max(-40,Math.min(40,_loc15_ * 0.4));
         _loc1_.currState.pose.y += _loc17_;
         if(_loc10_ > 150 && (_loc16_ > 40 || Math.abs(_loc15_) > 28))
         {
            _loc1_.SpeedDown();
         }
         else if(_loc10_ > 110 && (_loc16_ > 22 || Math.abs(_loc15_) > 12))
         {
            _loc1_.StopAccel();
         }
         else
         {
            _loc1_.SpeedUp();
         }
         if(_loc19_ && _loc21_ >= 30 && _loc21_ < _loc10_ && this.m_AutoShiftTarget == this.m_AutoShift)
         {
            if(_loc20_ < 450 && _loc10_ > 60)
            {
               _loc1_.SpeedDown();
            }
            else if(_loc20_ < 900)
            {
               _loc1_.StopAccel();
            }
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

      private function ResetAutoDrive() : void
      {
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
      {
         this.oil += 300;
         if(this.oil > this.maxOil)
         {
            this.oil = this.maxOil;
         }
      }
   }
}

