part of eval3D;

/// An immutable 3D point for working with the mathmatics for eval 3D noise.
class Point {
  /// The x component of the point.
  final double x;
  
  /// The y component of the point.
  final double y;
  
  /// The z component of the point.
  final double z;

  /// Contructs a new 3D point.
  Point(this.x, this.y, this.z);

  /// Creates a point where each component is the floor value.
  Point get floor => new Point(x.floorToDouble(), y.floorToDouble(), z.floorToDouble());

  /// Gets the sum of the components.
  double get sum => x + y + z;

  /// Gets the attenuation factor of the point assuming the point is offset from an origin.
  double get attn => 2.0 - (x * x) - (y * y) - (z * z);

  /// Creates a point where each component is the sum of the given two points' components.
  Point operator +(Point other) => new Point(x + other.x, y + other.y, z + other.z);

  /// Creates a point where each component is the difference of the given two points' components.
  Point operator -(Point other) => new Point(x - other.x, y - other.y, z - other.z);

  /// Creates a point which is the scaled point of the given point's components and scalar.
  Point operator *(double scalar) => new Point(x * scalar, y * scalar, z * scalar);

  /// Gets a human readable string for the point.
  @override
  String toString() => "$x, $y, $z";
}
