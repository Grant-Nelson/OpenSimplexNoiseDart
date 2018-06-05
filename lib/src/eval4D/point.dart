part of eval4D;

/// An immutable 4D point for working with the mathmatics for eval 4D noise.
class Point {
  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// The z component of the point.
  final double z;

  /// The w component of the point.
  final double w;

  /// Contructs a new 4D point.
  Point(this.x, this.y, this.z, this.w);

  /// Creates a point where each component is the floor value.
  Point get floor => new Point(x.floorToDouble(), y.floorToDouble(), z.floorToDouble(), w.floorToDouble());

  /// Gets the sum of the components.
  double get sum => x + y + z + w;

  /// Gets the attenuation factor of the point assuming the point is offset from an origin.
  double get attn => 2.0 - (x * x) - (y * y) - (z * z) - (w * w);

  /// Creates a point where each component is the sum of the given two points' components.
  Point operator +(Point other) => new Point(x + other.x, y + other.y, z + other.z, w + other.w);

  /// Creates a point where each component is the difference of the given two points' components.
  Point operator -(Point other) => new Point(x - other.x, y - other.y, z - other.z, w - other.w);

  /// Creates a point which is the scaled point of the given point's components and scalar.
  Point operator *(double scalar) => new Point(x * scalar, y * scalar, z * scalar, w * scalar);

  /// Gets a human readable string for the point.
  @override
  String toString() => "$x, $y, $z, $w";
}
