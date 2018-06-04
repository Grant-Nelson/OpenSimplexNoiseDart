library OpenSimplexNoise;

import 'eval2D/eval.dart' as e2D;
import 'eval3D/eval.dart' as e3D;
import 'eval4D/eval.dart' as e4D;

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
  final List<int> _perm;

  // Initializes using the given permutation array.
  OpenSimplexNoise.fromPerm(this._perm);

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
    return new e2D.Eval(_perm, new e2D.Point(x, y)).eval();
  }

  // Calculates 3D OpenSimplex Noise for the given 3D point.
  double eval3D(double x, double y, double z) {
    return new e3D.Eval(_perm, new e3D.Point(x, y, z)).eval();
  }

  // Calculates 4D OpenSimplex Noise for the given 4D point.
  double eval4D(double x, double y, double z, double w) {
    return new e4D.Eval(_perm, new e4D.Point(x, y, z, w)).eval();
  }
}
