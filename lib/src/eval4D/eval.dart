library eval4D;

part 'point.dart';

/// Open Simplex for 4D Noise
class Eval {
  /// (1 / sqrt(4 + 1) - 1) / 4;
  static const double _stretch = -0.138196601125011;

  /// (sqrt(4 + 1) - 1) / 4;
  static const double _squish = 0.309016994374947;

  /// Normalizing scalar to the result
  static const double _norm = 30.0;

  /// Gradients for 4D. They approximate the directions to the
  /// vertices of a disprismatotesseractihexadecachoron from the center,
  /// skewed so that the tetrahedral and cubic facets can be inscribed inside
  /// spheres of the same radius.
  static List<Point> _gradients = [
    new Point(3.0, 1.0, 1.0, 1.0),
    new Point(1.0, 3.0, 1.0, 1.0),
    new Point(1.0, 1.0, 3.0, 1.0),
    new Point(1.0, 1.0, 1.0, 3.0),
    new Point(-3.0, 1.0, 1.0, 1.0),
    new Point(-1.0, 3.0, 1.0, 1.0),
    new Point(-1.0, 1.0, 3.0, 1.0),
    new Point(-1.0, 1.0, 1.0, 3.0),
    new Point(3.0, -1.0, 1.0, 1.0),
    new Point(1.0, -3.0, 1.0, 1.0),
    new Point(1.0, -1.0, 3.0, 1.0),
    new Point(1.0, -1.0, 1.0, 3.0),
    new Point(-3.0, -1.0, 1.0, 1.0),
    new Point(-1.0, -3.0, 1.0, 1.0),
    new Point(-1.0, -1.0, 3.0, 1.0),
    new Point(-1.0, -1.0, 1.0, 3.0),
    new Point(3.0, 1.0, -1.0, 1.0),
    new Point(1.0, 3.0, -1.0, 1.0),
    new Point(1.0, 1.0, -3.0, 1.0),
    new Point(1.0, 1.0, -1.0, 3.0),
    new Point(-3.0, 1.0, -1.0, 1.0),
    new Point(-1.0, 3.0, -1.0, 1.0),
    new Point(-1.0, 1.0, -3.0, 1.0),
    new Point(-1.0, 1.0, -1.0, 3.0),
    new Point(3.0, -1.0, -1.0, 1.0),
    new Point(1.0, -3.0, -1.0, 1.0),
    new Point(1.0, -1.0, -3.0, 1.0),
    new Point(1.0, -1.0, -1.0, 3.0),
    new Point(-3.0, -1.0, -1.0, 1.0),
    new Point(-1.0, -3.0, -1.0, 1.0),
    new Point(-1.0, -1.0, -3.0, 1.0),
    new Point(-1.0, -1.0, -1.0, 3.0),
    new Point(3.0, 1.0, 1.0, -1.0),
    new Point(1.0, 3.0, 1.0, -1.0),
    new Point(1.0, 1.0, 3.0, -1.0),
    new Point(1.0, 1.0, 1.0, -3.0),
    new Point(-3.0, 1.0, 1.0, -1.0),
    new Point(-1.0, 3.0, 1.0, -1.0),
    new Point(-1.0, 1.0, 3.0, -1.0),
    new Point(-1.0, 1.0, 1.0, -3.0),
    new Point(3.0, -1.0, 1.0, -1.0),
    new Point(1.0, -3.0, 1.0, -1.0),
    new Point(1.0, -1.0, 3.0, -1.0),
    new Point(1.0, -1.0, 1.0, -3.0),
    new Point(-3.0, -1.0, 1.0, -1.0),
    new Point(-1.0, -3.0, 1.0, -1.0),
    new Point(-1.0, -1.0, 3.0, -1.0),
    new Point(-1.0, -1.0, 1.0, -3.0),
    new Point(3.0, 1.0, -1.0, -1.0),
    new Point(1.0, 3.0, -1.0, -1.0),
    new Point(1.0, 1.0, -3.0, -1.0),
    new Point(1.0, 1.0, -1.0, -3.0),
    new Point(-3.0, 1.0, -1.0, -1.0),
    new Point(-1.0, 3.0, -1.0, -1.0),
    new Point(-1.0, 1.0, -3.0, -1.0),
    new Point(-1.0, 1.0, -1.0, -3.0),
    new Point(3.0, -1.0, -1.0, -1.0),
    new Point(1.0, -3.0, -1.0, -1.0),
    new Point(1.0, -1.0, -3.0, -1.0),
    new Point(1.0, -1.0, -1.0, -3.0),
    new Point(-3.0, -1.0, -1.0, -1.0),
    new Point(-1.0, -3.0, -1.0, -1.0),
    new Point(-1.0, -1.0, -3.0, -1.0),
    new Point(-1.0, -1.0, -1.0, -3.0)
  ];

