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

      public static const AUTO_LINE:Array = [61978.9,-81741.4,51850.6,-136240,51735.3,-136828,51413.2,-138288,51301.8,-138874,51165.4,-139758,51067.8,-140649,51005.4,-141544,50944.1,-143039,50873.5,-143931,50771,-144818,50661.7,-145402,50581.7,-145688,50397.1,-146253,50092.4,-147094,49872.2,-147649,49285.3,-149026,48964.8,-149865,48297.5,-151854,46384.6,-157223,44916.1,-161158,43901.7,-163660,43543.9,-164486,41577,-168864,41323,-169408,41058,-169946,38581.8,-174744,36805.2,-177875,35256.3,-180445,33664.9,-182988,31985.4,-185473,30624,-187450,28662.8,-190104,27207.3,-192012,26835.3,-192482,24738.4,-195030,22782.9,-197306,20965.7,-199302,18896.1,-201474,16989.6,-203386,16343.4,-204012,14590.7,-205652,12332.6,-207627,10263.4,-209361,9799.4,-209741,8145.7,-211036,7666.4,-211396,2808.9,-214918,2313.1,-215256,54.1,-216735,-2494.6,-218317,-4830.5,-219671,-5624,-220095,-9621.5,-222161,-10697.8,-222691,-13152.4,-223816,-13978.6,-224172,-16194.1,-225095,-18706.5,-226084,-19551.6,-226393,-21817.2,-227185,-24959.9,-228191,-27265.8,-228856,-28137.2,-229080,-30767.6,-229689,-32822.2,-230123,-33705.6,-230294,-39035.1,-231163,-41712.7,-231510,-42607.6,-231601,-47996.6,-231942,-48895.3,-231982,-53995.1,-231989,-54594.9,-231979,-56693.8,-231913,-57592.6,-231869,-62677.9,-231482,-63870.5,-231355,-66545.2,-230986,-67136.9,-230888,-69200.9,-230502,-70081.5,-230316,-72708.6,-229694,-74446.5,-229225,-76173.7,-228719,-78735.3,-227866,-81542,-226807,-84033.1,-225766,-86484.7,-224635,-87562,-224108,-89422.1,-223133,-89948.2,-222845,-92285,-221492,-94569.9,-220054,-95073,-219727,-97062,-218384,-97794.9,-217862,-99485.1,-216616,-100426,-215872,-101106,-215286,-102418,-214060,-103090,-213470,-103781,-212901,-105194,-211804,-105880,-211227,-106328,-210828,-106766,-210418,-108490,-208749,-109122,-208108,-110365,-206807,-110976,-206146,-112748,-204109,-114446,-202011,-114816,-201538,-117884,-197464,-118405,-196731,-118738,-196233,-119872,-194465,-121241,-192138,-121676,-191350,-122796,-189228,-124100,-186526,-125209,-184064,-125446,-183513,-126241,-181569,-126662,-180446,-127917,-176754,-128272,-175608,-128933,-173301,-129089,-172721,-129923,-169220,-130104,-168338,-130439,-166570,-130631,-165385,-130964,-163009,-131244,-160625,-131328,-159729,-131500,-157035,-131563,-154036,-131494,-151037,-131341,-148642,-131233,-147447,-130969,-145062,-130849,-144170,-130475,-141800,-130299,-140917,-129917,-139158,-129700,-138285,-129306,-136838,-129137,-136262,-128860,-135406,-128260,-133709,-127945,-132866,-126473,-129255,-126112,-128431,-124983,-125978,-123819,-123542,-123276,-122472,-122567,-121150,-122271,-120630,-121642,-119612,-121137,-118871,-120605,-118149,-119681,-116969,-119325,-116489,-118982,-116001,-118491,-115255,-118185,-114746,-118056,-114480,-117228,-112576,-117093,-112314,-116448,-111318,-115583,-110100,-114906,-109112,-114557,-108624,-98975.4,-87686.1,-98225.9,-86749.4,-70631.8,-53510.7,-70242.2,-53054.8,-69638.4,-52388.3,-69013.2,-51741.2,-67743.6,-50465.4,-67125.3,-49814,-66728,-49368,-66157.3,-48679.7,-65793.7,-48208.3,-65621.7,-47965.4,-65284.3,-47474.8,-64628.3,-46478.7,-64110.3,-45748.9,-63013,-44328.6,-61956.2,-42874.7,-58658.3,-38599.1,-53949.4,-32008.6,-51912.3,-29040.4,-50266.6,-26532.1,-48366.1,-23474.8,-46738,-20604.6,-45480.6,-18215.3,-44428.2,-16058.5,-43939.9,-14963.1,-43166.6,-13011,-42868.7,-12162.5,-42422.7,-10730.7,-42113.6,-9573,-41859.3,-8401.7,-41655.1,-7220.2,-41509.4,-6031.2,-41425.4,-4835.5,-41400.8,-3937.3,-41404.6,-3338.6,-41474.2,-2142.1,-41524.1,-1546.4,-41627.1,-656.7,-41765.6,227.8,-41946.6,1105.5,-42163.6,1976.4,-42326.5,2552.6,-42598.8,3409.1,-42902,4255.8,-43232.1,5092.4,-43468.8,5642.7,-43849.4,6456.7,-44257.8,7257.6,-44544.1,7784.1,-44842.3,8303.4,-45159.3,8811.2,-45658.8,9558.3,-46179.8,10291.8,-46724.2,11007.3,-47101.2,11473.3,-48472.9,13063,-48877.9,13505,-49504.1,14150.1,-50581.9,15193.2,-51241.7,15804.7,-52152.2,16585.9,-52847.2,17156.1,-53319.6,17523.5,-53814.9,17858.7,-54571.4,18342.6,-56119.4,19260.2,-57176,19827.8,-85033.5,33877.7,-103530,43171,-104062,43445.2,-104846,43878.1,-106376,44791,-107452,45290.9,-108552,45755,-109369,46126.3,-110174,46523.9,-110960,46947.7,-111974,47552.3,-112205,47728.2,-112397,47938,-112558,48171.4,-112668,48430.8,-112734,48704.8,-112745,48987.6,-112716,49270.7,-112638,49549.5,-112299,50366.6,-111930,51177.3,-111533,51981.4,-110844,53313.9,-86319.4,101424,-65940.8,141545,-65373.8,142596,-64762.6,143612,-64170.1,144272,-63555.1,144919,-63390.6,145169,-63242.6,145427,-62677.4,146473,-62419.4,147007,-62311.3,147283,-62038,148130,-61710.2,149271,-61535.3,149836,-61433,150112,-61301.6,150375,-60822.3,151121,-60157.7,152106,-59684.6,152863,-59238.2,153636,-58522.8,154943,-57901.2,155966,-52892.2,163802,-52218.6,164795,-45175.5,174510,-44637.7,175232,-43542.7,176660,-43169.1,177130,-37851.7,183632,-33980.2,188216,-33584.7,188667,-31769.7,190666,-28444.3,194128,-26399,196322,-25760.2,196955,-22934.9,199644,-19366.5,202854,-16508.6,205508,-14484.9,207295,-13800.4,207879,-9641.8,211324,-5379.1,214639,-4659.8,215179,-229.8,218267,516.6,218770,3531.6,220737,7613.1,223263,8650,223866,12337.3,225877,13403.8,226426,15843.9,227582,18321.7,228654,19152,229001,23342.1,230642,26159.6,231672,27296.5,232053,28450.4,232378,29613.2,232675,30489.6,232878,32547.7,233295,33433,233456,35508.6,233774,36103.3,233851,36998.2,233943,38791.8,234094,39690.2,234140,41489.6,234186,42089.2,234188,42988.5,234164,44786.6,234082,45385,234044,46578.5,233926,47769.8,233782,48660.2,233654,50430.3,233329,51601.6,233073,52471.7,232846,53337.1,232598,54482.2,232242,55047.7,232043,56170.2,231619,57279.7,231164,57826.8,230919,59179.8,230272,60249.1,229729,61292.7,229139,62321,228520,62826.3,228198,63324,227864,64058.2,227343,65010.8,226616,65926.2,225844,66800.7,225026,67429.1,224384,67834.2,223943,68610.5,223032,68979,222561,69332,222078,69833.1,221336,70145.5,220828,70440.2,220310,70851.6,219515,71606.5,217889,72125.7,216814,72369.8,216271,72591.9,215718,72995.4,214594,73340.1,213449,73626.4,212285,73921.3,210815,74100.3,209629,74251.2,208438,74340.6,207543,74400,206646,74496.4,204548,74513.2,203948,74520.3,201549,74495,200649,74238.5,195856,74136.8,194661,73840.3,192280,73492.6,189905,72382.5,183095,65715.2,147108,65248.4,144448,64949.5,142370,64840.4,141476,63960,133123,63861.6,131927,63553.1,126536,63464.1,120837,63487,119337,63676.5,114541,63972.7,110352,64416.3,106175,64489.1,105580,64574.8,104986,65350.1,100249,65571.5,99070.4,66774.3,93498.7,67526.2,90285.6,68373.7,87096.4,68956.7,85079,69137.1,84507.1,69432.2,83657.3,70266.7,81407.2,72067.9,76958,72420.7,76130.5,72802.2,75315.8,73461.8,73968.6,73872.5,73168.1,74884.3,71328,75496.2,70296.5,76141.7,69285,76646.8,68541.5,76997.6,68056.1,77546.8,67344.8,84990.7,58318.4,85553,57616.9,85913.8,57139.6,86429.6,56407.5,86910.8,55654.9,87209.7,55141.1,87631.6,54357,87754.8,54087.4,87857.1,53809.3,87942,53524.8,88250.7,52375.2,88583.4,50915.5,88879.2,49758.6,89075,48895,89119.8,48605.7,89077,47425.9,89004.7,46539.6,88895.6,45652.8,88754,44766.6,80589.4,513.5,79925.2,-3020.3,79753.6,-4181.6,79742.3,-4467,79899.5,-5005.3,80065.7,-5243.5,80255.2,-5465.6,81038,-6333.8,81448.1,-6752.2,81892.3,-7139.8,82157.7,-7271.2,82741,-7403.1,83622.6,-7576.5,165756,-22043.3,166339,-22167,167201,-22377.5,167768,-22534.3,168035,-22646,168266,-22810.3,168468,-23006.1,168646,-23224.9,168766,-23480.3,168856,-23748.3,168892,-24032.5,168883,-24324.3,168838,-24910.6,168745,-25792.8,146961,-149286,146791,-150167,146661,-150749,146442,-151614,146125,-152743,146086,-153618,146031,-154204,145922,-155086,145782,-155971,145612,-156851,145483,-157431,145187,-158573,145070,-158836,144916,-159075,144730,-159288,144506,-159459,144252,-159582,143985,-159674,143702,-159714,143410,-159707,142530,-159625,141941,-159552,141056,-159416,74874.7,-147758,73997.9,-147592,72598.2,-147294,71459.3,-147130,70589.8,-146976,69723,-146789,68866,-146572,68590.5,-146477,68337.7,-146343,68119,-146164,67922.9,-145962,67771.6,-145724,67670.4,-145459,67607.9,-145182,67588.6,-144895,67637.6,-144308,67736.5,-143426,67916.3,-142245,84794.8,-46522.9,84881.1,-45933.2,84983.7,-45050.8,85036.1,-44463.9,85034.3,-44173.7,84991.4,-43891,84894.7,-43625.8,84758.4,-43380.4,84584.3,-43160.3,84376.7,-42969.9,84135.5,-42819,83869,-42707.7,83014.1,-42482,82146.7,-42283.1,81561,-42166.9,80379.6,-41957.5,73286.1,-40724.2,72401.3,-40591.4,71813,-40518.1,70933.7,-40435.8,70643.2,-40428.6,70363.4,-40475.4,70107.2,-40585.7,69878,-40742.1,69682.5,-40940.2,69533.3,-41179.6,69436.2,-41451.5,69294.6,-42021.9,69050,-43180.7,68575.8,-46140.3,68470.6,-46731];

      private var m_AutoIdx:int = 0;

      public var m_AutoTanX:Number = 0;

      public var m_AutoTanZ:Number = 1;

      private var m_AutoT:Number = 0;

      private var m_AutoD:Number = 0;

      private var m_AutoPX:Number = 0;

      private var m_AutoPZ:Number = 0;

      public static const AUTO_EXTRA:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,0,0,0,1,1,1,1,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,0,0,1,0,0,1,1,1,1,1,1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,1,0,1,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,0,1,1,0,0,0,1,1,1,1,1,1,0,1,0,1,1,0,1,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0,1,1,1,1,0,1,0,1,1,1,1,1,1,0,1,0,1,1,0,1,1,1,1,0,1,0,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];

      private var m_AutoShift:Number = 0;

      private var m_AutoShiftTarget:Number = 0;

      private var m_AutoHold:int = 0;

      private var m_AutoBlockDist:Number = 1e9;

      private var m_AutoBlockSpeed:Number = 0;

      public static const AUTO_SPEED:Array = [300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,293,284,284,283,283,283,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,299,261,261,261,262,300,300,300,300,300,300,300,300,300,279,260,253,243,233,233,233,293,293,300,300,300,300,300,300,300,300,300,300,300,300,300,300,300,292,283,278,278,278,289,289,300,300,300,300,300,300,300,300,300,300,297,288,287,278,278,278,283,300,300,300,300,300,300,300,300,294,285,285,285,300,300,300,300,300,300,300,300,300,300,294,275,245,234,234,234,254,254,254,266,300,300,300,300];

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

