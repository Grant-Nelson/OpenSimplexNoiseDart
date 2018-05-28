library OpenSimplexNoise.test;

import 'package:OpenSimplexNoiseDart/OpenSimplexNoise.dart';

part 'data2D.dart';
part 'data3D.dart';
part 'data4D.dart';

/// Tests for OpenSimplex noise,
/// based on the output of the Java implementation.
///
/// Test values borrowed from https://github.com/ojrac/opensimplex-go/blob/master/opensimplex_test.go
void main() {
  check2D();
  check3D();
  check4D();
}

void check2D() {
  print("Check 2D Noise");
  OpenSimplexNoise noise = new OpenSimplexNoise();
  for (Data2D datum in get2DSamples()) {
    double result = noise.eval2D(datum.x, datum.y);
    if ((result - datum.exp).abs() > 1.0e-12) {
      print("FAILED: eval2D(${datum.x}, ${datum.y})");
      print("        expected: ${datum.exp}");
      print("        result:   $result");
      print("        diff:     ${(result - datum.exp).abs()}");
      return;
    }
  }
  print("PASSED");
}

void check3D() {
  print("Check 3D Noise");
  OpenSimplexNoise noise = new OpenSimplexNoise();
  for (Data3D datum in get3DSamples()) {
    double result = noise.eval3D(datum.x, datum.y, datum.z);
    if ((result - datum.exp).abs() > 1.0e-12) {
      print("FAILED: eval3D(${datum.x}, ${datum.y}, ${datum.z})");
      print("        expected: ${datum.exp}");
      print("        result:   $result");
      print("        diff:     ${(result - datum.exp).abs()}");
      return;
    }
  }
  print("PASSED");
}

void check4D() {
  // print("Check 4D Noise");
  // OpenSimplexNoise noise = new OpenSimplexNoise();
  // for (Data4D datum in get4DSamples()) {
  //   double result = noise.eval4D(datum.x, datum.y, datum.z, datum.w);
  //   if ((result - datum.exp).abs() > 1.0e-12) {
  //     print("FAILED: eval4D(${datum.x}, ${datum.y}, ${datum.z}, ${datum.w})");
  //     print("        expected: ${datum.exp}");
  //     print("        result:   $result");
  //     print("        diff:     ${(result - datum.exp).abs()}");
  //     return;
  //   }
  // }
  // print("PASSED");
}