  /// Predefined point with each componenent equal to the [_stretch] value.
  static final Point _pntStretch = new Point(_stretch, _stretch, _stretch, _stretch);
  
  /// Predefined point with each componenent equal to the [_squish] value.
  static final Point _pntSquish = new Point(_squish, _squish, _squish, _squish);

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

  // TODO: REMOVE
  bool _done;

  /// Contructs a new evaluator for 3D noise.
  Eval._(this._perm, this._grid, this._origin, this._ins) {
    _value = 0.0;
    _done = false;
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
    final int index2 = (_perm[(_perm[index1] + grid.w.toInt()) & 0xFF] & 0xFC) >> 2;
    final Point pnt = _gradients[index2];
    return pnt.x * delta.x + pnt.y * delta.y + pnt.z * delta.z + pnt.w * delta.w;
  }

  /// Contributes a point into the noise value if the attenuation is positive.
  void _contribute(double dx, double dy, double dz, double dw) {
    final Point delta = new Point(dx, dy, dz, dw);
    final Point shifted = _origin - delta - _pntSquish * delta.sum;
    final double attn = shifted.attn;
    if (attn > 0.0) {
      final double attn2 = attn * attn;
      _value += attn2 * attn2 * _extrapolate(_grid + delta, shifted);
    }
  }

