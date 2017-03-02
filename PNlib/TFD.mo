within PNlib;
model TFD "Discrete Transition with fire duration"
  parameter Integer nIn = 0 "number of input places" annotation(Dialog(connectorSizing=true));
  parameter Integer nOut = 0 "number of output places" annotation(Dialog(connectorSizing=true));
  //****MODIFIABLE PARAMETERS AND VARIABLES BEGIN****//
  Real duration = 1 "duration of timed transition" annotation(Dialog(enable = true, group = "Duration"));
  Real arcWeightIn[nIn] = fill(1, nIn) "arc weights of input places" annotation(Dialog(enable = true, group = "Arc Weights"));
  Real arcWeightOut[nOut] = fill(1, nOut) "arc weights of output places" annotation(Dialog(enable = true, group = "Arc Weights"));
  Boolean firingCon=true "additional firing condition" annotation(Dialog(enable = true, group = "Firing Condition"));
  //****MODIFIABLE PARAMETERS AND VARIABLES END****//
protected
  outer PNlib.Settings settings "global settings for animation and display";
  Integer showTransitionName=settings.showTransitionName "only for transition animation and display (Do not change!)";
  Integer showDuration=settings.showDelay "only for transition animation and display (Do not change!)";
  Real color[3] "only for transition animation and display (Do not change!)";
  Real tIn[nIn] "tokens of input places";
  Real tOut[nOut] "tokens of output places";
  Real testValue[nIn] "test values of input arcs";
  Real firingTime1 "next putative firing time";
  Real firingTime2 "next putative firing time";
  Real fireTime "for transition animation";
  Real minTokens[nIn] "minimum tokens of input places";
  Real maxTokens[nOut] "maximum tokens of output places";
  Real duration_ = if duration < 1e-6 then 1e-6 else duration "due to event problems if duration==0";
  Integer tIntIn[nIn] "integer tokens of input places (for generating events!)";
  Integer tIntOut[nOut]
    "integer tokens of output places (for generating events!)";
  Integer arcType[nIn]
    "type of input arcs 1=normal, 2=test arc, 3=inhibitor arc, 4=read arc";
  Integer arcWeightIntIn[nIn]
    "Integer arc weights of discrete input places (for generating events!)";
  Integer arcWeightIntOut[nOut]
    "Integer arc weights of discrete output places (for generating events!)";
  Integer minTokensInt[nIn]
    "Integer minimum tokens of input places (for generating events!)";
  Integer maxTokensInt[nOut]
    "Integer maximum tokens of output places (for generating events!)";
  Integer testValueInt[nIn]
    "Integer test values of input arcs (for generating events!)";
  Integer normalArc[nIn]
    "1=no, 2=yes, i.e. double arc: test and normal arc or inhibitor and normal arc";
  Boolean disPlaceIn[nIn]
    "Are the input places discrete or continuous? true=discrete";
  Boolean disPlaceOut[nOut]
    "Are the output places discrete or continuous? true=discrete";
  Boolean enableIn[nIn] "Is the transition enabled by input places?";
  Boolean enableOut[nOut] "Is the transition enabled by output places?";
  Boolean durationPassed1(start=false, fixed=true) "Is the duration passed?";
  Boolean durationPassed2(start=false, fixed=true) "Is the duration passed?";
  Boolean durationPassed(start=false, fixed=true) "Is the duration passed?";
  Boolean ani "for transition animation";
  Real fire( start=0.0, fixed=true) "Is the duration passed?";
  Real prefire( start=0.0, fixed=true) "Is the duration passed?";

  //****BLOCKS BEGIN****// since no events are generated within functions!!!
  //activation process
  Blocks.activationDisIn activationIn(testValue=testValue, testValueInt=testValueInt, normalArc=normalArc, nIn=nIn, tIn=tIn, tIntIn=tIntIn, arcType=arcType, arcWeightIn=arcWeightIn, arcWeightIntIn=arcWeightIntIn, minTokens=minTokens, minTokensInt=minTokensInt, firingCon=firingCon, disPlaceIn=disPlaceIn);
  Blocks.activationDisOut activationOut(nOut=nOut, tOut=tOut, tIntOut=tIntOut, arcWeightOut=arcWeightOut, arcWeightIntOut=arcWeightIntOut, maxTokens=maxTokens, maxTokensInt=maxTokensInt, firingCon=firingCon, disPlaceOut=disPlaceOut);
  //Is the transition enabled by all input places?
  Boolean enabledByInPlaces = Functions.OddsAndEnds.allTrue(enableIn);
   //Is the transition enabled by all output places?
  Boolean enabledByOutPlaces = Functions.OddsAndEnds.allTrue(enableOut);
  //****BLOCKS END****//
