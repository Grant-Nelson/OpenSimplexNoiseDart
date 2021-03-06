library eval2D;

part 'point.dart';

/// Open Simplex for 2D Noise
class Eval {
  /// (1 / sqrt(2 + 1) - 1) / 2
  static const double _stretch = -0.211324865405187;

  /// (sqrt(2 + 1) - 1) / 2
  static const double _squish = 0.366025403784439;

  /// Normalizing scalar to the result
  static const double _norm = 47.0;

  /// Gradients for 2D. They approximate the directions to the
  /// vertices of an octagon from the center.
  static List<Point> _gradients = [
    new Point( 5.0,  2.0),
    new Point( 2.0,  5.0),
    new Point(-5.0,  2.0),
    new Point(-2.0,  5.0),
    new Point( 5.0, -2.0),
    new Point( 2.0, -5.0),
    new Point(-5.0, -2.0),
    new Point(-2.0, -5.0)];

  /// Deltas for 2D contributions to the value.
  static List<Point> _deltas = [
    new Point( 1.0,  0.0),
    new Point( 0.0,  1.0),
    new Point( 1.0, -1.0),
    new Point(-1.0,  1.0),
    new Point( 1.0,  1.0),
    new Point( 0.0,  0.0),
    new Point( 2.0,  0.0),
    new Point( 0.0,  2.0)];

  /// Predefined point with each componenent equal to the [_stretch] value.
  static final Point _pntStretch = new Point(_stretch, _stretch);
  
  /// Predefined point with each componenent equal to the [_squish] value.
  static final Point _pntSquish = new Point(_squish, _squish);

  /// Noise permutation set.
  final List<int> _perm;

  /// The grid coordinates of rhombus (stretched square) super-cell origin.
  final Point _grid;

  /// The position relative to the origin point.
  final Point _origin;

  /// The grid coordinates relative to rhombus origin.
  final Point _ins;

  /// The accumulator of the noise value.
  double _value = 0.0;

  /// Contructs a new evaluator for 2D noise.
  Eval._(this._perm, this._grid, this._origin, this._ins);

  /// Creates a new evaluator for 2D noise and calcuate the initial values.
  factory Eval(List<int> perm, Point input) {
    // stretch input coordinates onto grid.
    final Point stretch = input + _pntStretch * input.sum;
    final Point grid = stretch.floor;

    // Skew out to get actual coordinates of rhombus origin.
    final Point squashed = grid + _pntSquish * grid.sum;
    final Point ins = stretch - grid;
    final Point origin = input - squashed;
    return new Eval._(perm, grid, origin, ins);
  }

  /// Extrapolates the offset grid point to the permutation of noise.
  double _extrapolate(Point grid, Point delta) {
    final int index = (grid.gradientIndex(_perm) & 0x0E) >> 1;
    final Point pnt = _gradients[index];
    return pnt.dot(delta);
  }

  /// Contributes a point into the noise value if the attenuation is positive.
  void _contribute(int index) {
    final Point delta = _deltas[index];
    final Point shifted = _origin - delta - _pntSquish * delta.sum;
    final double attn = shifted.attn;
    if (attn > 0.0) {
      final double attn2 = attn * attn;
      _value += attn2 * attn2 * _extrapolate(_grid + delta, shifted);
    }
  }

  /// Compute 2D OpenSimplex noise value.
  double eval() {
    _contribute(0);
    _contribute(1);

    // Sum those together to get a value that determines the region.
    final double inSum = _ins.sum;
    if (inSum <= 1.0) {
      // Inside the triangle (2-Simplex) at (0, 0)
      final double zins = 1.0 - inSum;
      if (zins > _ins.x || zins > _ins.y) {
        // (0, 0) is one of the closest two triangular vertices
        if (_ins.x > _ins.y)
          _contribute(2);
        else
          _contribute(3);
      } else {
        // (1, 0) and (0, 1) are the closest two vertices.
        _contribute(4);
      }

      _contribute(5);
    } else {
      // Inside the triangle (2-Simplex) at (1, 1)
      final double zins = 2.0 - inSum;
      if (zins < _ins.x || zins < _ins.y) {
        // (0, 0) is one of the closest two triangular vertices
        if (_ins.x > _ins.y)
          _contribute(6);
        else
          _contribute(7);
      } else {
        // (1, 0) and (0, 1) are the closest two vertices.
        _contribute(5);
      }

      _contribute(4);
    }

    return _value / _norm;
  }
}
