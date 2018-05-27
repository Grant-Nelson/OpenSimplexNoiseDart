part of eval2D;

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Point get floor => new Point(x.floorToDouble(), y.floorToDouble());

  Point offset(double value) => new Point(x + value, y + value);

  Point add(double dx, double dy) => new Point(x + dx, y + dy);

  double get sum => x + y;

  double get attn => 2.0 - x * x - y * y;

  Point operator +(Point other) => new Point(x + other.x, y + other.y);

  Point operator -(Point other) => new Point(x + other.x, y + other.y);

  Point operator -() => new Point(-x, -y);

  Point operator *(double scalar) => new Point(x * scalar, y * scalar);

  Point operator /(double scalar) => new Point(x / scalar, y / scalar);
}
