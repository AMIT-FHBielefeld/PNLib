within PNlib.Blocks;
block activationCon "activation process of continuous transitions"
//no events are generated within while-loops; for-loops are applied
  import PNlib.Types.ArcType;
  parameter input Integer nIn "number of input places";
  parameter input Integer nOut "number of output places";
  input Real tIn[:] "marking of input places";
  input Real tOut[:] "marking of output places";
  input Integer tIntIn[:] "marking of input places";
  input Integer tIntOut[:] "marking of output places";
  input ArcType arcType[:] "arc type of input places";
  input Real arcWeightIn[:] "arc weights of input places";
  input Real arcWeightOut[:] "arc weights of output places";
  input Integer arcWeightIntIn[:] "arc weights of input places";
  input Integer arcWeightIntOut[:] "arc weights of output places";
  input Real minTokens[:] "minimum capacities of input places";
  input Real maxTokens[:] "maximum capacities of output places";
  input Integer minTokensInt[:] "minimum capacities of input places";
  input Integer maxTokensInt[:] "maximum capacities of output places";
  input Boolean firingCon "firing condition";
  input Boolean fed[:] "input places are fed?";
  input Boolean emptied[:] "output places are emptied?";
  input Boolean disPlaceIn[:] "types of input places";
  input Boolean disPlaceOut[:] "types of output places";
  input Real testValue[:] "test values of test and inhibitor arcs";
  input Integer testValueInt[:] "integer test values of test and inhibitor arcs";
  input Boolean normalArc[:] "normal or double arc?";
  output Boolean active "activation of transition";
  output Boolean weaklyInputActiveVec[nIn] "places that causes weakly input activation";
  output Boolean weaklyOutputActiveVec[nOut] "places that causes weakly output activation";
algorithm
  active := true;
  weaklyInputActiveVec := fill(false, nIn);
  weaklyOutputActiveVec := fill(false, nOut);

  //check input places
  for i in 1:nIn loop
    if disPlaceIn[i] then //discrete place
      if arcType[i]==ArcType.NormalArc and (tIntIn[i]-arcWeightIntIn[i]  < minTokensInt[i]) then //normal arc
        active := false;
      elseif arcType[i]==ArcType.RealTestArc and (tIntIn[i] <= testValueInt[i]) then //real test arc
        active := false;
      elseif arcType[i]==ArcType.TestArc and (tIntIn[i] < testValueInt[i]) then //test arc
        active := false;
      elseif arcType[i]==ArcType.RealInhibitorArc and (tIntIn[i] >= testValueInt[i]) then // real inhibition arc
        active := false;
      elseif arcType[i]==ArcType.InhibitorArc and (tIntIn[i] > testValueInt[i]) then //inhibition arc
        active := false;
      end if;
    else  //continuous place
      if arcType[i]==ArcType.NormalArc or not normalArc[i] then  //normal arc or double arc
        if arcWeightIn[i] <= 0.0 then
        elseif tIn[i]<=minTokens[i] and (not fed[i]) then
          active := false;
        elseif tIn[i]<=minTokens[i] and fed[i] then  //weakly input active??
          weaklyInputActiveVec[i] := true;
        end if;
      end if;
      if arcType[i]==ArcType.RealTestArc then //real test arc
        if tIn[i] <= testValue[i] then
          active := false;
        end if;
        if tIn[i] > testValue[i] and fed[i] and not normalArc[i] then  //weakly input active??
          weaklyInputActiveVec[i] := true;
        end if;
      elseif arcType[i]==ArcType.TestArc then //test arc
        if tIn[i] < testValue[i] then
          active := false;
        end if;
        if tIn[i] >= testValue[i] and fed[i] and not normalArc[i] then  //weakly input active??
          weaklyInputActiveVec[i] := true;
        end if;
      elseif arcType[i]==ArcType.RealInhibitorArc and (tIn[i] >= testValue[i]) then  //real inhibitor arc
        active := false;
      elseif arcType[i]==ArcType.InhibitorArc and (tIn[i] > testValue[i]) then  //inhibitor arc
        active := false;
      end if;
    end if;
  end for;

  //output places
  for i in 1:nOut loop
    if disPlaceOut[i] then  //discrete place
      if tIntOut[i]+arcWeightIntOut[i] > maxTokensInt[i] then
        active := false;
      end if;
    else  //continuous place
      if tOut[i] >= maxTokens[i] then
        if emptied[i] then
          weaklyOutputActiveVec[i] := true;
        else
          active := false;
        end if;
      end if;
    end if;
  end for;

  active := active and firingCon;
  // hack for Dymola 2017
  // weaklyOutputActiveVec := weaklyOutputActiveVec and fill(firingCon, nOut);
  for i in 1:nOut loop
    weaklyOutputActiveVec[i] := weaklyOutputActiveVec[i] and firingCon;
  end for;

  // hack for Dymola 2017
  //weaklyInputActiveVec := weaklyInputActiveVec and fill(firingCon, nIn);
  for i in 1:nIn loop
    weaklyInputActiveVec[i] := weaklyInputActiveVec[i] and firingCon;
  end for;
end activationCon;
