library main;

import 'dart:html';
import 'package:OpenSimplexNoiseDart/OpenSimplexNoise.dart';

void main() {
  document.title = "Open Simplex Noise";

  CanvasElement canvas = new Element.canvas();
  canvas.style
    ..width = "100%"
    ..height = "100%"
    ..margin = "0px"
    ..padding = "0px"
    ..overflow = "hidden";
  document.body.append(canvas);

  CanvasRenderingContext2D context = canvas.getContext('2d');
  OpenSimplexNoise noise = new OpenSimplexNoise();

  final double scalar = 0.08;
  final double compOff = 0.5;
  final int width = canvas.width;
  final int height = canvas.height;

  for (int i = 0; i < width; i++) {
    final double x = i.toDouble() * scalar;
    for (int j = 0; j < height; j++) {
      final double y = j.toDouble() * scalar;

      double red = noise.eval3D(x, y, compOff) * 255.0;
      double green = noise.eval3D(x, y, 2.0 * compOff) * 255.0;
      double blue = noise.eval3D(x, y, 3.0 * compOff) * 255.0;

      context.fillStyle = 'rgb(${red.toInt()}, ${green.toInt()}, ${blue.toInt()})';
      context.fillRect(i, j, 1, 1);
    }
  }
}
