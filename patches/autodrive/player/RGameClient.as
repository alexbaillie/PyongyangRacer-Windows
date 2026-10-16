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

      private var m_FHeld:Boolean = false;

      private var m_AutoPending:Boolean = false;

      private var m_CheatMsg:Sprite = null;

      private var m_CheatMsgText:TextField = null;

      private var m_CheatMsgTimer:uint = 0;

      public static const AUTO_LINE:Array = [61947.6,-81635.4,51582.1,-137410,49263.2,-148265,48988.4,-149433,48746.6,-150299,48387.3,-151444,46991.4,-155405,44910,-161032,43898.5,-163536,43544.4,-164363,41326.3,-169286,40926.5,-170092,38729.8,-174360,38447,-174889,36662.5,-178015,34162.6,-182113,33674.8,-182869,30981.8,-186842,30466.1,-187580,27225.1,-191899,26473.7,-192834,23202.5,-196746,20790.3,-199418,18716.5,-201586,17020.5,-203284,16376.4,-203913,14623,-205552,13948.4,-206147,10065.7,-209454,9364.1,-210017,7465.4,-211485,3336.6,-214478,2601.1,-214997,-921.4,-217284,-1432.1,-217598,-4269.1,-219284,-5049.6,-219732,-9842.2,-222219,-10649.9,-222616,-12829.5,-223620,-16423.5,-225134,-18658.2,-226009,-21484.3,-227015,-22337.2,-227302,-24909.3,-228123,-27214.8,-228790,-28085.7,-229016,-30715.5,-229627,-33063.9,-230122,-33653.3,-230233,-39279.3,-231148,-41659.4,-231455,-42554.3,-231547,-47643,-231883,-48541.8,-231924,-51241.4,-231962,-54541.2,-231930,-57239.6,-231838,-58138,-231789,-62922.6,-231405,-64115.8,-231283,-66788.1,-230899,-69147.6,-230461,-70028.3,-230276,-72655.6,-229654,-75260.8,-228946,-76120.8,-228681,-77832.9,-228126,-78684.4,-227835,-79530.1,-227527,-81491.1,-226776,-83982.1,-225734,-86705.2,-224476,-87511.9,-224077,-89372,-223103,-90160.2,-222669,-91979.2,-221620,-94772.8,-219863,-96516.7,-218693,-98953.3,-216943,-99671.6,-216402,-102252,-214345,-104314,-212601,-106307,-210780,-106744,-210370,-108682,-208489,-110139,-206977,-110748,-206314,-112723,-204057,-114423,-201960,-114792,-201487,-117861,-197413,-118380,-196678,-118713,-196180,-119845,-194411,-121361,-191823,-122768,-189173,-123943,-186742,-125298,-183734,-126209,-181514,-126632,-180391,-127610,-177555,-127890,-176700,-128333,-175267,-129133,-172375,-129355,-171504,-129950,-168870,-130399,-166512,-130589,-165328,-130920,-162951,-131198,-160567,-131278,-159671,-131465,-156376,-131493,-155477,-131513,-153977,-131466,-151578,-131256,-148285,-131151,-147090,-130913,-145003,-130616,-142925,-130410,-141743,-129849,-139102,-129631,-138230,-129149,-136495,-128787,-135352,-127981,-133091,-126866,-130306,-125668,-127556,-123738,-123491,-123193,-122423,-122345,-120835,-121907,-120049,-121450,-119273,-121133,-118764,-115595,-110198,-114921,-109207,-98803.8,-87545,-98239.6,-86844.1,-70070.6,-52913,-62478.8,-43619.7,-58984.7,-39116.3,-58624.1,-38636.9,-53915,-32046.5,-51877.7,-29078.5,-50231.8,-26570.3,-48330.9,-23513.3,-46702.1,-20643.5,-45444.4,-18254.4,-44391.7,-16097.7,-43902.2,-15002.9,-43128.6,-13050.9,-42737.4,-11917.4,-42381.9,-10771.4,-42071.1,-9614.2,-41816.3,-8443,-41613.6,-7261.3,-41471,-6072,-41404,-5176.1,-41369.4,-4278.5,-41365.6,-3380.5,-41382.8,-2782.2,-41435.6,-1890.2,-41517.2,-1003.2,-41597.9,-415.1,-41698.7,170.6,-41876.4,1045.8,-42018.4,1627,-42257.5,2493.2,-42526.2,3350.4,-42826.5,4197.8,-43154.3,5035.5,-43388.9,5586.7,-43766.3,6402.2,-44172.7,7204.2,-44460.4,7729.8,-44761.2,8247.5,-45236,9009.6,-45736.6,9756,-46084.9,10244.3,-46628.5,10960.4,-47194.2,11659.3,-48570.5,13244.7,-49186.7,13899.4,-49609.7,14324.3,-50690.5,15364.2,-51132.2,15769.9,-51809.8,16361.7,-52505.5,16930.9,-53462.9,17648,-54454.4,18317.2,-55219.5,18789,-55994.7,19246,-57048.1,19819.3,-84905.6,33869.3,-103670,43298.4,-104197,43578.8,-104973,44022.1,-105480,44331.8,-106725,45127.8,-107268,45355.8,-108374,45782.9,-109196,46134.3,-110270,46650.6,-111054,47073,-111817,47523,-112061,47684.7,-112269,47882.3,-112442,48107.4,-112567,48360.3,-112649,48629.9,-112675,48911,-112669,49194.1,-112602,49474.7,-112270,50293.3,-111907,51105.4,-111513,51910.3,-110688,53510,-86299.5,101352,-66054.9,141205,-65478.9,142250,-64859.1,143264,-63941,144432,-63406.9,145150,-62987.6,145935,-62724.8,146465,-62603.4,146735,-62499.4,147012,-62254.4,147867,-61959,149014,-61799.4,149582,-61689.7,149854,-61547.1,150111,-61050.6,150845,-60359.4,151812,-59863.4,152556,-59395.3,153317,-58513.8,154876,-58047.7,155644,-52877.1,163733,-52204.9,164726,-45162.8,174443,-44625.9,175165,-43158.4,177064,-37841.1,183567,-33971,188152,-33575.7,188603,-31760.6,190602,-28436.2,194064,-26390.7,196258,-25753.3,196893,-22928.5,199582,-19359.6,202792,-16280.1,205648,-14025.3,207626,-9636.5,211263,-5136.8,214762,-4413.3,215297,-1464.1,217361,2524.8,220031,7356.5,223055,10223,224690,12601.3,225968,13404.8,226373,15572.1,227403,18598.7,228718,19433,229055,25028.1,231222,26725.3,231820,27583.9,232087,28450.7,232326,29613.5,232623,30489.6,232828,32547.9,233244,33137.9,233352,33729.9,233448,36402.8,233829,36998.8,233896,38493.2,234024,39690.9,234090,41790.1,234140,42989.3,234118,44188.4,234071,45086.2,234016,45981.7,233932,47770,233726,48364.4,233647,49251.9,233501,50431,233278,51602.2,233021,52472.1,232794,53337.5,232546,54481.5,232187,55047.2,231988,56170.1,231566,57279.3,231110,57826.1,230864,59179,230217,60247.7,229673,61290.9,229082,62318.5,228462,62823.8,228140,63321.5,227806,64054.2,227283,65004.5,226554,65692.9,225977,66140,225578,67003.3,224748,67823.8,223876,68601.1,222966,69331.9,222018,69678.5,221530,70173.4,220781,70788.3,219753,71351.7,218695,71484.1,218426,71973.9,217331,72421.7,216220,72816.7,215088,73084,214229,73247.7,213652,73533.1,212488,73777,211313,73885.3,210724,74022.4,209835,74175.7,208644,74300.1,207452,74339.2,206853,74436.9,204756,74464.4,203856,74472.1,201756,74443.1,200557,74224.3,196363,74157.1,195466,74095.2,194869,73776.2,192188,73428.5,189814,72263.8,182708,65384,145540,65232.5,144653,64887,142278,64778.6,141384,64163.5,135718,63868.5,132732,63823.1,132134,63554.4,127642,63507.7,126443,63413.6,120744,63417.8,120144,63478.5,117745,63803.8,111754,63881.4,110858,64346.4,106382,64413.7,105786,64538.6,104895,65365,99862.3,65769.6,97801.8,67221.8,91363.6,67430,90488.1,68030.6,88164.5,68847.1,85277.8,69020.5,84703.7,69308,83851.4,70030.3,81879.5,72049.1,76871.2,72403,76044.2,72656.1,75500.6,73447.6,73883.9,74003.8,72821,75023.5,70985.4,75487.8,70215,75971.6,69456.1,76643.7,68463.8,77176.4,67740.4,77545.4,67268.3,85366.2,57775.6,85731.3,57301.2,86253.9,56573.4,86743.5,55825.5,87047.7,55314.5,87611.6,54269.4,87730,53997.5,87915.7,53433.3,88083.3,52862.3,88311.9,51997,88876.8,49671,89067,48805,89050.5,47920.2,88974.3,46738.5,88872.6,45851.5,88685.3,44669.9,80575.1,711.8,79799.4,-3409.5,79668.2,-4279.4,79721.2,-4555.4,79881.7,-5093.6,80641.1,-5980.4,81238.9,-6621.1,81455.9,-6818.1,81921.1,-7175.6,82192.1,-7291.1,83352.1,-7564.2,84233.8,-7734.5,157508,-20631,158388,-20799.6,160114,-21203.1,160982,-21371,161861,-21508.1,163642,-21726,164235,-21818.6,165416,-22029.2,166291,-22210.5,167154,-22420.2,167721,-22576.7,167986,-22692,168216,-22857.4,168426,-23046.9,168593,-23274,168712,-23530.2,168800,-23798.8,168836,-24083.3,168777,-24962,168685,-25844.1,146902,-149338,146792,-149926,146602,-150800,146096,-152796,146038,-153669,145980,-154255,145867,-155138,145722,-156023,145550,-156902,145419,-157480,145196,-158336,145107,-158615,144981,-158873,144808,-159096,144610,-159298,144370,-159445,144114,-159563,143842,-159641,143554,-159660,142674,-159584,142085,-159517,140905,-159339,75019.6,-147734,73855.5,-147508,72735.5,-147250,71598.3,-147096,70442.4,-146890,69865.5,-146765,69007.3,-146551,68725.2,-146470,68464.5,-146349,68237.7,-146179,68032.2,-145985,67879.6,-145749,67756.7,-145496,67673.6,-145225,67646.8,-144939,67689.9,-144353,67749.8,-143765,67823.6,-143176,67959.1,-142291,84837.6,-46568.4,84997.1,-45390,85058.3,-44802.3,85098.8,-44216.5,85070.4,-43930.5,84985.2,-43660.7,84870,-43403,84696.7,-43181.1,84498.2,-42981.8,84270,-42813.9,84006.7,-42696.3,83154.8,-42464.1,81997.1,-42201.2,80228.2,-41880.1,73430.1,-40698.5,72250.1,-40517.6,71368.5,-40416.3,70782.9,-40366.5,70496.4,-40382.9,70223.9,-40453.1,69976.9,-40580.8,69759.6,-40753.4,69577.7,-40965.3,69452.5,-41221.3,69369.9,-41500.7,69168,-42361.1,68991.1,-43233.1,68464.8,-46488.1];

      private var m_AutoIdx:int = 0;

      public var m_AutoTanX:Number = 0;

      public var m_AutoTanZ:Number = 1;

      private var m_AutoT:Number = 0;

      private var m_AutoD:Number = 0;

      private var m_AutoPX:Number = 0;

      private var m_AutoPZ:Number = 0;

      public static const AUTO_EXTRA:Array = [0,0,0,0,0,1,1,1,0,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,0,1,1,0,1,1,0,1,1,1,1,1,1,1,0,0,0,1,0,0,1,1,1,1,0,0,0,1,0,0,0,0,1,1,0,0,1,1,1,1,0,0,1,0,0,0,0,0,0,1,1,0,0,1,0,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,1,0,1,1,0,1,1,0,1,1,1,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,0,0,0,0,1,1,1,0,0,0,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,1,0,1,1,1,1,0,1,0,1,1,0,1,1,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,1,1,1,1,0,1,1,0,1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,1,0,0,0,0,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];

      private var m_AutoShift:Number = 0;

      private var m_AutoShiftTarget:Number = 0;

      private var m_AutoHold:int = 0;

      private var m_AutoBlockDist:Number = 1e9;

      private var m_AutoBlockSpeed:Number = 0;

      public static const AUTO_SPEED:Array = [300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,267,235,198,188,174,174,167,167,161,161,161,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,284,284,284,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,205,205,205,248,248,222,210,210,210,300,300,300,300,300,300,300,300,300,263,230,192,162,162,162,167,167,167,177,177,300,300,300,300,300,300,300,300,300,274,242,219,179,164,157,139,139,139,161,161,161,300,300,300,300,300,300,285,245,222,183,167,157,140,140,140,167,167,167,300,300,300,300,264,220,195,165,157,139,139,139,160,160,160,300,300,300,275,232,195,166,149,149,149,133,133,133,207,300,300,300];

      private var m_AutoCool:int = 0;

      private var m_AutoCardShift:Number = 0;

      private var m_AutoPrevTurn:Number = 0;

      private var m_AutoBlend:Number = 0;

      private var m_AutoBlendInit:Boolean = false;
      
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
         if(param1.keyCode == 70 && !this.m_FHeld)
         {
            this.m_FHeld = true;
            this.TryToggleAutoDrive();
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
         if(param1.keyCode == 70)
         {
            this.m_FHeld = false;
         }
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
         if(this.m_AutoPending && this.m_RenderMode == RENDER_PLAYING && !this.m_AutoDrive && !this.pause)
         {
            this.m_AutoPending = false;
            this.ToggleAutoDrive();
         }
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
      
      private function TryToggleAutoDrive() : void
      {
         if(this.m_RenderMode == RENDER_READY && this.m_CarList.length > this.m_PlayerID)
         {
            this.m_AutoPending = !this.m_AutoPending;
            this.ShowCheatMessage(this.m_AutoPending ? "Autodrive will start with the race" : "Autodrive cancelled",3000);
            return;
         }
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
            this.m_AutoBlend = 0;
            this.m_AutoBlendInit = true;
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
               if(_loc10_ > -300 && _loc10_ < 7500 && Math.abs(_loc11_) < 950 && _loc10_ < _loc6_)
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
         _loc19_ = this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,this.m_AutoShift + this.m_AutoCardShift,0,2200 + _loc10_ * 12,230);
         _loc20_ = this.m_AutoBlockDist;
         _loc21_ = this.m_AutoBlockSpeed;
         if(this.m_AutoShiftTarget == 0)
         {
            if(_loc19_ && _loc21_ < _loc10_ - 15 && _loc18_ && !this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,600,-700,8000,300))
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
         if(_loc24_ < -45 && this.AutoScanCars(_loc3_,_loc4_,this.m_AutoTanX,this.m_AutoTanZ,-330,-900,9000,330))
         {
            _loc24_ = Math.max(_loc24_,-45);
         }
         if(this.m_AutoCardShift < _loc24_)
         {
            this.m_AutoCardShift = Math.min(_loc24_,this.m_AutoCardShift + 20);
         }
         else if(this.m_AutoCardShift > _loc24_)
         {
            this.m_AutoCardShift = Math.max(_loc24_,this.m_AutoCardShift - 20);
         }
         if(this.m_AutoBlendInit)
         {
            this.m_AutoBlendInit = false;
            this.AutoPointAhead(this.m_AutoIdx,_loc6_,0);
            this.m_AutoBlend = (_loc3_ - this.m_AutoPX) * this.m_AutoTanZ - (_loc4_ - this.m_AutoPZ) * this.m_AutoTanX;
            if(this.m_AutoBlend > 500 || this.m_AutoBlend < -500)
            {
               this.m_AutoBlend = 0;
            }
         }
         this.m_AutoBlend *= 0.96;
         _loc22_ = this.m_AutoTanZ * (this.m_AutoShift + this.m_AutoCardShift + this.m_AutoBlend);
         _loc23_ = -this.m_AutoTanX * (this.m_AutoShift + this.m_AutoCardShift + this.m_AutoBlend);
         _loc11_ = Math.max(450,Math.min(1400,_loc10_ * 4.0));
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
         _loc17_ = Math.max(-40,Math.min(40,_loc15_ * 0.3));
         _loc17_ = this.m_AutoPrevTurn + Math.max(-3,Math.min(3,_loc17_ - this.m_AutoPrevTurn));
         this.m_AutoPrevTurn = _loc17_;
         _loc1_.currState.pose.y += _loc17_;
         _loc1_.SpeedUp();
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
         this.m_AutoPending = false;
         this.SetAutoBoost(false);
         this.m_AutoDrive = false;
         this.m_CheatBuf.splice(0);
         this.HideCheatMessage();
      }

      private function ShowCheatMessage(param1:String, param2:int = 5000) : void
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
         this.m_CheatMsgTimer = setTimeout(this.HideCheatMessage,param2);
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