  /// Calculate 4D OpenSimplex noise value.
  double eval() {
    // Sum those together to get a value that determines the region.
    final double inSum = _ins.sum;
    if (inSum <= 1) {
      // We're inside the pentachoron (4-Simplex) at (0,0,0,0)

      // Determine which two of (0,0,0,1), (0,0,1,0), (0,1,0,0), (1,0,0,0) are closest.
      int aPoint = 0x01;
      int bPoint = 0x02;
      double aScore = _ins.x;
      double bScore = _ins.y;
      if (aScore >= bScore && _ins.z > bScore) {
        bScore = _ins.z;
        bPoint = 0x04;
      } else if (aScore < bScore && _ins.z > aScore) {
        aScore = _ins.z;
        aPoint = 0x04;
      }
      if (aScore >= bScore && _ins.w > bScore) {
        bScore = _ins.w;
        bPoint = 0x08;
      } else if (aScore < bScore && _ins.w > aScore) {
        aScore = _ins.w;
        aPoint = 0x08;
      }

      // Now we determine the three lattice points not part of the pentachoron that may contribute.
      // This depends on the closest two pentachoron vertices, including (0, 0, 0, 0)
      final double uins = 1.0 - inSum;
      if (uins > aScore || uins > bScore) {
        // (0, 0, 0, 0) is one of the closest two pentachoron vertices.
        // Our other closest vertex is the closest out of a and b.
        final int closest = (bScore > aScore) ? bPoint : aPoint;
        if (closest == 1) {
          _contribute(1.0, -1.0, 0.0, 0.0);
          _contribute(1.0, 0.0, -1.0, 0.0);
          _contribute(1.0, 0.0, 0.0, -1.0);
        } else if (closest == 2) {
          _contribute(-1.0, 1.0, 0.0, 0.0);
          _contribute(0.0, 1.0, -1.0, 0.0);
          _contribute(0.0, 1.0, 0.0, -1.0);
        } else if (closest == 4) {
          _contribute(-1.0, 0.0, 1.0, 0.0);
          _contribute(0.0, -1.0, 1.0, 0.0);
          _contribute(0.0, 0.0, 1.0, -1.0);
        } else {
          // closest == 8
          _contribute(-1.0, 0.0, 0.0, 1.0);
          _contribute(0.0, -1.0, 0.0, 1.0);
          _contribute(0.0, 0.0, -1.0, 1.0);
        }
      } else {
        // (0, 0, 0, 0) is not one of the closest two pentachoron vertices.
        // Our three extra vertices are determined by the closest two.
        final int closest = aPoint | bPoint;
        if (closest == 3) {
          _contribute(1.0, 1.0, 0.0, 0.0);
          _contribute(1.0, 1.0, -1.0, 0.0);
          _contribute(1.0, 1.0, 0.0, -1.0);
        } else if (closest == 5) {
          _contribute(1.0, 0.0, 1.0, 0.0);
          _contribute(1.0, -1.0, 1.0, 0.0);
          _contribute(1.0, 0.0, 1.0, -1.0);
        } else if (closest == 6) {
          _contribute(0.0, 1.0, 1.0, 0.0);
          _contribute(-1.0, 1.0, 1.0, 0.0);
          _contribute(0.0, 1.0, 1.0, -1.0);
        } else if (closest == 9) {
          _contribute(1.0, 0.0, 0.0, 1.0);
          _contribute(1.0, -1.0, 0.0, 1.0);
          _contribute(1.0, 0.0, -1.0, 1.0);
        } else if (closest == 10) {
          _contribute(0.0, 1.0, 0.0, 1.0);
          _contribute(-1.0, 1.0, 0.0, 1.0);
          _contribute(0.0, 1.0, -1.0, 1.0);
        } else {
          // closest == 12
          _contribute(0.0, 0.0, 1.0, 1.0);
          _contribute(-1.0, 0.0, 1.0, 1.0);
          _contribute(0.0, -1.0, 1.0, 1.0);
        }
      }

      _contribute(0.0, 0.0, 0.0, 0.0);
      _contribute(1.0, 0.0, 0.0, 0.0);
      _contribute(0.0, 1.0, 0.0, 0.0);
      _contribute(0.0, 0.0, 1.0, 0.0);
      _contribute(0.0, 0.0, 0.0, 1.0);
    } else if (inSum >= 3.0) {
      // We're inside the pentachoron (4-Simplex) at (1, 1, 1, 1)
      // Determine which two of (1, 1, 1, 0), (1, 1, 0, 1), (1, 0, 1, 1), (0, 1, 1, 1) are closest.
      int aPoint = 0x0E;
      int bPoint = 0x0D;
      double aScore = _ins.x;
      double bScore = _ins.y;
      if (aScore <= bScore && _ins.z < bScore) {
        bScore = _ins.z;
        bPoint = 0x0B;
      } else if (aScore > bScore && _ins.z < aScore) {
        aScore = _ins.z;
        aPoint = 0x0B;
      }
      if (aScore <= bScore && _ins.w < bScore) {
        bScore = _ins.w;
        bPoint = 0x07;
      } else if (aScore > bScore && _ins.w < aScore) {
        aScore = _ins.w;
        aPoint = 0x07;
      }

      // Now we determine the three lattice points not part of the pentachoron that may contribute.
      // This depends on the closest two pentachoron vertices, including (0, 0, 0, 0)
      final double uins = 4.0 - inSum;
      if (uins < aScore || uins < bScore) {
        // (1, 1, 1, 1) is one of the closest two pentachoron vertices.
        // Our other closest vertex is the closest out of a and b.
        final int closest = (bScore < aScore) ? bPoint : aPoint;
        if (closest == 7) {
          _contribute(2.0, 1.0, 1.0, 0.0);
          _contribute(1.0, 2.0, 1.0, 0.0);
          _contribute(1.0, 1.0, 2.0, 0.0);
        } else if (closest == 11) {
          _contribute(2.0, 1.0, 0.0, 1.0);
          _contribute(1.0, 2.0, 0.0, 1.0);
          _contribute(1.0, 1.0, 0.0, 2.0);
        } else if (closest == 13) {
          _contribute(2.0, 0.0, 1.0, 1.0);
          _contribute(1.0, 0.0, 2.0, 1.0);
          _contribute(1.0, 0.0, 1.0, 2.0);
        } else {
          // closest == 14
          _contribute(0.0, 2.0, 1.0, 1.0);
          _contribute(0.0, 1.0, 2.0, 1.0);
          _contribute(0.0, 1.0, 1.0, 2.0);
        }
      } else {
        // (1,1,1,1) is not one of the closest two pentachoron vertices.
        // Our three extra vertices are determined by the closest two.
        final int closest = aPoint & bPoint;
        if (closest == 3) {
          _contribute(1.0, 1.0, 0.0, 0.0);
          _contribute(2.0, 1.0, 0.0, 0.0);
          _contribute(1.0, 2.0, 0.0, 0.0);
        } else if (closest == 5) {
          _contribute(1.0, 0.0, 1.0, 0.0);
          _contribute(2.0, 0.0, 1.0, 0.0);
          _contribute(1.0, 0.0, 2.0, 0.0);
        } else if (closest == 6) {
          _contribute(0.0, 1.0, 1.0, 0.0);
          _contribute(0.0, 2.0, 1.0, 0.0);
          _contribute(0.0, 1.0, 2.0, 0.0);
        } else if (closest == 9) {
          _contribute(1.0, 0.0, 0.0, 1.0);
          _contribute(2.0, 0.0, 0.0, 1.0);
          _contribute(1.0, 0.0, 0.0, 2.0);
        } else if (closest == 10) {
          _contribute(0.0, 1.0, 0.0, 1.0);
          _contribute(0.0, 2.0, 0.0, 1.0);
          _contribute(0.0, 1.0, 0.0, 2.0);
        } else {
          // closest == 12
          _contribute(0.0, 0.0, 1.0, 1.0);
          _contribute(0.0, 0.0, 2.0, 1.0);
          _contribute(0.0, 0.0, 1.0, 2.0);
        }
      }

      _contribute(1.0, 1.0, 1.0, 0.0);
      _contribute(1.0, 1.0, 0.0, 1.0);
      _contribute(1.0, 0.0, 1.0, 1.0);
      _contribute(0.0, 1.0, 1.0, 1.0);
      _contribute(1.0, 1.0, 1.0, 1.0);
    } else if (inSum <= 2.0) {
      // We're inside the first dispentachoron (Rectified 4-Simplex)
      double aScore, bScore;
      int aPoint, bPoint;
      bool aIsBiggerSide = true;
      bool bIsBiggerSide = true;

      // Decide between (1, 1, 0, 0) and (0, 0, 1, 1)
      if (_ins.x + _ins.y > _ins.z + _ins.w) {
        aScore = _ins.x + _ins.y;
        aPoint = 0x03;
      } else {
        aScore = _ins.z + _ins.w;
        aPoint = 0x0C;
      }

      // Decide between (1, 0, 1, 0) and (0, 1, 0, 1)
      if (_ins.x + _ins.z > _ins.y + _ins.w) {
        bScore = _ins.x + _ins.z;
        bPoint = 0x05;
      } else {
        bScore = _ins.y + _ins.w;
        bPoint = 0x0A;
      }

      // Closer between (1, 0, 0, 1) and (0, 1, 1, 0) will replace the further of a and b, if closer.
      if (_ins.x + _ins.w > _ins.y + _ins.z) {
        double score = _ins.x + _ins.w;
        if (aScore >= bScore && score > bScore) {
          bScore = score;
          bPoint = 0x09;
        } else if (aScore < bScore && score > aScore) {
          aScore = score;
          aPoint = 0x09;
        }
      } else {
        double score = _ins.y + _ins.z;
        if (aScore >= bScore && score > bScore) {
          bScore = score;
          bPoint = 0x06;
        } else if (aScore < bScore && score > aScore) {
          aScore = score;
          aPoint = 0x06;
        }
      }

      // Decide if (1, 0, 0, 0) is closer.
      double p1 = 2.0 - inSum + _ins.x;
      if (aScore >= bScore && p1 > bScore) {
        bScore = p1;
        bPoint = 0x01;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p1 > aScore) {
        aScore = p1;
        aPoint = 0x01;
        aIsBiggerSide = false;
      }

      // Decide if (0, 1, 0, 0) is closer.
      double p2 = 2.0 - inSum + _ins.y;
      if (aScore >= bScore && p2 > bScore) {
        bScore = p2;
        bPoint = 0x02;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p2 > aScore) {
        aScore = p2;
        aPoint = 0x02;
        aIsBiggerSide = false;
      }

      // Decide if (0, 0, 1, 0) is closer.
      double p3 = 2.0 - inSum + _ins.z;
      if (aScore >= bScore && p3 > bScore) {
        bScore = p3;
        bPoint = 0x04;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p3 > aScore) {
        aScore = p3;
        aPoint = 0x04;
        aIsBiggerSide = false;
      }

      // Decide if (0, 0, 0, 1) is closer.
      double p4 = 2.0 - inSum + _ins.w;
      if (aScore >= bScore && p4 > bScore) {
        bScore = p4;
        bPoint = 0x08;
        bIsBiggerSide = false;
      } else if (aScore < bScore && p4 > aScore) {
        aScore = p4;
        aPoint = 0x08;
        aIsBiggerSide = false;
      }

      // Where each of the two closest points are determines how the extra three
      // vertices are calculated.
      if (aIsBiggerSide == bIsBiggerSide) {
        if (aIsBiggerSide) {
          // Both closest points on the bigger side
          int c1 = aPoint | bPoint;
          if (c1 == 7) {
            _contribute(1.0, 1.0, 1.0, 0.0);
            _contribute(1.0, 1.0, 1.0, -1.0);
          } else if (c1 == 11) {
            _contribute(1.0, 1.0, 0.0, 1.0);
            _contribute(1.0, 1.0, -1.0, 1.0);
          } else if (c1 == 13) {
            _contribute(1.0, 0.0, 1.0, 1.0);
            _contribute(1.0, -1.0, 1.0, 1.0);
          } else {
            // c1 == 14
            _contribute(0.0, 1.0, 1.0, 1.0);
            _contribute(-1.0, 1.0, 1.0, 1.0);
          }

          // One combination is a permutation of (0, 0, 0, 2) based on c2
          int c2 = aPoint & bPoint;
          if (c2 == 1)
            _contribute(2.0, 0.0, 0.0, 0.0);
          else if (c2 == 2)
            _contribute(0.0, 2.0, 0.0, 0.0);
          else if (c2 == 4)
            _contribute(0.0, 0.0, 2.0, 0.0);
          else // c2 == 8
            _contribute(0.0, 0.0, 0.0, 2.0);
        } else {
          // Both closest points on the smaller side
          // One of the two extra points is (0, 0, 0, 0)
          _contribute(0.0, 0.0, 0.0, 0.0);

          // Other two points are based on the omitted axes.
          final int closest = aPoint | bPoint;
          if (closest == 3) {
            _contribute(1.0, 1.0, -1.0, 0.0);
            _contribute(1.0, 1.0, 0.0, -1.0);
          } else if (closest == 5) {
            _contribute(1.0, -1.0, 1.0, 0.0);
            _contribute(1.0, 0.0, 1.0, -1.0);
          } else if (closest == 6) {
            _contribute(-1.0, 1.0, 1.0, 0.0);
            _contribute(0.0, 1.0, 1.0, -1.0);
          } else if (closest == 9) {
            _contribute(1.0, -1.0, 0.0, 1.0);
            _contribute(1.0, 0.0, -1.0, 1.0);
          } else if (closest == 10) {
            _contribute(-1.0, 1.0, 0.0, 1.0);
            _contribute(0.0, 1.0, -1.0, 1.0);
          } else {
            // closest == 12
            _contribute(-1.0, 0.0, 1.0, 1.0);
            _contribute(0.0, -1.0, 1.0, 1.0);
          }
        }
      } else {
        // One point on each "side"
        int c1, c2;
        if (aIsBiggerSide) {
          c1 = aPoint;
          c2 = bPoint;
        } else {
          c1 = bPoint;
          c2 = aPoint;
        }

        // Two contributions are the bigger-sided point with each 0 replaced with -1.
        if (c1 == 3) {
          _contribute(1.0, 1.0, -1.0, 0.0);
          _contribute(1.0, 1.0, 0.0, -1.0);
        } else if (c1 == 5) {
          _contribute(1.0, -1.0, 1.0, 0.0);
          _contribute(1.0, 0.0, 1.0, -1.0);
        } else if (c1 == 6) {
          _contribute(-1.0, 1.0, 1.0, 0.0);
          _contribute(0.0, 1.0, 1.0, -1.0);
        } else if (c1 == 9) {
          _contribute(1.0, -1.0, 0.0, 1.0);
          _contribute(1.0, 0.0, -1.0, 1.0);
        } else if (c1 == 10) {
          _contribute(-1.0, 1.0, 0.0, 1.0);
          _contribute(0.0, 1.0, -1.0, 1.0);
        } else if (c1 == 12) {
          _contribute(-1.0, 0.0, 1.0, 1.0);
          _contribute(0.0, -1.0, 1.0, 1.0);
        }

        // One contribution is a permutation of (0, 0, 0, 2) based on the smaller-sided point
        if (c2 == 1)
          _contribute(2.0, 0.0, 0.0, 0.0);
        else if (c2 == 2)
          _contribute(0.0, 2.0, 0.0, 0.0);
        else if (c2 == 4)
          _contribute(0.0, 0.0, 2.0, 0.0);
        else // c2 == 8
          _contribute(0.0, 0.0, 0.0, 2.0);
      }

      _contribute(1.0, 0.0, 0.0, 0.0);
      _contribute(0.0, 1.0, 0.0, 0.0);
      _contribute(0.0, 0.0, 1.0, 0.0);
      _contribute(0.0, 0.0, 0.0, 1.0);
      _contribute(1.0, 1.0, 0.0, 0.0);
      _contribute(1.0, 0.0, 1.0, 0.0);
      _contribute(1.0, 0.0, 0.0, 1.0);
      _contribute(0.0, 1.0, 1.0, 0.0);
      _contribute(0.0, 1.0, 0.0, 1.0);
      _contribute(0.0, 0.0, 1.0, 1.0);
    } else {
      // We're inside the second dispentachoron (Rectified 4-Simplex)
      double aScore, bScore;
      int aPoint, bPoint;
      bool aIsBiggerSide = true;
      bool bIsBiggerSide = true;

      // Decide between (0,0,1,1) and (1,1,0,0)
      if (_ins.x + _ins.y < _ins.z + _ins.w) {
        aScore = _ins.x + _ins.y;
        aPoint = 0x0C;
      } else {
        aScore = _ins.z + _ins.w;
        aPoint = 0x03;
      }

      // Decide between (0,1,0,1) and (1,0,1,0)
      if (_ins.x + _ins.z < _ins.y + _ins.w) {
        bScore = _ins.x + _ins.z;
        bPoint = 0x0A;
      } else {
        bScore = _ins.y + _ins.w;
        bPoint = 0x05;
      }

      // Closer between (0,1,1,0) and (1,0,0,1) will replace the further of a and b,
      // if closer.
      if (_ins.x + _ins.w < _ins.y + _ins.z) {
        double score = _ins.x + _ins.w;
        if (aScore <= bScore && score < bScore) {
          bScore = score;
          bPoint = 0x06;
        } else if (aScore > bScore && score < aScore) {
          aScore = score;
          aPoint = 0x06;
        }
      } else {
        double score = _ins.y + _ins.z;
        if (aScore <= bScore && score < bScore) {
          bScore = score;
          bPoint = 0x09;
        } else if (aScore > bScore && score < aScore) {
          aScore = score;
          aPoint = 0x09;
        }
      }

      // Decide if (0, 1, 1, 1) is closer.
      final double p1 = 3.0 - inSum + _ins.x;
      if (aScore <= bScore && p1 < bScore) {
        bScore = p1;
        bPoint = 0x0E;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p1 < aScore) {
        aScore = p1;
        aPoint = 0x0E;
        aIsBiggerSide = false;
      }

      // Decide if (1, 0, 1, 1) is closer.
      final double p2 = 3.0 - inSum + _ins.y;
      if (aScore <= bScore && p2 < bScore) {
        bScore = p2;
        bPoint = 0x0D;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p2 < aScore) {
        aScore = p2;
        aPoint = 0x0D;
        aIsBiggerSide = false;
      }

      // Decide if (1, 1, 0, 1) is closer.
      final double p3 = 3.0 - inSum + _ins.z;
      if (aScore <= bScore && p3 < bScore) {
        bScore = p3;
        bPoint = 0x0B;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p3 < aScore) {
        aScore = p3;
        aPoint = 0x0B;
        aIsBiggerSide = false;
      }

      // Decide if (1, 1, 1, 0) is closer.
      final double p4 = 3.0 - inSum + _ins.w;
      if (aScore <= bScore && p4 < bScore) {
        bScore = p4;
        bPoint = 0x07;
        bIsBiggerSide = false;
      } else if (aScore > bScore && p4 < aScore) {
        aScore = p4;
        aPoint = 0x07;
        aIsBiggerSide = false;
      }

      // Where each of the two closest points are determines how the extra three
      // vertices are calculated.
      if (aIsBiggerSide == bIsBiggerSide) {
        if (aIsBiggerSide) {
          // Both closest points on the bigger side

          // Two contributions are permutations of (0, 0, 0, 1) and (0, 0, 0, 2) based on c1
          int c1 = aPoint & bPoint;
          if (c1 == 1) {
            _contribute(1.0, 0.0, 0.0, 0.0);
            _contribute(2.0, 0.0, 0.0, 0.0);
          } else if (c1 == 2) {
            _contribute(0.0, 1.0, 0.0, 0.0);
            _contribute(0.0, 2.0, 0.0, 0.0);
          } else if (c1 == 4) {
            _contribute(0.0, 0.0, 1.0, 0.0);
            _contribute(0.0, 0.0, 2.0, 0.0);
          } else {
            // c2 == 8
            _contribute(0.0, 0.0, 0.0, 1.0);
            _contribute(0.0, 0.0, 0.0, 2.0);
          }

          // One contribution is a permutation of (1, 1, 1, -1) based on c2
          int c2 = aPoint | bPoint;

          if ((c2 & 0x01) == 0) {
            _contribute(-1.0, 1.0, 1.0, 1.0);
          } else if ((c2 & 0x02) == 0) {
            _contribute(1.0, -1.0, 1.0, 1.0);
          } else if ((c2 & 0x04) == 0) {
            _contribute(1.0, 1.0, -1.0, 1.0);
          } else {
            // (c2 & 0x08) == 0
            _contribute(1.0, 1.0, 1.0, -1.0);
          }
        } else {
          // Both closest points on the smaller side
          // One of the two extra points is (1, 1, 1, 1)
          _contribute(1.0, 1.0, 1.0, 1.0);

          // Other two points are based on the shared axes.
          final int closest = aPoint & bPoint;
          if (closest == 3) {
            _contribute(2.0, 1.0, 0.0, 0.0);
            _contribute(1.0, 2.0, 0.0, 0.0);
          } else if (closest == 5) {
            _contribute(2.0, 0.0, 1.0, 0.0);
            _contribute(1.0, 0.0, 2.0, 0.0);
          } else if (closest == 6) {
            _contribute(0.0, 2.0, 1.0, 0.0);
            _contribute(0.0, 1.0, 2.0, 0.0);
          } else if (closest == 9) {
            _contribute(2.0, 0.0, 0.0, 1.0);
            _contribute(1.0, 0.0, 0.0, 2.0);
          } else if (closest == 10) {
            _contribute(0.0, 2.0, 0.0, 1.0);
            _contribute(0.0, 1.0, 0.0, 2.0);
          } else {
            // closest == 12
            _contribute(0.0, 0.0, 2.0, 1.0);
            _contribute(0.0, 0.0, 1.0, 2.0);
          }
        }
      } else {
        // One point on each "side"
        int c1, c2;
        if (aIsBiggerSide) {
          c1 = aPoint;
          c2 = bPoint;
        } else {
          c1 = bPoint;
          c2 = aPoint;
        }

        // Two contributions are the bigger-sided point with each 1 replaced with 2.
        if (c1 == 3) {
          _contribute(2.0, 1.0, 0.0, 0.0);
          _contribute(1.0, 2.0, 0.0, 0.0);
        } else if (c1 == 5) {
          _contribute(2.0, 0.0, 1.0, 0.0);
          _contribute(1.0, 0.0, 2.0, 0.0);
        } else if (c1 == 6) {
          _contribute(0.0, 2.0, 1.0, 0.0);
          _contribute(0.0, 1.0, 2.0, 0.0);
        } else if (c1 == 9) {
          _contribute(2.0, 0.0, 0.0, 1.0);
          _contribute(1.0, 0.0, 0.0, 2.0);
        } else if (c1 == 10) {
          _contribute(0.0, 2.0, 0.0, 1.0);
          _contribute(0.0, 1.0, 0.0, 2.0);
        } else if (c1 == 12) {
          _contribute(0.0, 0.0, 2.0, 1.0);
          _contribute(0.0, 0.0, 1.0, 2.0);
        }

        // One contribution is a permutation of (1, 1, 1, -1) based on the smaller-sided point
        if (c2 == 7)
          _contribute(1.0, 1.0, 1.0, -1.0);
        else if (c2 == 11)
          _contribute(1.0, 1.0, -1.0, 1.0);
        else if (c2 == 13)
          _contribute(1.0, -1.0, 1.0, 1.0);
        else // c2 == 14
          _contribute(-1.0, 1.0, 1.0, 1.0);
      }

      _contribute(1.0, 1.0, 1.0, 0.0);
      _contribute(1.0, 1.0, 0.0, 1.0);
      _contribute(1.0, 0.0, 1.0, 1.0);
      _contribute(0.0, 1.0, 1.0, 1.0);
      _contribute(1.0, 1.0, 0.0, 0.0);
      _contribute(1.0, 0.0, 1.0, 0.0);
      _contribute(1.0, 0.0, 0.0, 1.0);
      _contribute(0.0, 1.0, 1.0, 0.0);
      _contribute(0.0, 1.0, 0.0, 1.0);
      _contribute(0.0, 0.0, 1.0, 1.0);
    }

    return _value / _norm;
  }
}
