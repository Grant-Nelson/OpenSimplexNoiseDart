library eval2D;

part 'extra.dart';
part 'point.dart';

// Open Simplex for 2D Noise
class Eval {
  // (1 / sqrt(2 + 1) - 1) / 2
  static const double _stretch = -0.211324865405187;

  // (sqrt(2 + 1) - 1) / 2
  static const double _squish = 0.366025403784439;

  // sqrt(2 + 1) - 1
  static const double _squish2 = 0.732050807568878;

  // Normalizing scalar to the result
  static const double _norm = 47.0;

  // Gradients for 2D. They approximate the directions to the
  // vertices of an octagon from the center.
  static List<Point> _gradients = [
    new Point(5.0, 2.0),
    new Point(2.0, 5.0),
    new Point(-5.0, 2.0),
    new Point(-2.0, 5.0),
    new Point(5.0, -2.0),
    new Point(2.0, -5.0),
    new Point(-5.0, -2.0),
    new Point(-2.0, -5.0)
  ];

  List<int> _perm;

  Eval(this._perm);

  double _extrapolate(Point grid, Point delta) {
    int index = (_perm[(_perm[grid.x.toInt() & 0xFF] + grid.y.toInt()) & 0xFF] & 0x0E) >> 1;
    Point pnt = _gradients[index];
    return pnt.x * delta.x + pnt.y * delta.y;
  }

  double _attnValue(Point grid, Point delta) {
    double attn = delta.attn;
    if (attn > 0.0) {
      double attn2 = attn * attn;
      return attn2 * attn2 * _extrapolate(grid, delta);
    }
    return 0.0;
  }

  // Compute 2D OpenSimplex Noise.
  double eval(Point input) {
    // Place input coordinates onto grid.
    double stretchOffset = input.sum * _stretch;
    Point stretched = input.add(stretchOffset, stretchOffset);

    // Floor to get grid coordinates of rhombus (stretched square) super-cell origin.
    Point grid = stretched.floor;

    // Skew out to get actual coordinates of rhombus origin.
    double squishOffset = grid.sum * _squish;
    Point squashed = grid.add(squishOffset, squishOffset);

    // Compute grid coordinates relative to rhombus origin.
    Point ins = stretched - grid;

    // Sum those together to get a value that determines the region.
    double inSum = ins.sum;

    // Positions relative to origin point.
    Point origin = input - squashed;

    double value = 0.0;

    // Contribution (1, 0)
    value += _attnValue(grid.add(1.0, 0.0), origin.add(-1.0 - _squish, -_squish));

    // Contribution (0, 1)
    value += _attnValue(grid.add(0.0, 1.0), origin.add(-_squish, -1.0 - _squish));

    Extra extra = new Extra(grid, origin);
    if (inSum <= 1.0) {
      // Inside the triangle (2-Simplex) at (0, 0)
      double zins = 1.0 - inSum;
      if (zins > ins.x || zins > ins.y) {
        // (0,0) is one of the closest two triangular vertices
        if (ins.x > ins.y) {
          extra.add(1.0, -1.0, -1.0, 1.0);
        } else {
          extra.add(-1.0, 1.0, 1.0, -1.0);
        }
      } else {
        // (1,0) and (0,1) are the closest two vertices.
        extra.add(1.0, 1.0, -1.0 - _squish2, -1.0 - _squish2);
      }

      // Contribution (0,0)
      value += _attnValue(grid, origin);
    } else {
      // Inside the triangle (2-Simplex) at (1,1)
      double zins = 2 - inSum;
      if (zins < ins.x || zins < ins.y) {
        // (0,0) is one of the closest two triangular vertices
        if (ins.x > ins.y) {
          extra.add(2.0, 0.0, -2.0 - _squish2, -_squish2);
        } else {
          extra.add(0.0, 2.0, -_squish2, -2.0 - _squish2);
        }
      } else {
        // (1, 0) and (0, 1) are the closest two vertices.
        extra.add(0.0, 0.0, 0.0, 0.0);
      }

      // Contribution (1,1)
      value += _attnValue(grid.add(1.0, 1.0), origin.add(-1.0 - _squish2, -1.0 - _squish2));
    }

    // Extra Vertex
    value += _attnValue(extra.grid, extra.delta);

    return value / _norm;
  }
}
