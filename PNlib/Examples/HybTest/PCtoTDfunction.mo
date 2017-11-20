within PNlib.Examples.HybTest;

model PCtoTDfunction
  extends Modelica.Icons.Example;
  inner PNlib.Components.Settings settings annotation(Placement(transformation(extent = {{20, 20}, {40, 40}})));
  PNlib.Components.PC P1(nOut=1, startMarks=5) annotation(Placement(transformation(extent = {{-30, -10}, {-10, 10}})));
  PNlib.Components.TD T1(nIn=1, arcWeightIn={P1.t}) annotation(Placement(transformation(extent = {{10, -10}, {30, 10}})));
equation
  connect(T1.inPlaces[1], P1.outTransition[1]) annotation(Line(points = {{15.2, 0}, {-9.2, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
  annotation(Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-40, -40}, {40, 40}}), graphics), experiment(StartTime = 0.0, StopTime = 5.0, Tolerance = 1e-6));
end PCtoTDfunction;
