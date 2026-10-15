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

      public static const AUTO_LINE:Array = [61979,-81740.9,51631.3,-137419,49312.3,-148274,49109.5,-149151,48795,-150308,48437,-151453,47041.2,-155414,44960,-161041,43948.7,-163545,43595,-164372,41377.1,-169296,40977.7,-170102,38498.6,-174899,36714.7,-178026,34214.9,-182123,33727.8,-182880,30693.6,-187346,30162.9,-188073,27279.8,-191911,26528.6,-192846,23257.5,-196759,21049.3,-199211,18773.1,-201600,16865.1,-203510,16433.9,-203928,14681,-205567,14006.9,-206163,10124.9,-209470,9423.6,-210034,7525.4,-211502,2908.9,-214846,2163.3,-215349,-860,-217303,-1369.9,-217620,-4206.9,-219305,-4987,-219753,-5514.7,-220038,-9778.7,-222242,-10857.4,-222768,-13038.9,-223768,-16357.9,-225162,-18592.1,-226038,-21418.1,-227045,-22270.5,-227334,-24842.2,-228156,-27147.4,-228824,-28017.8,-229051,-30647.4,-229664,-32995.7,-230159,-33584.9,-230271,-39210.5,-231188,-41590.4,-231497,-42783.9,-231617,-47573.7,-231929,-48472.4,-231972,-51471.9,-232013,-53871.8,-231992,-54771.5,-231972,-57170.1,-231891,-58068.7,-231844,-63152.2,-231436,-64344.4,-231303,-66719.7,-230961,-69079.4,-230524,-70253.2,-230276,-72879.1,-229649,-75482.1,-228932,-78052.3,-228106,-78619.8,-227912,-79746.9,-227500,-81705.9,-226743,-83919.4,-225816,-86643.8,-224560,-87717.9,-224026,-89312.2,-223190,-90102.1,-222759,-91664.1,-221865,-92178.3,-221556,-94969.5,-219796,-96709,-218619,-99143.5,-216866,-99857.6,-216319,-101737,-214827,-102434,-214257,-104492,-212510,-106262,-210889,-106917,-210272,-108640,-208601,-110099,-207091,-110909,-206206,-112689,-204176,-113072,-203715,-114762,-201609,-117833,-197537,-118356,-196805,-118690,-196307,-119982,-194285,-121196,-192215,-121634,-191429,-122891,-189039,-124062,-186607,-125294,-183871,-126319,-181374,-126734,-180248,-127807,-177127,-128427,-175121,-129299,-171939,-129908,-169308,-130031,-168721,-130422,-166658,-130618,-165474,-130989,-162800,-131234,-160714,-131317,-159819,-131522,-156225,-131564,-154125,-131538,-152326,-131509,-151426,-131296,-148133,-131216,-147237,-130945,-144852,-130644,-142774,-130432,-141594,-129866,-138954,-129643,-138082,-129241,-136637,-128981,-135776,-128791,-135208,-127981,-132948,-126862,-130165,-125659,-127417,-123725,-123354,-123318,-122551,-122329,-120699,-121886,-119915,-121427,-119142,-121108,-118633,-115570,-110068,-115066,-109322,-98953.8,-87657.6,-98394.7,-86952.7,-70034.1,-52790.8,-62632.1,-43729.9,-62258.6,-43260.4,-58417.9,-38266.6,-53368.7,-31181.9,-53030,-30686.7,-50049.3,-26183.9,-49727.8,-25677.4,-48161.4,-23118.8,-46827.7,-20771.4,-45840.7,-18917.8,-45434.8,-18114.7,-44384.5,-15956.8,-43899.9,-14860,-43234.8,-13187.6,-42835.5,-12057,-42392.2,-10624.4,-42088.9,-9465.3,-41838.6,-8293,-41645,-7110.3,-41507.6,-5920.4,-41424.7,-4724.5,-41400.1,-3826.5,-41399.4,-3527.2,-41440.9,-2332.3,-41460.7,-861.6,-41488.9,-575.9,-41774.2,243.7,-41930.5,499.8,-41948.1,788.5,-42190.6,1956.3,-42409.2,2824.9,-42594.4,3394.2,-42896.3,4241,-43113.2,4800.2,-43463.8,5627.7,-43841.2,6443.1,-44108.9,6979.4,-44534.1,7771.7,-44833.3,8290.3,-45154.4,8795.3,-45659.6,9538.3,-46361.4,10511.5,-46905.8,11227.2,-47473.8,11924.2,-48661.1,13276.5,-49071.8,13713.2,-49706.8,14350.1,-50788.7,15389,-51231.4,15793.5,-52369.7,16769.9,-52834.1,17148.5,-53306.3,17516.2,-54051,18016.6,-54557.7,18335.9,-56106.3,19252.7,-57162.5,19821,-85019.9,33870.9,-103784,43299.8,-104833,43870,-106363,44782,-107167,45163.2,-108538,45746.8,-109357,46117.8,-110160,46517.2,-110946,46941.2,-111961,47545.6,-112195,47717.9,-112389,47926.5,-112551,48158.7,-112664,48417.2,-112732,48690.7,-112745,48973.3,-112718,49256.5,-112644,49535.8,-112308,50353.6,-112066,50895,-111677,51701,-110715,53567.6,-86326.3,101410,-65947.6,141531,-65380,142582,-64768.9,143598,-64184.7,144265,-63576.4,144917,-63407.2,145163,-63109.9,145678,-62550.1,146725,-62425.8,146994,-62221.9,147550,-61957,148400,-61714.4,149257,-61540.5,149822,-61438.9,150098,-61308.3,150362,-60830.3,151108,-60165.3,152094,-59691.6,152850,-59245.1,153622,-58529.4,154930,-57909.4,155954,-52900.3,163789,-52227.4,164782,-45184.4,174498,-44646.9,175220,-43178.7,177118,-37861.3,183621,-34184.6,187976,-33594.9,188656,-31780.1,190655,-28454.8,194117,-26409.1,196311,-25771.1,196945,-23166,199430,-19377.7,202844,-16297.4,205699,-14042.3,207677,-9653.5,211314,-5153.4,214813,-4429.3,215347,-1480,217411,2509,220081,7341.1,223104,10207.7,224738,12321.6,225875,13389.7,226421,15557.1,227451,18583.8,228766,19418.1,229103,25013.2,231270,26710.5,231868,27569,232135,28435.9,232374,29598.7,232671,30474.8,232875,32533,233292,33122.9,233401,33715,233497,36387.7,233878,36983.7,233945,38478.2,234073,39675.8,234140,41775,234190,42974.3,234169,44173.3,234122,45071.3,234069,45966.7,233984,47755,233778,48645.9,233654,50416.3,233332,51587.7,233076,52168.7,232929,53323.3,232602,54467.9,232245,55033.9,232047,56156.8,231624,57266.9,231171,57813.9,230925,59166.9,230278,60236.5,229736,61280.4,229146,62308.8,228528,62814.3,228206,63312.2,227872,64045.8,227351,64996.1,226621,65685.3,226045,66132.7,225647,66998.2,224820,67822.4,223952,68602.9,223044,68975.9,222576,69511.9,221855,70179.2,220862,70798.3,219836,71088.6,219312,71500,218513,72107.7,217142,72440.6,216308,72839.5,215178,73109,214319,73273.8,213743,73563.8,212580,73810.3,211405,73921.1,210816,74100.1,209630,74251,208440,74340.5,207545,74399.9,206647,74496.4,204550,74513.2,203950,74520.4,201550,74496.8,200651,74261.5,196157,74156.5,194962,73839.3,192281,73492.7,189906,72331,182800,65397.3,145337,65252.3,144449,64950.9,142370,64839,141478,64191.5,135513,63927.6,132826,63860.8,131928,63592.2,127436,63559.3,126537,63464.9,120838,63466.8,120238,63526.2,117839,63549.4,117239,63869.7,111548,63922,110951,64418,106177,64575.2,104987,65399.5,99954.6,65801.4,97893.6,67458.1,90579,68135.3,87965.3,68957.8,85080.4,69331.1,83940.7,69946.9,82249.4,70266.3,81408.2,72067.5,76958.9,72544.7,75858.6,73461.4,73969.5,73872,73168.9,74883.9,71328.9,75338.8,70552.9,75655.4,70043.5,76141.1,69285.9,76646.2,68542.4,76997,68056.9,77546.2,67345.6,84990.1,58319.2,85552.4,57617.7,85913.2,57140.4,86429,56408.3,86910.3,55655.7,87209.2,55142,87631.2,54357.9,87754.4,54088.3,87856.7,53810.2,87941.5,53525.6,88249.5,52376,88582.3,50916.2,88880.1,49759.5,89074.9,48896,89119.7,48606.6,89077,47426.8,89004.8,46540.6,88895.7,45653.8,88754.1,44767.6,80589.6,514.5,79925.3,-3019.3,79753.6,-4180.6,79742.2,-4466.1,79899.2,-5004.4,80064.2,-5243.3,80253.9,-5465.3,81037.1,-6333.2,81447.2,-6751.8,81891,-7139.9,82156.7,-7270.9,82740,-7402.9,83621.6,-7576.3,165756,-22043.2,166338,-22166.8,167200,-22377.2,167767,-22533.8,168034,-22645.5,168265,-22809.7,168468,-23005.4,168645,-23224.1,168765,-23479.5,168855,-23747.4,168892,-24031.6,168883,-24323.3,168838,-24909.7,168745,-25791.8,146961,-149285,146791,-150166,146592,-151038,146443,-151613,146125,-152742,146086,-153617,146031,-154203,145923,-155085,145782,-155970,145612,-156850,145484,-157430,145188,-158572,145071,-158835,144917,-159074,144731,-159287,144507,-159458,144253,-159581,143986,-159674,143703,-159713,143411,-159706,142530,-159626,141942,-159552,141057,-159417,74875.7,-147758,73998.8,-147592,72599.1,-147294,71460.2,-147130,70590.8,-146976,69724,-146790,68866.9,-146572,68591.3,-146478,68338.4,-146344,68119.7,-146165,67923.5,-145962,67772.1,-145724,67670.7,-145460,67608.1,-145183,67588.7,-144896,67698.4,-143721,67865.4,-142542,84794.7,-46523.9,84881,-45934.2,84983.6,-45051.8,85036.1,-44464.9,85034.5,-44174.7,84991.7,-43891.9,84895.1,-43626.7,84758.9,-43381.2,84585,-43161,84377.5,-42970.5,84136.4,-42819.5,83869.9,-42708.1,83015,-42482.3,82147.6,-42283.3,81561.9,-42167.1,80380.6,-41957.7,73287.1,-40724.4,72402.3,-40591.5,71814,-40518.2,70934.7,-40435.7,70644.1,-40428.4,70364.3,-40475.1,70108,-40585.3,69878.7,-40741.5,69683.1,-40939.5,69533.7,-41178.7,69434.5,-41449.6,69293.2,-42020.1,69050.5,-43179.9,68947.9,-43768.3,68576,-46139.3,68470.7,-46730];

      private var m_AutoIdx:int = 0;

      public var m_AutoTanX:Number = 0;

      public var m_AutoTanZ:Number = 1;

      private var m_AutoT:Number = 0;

      private var m_AutoD:Number = 0;

      private var m_AutoPX:Number = 0;

      private var m_AutoPZ:Number = 0;

      public static const AUTO_EXTRA:Array = [0,0,0,0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,0,1,0,0,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,0,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,0,1,0,1,1,1,1,1,0,1,1,0,1,1,1,1,0,1,1,1,0,1,1,0,1,1,1,1,1,0,0,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,0,0,1,1,0,1,1,0,0,1,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1,0,1,0,0,1,1,1,1,1,0,1,1,0,1,0,0,1,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1,1,1,0,0,1,1,1,1,1,1,1,0,0,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,1,1,0,1,1,0,1,1,0,1,1,1,1,0,1,0,1,1,0,1,1,1,0,0,0,0,0,1,1,1,1,1,0,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,0,1,0,1,1,1,1,0,1,0,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];

      private var m_AutoShift:Number = 0;

      private var m_AutoShiftTarget:Number = 0;

      private var m_AutoHold:int = 0;

      private var m_AutoBlockDist:Number = 1e9;

      private var m_AutoBlockSpeed:Number = 0;

      public static const AUTO_SPEED:Array = [300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,289,280,238,174,158,97,97,97,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,287,247,238,227,227,226,226,226,283,283,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,255,209,209,209,212,300,291,272,272,272,300,300,284,264,232,208,208,199,186,186,186,234,234,285,300,300,300,300,300,300,300,300,300,300,300,300,288,248,237,226,222,222,222,231,231,286,300,300,300,300,300,300,300,300,273,242,231,231,222,222,222,226,296,296,300,300,300,290,261,240,228,228,228,257,247,247,247,280,300,300,300,300,288,258,237,201,187,187,187,203,203,203,220,300,300,300,300,300];

      private var m_AutoCool:int = 0;

      private var m_AutoCardShift:Number = 0;

      private var m_AutoPrevTurn:Number = 0;
      
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
            this.m_AutoCool = 0;
            this.m_AutoCardShift = 0;
            this.m_AutoPrevTurn = 0;
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
               if(_loc10_ > -250 && _loc10_ < 3200 && Math.abs(_loc11_) < 950 && _loc10_ < _loc6_)
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
            this.m_AutoCardShift = Math.min(_loc24_,this.m_AutoCardShift + 22);
         }
         else if(this.m_AutoCardShift > _loc24_)
         {
            this.m_AutoCardShift = Math.max(_loc24_,this.m_AutoCardShift - 22);
         }
         _loc22_ = this.m_AutoTanZ * (this.m_AutoShift + this.m_AutoCardShift);
         _loc23_ = -this.m_AutoTanX * (this.m_AutoShift + this.m_AutoCardShift);
         _loc11_ = Math.max(250,Math.min(900,_loc10_ * 3.0));
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
         _loc17_ = Math.max(-40,Math.min(40,_loc15_ * 0.4));
         _loc17_ = this.m_AutoPrevTurn + Math.max(-4,Math.min(4,_loc17_ - this.m_AutoPrevTurn));
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

