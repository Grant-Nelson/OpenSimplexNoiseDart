library eval3D;

part 'extra.dart';
part 'point.dart';

// Open Simplex for 3D Noise
class Eval {
  // (1 / sqrt(3 + 1) - 1) / 3
  static const double _stretch = -1.0 / 6.0;

  // (sqrt(3 + 1) - 1) / 3
  static const double _squish = 1.0 / 3.0;

  // 2 * (sqrt(3 + 1) - 1) / 3
  static const double _squish2 = 2.0 / 3.0;

  // 3 * (sqrt(3 + 1) - 1) / 3
  static const double _squish3 = 1.0;

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

  List<int> _perm;
  List<int> _permGradIndex;

  Eval(this._perm) {
    _permGradIndex = new List<int>(256);
    for (int i = 0; i < 256; i++) {
      //Since 3D has 24 gradients, simple bitmask won't work, so precompute modulo array.
      _permGradIndex[i] = _perm[i] % (_gradients.length ~/ 3);
    }
  }

  double _extrapolate(Point grid, Point delta) {
    int index = _permGradIndex[(_perm[(_perm[grid.x.toInt() & 0xFF] + grid.y.toInt()) & 0xFF] + grid.z.toInt()) & 0xFF];
    Point pnt = _gradients[index];
    return pnt.x * delta.x + pnt.y * delta.y + pnt.z * delta.z;
  }

  double _attnValue(Point grid, Point delta) {
    double attn = delta.attn;
    if (attn > 0.0) {
      double attn2 = attn * attn;
      return attn2 * attn2 * _extrapolate(grid, delta);
    }
    return 0.0;
  }

