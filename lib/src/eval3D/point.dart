part of eval3D;

class Point {
  final double x;
  final double y;
  final double z;

  Point(this.x, this.y, this.z);

  Point get floor => new Point(x.floorToDouble(), y.floorToDouble(), z.floorToDouble());

  double get sum => x + y + z;

  double get attn => 2.0 - (x * x) - (y * y) - (z * z);

  Point operator +(Point other) => new Point(x + other.x, y + other.y, z + other.z);

  Point operator -(Point other) => new Point(x - other.x, y - other.y, z - other.z);

  Point operator *(double scalar) => new Point(x * scalar, y * scalar, z * scalar);

  @override
  String toString() => "$x, $y, $z";
}
