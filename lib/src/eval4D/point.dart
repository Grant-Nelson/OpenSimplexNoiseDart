part of eval4D;

class Point {
  final double x;
  final double y;
  final double z;
  final double w;

  Point(this.x, this.y, this.z, this.w);

  Point get floor => new Point(x.floorToDouble(), y.floorToDouble(), z.floorToDouble(), w.floorToDouble());

  double get sum => x + y + z + w;

  double get attn => 2.0 - (x * x) - (y * y) - (z * z) - (w * w);

  Point operator +(Point other) => new Point(x + other.x, y + other.y, z + other.z, w + other.w);

  Point operator -(Point other) => new Point(x - other.x, y - other.y, z - other.z, w - other.w);

  Point operator *(double scalar) => new Point(x * scalar, y * scalar, z * scalar, w * scalar);

  @override
  String toString() => "$x, $y, $z, $w";
}
