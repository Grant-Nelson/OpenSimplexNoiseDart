library main;

import 'dart:html';

import 'package:open_simplex_noise/OpenSimplexNoise.dart';

void main() {
  document.title = "Open Simplex Noise";

  CanvasElement canvas = new CanvasElement();
  canvas.style
    ..width    = "100%"
    ..height   = "100%"
    ..margin   = "0px"
    ..padding  = "0px"
    ..overflow = "hidden";
  InputElement inputX = new InputElement(type: 'number')
    ..value = '0.0'
    ..step = '1.0';
  InputElement inputY = new InputElement(type: 'number')
    ..value = '0.0'
    ..step = '1.0';
  InputElement inputZ = new InputElement(type: 'number')
    ..value = '0.0'
    ..step = '0.1';
  document.body
    ?..append(canvas)
    ..append(inputX)
    ..append(inputY)
    ..append(inputZ);

  CanvasRenderingContext2D context = canvas.getContext('2d') as CanvasRenderingContext2D;
  OpenSimplexNoise noise = new OpenSimplexNoise();
  final double scalar  = 0.1;
  final double compOff = 0.5;
  final int width  = canvas.width  ?? 100;
  final int height = canvas.height ?? 100;

  var render = () {
    final double dx = double.parse(inputX.value ?? '0.0');
    final double dy = double.parse(inputY.value ?? '0.0');
    final double dz = double.parse(inputZ.value ?? '0.0');

    for (int i = 0; i < width; i++) {
      final double x = i.toDouble() * scalar + dx;
      for (int j = 0; j < height; j++) {
        final double y = j.toDouble() * scalar + dy;

        double red   = (noise.eval4D(x, y, dz,       compOff) * 0.5 + 0.5) * 255.0;
        double green = (noise.eval4D(x, y, dz, 2.0 * compOff) * 0.5 + 0.5) * 255.0;
        double blue  = (noise.eval4D(x, y, dz, 3.0 * compOff) * 0.5 + 0.5) * 255.0;

        context.fillStyle = 'rgb(${red.toInt()}, ${green.toInt()}, ${blue.toInt()})';
        context.fillRect(i, j, 1, 1);
      }
    }
  };

  render();
  inputX.onChange.listen((_) { render(); });
  inputY.onChange.listen((_) { render(); });
  inputZ.onChange.listen((_) { render(); });
}
