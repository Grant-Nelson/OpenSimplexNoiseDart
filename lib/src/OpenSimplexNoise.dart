library OpenSimplexNoise;

import 'eval2D/eval.dart' as e2D;
import 'eval3D/eval.dart' as e3D;

part 'eval4D.dart';

/// This generates smoothly-changing deterministic random values in
/// 2 or 3 dimensions. This can be used for procedurally generated textures,
/// shapes, or terrain.
///
/// OpenSimplex noise is a Dart implementation of Kurt Spencer's patent-free
/// alternative to Perlin and Simplex noise.
///
/// For more information: http://uniblock.tumblr.com/post/97868843242/noise
/// or https://gist.github.com/KdotJPG/b1270127455a94ac5d19
class OpenSimplexNoise {
  e2D.Eval _eval2D;
  e3D.Eval _eval3D;

  // Initializes using the given permutation array.
  OpenSimplexNoise.fromPerm(_perm) {
    _eval2D = new e2D.Eval(_perm);
    _eval3D = new e3D.Eval(_perm);
  }

  // Initializes using a permutation array generated from a seed.
  // The seed is 53-bits when Dart has been transpiled into JS.
  factory OpenSimplexNoise([int seed = 0]) {
    List<int> perm = new List<int>(256);
    List<int> source = new List<int>(256);
    for (int i = 0; i < 256; i++) source[i] = i;

    const int seedMul = 6364136223846793005;
    const int seedAdd = 1442695040888963407;
    seed = (seed * seedMul + seedAdd).toSigned(64);
    seed = (seed * seedMul + seedAdd).toSigned(64);
    seed = (seed * seedMul + seedAdd).toSigned(64);

    for (int i = 255; i >= 0; i--) {
      seed = (seed * seedMul + seedAdd).toSigned(64);
      int r = ((seed + 31) % (i + 1));
      if (r < 0) r += (i + 1);
      perm[i] = source[r];
      source[r] = source[i];
    }

    return new OpenSimplexNoise.fromPerm(perm);
  }

  // Calculates 2D OpenSimplex Noise for the given 2D point.
  double eval2D(double x, double y) {
    return _eval2D.eval(new e2D.Point(x, y));
  }

  // Calculates 3D OpenSimplex Noise for the given 3D point.
  double eval3D(double x, double y, double z) {
    return _eval3D.eval(new e3D.Point(x, y, z));
  }

  // Calculates 4D OpenSimplex Noise for the given 4D point.
  double eval4D(double x, double y, double z, double w) {
    return 0.0; // TODO: Replace
  }
}
