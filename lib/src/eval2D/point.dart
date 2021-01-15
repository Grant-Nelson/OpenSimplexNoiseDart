part of eval2D;

/// An immutable 2D point for working with the mathmatics for eval 2D noise.
class Point {
  /// The x component of the point.
  final double x;

  /// The y component of the point.
  final double y;

  /// Contructs a new 2D point.
  Point(this.x, this.y);

  /// Creates a point where each component is the floor value.
  Point get floor => new Point(x.floorToDouble(), y.floorToDouble());

  /// Gets the sum of the components.
  double get sum => x + y;

  /// Gets the attenuation factor of the point assuming the point is offset from an origin.
  double get attn => 2.0 - (x * x) - (y * y);

  /// Gets the dot product between these two points.
  double dot(Point other) => x * other.x + y * other.y;

  /// Determines the gradient index this point represents using the given noise permutation.
  int gradientIndex(List<int> perm) {
    int index = x.toInt();
    index = perm[index & 0xFF] + y.toInt();
    return perm[index & 0xFF];
  }

  /// Creates a point where each component is the sum of the given two points' components.
  Point operator +(Point other) => new Point(x + other.x, y + other.y);

  /// Creates a point where each component is the difference of the given two points' components.
  Point operator -(Point other) => new Point(x - other.x, y - other.y);

  /// Creates a point which is the scaled point of the given point's components and scalar.
  Point operator *(double scalar) => new Point(x * scalar, y * scalar);

  /// Gets a human readable string for the point.
  @override
  String toString() => "$x, $y";
}
