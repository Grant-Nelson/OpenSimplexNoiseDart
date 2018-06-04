library eval3D;

part 'point.dart';

// Open Simplex for 3D Noise
class Eval {
  // (1 / sqrt(3 + 1) - 1) / 3
  static const double _stretch = -1.0 / 6.0;

  // (sqrt(3 + 1) - 1) / 3
  static const double _squish = 1.0 / 3.0;

  // Normalizing scalar to the result
  static const double _norm = 103.0;

  // Gradients for 3D. They approximate the directions to the
  // vertices of a rhombicuboctahedron from the center, skewed so
  // that the triangular and square facets can be inscribed inside
  // circles of the same radius.
  static List<Point> _gradients = [
    new Point(-11.0, 4.0, 4.0),
    new Point(-4.0, 11.0, 4.0),
    new Point(-4.0, 4.0, 11.0),
    new Point(11.0, 4.0, 4.0),
    new Point(4.0, 11.0, 4.0),
    new Point(4.0, 4.0, 11.0),
    new Point(-11.0, -4.0, 4.0),
    new Point(-4.0, -11.0, 4.0),
    new Point(-4.0, -4.0, 11.0),
    new Point(11.0, -4.0, 4.0),
    new Point(4.0, -11.0, 4.0),
    new Point(4.0, -4.0, 11.0),
    new Point(-11.0, 4.0, -4.0),
    new Point(-4.0, 11.0, -4.0),
    new Point(-4.0, 4.0, -11.0),
    new Point(11.0, 4.0, -4.0),
    new Point(4.0, 11.0, -4.0),
    new Point(4.0, 4.0, -11.0),
    new Point(-11.0, -4.0, -4.0),
    new Point(-4.0, -11.0, -4.0),
    new Point(-4.0, -4.0, -11.0),
    new Point(11.0, -4.0, -4.0),
    new Point(4.0, -11.0, -4.0),
    new Point(4.0, -4.0, -11.0)
  ];

  static final Point _pntStretch = new Point(_stretch, _stretch, _stretch);
  static final Point _pntSquish = new Point(_squish, _squish, _squish);

  /// Noise permutation set.
  final List<int> _perm;

  /// The simplectic honeycomb coordinates of rhombohedron (stretched cube) super-cell origin.
  final Point _grid;

  /// The position relative to the origin point.
  final Point _origin;

  /// The simplectic honeycomb coordinates relative to rhombohedral origin.
  final Point _ins;

  /// The accumulator of the noise value.
  double _value;

  /// Contructs a new evaluator for 3D noise.
  Eval._(this._perm, this._grid, this._origin, this._ins) {
    _value = 0.0;
  }

  /// Creates a new evaluator for 3D noise and calcuate the initial values.
  factory Eval(List<int> perm, Point input) {
    // Place input coordinates on simplectic honeycomb.
    Point stretch = input + _pntStretch * input.sum;
    Point grid = stretch.floor;

    // Skew out to get actual coordinates of rhombohedron origin.
    Point squish = grid + _pntSquish * grid.sum;
    Point ins = stretch - grid;
    Point origin = input - squish;
    return new Eval._(perm, grid, origin, ins);
  }

  /// Extrapolates the offset grid point to the permutation of noise.
  double _extrapolate(Point grid, Point delta) {
    final int index0 = (_perm[grid.x.toInt() & 0xFF] + grid.y.toInt()) & 0xFF;
    final int index1 = (_perm[index0] + grid.z.toInt()) & 0xFF;
    final int index2 = _perm[index1] % _gradients.length;
    final Point pnt = _gradients[index2];
    return pnt.x * delta.x + pnt.y * delta.y + pnt.z * delta.z;
  }

  /// Contributes a point into the noise value if the attenuation is positive.
  void _contribute(double dx, double dy, double dz) {
    final Point delta = new Point(dx, dy, dz);
    final Point shifted = _origin - delta - _pntSquish * delta.sum;
    final double attn = shifted.attn;
    if (attn > 0.0) {
      final double attn2 = attn * attn;
      _value += attn2 * attn2 * _extrapolate(_grid + delta, shifted);
    }
  }