  // Compute 3D OpenSimplex Noise.
  double eval(Point input) {
    // Place input coordinates on simplectic honeycomb.
    double stretchOffset = input.sum * _stretch;
    Point stretch = input.add(stretchOffset, stretchOffset, stretchOffset); // TODO: xs, ys, zs

    // Floor to get simplectic honeycomb coordinates of rhombohedron (stretched cube) super-cell origin.
    Point grid = stretch.floor; // TODO: xsb, ysb, zsb

    // Skew out to get actual coordinates of rhombohedron origin.
    double squishOffset = grid.sum * _squish;
    Point squish = grid.add(squishOffset, squishOffset, squishOffset); // TODO: xb, yb, zb

    // Compute simplectic honeycomb coordinates relative to rhombohedral origin.
    Point ins = squish - grid; // TODO: xins, yins, zins

    // Sum those together to get a value that determines the region.
    double inSum = ins.sum;

    // Positions relative to origin point.
    Point origin = input - squish;

    Extra extra = new Extra(grid, origin);
    double value = 0.0;
    if (inSum <= 1) {
      // Inside the tetrahedron (3-Simplex) at (0, 0, 0)

      // Determine which two of (0, 0, 1), (0, 1, 0), (1, 0, 0) are closest.
      int aPoint = 0x01;
      double aScore = ins.x;
      int bPoint = 0x02;
      double bScore = ins.y;
      if (aScore >= bScore && ins.z > bScore) {
        bScore = ins.z;
        bPoint = 0x04;
      } else if (aScore < bScore && ins.z > aScore) {
        aScore = ins.z;
        aPoint = 0x04;
      }

      // Now we determine the two lattice points not part of the tetrahedron that may contribute.
      // This depends on the closest two tetrahedral vertices, including (0, 0, 0)
      double wins = 1 - inSum;
      if (wins > aScore || wins > bScore) {
        // (0, 0, 0) is one of the closest two tetrahedral vertices.
        // Our other closest vertex is the closest out of a and b.
        int closest = (bScore > aScore) ? bPoint : aPoint;

        if ((closest & 0x01) == 0) {
          extra.addX(-1.0, 0.0, 1.0, 0.0);
        } else {
          extra.addX(1.0, 1.0, -1.0, -1.0);
        }

        if ((closest & 0x02) == 0) {
          if ((closest & 0x01) == 0) {
            extra.addY(0.0, -1.0, 0.0, 1.0);
          } else {
            extra.addY(-1.0, 0.0, 1.0, 0.0);
          }
        } else {
          extra.addY(1.0, 1.0, -1.0, -1.0);
        }

        if ((closest & 0x04) == 0) {
          extra.addZ(0.0, -1.0, 0.0, 1.0);
        } else {
          extra.addZ(1.0, 1.0, -1.0, -1.0);
        }
      } else {
        // (0, 0, 0) is not one of the closest two tetrahedral vertices.
        // Our two extra vertices are determined by the closest two.
        int closest = aPoint | bPoint;

        if ((closest & 0x01) == 0) {
          extra.addX(0.0, -1.0, -_squish2, 1.0 - _squish);
        } else {
          extra.addX(1.0, 1.0, -1.0 - _squish2, -1.0 - _squish);
        }

        if ((closest & 0x02) == 0) {
          extra.addY(0.0, -1.0, -_squish2, 1.0 - _squish);
        } else {
          extra.addY(1.0, 1.0, -1.0 - _squish2, -1.0 - _squish);
        }

        if ((closest & 0x04) == 0) {
          extra.addZ(0.0, -1.0, -_squish2, 1.0 - _squish);
        } else {
          extra.addZ(1.0, 1.0, -1.0 - _squish2, -1.0 - _squish);
        }
      }

      // Contribution (0, 0, 0)
      value += _attnValue(grid, origin);

      // Contribution (1, 0, 0)
      value += _attnValue(grid.add(1.0, 0.0, 0.0), origin.add(-1.0 - _squish, -_squish, -_squish));

      // Contribution (0, 1, 0)
      value += _attnValue(grid.add(0.0, 1.0, 0.0), origin.add(-_squish, -1.0 - _squish, 0.0));

      // Contribution (0, 0, 1)
      value += _attnValue(grid.add(0.0, 0.0, 1.0), origin.add(0.0, 0.0, -1.0 - _squish));
    } else if (inSum >= 2) {
      // Inside the tetrahedron (3-Simplex) at (1, 1, 1)

      // Determine which two tetrahedral vertices are the closest, out of (1, 1, 0), (1, 0, 1), (0, 1, 1) but not (1, 1, 1).
      int aPoint = 0x06;
      double aScore = ins.x;
      int bPoint = 0x05;
      double bScore = ins.y;
      if (aScore <= bScore && ins.z < bScore) {
        bScore = ins.z;
        bPoint = 0x03;
      } else if (aScore > bScore && ins.z < aScore) {
        aScore = ins.z;
        aPoint = 0x03;
      }

      // Now we determine the two lattice points not part of the tetrahedron that may contribute.
      // This depends on the closest two tetrahedral vertices, including (1, 1, 1)
      double wins = 3 - inSum;
      if (wins < aScore || wins < bScore) {
        // (1, 1, 1) is one of the closest two tetrahedral vertices.
        // Our other closest vertex is the closest out of a and b.
        int closest = (bScore < aScore ? bPoint : aPoint);

        if ((closest & 0x01) != 0) {
          extra.addX(2.0, 1.0, -2.0 - _squish2, -1.0 - _squish);
        } else {
          extra.addX(0.0, 0.0, -_squish2, -_squish);
        }

        if ((closest & 0x02) != 0) {
          if ((closest & 0x01) != 0) {
            extra.addY(1.0, 0.0, -1.0 - _squish3, -_squish3);
          } else {
            extra.addY(0.0, 1.0, -_squish3, -1.0 - _squish3);
          }
        } else {
          extra.addY(0.0, 0.0, -_squish3, -_squish3);
        }

        if ((closest & 0x04) != 0) {
          extra.addZ(1.0, 2.0, -1.0 - _squish3, -2.0 - _squish3);
        } else {
          extra.addZ(0.0, 0.0, -_squish3, -_squish3);
        }
      } else {
        // (1, 1, 1) is not one of the closest two tetrahedral vertices.
        // Our two extra vertices are determined by the closest two.
        int closest = aPoint & bPoint;

        if ((closest & 0x01) != 0) {
          extra.addX(1.0, 2.0, -1.0 - _squish, -2.0 - _squish2);
        } else {
          extra.addX(0.0, 0.0, -_squish, -_squish2);
        }

        if ((closest & 0x02) != 0) {
          extra.addY(1.0, 2.0, -1.0 - _squish, -2.0 - _squish2);
        } else {
          extra.addY(0.0, 0.0, -_squish, -_squish2);
        }

        if ((closest & 0x04) != 0) {
          extra.addZ(1.0, 2.0, -1.0 - _squish, -2.0 - _squish2);
        } else {
          extra.addZ(0.0, 0.0, -_squish, -_squish2);
        }
      }

      // Contribution (1, 1, 0)
      value += _attnValue(grid.add(1.0, 1.0, 0.0), origin.add(-1.0 - _squish2, -1.0 - _squish2, -_squish2));

      // Contribution (1, 0, 1)
      value += _attnValue(grid.add(1.0, 0.0, 1.0), origin.add(-1.0 - _squish2, -_squish2, -1.0 - _squish2));

      // Contribution (0, 1, 1)
      value += _attnValue(grid.add(0.0, 1.0, 1.0), origin.add(-_squish2, -1.0 - _squish2, -1.0 - _squish2));

      // Contribution (1, 1, 1)
      value += _attnValue(grid.add(1.0, 1.0, 1.0), origin.add(-1.0 - _squish3, -1.0 - _squish3, -1.0 - _squish3));
    } else {
      // Inside the octahedron (Rectified 3-Simplex) in between.
      double aScore;
      int aPoint;
      bool aIsFurtherSide;
      double bScore;
      int bPoint;
      bool bIsFurtherSide;

      // Decide between point (0, 0, 1) and (1, 1, 0) as closest
      double p1 = ins.x + ins.y;
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
      double p2 = ins.x + ins.z;
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
      double p3 = ins.y + ins.z;
      if (p3 > 1.0) {
        double score = p3 - 1.0;
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
        double score = 1.0 - p3;
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
          extra.delta0.add(-1.0 - _squish3, -1.0 - _squish3, -1.0 - _squish3);
          extra.grid0.add(1.0, 1.0, 1.0);

          // Other extra point is based on the shared axis.
          int closest = aPoint & bPoint;
          if ((closest & 0x01) != 0) {
            extra.delta1.add(-2.0 - _squish2, -_squish2, -_squish2);
            extra.grid1.add(2.0, 0.0, 0.0);
          } else if ((closest & 0x02) != 0) {
            extra.delta1.add(-_squish2, -2.0 - _squish2, -_squish2);
            extra.grid1.add(0.0, 2.0, 0.0);
          } else {
            extra.delta1.add(-_squish2, -_squish2, -2.0 - _squish2);
            extra.grid1.add(0.0, 0.0, 2.0);
          }
        } else {
          // Both closest points on (0, 0, 0) side

          // One of the two extra points is (0, 0, 0)
          extra.delta0.add(0.0, 0.0, 0.0);
          extra.grid0.add(0.0, 0.0, 0.0);

          // Other extra point is based on the omitted axis.
          int closest = aPoint | bPoint;
          if ((closest & 0x01) == 0) {
            extra.delta1.add(1.0 - _squish, -1.0 - _squish, -1.0 - _squish);
            extra.grid1.add(-1.0, 1.0, 1.0);
          } else if ((closest & 0x02) == 0) {
            extra.delta1.add(-1.0 - _squish, 1.0 - _squish, -1.0 - _squish);
            extra.grid1.add(1.0, -1.0, 1.0);
          } else {
            extra.delta1.add(-1.0 - _squish, -1.0 - _squish, 1.0 - _squish);
            extra.grid1.add(1.0, 1.0, -1.0);
          }
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
        if ((c1 & 0x01) == 0) {
          extra.delta0.add(1.0 - _squish, -1.0 - _squish, -1.0 - _squish);
          extra.grid0.add(-1.0, 1.0, 1.0);
        } else if ((c1 & 0x02) == 0) {
          extra.delta0.add(-1.0 - _squish, 1.0 - _squish, -1.0 - _squish);
          extra.grid0.add(1.0, -1.0, 1.0);
        } else {
          extra.delta0.add(-1.0 - _squish, -1.0 - _squish, 1.0 - _squish);
          extra.grid0.add(1.0, 1.0, -1.0);
        }

        // One contribution is a permutation of (0, 0, 2)
        if ((c2 & 0x01) != 0) {
          extra.delta1.add(-2.0 - _squish2, -_squish2, -_squish2);
          extra.grid1.add(2.0, 0.0, 0.0);
        } else if ((c2 & 0x02) != 0) {
          extra.delta1.add(-_squish2, -2.0 - _squish2, -_squish2);
          extra.grid1.add(0.0, 2.0, 0.0);
        } else {
          extra.delta1.add(-_squish2, -_squish2, -2.0 - _squish2);
          extra.grid1.add(0.0, 0.0, 2.0);
        }
      }

      // Contribution (1, 0, 0)
      value += _attnValue(grid.add(1.0, 0.0, 0.0), origin.add(-1.0 - _squish, -_squish, -_squish));

      // Contribution (0, 1, 0)
      value += _attnValue(grid.add(0.0, 1.0, 0.0), origin.add(-_squish, -1.0 - _squish, -_squish));

      // Contribution (0, 0, 1)
      value += _attnValue(grid.add(0.0, 0.0, 1.0), origin.add(-_squish, -_squish, -1.0 - _squish));

      // Contribution (1, 1, 0)
      value += _attnValue(grid.add(1.0, 1.0, 0.0), origin.add(-1.0 - _squish, -1.0 - _squish, -_squish));

      // Contribution (1, 0, 1)
      value += _attnValue(grid.add(1.0, 0.0, 1.0), origin.add(-1.0 - _squish, -_squish, -1.0 - _squish));

      // Contribution (0, 1, 1)
      value += _attnValue(grid.add(0.0, 1.0, 1.0), origin.add(-_squish, -1.0 - _squish, -1.0 - _squish));
    }

    // First extra vertex
    value += _attnValue(extra.grid0, extra.delta0);

    // Second extra vertex
    value += _attnValue(extra.grid1, extra.delta1);

    return value / _norm;
  }
}