public
  Boolean active1 "Is the transition active?";
  Boolean active2 "Is the transition active?";
  Boolean fire1 "Does the transition fire?";
  Boolean fire2 "Does the transition fire?";
  PNlib.Interfaces.TransitionIn inPlaces[nIn](
    each active=durationPassed1,
    arcWeight=arcWeightIn,
    arcWeightint=arcWeightIntIn,
    each fire=fire1,
    each disTransition=true,
    each instSpeed=0,
    each prelimSpeed=0,
    each maxSpeed=0,
    t=tIn,
    tint=tIntIn,
    arcType=arcType,
    minTokens=minTokens,
    minTokensint=minTokensInt,
    disPlace=disPlaceIn,
    enable=enableIn,
    testValue=testValue,
    testValueint=testValueInt,
    normalArc=normalArc) if nIn > 0 "connector for input places" annotation(Placement(transformation(extent={{-56, -10}, {-40, 10}}, rotation=0)));
  PNlib.Interfaces.TransitionOut outPlaces[nOut](
    each active=durationPassed2,
    arcWeight=arcWeightOut,
    arcWeightint=arcWeightIntOut,
    each fire=fire2,
    each enabledByInPlaces=true,
    each disTransition=true,
    each instSpeed=0,
    each prelimSpeed=0,
    each maxSpeed=0,
    t=tOut,
    tint=tIntOut,
    maxTokens=maxTokens,
    maxTokensint=maxTokensInt,
    disPlace=disPlaceOut,
    enable=enableOut) if nOut > 0 "connector for output places" annotation(Placement(transformation(extent={{40, -10}, {56, 10}}, rotation=0)));
    //each enabledByInPlaces=enabledByInPlaces,
equation
  //****MAIN BEGIN****//
   //reset active when duration passed
   active1 = activationIn.active  and not pre(durationPassed1) and 0.5>=prefire;
   active2 = activationOut.active and not pre(durationPassed2) and prefire>=0.5;
   //active2 = false and not pre(durationPassed2);
   
   //save next putative firing time
   when active1 then
      firingTime1 = time+1e-6;
   end when;
   
   
   when active2 then
      firingTime2 = if time>=firingTime1+duration_-1e-6  then time+1e-6 else time +duration_;
   end when;
   

  prefire=pre(fire);
  durationPassed = durationPassed1 or durationPassed2;
  when {durationPassed1, durationPassed2} then
    //fire=not prefire ;
    if durationPassed2 then
      //reinit(fire,0.0);
      fire=0.0;
    else
      //reinit(fire,1.0);
      fire=1.0;
    end if; 
  end when;

   //duration passed?
   durationPassed1= active1 and time>=firingTime1;
   durationPassed2= active2 and time>=firingTime2;

  /* when {pre(fire1), pre(fire2)} then
      nofire = not pre( nofire);
   end when;*/


   //firing process
   //fire=if nOut==0 then enabledByInPlaces else enabledByOutPlaces;
  fire1=enabledByInPlaces;
  fire2=enabledByOutPlaces;
  //fire2=active2 and time>=firingTime2;

   
   //****MAIN END****//
    //****ANIMATION BEGIN****//
    when fire1 then
     fireTime=time;
     ani=true;
   end when;
   color=if (fireTime+settings.timeFire>=time and settings.animateTransition==1 and ani) then {255, 255, 0} else {0, 0, 0};
   //****ANIMATION END****//
   //****ERROR MESSENGES BEGIN****//
   for i in 1:nIn loop
      if disPlaceIn[i] then
        arcWeightIntIn[i]=integer(arcWeightIn[i]);
      else
        arcWeightIntIn[i]=1;
      end if;
      assert((disPlaceIn[i] and arcWeightIn[i]-arcWeightIntIn[i]<=0.0) or not disPlaceIn[i], "Input arcs connected to discrete places must have integer weights.");
      assert(arcWeightIn[i]>=0, "Input arc weights must be positive.");
   end for;
   for i in 1:nOut loop
      if disPlaceOut[i] then
        arcWeightIntOut[i]=integer(arcWeightOut[i]);
      else
        arcWeightIntOut[i]=1;
      end if;
      assert((disPlaceOut[i] and arcWeightOut[i]-arcWeightIntOut[i]<=0.0) or not disPlaceOut[i], "Output arcs connected to discrete places must have integer weights.");
      assert(arcWeightOut[i]>=0, "Output arc weights must be positive.");
   end for;
   //****ERROR MESSENGES END****//

  annotation(defaultComponentName = "T1", Icon(graphics={Rectangle(
          extent={{-40, 100}, {40, -100}},
          lineColor={0, 0, 0},
        fillColor=DynamicSelect({0, 0, 0}, color),
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-2, -116}, {-2, -144}},
          lineColor={0, 0, 0},
          textString=DynamicSelect("fd=%duration", if showDuration==1 then "d=%duration" else " ")),
                                          Text(
          extent={{-4, 139}, {-4, 114}},
          lineColor={0, 0, 0},
          textString="%name")}), Diagram(graphics));
end TFD;
