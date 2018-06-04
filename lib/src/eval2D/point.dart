part of eval2D;

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Point get floor => new Point(x.floorToDouble(), y.floorToDouble());

  double get sum => x + y;

  double get attn => 2.0 - (x * x) - (y * y);

  Point operator +(Point other) => new Point(x + other.x, y + other.y);

  Point operator -(Point other) => new Point(x - other.x, y - other.y);

  Point operator *(double scalar) => new Point(x * scalar, y * scalar);

  @override
  String toString() => "$x, $y";
}
