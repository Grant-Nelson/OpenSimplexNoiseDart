part of eval3D;

class Extra {
  Point grid0;
  Point grid1;
  Point delta0;
  Point delta1;

  Extra(Point grid, Point origin) {
    grid0 = grid;
    grid1 = grid;
    delta0 = origin;
    delta1 = origin;
  }

  void add0(double gridX, double gridY, double gridZ, double deltaX, double deltaY, double deltaZ) {
    grid0 = grid0.add(gridX, gridY, gridZ);
    delta0 = delta0.add(deltaX, deltaY, deltaZ);
  }

  void add1(double gridX, double gridY, double gridZ, double deltaX, double deltaY, double deltaZ) {
    grid1 = grid1.add(gridX, gridY, gridZ);
    delta1 = delta1.add(deltaX, deltaY, deltaZ);
  }

  void addX(double grid0val, double grid1val, double delta0val, double delta1val) {
    grid0 = grid0.addX(grid0val);
    grid1 = grid1.addX(grid1val);
    delta0 = delta0.addX(delta0val);
    delta1 = delta1.addX(delta1val);
  }

  void addY(double grid0val, double grid1val, double delta0val, double delta1val) {
    grid0 = grid0.addY(grid0val);
    grid1 = grid1.addY(grid1val);
    delta0 = delta0.addY(delta0val);
    delta1 = delta1.addY(delta1val);
  }

  void addZ(double grid0val, double grid1val, double delta0val, double delta1val) {
    grid0 = grid0.addZ(grid0val);
    grid1 = grid1.addZ(grid1val);
    delta0 = delta0.addZ(delta0val);
    delta1 = delta1.addZ(delta1val);
  }
}