  /// Compute 3D OpenSimplex noise value.
  double eval() {
    // Sum those together to get a value that determines the region.
    final double inSum = _ins.sum;
    if (inSum <= 1.0) {
      // Inside the tetrahedron (3-Simplex) at (0, 0, 0)

      // Determine which two of (0, 0, 1), (0, 1, 0), (1, 0, 0) are closest.
      double aScore = _ins.x;
      double bScore = _ins.y;
      int aPoint = 0x01;
      int bPoint = 0x02;
      if (_ins.x >= _ins.y && _ins.z > _ins.y) {
        bScore = _ins.z;
        bPoint = 0x04;
      } else if (_ins.x < _ins.y && _ins.z > _ins.x) {
        aScore = _ins.z;
        aPoint = 0x04;
      }

      // Now we determine the two lattice points not part of the tetrahedron that may contribute.
      // This depends on the closest two tetrahedral vertices, including (0, 0, 0)
      final double wins = 1 - inSum;
      if (wins > aScore || wins > bScore) {
        // (0, 0, 0) is one of the closest two tetrahedral vertices.
        // Our other closest vertex is the closest out of a and b.
        final int closest = (bScore > aScore) ? bPoint : aPoint;
        if (closest == 1) {
          _contribute(1.0, -1.0, 0.0);
          _contribute(1.0, 0.0, -1.0);
        } else if (closest == 2) {
          _contribute(-1.0, 1.0, 0.0);
          _contribute(0.0, 1.0, -1.0);
        } else {
          // closest == 4
          _contribute(-1.0, 0.0, 1.0);
          _contribute(0.0, -1.0, 1.0);
        }
      } else {
        // (0, 0, 0) is not one of the closest two tetrahedral vertices.
        // Our two extra vertices are determined by the closest two.
        final int closest = aPoint | bPoint;
        if (closest == 3) {
          _contribute(1.0, 1.0, 0.0);
          _contribute(1.0, 1.0, -1.0);
        } else if (closest == 5) {
          _contribute(1.0, 0.0, 1.0);
          _contribute(1.0, -1.0, 1.0);
        } else {
          // closest == 6
          _contribute(0.0, 1.0, 1.0);
          _contribute(-1.0, 1.0, 1.0);
        }
      }

      _contribute(0.0, 0.0, 0.0);
      _contribute(1.0, 0.0, 0.0);
      _contribute(0.0, 1.0, 0.0);
      _contribute(0.0, 0.0, 1.0);
    } else if (inSum >= 2.0) {
      // Inside the tetrahedron (3-Simplex) at (1, 1, 1)

      // Determine which two tetrahedral vertices are the closest, out of (1, 1, 0), (1, 0, 1), (0, 1, 1) but not (1, 1, 1).
      int aPoint = 0x06;
      double aScore = _ins.x;
      int bPoint = 0x05;
      double bScore = _ins.y;
      if (aScore <= bScore && _ins.z < bScore) {
        bScore = _ins.z;
        bPoint = 0x03;
      } else if (aScore > bScore && _ins.z < aScore) {
        aScore = _ins.z;
        aPoint = 0x03;
      }

      // Now we determine the two lattice points not part of the tetrahedron that may contribute.
      // This depends on the closest two tetrahedral vertices, including (1, 1, 1)
      final double wins = 3.0 - inSum;
      if (wins < aScore || wins < bScore) {
        // (1, 1, 1) is one of the closest two tetrahedral vertices.
        // Our other closest vertex is the closest out of a and b.
        final int closest = (bScore < aScore ? bPoint : aPoint);
        if (closest == 3) {
          _contribute(2.0, 1.0, 0.0);
          _contribute(1.0, 2.0, 0.0);
        } else if (closest == 5) {
          _contribute(2.0, 0.0, 1.0);
          _contribute(1.0, 0.0, 2.0);
        } else {
          // closest == 6
          _contribute(0.0, 2.0, 1.0);
          _contribute(0.0, 1.0, 2.0);
        }
      } else {
        // (1, 1, 1) is not one of the closest two tetrahedral vertices.
        // Our two extra vertices are determined by the closest two.
        final int closest = aPoint & bPoint;
        if (closest == 1) {
          _contribute(1.0, 0.0, 0.0);
          _contribute(2.0, 0.0, 0.0);
        } else if (closest == 2) {
          _contribute(0.0, 1.0, 0.0);
          _contribute(0.0, 2.0, 0.0);
        } else {
          // closest == 4
          _contribute(0.0, 0.0, 1.0);
          _contribute(0.0, 0.0, 2.0);
        }
      }

      _contribute(1.0, 1.0, 0.0);
      _contribute(1.0, 0.0, 1.0);
      _contribute(0.0, 1.0, 1.0);
      _contribute(1.0, 1.0, 1.0);
    } else {
      // Inside the octahedron (Rectified 3-Simplex) in between.
      double aScore, bScore;
      int aPoint, bPoint;
      bool aIsFurtherSide, bIsFurtherSide;

      // Decide between point (0, 0, 1) and (1, 1, 0) as closest
      final double p1 = _ins.x + _ins.y;
      if (p1 > 1.0) {
        aScore = p1 - 1.0;
        aPoint = 0x03;
        aIsFurtherSide = true;
      } else {
        aScore = 1.0 - p1;
        aPoint = 0x04;
        aIsFurtherSide = false;
      }

      // Decide between point (0, 1, 0) and (1, 0, 1) as closest
      final double p2 = _ins.x + _ins.z;
      if (p2 > 1.0) {
        bScore = p2 - 1.0;
        bPoint = 0x05;
        bIsFurtherSide = true;
      } else {
        bScore = 1.0 - p2;
        bPoint = 0x02;
        bIsFurtherSide = false;
      }

      // The closest out of the two (1, 0, 0) and (0, 1, 1) will replace
      // the furthest out of the two decided above, if closer.
      final double p3 = _ins.y + _ins.z;
      if (p3 > 1.0) {
        final double score = p3 - 1.0;
        if (aScore <= bScore && aScore < score) {
          aScore = score;
          aPoint = 0x06;
          aIsFurtherSide = true;
        } else if (aScore > bScore && bScore < score) {
          bScore = score;
          bPoint = 0x06;
          bIsFurtherSide = true;
        }
      } else {
        final double score = 1.0 - p3;
        if (aScore <= bScore && aScore < score) {
          aScore = score;
          aPoint = 0x01;
          aIsFurtherSide = false;
        } else if (aScore > bScore && bScore < score) {
          bScore = score;
          bPoint = 0x01;
          bIsFurtherSide = false;
        }
      }

      // Where each of the two closest points are determines how the extra two vertices are calculated.
      if (aIsFurtherSide == bIsFurtherSide) {
        if (aIsFurtherSide) {
          // Both closest points on (1, 1, 1) side

          // One of the two extra points is (1, 1, 1)
          _contribute(1.0, 1.0, 1.0);

          // Other extra point is based on the shared axis.
          int closest = aPoint & bPoint;
          if (closest == 1)
            _contribute(2.0, 0.0, 0.0);
          else if (closest == 2)
            _contribute(0.0, 2.0, 0.0);
          else // closest == 4
            _contribute(0.0, 0.0, 2.0);
        } else {
          // Both closest points on (0, 0, 0) side

          // One of the two extra points is (0, 0, 0)
          _contribute(0.0, 0.0, 0.0);

          // Other extra point is based on the omitted axis.
          int closest = aPoint | bPoint;
          if (closest == 3)
            _contribute(1.0, 1.0, -1.0);
          else if (closest == 5)
            _contribute(1.0, -1.0, 1.0);
          else // closest == 6
            _contribute(-1.0, 1.0, 1.0);
        }
      } else {
        // One point on (0, 0, 0) side, one point on (1, 1, 1) side
        int c1, c2;
        if (aIsFurtherSide) {
          c1 = aPoint;
          c2 = bPoint;
        } else {
          c1 = bPoint;
          c2 = aPoint;
        }

        // One contribution is a permutation of (1, 1, -1)
        if (c1 == 3)
          _contribute(1.0, 1.0, -1.0);
        else if (c1 == 5)
          _contribute(1.0, -1.0, 1.0);
        else // c1 == 6
          _contribute(-1.0, 1.0, 1.0);

        // One contribution is a permutation of (0, 0, 2)
        if (c2 == 1)
          _contribute(2.0, 0.0, 0.0);
        else if (c2 == 2)
          _contribute(0.0, 2.0, 0.0);
        else // c2 == 4
          _contribute(0.0, 0.0, 2.0);
      }

      _contribute(1.0, 0.0, 0.0);
      _contribute(0.0, 1.0, 0.0);
      _contribute(0.0, 0.0, 1.0);
      _contribute(1.0, 1.0, 0.0);
      _contribute(1.0, 0.0, 1.0);
      _contribute(0.0, 1.0, 1.0);
    }
    return _value / _norm;
  }
}
