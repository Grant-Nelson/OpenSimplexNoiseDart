part of eval3D;

class Point {
  final double x;
  final double y;
  final double z;

  Point(this.x, this.y, this.z);

  Point get floor => new Point(x.floorToDouble(), y.floorToDouble(), z.floorToDouble());

  double get sum => x + y + z;

  double get attn => 2.0 - (x * x) - (y * y) - (z * z);

  Point add(double dx, double dy, double dz) => new Point(x + dx, y + dy, z + dz);

  Point addX(double dx) => new Point(x + dx, y, z);

  Point addY(double dy) => new Point(x, y + dy, z);

  Point addZ(double dz) => new Point(x, y, z + dz);

  Point operator +(Point other) => new Point(x + other.x, y + other.y, z + other.z);

  Point operator -(Point other) => new Point(x - other.x, y - other.y, z - other.z);

  Point operator *(double scalar) => new Point(x * scalar, y * scalar, z * scalar);

  @override
  String toString() => "$x, $y, $z";
}
