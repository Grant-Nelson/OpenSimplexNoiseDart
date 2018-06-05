library main;

import 'dart:html';
import 'package:OpenSimplexNoiseDart/OpenSimplexNoise.dart';

CanvasElement _canvas;
CanvasRenderingContext2D _context;

void main() {
  document.title = "Open Simplex Noise";

  _canvas = new Element.canvas();
  _context = _canvas.getContext('2d');
  _canvas.style
    ..width = "100%"
    ..height = "100%"
    ..margin = "0px"
    ..padding = "0px"
    ..overflow = "hidden";
  document.body.append(_canvas);

  _draw();
}

void _draw() {
  int width = _canvas.width;
  int height = _canvas.height;
  OpenSimplexNoise noise = new OpenSimplexNoise();
  final double scalar = 0.08;
  final double compOff = 0.5;

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      double red = noise.eval3D(i.toDouble() * scalar, j.toDouble() * scalar, compOff) * 255.0;
      double green = noise.eval3D(i.toDouble() * scalar, j.toDouble() * scalar, 2.0 * compOff) * 255.0;
      double blue = noise.eval3D(i.toDouble() * scalar, j.toDouble() * scalar, 3.0 * compOff) * 255.0;

      _context.fillStyle = 'rgb(${red.toInt()}, ${green.toInt()}, ${blue.toInt()})';
      _context.fillRect(i, j, 1, 1);
    }
  }
}
