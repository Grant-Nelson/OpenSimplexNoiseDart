part of eval2D;

class Extra {
  Point grid;
  Point delta;

  Extra(this.grid, this.delta);

  void add(double gridX, double gridY, double deltaX, double deltaY) {
    grid = grid.add(gridX, gridY);
    delta = delta.add(deltaX, deltaY);
  }
}
