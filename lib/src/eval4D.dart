part of OpenSimplexNoise;

/*
	static const double _stretch4D = -0.138196601125011;    // (1 / Math.sqrt(4 + 1) - 1) / 4
	static const double _squish4D = 0.309016994374947;      // (Math.sqrt(4 + 1) - 1) / 4
	static const double _norm4D = 30.0;
  
	List<int> _perm;
	
	//Gradients for 4D. They approximate the directions to the
	//vertices of a disprismatotesseractihexadecachoron from the center,
	//skewed so that the tetrahedral and cubic facets can be inscribed inside
	//spheres of the same radius.
	private static byte[] gradients4D = new byte[] {
	     3,  1,  1,  1,      1,  3,  1,  1,      1,  1,  3,  1,      1,  1,  1,  3,
	    -3,  1,  1,  1,     -1,  3,  1,  1,     -1,  1,  3,  1,     -1,  1,  1,  3,
	     3, -1,  1,  1,      1, -3,  1,  1,      1, -1,  3,  1,      1, -1,  1,  3,
	    -3, -1,  1,  1,     -1, -3,  1,  1,     -1, -1,  3,  1,     -1, -1,  1,  3,
	     3,  1, -1,  1,      1,  3, -1,  1,      1,  1, -3,  1,      1,  1, -1,  3,
	    -3,  1, -1,  1,     -1,  3, -1,  1,     -1,  1, -3,  1,     -1,  1, -1,  3,
	     3, -1, -1,  1,      1, -3, -1,  1,      1, -1, -3,  1,      1, -1, -1,  3,
	    -3, -1, -1,  1,     -1, -3, -1,  1,     -1, -1, -3,  1,     -1, -1, -1,  3,
	     3,  1,  1, -1,      1,  3,  1, -1,      1,  1,  3, -1,      1,  1,  1, -3,
	    -3,  1,  1, -1,     -1,  3,  1, -1,     -1,  1,  3, -1,     -1,  1,  1, -3,
	     3, -1,  1, -1,      1, -3,  1, -1,      1, -1,  3, -1,      1, -1,  1, -3,
	    -3, -1,  1, -1,     -1, -3,  1, -1,     -1, -1,  3, -1,     -1, -1,  1, -3,
	     3,  1, -1, -1,      1,  3, -1, -1,      1,  1, -3, -1,      1,  1, -1, -3,
	    -3,  1, -1, -1,     -1,  3, -1, -1,     -1,  1, -3, -1,     -1,  1, -1, -3,
	     3, -1, -1, -1,      1, -3, -1, -1,      1, -1, -3, -1,      1, -1, -1, -3,
	    -3, -1, -1, -1,     -1, -3, -1, -1,     -1, -1, -3, -1,     -1, -1, -1, -3,
	};

	double _extrapolate4D(int xsb, int ysb, int zsb, int wsb, double dx, double dy, double dz, double dw) {
		int index = perm[(perm[(perm[(perm[xsb & 0xFF] + ysb) & 0xFF] + zsb) & 0xFF] + wsb) & 0xFF] & 0xFC;
		return gradients4D[index] * dx
			+ gradients4D[index + 1] * dy
			+ gradients4D[index + 2] * dz
			+ gradients4D[index + 3] * dw;
	}

  //4D OpenSimplex Noise.
	public double eval(double x, double y, double z, double w) {
	
		//Place input coordinates on simplectic honeycomb.
		double stretchOffset = (x + y + z + w) * _stretch4D;
		double xs = x + stretchOffset;
		double ys = y + stretchOffset;
		double zs = z + stretchOffset;
		double ws = w + stretchOffset;
		
		//Floor to get simplectic honeycomb coordinates of rhombo-hypercube super-cell origin.
		int xsb = fastFloor(xs);
		int ysb = fastFloor(ys);
		int zsb = fastFloor(zs);
		int wsb = fastFloor(ws);
		
		//Skew out to get actual coordinates of stretched rhombo-hypercube origin. We'll need these later.
		double squishOffset = (xsb + ysb + zsb + wsb) * _squish4D;
		double xb = xsb + squishOffset;
		double yb = ysb + squishOffset;
		double zb = zsb + squishOffset;
		double wb = wsb + squishOffset;
		
		//Compute simplectic honeycomb coordinates relative to rhombo-hypercube origin.
		double xins = xs - xsb;
		double yins = ys - ysb;
		double zins = zs - zsb;
		double wins = ws - wsb;
		
		//Sum those together to get a value that determines which region we're in.
		double inSum = xins + yins + zins + wins;

		//Positions relative to origin point.
		double dx0 = x - xb;
		double dy0 = y - yb;
		double dz0 = z - zb;
		double dw0 = w - wb;
		
		//We'll be defining these inside the next block and using them afterwards.
		double dx_ext0, dy_ext0, dz_ext0, dw_ext0;
		double dx_ext1, dy_ext1, dz_ext1, dw_ext1;
		double dx_ext2, dy_ext2, dz_ext2, dw_ext2;
		int xsv_ext0, ysv_ext0, zsv_ext0, wsv_ext0;
		int xsv_ext1, ysv_ext1, zsv_ext1, wsv_ext1;
		int xsv_ext2, ysv_ext2, zsv_ext2, wsv_ext2;
		
		double value = 0;
		if (inSum <= 1) { //We're inside the pentachoron (4-Simplex) at (0,0,0,0)

			//Determine which two of (0,0,0,1), (0,0,1,0), (0,1,0,0), (1,0,0,0) are closest.
			byte aPoint = 0x01;
			double aScore = xins;
			byte bPoint = 0x02;
			double bScore = yins;
			if (aScore >= bScore && zins > bScore) {
				bScore = zins;
				bPoint = 0x04;
			} else if (aScore < bScore && zins > aScore) {
				aScore = zins;
				aPoint = 0x04;
			}
			if (aScore >= bScore && wins > bScore) {
				bScore = wins;
				bPoint = 0x08;
			} else if (aScore < bScore && wins > aScore) {
				aScore = wins;
				aPoint = 0x08;
			}
			
			//Now we determine the three lattice points not part of the pentachoron that may contribute.
			//This depends on the closest two pentachoron vertices, including (0,0,0,0)
			double uins = 1 - inSum;
			if (uins > aScore || uins > bScore) { //(0,0,0,0) is one of the closest two pentachoron vertices.
				byte c = (bScore > aScore ? bPoint : aPoint); //Our other closest vertex is the closest out of a and b.
				if ((c & 0x01) == 0) {
					xsv_ext0 = xsb - 1;
					xsv_ext1 = xsv_ext2 = xsb;
					dx_ext0 = dx0 + 1;
					dx_ext1 = dx_ext2 = dx0;
				} else {
					xsv_ext0 = xsv_ext1 = xsv_ext2 = xsb + 1;
					dx_ext0 = dx_ext1 = dx_ext2 = dx0 - 1;
				}

				if ((c & 0x02) == 0) {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb;
					dy_ext0 = dy_ext1 = dy_ext2 = dy0;
					if ((c & 0x01) == 0x01) {
						ysv_ext0 -= 1;
						dy_ext0 += 1;
					} else {
						ysv_ext1 -= 1;
						dy_ext1 += 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb + 1;
					dy_ext0 = dy_ext1 = dy_ext2 = dy0 - 1;
				}
				
				if ((c & 0x04) == 0) {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb;
					dz_ext0 = dz_ext1 = dz_ext2 = dz0;
					if ((c & 0x03) != 0) {
						if ((c & 0x03) == 0x03) {
							zsv_ext0 -= 1;
							dz_ext0 += 1;
						} else {
							zsv_ext1 -= 1;
							dz_ext1 += 1;
						}
					} else {
						zsv_ext2 -= 1;
						dz_ext2 += 1;
					}
				} else {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb + 1;
					dz_ext0 = dz_ext1 = dz_ext2 = dz0 - 1;
				}
				
				if ((c & 0x08) == 0) {
					wsv_ext0 = wsv_ext1 = wsb;
					wsv_ext2 = wsb - 1;
					dw_ext0 = dw_ext1 = dw0;
					dw_ext2 = dw0 + 1;
				} else {
					wsv_ext0 = wsv_ext1 = wsv_ext2 = wsb + 1;
					dw_ext0 = dw_ext1 = dw_ext2 = dw0 - 1;
				}
			} else { //(0,0,0,0) is not one of the closest two pentachoron vertices.
				byte c = (byte)(aPoint | bPoint); //Our three extra vertices are determined by the closest two.
				
				if ((c & 0x01) == 0) {
					xsv_ext0 = xsv_ext2 = xsb;
					xsv_ext1 = xsb - 1;
					dx_ext0 = dx0 - 2 * _squish4D;
					dx_ext1 = dx0 + 1 - _squish4D;
					dx_ext2 = dx0 - _squish4D;
				} else {
					xsv_ext0 = xsv_ext1 = xsv_ext2 = xsb + 1;
					dx_ext0 = dx0 - 1 - 2 * _squish4D;
					dx_ext1 = dx_ext2 = dx0 - 1 - _squish4D;
				}
				
				if ((c & 0x02) == 0) {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb;
					dy_ext0 = dy0 - 2 * _squish4D;
					dy_ext1 = dy_ext2 = dy0 - _squish4D;
					if ((c & 0x01) == 0x01) {
						ysv_ext1 -= 1;
						dy_ext1 += 1;
					} else {
						ysv_ext2 -= 1;
						dy_ext2 += 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb + 1;
					dy_ext0 = dy0 - 1 - 2 * _squish4D;
					dy_ext1 = dy_ext2 = dy0 - 1 - _squish4D;
				}
				
				if ((c & 0x04) == 0) {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb;
					dz_ext0 = dz0 - 2 * _squish4D;
					dz_ext1 = dz_ext2 = dz0 - _squish4D;
					if ((c & 0x03) == 0x03) {
						zsv_ext1 -= 1;
						dz_ext1 += 1;
					} else {
						zsv_ext2 -= 1;
						dz_ext2 += 1;
					}
				} else {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb + 1;
					dz_ext0 = dz0 - 1 - 2 * _squish4D;
					dz_ext1 = dz_ext2 = dz0 - 1 - _squish4D;
				}
				
				if ((c & 0x08) == 0) {
					wsv_ext0 = wsv_ext1 = wsb;
					wsv_ext2 = wsb - 1;
					dw_ext0 = dw0 - 2 * _squish4D;
					dw_ext1 = dw0 - _squish4D;
					dw_ext2 = dw0 + 1 - _squish4D;
				} else {
					wsv_ext0 = wsv_ext1 = wsv_ext2 = wsb + 1;
					dw_ext0 = dw0 - 1 - 2 * _squish4D;
					dw_ext1 = dw_ext2 = dw0 - 1 - _squish4D;
				}
			}

			//Contribution (0,0,0,0)
			double attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0 - dw0 * dw0;
			if (attn0 > 0) {
				attn0 *= attn0;
				value += attn0 * attn0 * extrapolate(xsb + 0, ysb + 0, zsb + 0, wsb + 0, dx0, dy0, dz0, dw0);
			}

			//Contribution (1,0,0,0)
			double dx1 = dx0 - 1 - _squish4D;
			double dy1 = dy0 - 0 - _squish4D;
			double dz1 = dz0 - 0 - _squish4D;
			double dw1 = dw0 - 0 - _squish4D;
			double attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 1, ysb + 0, zsb + 0, wsb + 0, dx1, dy1, dz1, dw1);
			}

			//Contribution (0,1,0,0)
			double dx2 = dx0 - 0 - _squish4D;
			double dy2 = dy0 - 1 - _squish4D;
			double dz2 = dz1;
			double dw2 = dw1;
			double attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 0, ysb + 1, zsb + 0, wsb + 0, dx2, dy2, dz2, dw2);
			}

			//Contribution (0,0,1,0)
			double dx3 = dx2;
			double dy3 = dy1;
			double dz3 = dz0 - 1 - _squish4D;
			double dw3 = dw1;
			double attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 0, ysb + 0, zsb + 1, wsb + 0, dx3, dy3, dz3, dw3);
			}

			//Contribution (0,0,0,1)
			double dx4 = dx2;
			double dy4 = dy1;
			double dz4 = dz1;
			double dw4 = dw0 - 1 - _squish4D;
			double attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
			if (attn4 > 0) {
				attn4 *= attn4;
				value += attn4 * attn4 * extrapolate(xsb + 0, ysb + 0, zsb + 0, wsb + 1, dx4, dy4, dz4, dw4);
			}
		} else if (inSum >= 3) { //We're inside the pentachoron (4-Simplex) at (1,1,1,1)
			//Determine which two of (1,1,1,0), (1,1,0,1), (1,0,1,1), (0,1,1,1) are closest.
			byte aPoint = 0x0E;
			double aScore = xins;
			byte bPoint = 0x0D;
			double bScore = yins;
			if (aScore <= bScore && zins < bScore) {
				bScore = zins;
				bPoint = 0x0B;
			} else if (aScore > bScore && zins < aScore) {
				aScore = zins;
				aPoint = 0x0B;
			}
			if (aScore <= bScore && wins < bScore) {
				bScore = wins;
				bPoint = 0x07;
			} else if (aScore > bScore && wins < aScore) {
				aScore = wins;
				aPoint = 0x07;
			}
			
			//Now we determine the three lattice points not part of the pentachoron that may contribute.
			//This depends on the closest two pentachoron vertices, including (0,0,0,0)
			double uins = 4 - inSum;
			if (uins < aScore || uins < bScore) { //(1,1,1,1) is one of the closest two pentachoron vertices.
				byte c = (bScore < aScore ? bPoint : aPoint); //Our other closest vertex is the closest out of a and b.
				
				if ((c & 0x01) != 0) {
					xsv_ext0 = xsb + 2;
					xsv_ext1 = xsv_ext2 = xsb + 1;
					dx_ext0 = dx0 - 2 - 4 * _squish4D;
					dx_ext1 = dx_ext2 = dx0 - 1 - 4 * _squish4D;
				} else {
					xsv_ext0 = xsv_ext1 = xsv_ext2 = xsb;
					dx_ext0 = dx_ext1 = dx_ext2 = dx0 - 4 * _squish4D;
				}

				if ((c & 0x02) != 0) {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb + 1;
					dy_ext0 = dy_ext1 = dy_ext2 = dy0 - 1 - 4 * _squish4D;
					if ((c & 0x01) != 0) {
						ysv_ext1 += 1;
						dy_ext1 -= 1;
					} else {
						ysv_ext0 += 1;
						dy_ext0 -= 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb;
					dy_ext0 = dy_ext1 = dy_ext2 = dy0 - 4 * _squish4D;
				}
				
				if ((c & 0x04) != 0) {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb + 1;
					dz_ext0 = dz_ext1 = dz_ext2 = dz0 - 1 - 4 * _squish4D;
					if ((c & 0x03) != 0x03) {
						if ((c & 0x03) == 0) {
							zsv_ext0 += 1;
							dz_ext0 -= 1;
						} else {
							zsv_ext1 += 1;
							dz_ext1 -= 1;
						}
					} else {
						zsv_ext2 += 1;
						dz_ext2 -= 1;
					}
				} else {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb;
					dz_ext0 = dz_ext1 = dz_ext2 = dz0 - 4 * _squish4D;
				}
				
				if ((c & 0x08) != 0) {
					wsv_ext0 = wsv_ext1 = wsb + 1;
					wsv_ext2 = wsb + 2;
					dw_ext0 = dw_ext1 = dw0 - 1 - 4 * _squish4D;
					dw_ext2 = dw0 - 2 - 4 * _squish4D;
				} else {
					wsv_ext0 = wsv_ext1 = wsv_ext2 = wsb;
					dw_ext0 = dw_ext1 = dw_ext2 = dw0 - 4 * _squish4D;
				}
			} else { //(1,1,1,1) is not one of the closest two pentachoron vertices.
				byte c = (byte)(aPoint & bPoint); //Our three extra vertices are determined by the closest two.
				
				if ((c & 0x01) != 0) {
					xsv_ext0 = xsv_ext2 = xsb + 1;
					xsv_ext1 = xsb + 2;
					dx_ext0 = dx0 - 1 - 2 * _squish4D;
					dx_ext1 = dx0 - 2 - 3 * _squish4D;
					dx_ext2 = dx0 - 1 - 3 * _squish4D;
				} else {
					xsv_ext0 = xsv_ext1 = xsv_ext2 = xsb;
					dx_ext0 = dx0 - 2 * _squish4D;
					dx_ext1 = dx_ext2 = dx0 - 3 * _squish4D;
				}
				
				if ((c & 0x02) != 0) {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb + 1;
					dy_ext0 = dy0 - 1 - 2 * _squish4D;
					dy_ext1 = dy_ext2 = dy0 - 1 - 3 * _squish4D;
					if ((c & 0x01) != 0) {
						ysv_ext2 += 1;
						dy_ext2 -= 1;
					} else {
						ysv_ext1 += 1;
						dy_ext1 -= 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysv_ext2 = ysb;
					dy_ext0 = dy0 - 2 * _squish4D;
					dy_ext1 = dy_ext2 = dy0 - 3 * _squish4D;
				}
				
				if ((c & 0x04) != 0) {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb + 1;
					dz_ext0 = dz0 - 1 - 2 * _squish4D;
					dz_ext1 = dz_ext2 = dz0 - 1 - 3 * _squish4D;
					if ((c & 0x03) != 0) {
						zsv_ext2 += 1;
						dz_ext2 -= 1;
					} else {
						zsv_ext1 += 1;
						dz_ext1 -= 1;
					}
				} else {
					zsv_ext0 = zsv_ext1 = zsv_ext2 = zsb;
					dz_ext0 = dz0 - 2 * _squish4D;
					dz_ext1 = dz_ext2 = dz0 - 3 * _squish4D;
				}
				
				if ((c & 0x08) != 0) {
					wsv_ext0 = wsv_ext1 = wsb + 1;
					wsv_ext2 = wsb + 2;
					dw_ext0 = dw0 - 1 - 2 * _squish4D;
					dw_ext1 = dw0 - 1 - 3 * _squish4D;
					dw_ext2 = dw0 - 2 - 3 * _squish4D;
				} else {
					wsv_ext0 = wsv_ext1 = wsv_ext2 = wsb;
					dw_ext0 = dw0 - 2 * _squish4D;
					dw_ext1 = dw_ext2 = dw0 - 3 * _squish4D;
				}
			}

			//Contribution (1,1,1,0)
			double dx4 = dx0 - 1 - 3 * _squish4D;
			double dy4 = dy0 - 1 - 3 * _squish4D;
			double dz4 = dz0 - 1 - 3 * _squish4D;
			double dw4 = dw0 - 3 * _squish4D;
			double attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
			if (attn4 > 0) {
				attn4 *= attn4;
				value += attn4 * attn4 * extrapolate(xsb + 1, ysb + 1, zsb + 1, wsb + 0, dx4, dy4, dz4, dw4);
			}

			//Contribution (1,1,0,1)
			double dx3 = dx4;
			double dy3 = dy4;
			double dz3 = dz0 - 3 * _squish4D;
			double dw3 = dw0 - 1 - 3 * _squish4D;
			double attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 1, ysb + 1, zsb + 0, wsb + 1, dx3, dy3, dz3, dw3);
			}

			//Contribution (1,0,1,1)
			double dx2 = dx4;
			double dy2 = dy0 - 3 * _squish4D;
			double dz2 = dz4;
			double dw2 = dw3;
			double attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 1, ysb + 0, zsb + 1, wsb + 1, dx2, dy2, dz2, dw2);
			}

			//Contribution (0,1,1,1)
			double dx1 = dx0 - 3 * _squish4D;
			double dz1 = dz4;
			double dy1 = dy4;
			double dw1 = dw3;
			double attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 0, ysb + 1, zsb + 1, wsb + 1, dx1, dy1, dz1, dw1);
			}

			//Contribution (1,1,1,1)
			dx0 = dx0 - 1 - 4 * _squish4D;
			dy0 = dy0 - 1 - 4 * _squish4D;
			dz0 = dz0 - 1 - 4 * _squish4D;
			dw0 = dw0 - 1 - 4 * _squish4D;
			double attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0 - dw0 * dw0;
			if (attn0 > 0) {
				attn0 *= attn0;
				value += attn0 * attn0 * extrapolate(xsb + 1, ysb + 1, zsb + 1, wsb + 1, dx0, dy0, dz0, dw0);
			}
		} else if (inSum <= 2) { //We're inside the first dispentachoron (Rectified 4-Simplex)
			double aScore;
			byte aPoint;
			boolean aIsBiggerSide = true;
			double bScore;
			byte bPoint;
			boolean bIsBiggerSide = true;
			
			//Decide between (1,1,0,0) and (0,0,1,1)
			if (xins + yins > zins + wins) {
				aScore = xins + yins;
				aPoint = 0x03;
			} else {
				aScore = zins + wins;
				aPoint = 0x0C;
			}
			
			//Decide between (1,0,1,0) and (0,1,0,1)
			if (xins + zins > yins + wins) {
				bScore = xins + zins;
				bPoint = 0x05;
			} else {
				bScore = yins + wins;
				bPoint = 0x0A;
			}
			
			//Closer between (1,0,0,1) and (0,1,1,0) will replace the further of a and b, if closer.
			if (xins + wins > yins + zins) {
				double score = xins + wins;
				if (aScore >= bScore && score > bScore) {
					bScore = score;
					bPoint = 0x09;
				} else if (aScore < bScore && score > aScore) {
					aScore = score;
					aPoint = 0x09;
				}
			} else {
				double score = yins + zins;
				if (aScore >= bScore && score > bScore) {
					bScore = score;
					bPoint = 0x06;
				} else if (aScore < bScore && score > aScore) {
					aScore = score;
					aPoint = 0x06;
				}
			}
			
			//Decide if (1,0,0,0) is closer.
			double p1 = 2 - inSum + xins;
			if (aScore >= bScore && p1 > bScore) {
				bScore = p1;
				bPoint = 0x01;
				bIsBiggerSide = false;
			} else if (aScore < bScore && p1 > aScore) {
				aScore = p1;
				aPoint = 0x01;
				aIsBiggerSide = false;
			}
			
			//Decide if (0,1,0,0) is closer.
			double p2 = 2 - inSum + yins;
			if (aScore >= bScore && p2 > bScore) {
				bScore = p2;
				bPoint = 0x02;
				bIsBiggerSide = false;
			} else if (aScore < bScore && p2 > aScore) {
				aScore = p2;
				aPoint = 0x02;
				aIsBiggerSide = false;
			}
			
			//Decide if (0,0,1,0) is closer.
			double p3 = 2 - inSum + zins;
			if (aScore >= bScore && p3 > bScore) {
				bScore = p3;
				bPoint = 0x04;
				bIsBiggerSide = false;
			} else if (aScore < bScore && p3 > aScore) {
				aScore = p3;
				aPoint = 0x04;
				aIsBiggerSide = false;
			}
			
			//Decide if (0,0,0,1) is closer.
			double p4 = 2 - inSum + wins;
			if (aScore >= bScore && p4 > bScore) {
				bScore = p4;
				bPoint = 0x08;
				bIsBiggerSide = false;
			} else if (aScore < bScore && p4 > aScore) {
				aScore = p4;
				aPoint = 0x08;
				aIsBiggerSide = false;
			}
			
			//Where each of the two closest points are determines how the extra three vertices are calculated.
			if (aIsBiggerSide == bIsBiggerSide) {
				if (aIsBiggerSide) { //Both closest points on the bigger side
					byte c1 = (byte)(aPoint | bPoint);
					byte c2 = (byte)(aPoint & bPoint);
					if ((c1 & 0x01) == 0) {
						xsv_ext0 = xsb;
						xsv_ext1 = xsb - 1;
						dx_ext0 = dx0 - 3 * _squish4D;
						dx_ext1 = dx0 + 1 - 2 * _squish4D;
					} else {
						xsv_ext0 = xsv_ext1 = xsb + 1;
						dx_ext0 = dx0 - 1 - 3 * _squish4D;
						dx_ext1 = dx0 - 1 - 2 * _squish4D;
					}
					
					if ((c1 & 0x02) == 0) {
						ysv_ext0 = ysb;
						ysv_ext1 = ysb - 1;
						dy_ext0 = dy0 - 3 * _squish4D;
						dy_ext1 = dy0 + 1 - 2 * _squish4D;
					} else {
						ysv_ext0 = ysv_ext1 = ysb + 1;
						dy_ext0 = dy0 - 1 - 3 * _squish4D;
						dy_ext1 = dy0 - 1 - 2 * _squish4D;
					}
					
					if ((c1 & 0x04) == 0) {
						zsv_ext0 = zsb;
						zsv_ext1 = zsb - 1;
						dz_ext0 = dz0 - 3 * _squish4D;
						dz_ext1 = dz0 + 1 - 2 * _squish4D;
					} else {
						zsv_ext0 = zsv_ext1 = zsb + 1;
						dz_ext0 = dz0 - 1 - 3 * _squish4D;
						dz_ext1 = dz0 - 1 - 2 * _squish4D;
					}
					
					if ((c1 & 0x08) == 0) {
						wsv_ext0 = wsb;
						wsv_ext1 = wsb - 1;
						dw_ext0 = dw0 - 3 * _squish4D;
						dw_ext1 = dw0 + 1 - 2 * _squish4D;
					} else {
						wsv_ext0 = wsv_ext1 = wsb + 1;
						dw_ext0 = dw0 - 1 - 3 * _squish4D;
						dw_ext1 = dw0 - 1 - 2 * _squish4D;
					}
					
					//One combination is a permutation of (0,0,0,2) based on c2
					xsv_ext2 = xsb;
					ysv_ext2 = ysb;
					zsv_ext2 = zsb;
					wsv_ext2 = wsb;
					dx_ext2 = dx0 - 2 * _squish4D;
					dy_ext2 = dy0 - 2 * _squish4D;
					dz_ext2 = dz0 - 2 * _squish4D;
					dw_ext2 = dw0 - 2 * _squish4D;
					if ((c2 & 0x01) != 0) {
						xsv_ext2 += 2;
						dx_ext2 -= 2;
					} else if ((c2 & 0x02) != 0) {
						ysv_ext2 += 2;
						dy_ext2 -= 2;
					} else if ((c2 & 0x04) != 0) {
						zsv_ext2 += 2;
						dz_ext2 -= 2;
					} else {
						wsv_ext2 += 2;
						dw_ext2 -= 2;
					}
					
				} else { //Both closest points on the smaller side
					//One of the two extra points is (0,0,0,0)
					xsv_ext2 = xsb;
					ysv_ext2 = ysb;
					zsv_ext2 = zsb;
					wsv_ext2 = wsb;
					dx_ext2 = dx0;
					dy_ext2 = dy0;
					dz_ext2 = dz0;
					dw_ext2 = dw0;
					
					//Other two points are based on the omitted axes.
					byte c = (byte)(aPoint | bPoint);
					
					if ((c & 0x01) == 0) {
						xsv_ext0 = xsb - 1;
						xsv_ext1 = xsb;
						dx_ext0 = dx0 + 1 - _squish4D;
						dx_ext1 = dx0 - _squish4D;
					} else {
						xsv_ext0 = xsv_ext1 = xsb + 1;
						dx_ext0 = dx_ext1 = dx0 - 1 - _squish4D;
					}
					
					if ((c & 0x02) == 0) {
						ysv_ext0 = ysv_ext1 = ysb;
						dy_ext0 = dy_ext1 = dy0 - _squish4D;
						if ((c & 0x01) == 0x01)
						{
							ysv_ext0 -= 1;
							dy_ext0 += 1;
						} else {
							ysv_ext1 -= 1;
							dy_ext1 += 1;
						}
					} else {
						ysv_ext0 = ysv_ext1 = ysb + 1;
						dy_ext0 = dy_ext1 = dy0 - 1 - _squish4D;
					}
					
					if ((c & 0x04) == 0) {
						zsv_ext0 = zsv_ext1 = zsb;
						dz_ext0 = dz_ext1 = dz0 - _squish4D;
						if ((c & 0x03) == 0x03)
						{
							zsv_ext0 -= 1;
							dz_ext0 += 1;
						} else {
							zsv_ext1 -= 1;
							dz_ext1 += 1;
						}
					} else {
						zsv_ext0 = zsv_ext1 = zsb + 1;
						dz_ext0 = dz_ext1 = dz0 - 1 - _squish4D;
					}
					
					if ((c & 0x08) == 0)
					{
						wsv_ext0 = wsb;
						wsv_ext1 = wsb - 1;
						dw_ext0 = dw0 - _squish4D;
						dw_ext1 = dw0 + 1 - _squish4D;
					} else {
						wsv_ext0 = wsv_ext1 = wsb + 1;
						dw_ext0 = dw_ext1 = dw0 - 1 - _squish4D;
					}
					
				}
			} else { //One point on each "side"
				byte c1, c2;
				if (aIsBiggerSide) {
					c1 = aPoint;
					c2 = bPoint;
				} else {
					c1 = bPoint;
					c2 = aPoint;
				}
				
				//Two contributions are the bigger-sided point with each 0 replaced with -1.
				if ((c1 & 0x01) == 0) {
					xsv_ext0 = xsb - 1;
					xsv_ext1 = xsb;
					dx_ext0 = dx0 + 1 - _squish4D;
					dx_ext1 = dx0 - _squish4D;
				} else {
					xsv_ext0 = xsv_ext1 = xsb + 1;
					dx_ext0 = dx_ext1 = dx0 - 1 - _squish4D;
				}
				
				if ((c1 & 0x02) == 0) {
					ysv_ext0 = ysv_ext1 = ysb;
					dy_ext0 = dy_ext1 = dy0 - _squish4D;
					if ((c1 & 0x01) == 0x01) {
						ysv_ext0 -= 1;
						dy_ext0 += 1;
					} else {
						ysv_ext1 -= 1;
						dy_ext1 += 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysb + 1;
					dy_ext0 = dy_ext1 = dy0 - 1 - _squish4D;
				}
				
				if ((c1 & 0x04) == 0) {
					zsv_ext0 = zsv_ext1 = zsb;
					dz_ext0 = dz_ext1 = dz0 - _squish4D;
					if ((c1 & 0x03) == 0x03) {
						zsv_ext0 -= 1;
						dz_ext0 += 1;
					} else {
						zsv_ext1 -= 1;
						dz_ext1 += 1;
					}
				} else {
					zsv_ext0 = zsv_ext1 = zsb + 1;
					dz_ext0 = dz_ext1 = dz0 - 1 - _squish4D;
				}
				
				if ((c1 & 0x08) == 0) {
					wsv_ext0 = wsb;
					wsv_ext1 = wsb - 1;
					dw_ext0 = dw0 - _squish4D;
					dw_ext1 = dw0 + 1 - _squish4D;
				} else {
					wsv_ext0 = wsv_ext1 = wsb + 1;
					dw_ext0 = dw_ext1 = dw0 - 1 - _squish4D;
				}

				//One contribution is a permutation of (0,0,0,2) based on the smaller-sided point
				xsv_ext2 = xsb;
				ysv_ext2 = ysb;
				zsv_ext2 = zsb;
				wsv_ext2 = wsb;
				dx_ext2 = dx0 - 2 * _squish4D;
				dy_ext2 = dy0 - 2 * _squish4D;
				dz_ext2 = dz0 - 2 * _squish4D;
				dw_ext2 = dw0 - 2 * _squish4D;
				if ((c2 & 0x01) != 0) {
					xsv_ext2 += 2;
					dx_ext2 -= 2;
				} else if ((c2 & 0x02) != 0) {
					ysv_ext2 += 2;
					dy_ext2 -= 2;
				} else if ((c2 & 0x04) != 0) {
					zsv_ext2 += 2;
					dz_ext2 -= 2;
				} else {
					wsv_ext2 += 2;
					dw_ext2 -= 2;
				}
			}
			
			//Contribution (1,0,0,0)
			double dx1 = dx0 - 1 - _squish4D;
			double dy1 = dy0 - 0 - _squish4D;
			double dz1 = dz0 - 0 - _squish4D;
			double dw1 = dw0 - 0 - _squish4D;
			double attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 1, ysb + 0, zsb + 0, wsb + 0, dx1, dy1, dz1, dw1);
			}

			//Contribution (0,1,0,0)
			double dx2 = dx0 - 0 - _squish4D;
			double dy2 = dy0 - 1 - _squish4D;
			double dz2 = dz1;
			double dw2 = dw1;
			double attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 0, ysb + 1, zsb + 0, wsb + 0, dx2, dy2, dz2, dw2);
			}

			//Contribution (0,0,1,0)
			double dx3 = dx2;
			double dy3 = dy1;
			double dz3 = dz0 - 1 - _squish4D;
			double dw3 = dw1;
			double attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 0, ysb + 0, zsb + 1, wsb + 0, dx3, dy3, dz3, dw3);
			}

			//Contribution (0,0,0,1)
			double dx4 = dx2;
			double dy4 = dy1;
			double dz4 = dz1;
			double dw4 = dw0 - 1 - _squish4D;
			double attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
			if (attn4 > 0) {
				attn4 *= attn4;
				value += attn4 * attn4 * extrapolate(xsb + 0, ysb + 0, zsb + 0, wsb + 1, dx4, dy4, dz4, dw4);
			}
			
			//Contribution (1,1,0,0)
			double dx5 = dx0 - 1 - 2 * _squish4D;
			double dy5 = dy0 - 1 - 2 * _squish4D;
			double dz5 = dz0 - 0 - 2 * _squish4D;
			double dw5 = dw0 - 0 - 2 * _squish4D;
			double attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5 - dw5 * dw5;
			if (attn5 > 0) {
				attn5 *= attn5;
				value += attn5 * attn5 * extrapolate(xsb + 1, ysb + 1, zsb + 0, wsb + 0, dx5, dy5, dz5, dw5);
			}
			
			//Contribution (1,0,1,0)
			double dx6 = dx0 - 1 - 2 * _squish4D;
			double dy6 = dy0 - 0 - 2 * _squish4D;
			double dz6 = dz0 - 1 - 2 * _squish4D;
			double dw6 = dw0 - 0 - 2 * _squish4D;
			double attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6 - dw6 * dw6;
			if (attn6 > 0) {
				attn6 *= attn6;
				value += attn6 * attn6 * extrapolate(xsb + 1, ysb + 0, zsb + 1, wsb + 0, dx6, dy6, dz6, dw6);
			}

			//Contribution (1,0,0,1)
			double dx7 = dx0 - 1 - 2 * _squish4D;
			double dy7 = dy0 - 0 - 2 * _squish4D;
			double dz7 = dz0 - 0 - 2 * _squish4D;
			double dw7 = dw0 - 1 - 2 * _squish4D;
			double attn7 = 2 - dx7 * dx7 - dy7 * dy7 - dz7 * dz7 - dw7 * dw7;
			if (attn7 > 0) {
				attn7 *= attn7;
				value += attn7 * attn7 * extrapolate(xsb + 1, ysb + 0, zsb + 0, wsb + 1, dx7, dy7, dz7, dw7);
			}
			
			//Contribution (0,1,1,0)
			double dx8 = dx0 - 0 - 2 * _squish4D;
			double dy8 = dy0 - 1 - 2 * _squish4D;
			double dz8 = dz0 - 1 - 2 * _squish4D;
			double dw8 = dw0 - 0 - 2 * _squish4D;
			double attn8 = 2 - dx8 * dx8 - dy8 * dy8 - dz8 * dz8 - dw8 * dw8;
			if (attn8 > 0) {
				attn8 *= attn8;
				value += attn8 * attn8 * extrapolate(xsb + 0, ysb + 1, zsb + 1, wsb + 0, dx8, dy8, dz8, dw8);
			}
			
			//Contribution (0,1,0,1)
			double dx9 = dx0 - 0 - 2 * _squish4D;
			double dy9 = dy0 - 1 - 2 * _squish4D;
			double dz9 = dz0 - 0 - 2 * _squish4D;
			double dw9 = dw0 - 1 - 2 * _squish4D;
			double attn9 = 2 - dx9 * dx9 - dy9 * dy9 - dz9 * dz9 - dw9 * dw9;
			if (attn9 > 0) {
				attn9 *= attn9;
				value += attn9 * attn9 * extrapolate(xsb + 0, ysb + 1, zsb + 0, wsb + 1, dx9, dy9, dz9, dw9);
			}
			
			//Contribution (0,0,1,1)
			double dx10 = dx0 - 0 - 2 * _squish4D;
			double dy10 = dy0 - 0 - 2 * _squish4D;
			double dz10 = dz0 - 1 - 2 * _squish4D;
			double dw10 = dw0 - 1 - 2 * _squish4D;
			double attn10 = 2 - dx10 * dx10 - dy10 * dy10 - dz10 * dz10 - dw10 * dw10;
			if (attn10 > 0) {
				attn10 *= attn10;
				value += attn10 * attn10 * extrapolate(xsb + 0, ysb + 0, zsb + 1, wsb + 1, dx10, dy10, dz10, dw10);
			}
		} else { //We're inside the second dispentachoron (Rectified 4-Simplex)
			double aScore;
			byte aPoint;
			boolean aIsBiggerSide = true;
			double bScore;
			byte bPoint;
			boolean bIsBiggerSide = true;
			
			//Decide between (0,0,1,1) and (1,1,0,0)
			if (xins + yins < zins + wins) {
				aScore = xins + yins;
				aPoint = 0x0C;
			} else {
				aScore = zins + wins;
				aPoint = 0x03;
			}
			
			//Decide between (0,1,0,1) and (1,0,1,0)
			if (xins + zins < yins + wins) {
				bScore = xins + zins;
				bPoint = 0x0A;
			} else {
				bScore = yins + wins;
				bPoint = 0x05;
			}
			
			//Closer between (0,1,1,0) and (1,0,0,1) will replace the further of a and b, if closer.
			if (xins + wins < yins + zins) {
				double score = xins + wins;
				if (aScore <= bScore && score < bScore) {
					bScore = score;
					bPoint = 0x06;
				} else if (aScore > bScore && score < aScore) {
					aScore = score;
					aPoint = 0x06;
				}
			} else {
				double score = yins + zins;
				if (aScore <= bScore && score < bScore) {
					bScore = score;
					bPoint = 0x09;
				} else if (aScore > bScore && score < aScore) {
					aScore = score;
					aPoint = 0x09;
				}
			}
			
			//Decide if (0,1,1,1) is closer.
			double p1 = 3 - inSum + xins;
			if (aScore <= bScore && p1 < bScore) {
				bScore = p1;
				bPoint = 0x0E;
				bIsBiggerSide = false;
			} else if (aScore > bScore && p1 < aScore) {
				aScore = p1;
				aPoint = 0x0E;
				aIsBiggerSide = false;
			}
			
			//Decide if (1,0,1,1) is closer.
			double p2 = 3 - inSum + yins;
			if (aScore <= bScore && p2 < bScore) {
				bScore = p2;
				bPoint = 0x0D;
				bIsBiggerSide = false;
			} else if (aScore > bScore && p2 < aScore) {
				aScore = p2;
				aPoint = 0x0D;
				aIsBiggerSide = false;
			}
			
			//Decide if (1,1,0,1) is closer.
			double p3 = 3 - inSum + zins;
			if (aScore <= bScore && p3 < bScore) {
				bScore = p3;
				bPoint = 0x0B;
				bIsBiggerSide = false;
			} else if (aScore > bScore && p3 < aScore) {
				aScore = p3;
				aPoint = 0x0B;
				aIsBiggerSide = false;
			}
			
			//Decide if (1,1,1,0) is closer.
			double p4 = 3 - inSum + wins;
			if (aScore <= bScore && p4 < bScore) {
				bScore = p4;
				bPoint = 0x07;
				bIsBiggerSide = false;
			} else if (aScore > bScore && p4 < aScore) {
				aScore = p4;
				aPoint = 0x07;
				aIsBiggerSide = false;
			}
			
			//Where each of the two closest points are determines how the extra three vertices are calculated.
			if (aIsBiggerSide == bIsBiggerSide) {
				if (aIsBiggerSide) { //Both closest points on the bigger side
					byte c1 = (byte)(aPoint & bPoint);
					byte c2 = (byte)(aPoint | bPoint);
					
					//Two contributions are permutations of (0,0,0,1) and (0,0,0,2) based on c1
					xsv_ext0 = xsv_ext1 = xsb;
					ysv_ext0 = ysv_ext1 = ysb;
					zsv_ext0 = zsv_ext1 = zsb;
					wsv_ext0 = wsv_ext1 = wsb;
					dx_ext0 = dx0 - _squish4D;
					dy_ext0 = dy0 - _squish4D;
					dz_ext0 = dz0 - _squish4D;
					dw_ext0 = dw0 - _squish4D;
					dx_ext1 = dx0 - 2 * _squish4D;
					dy_ext1 = dy0 - 2 * _squish4D;
					dz_ext1 = dz0 - 2 * _squish4D;
					dw_ext1 = dw0 - 2 * _squish4D;
					if ((c1 & 0x01) != 0) {
						xsv_ext0 += 1;
						dx_ext0 -= 1;
						xsv_ext1 += 2;
						dx_ext1 -= 2;
					} else if ((c1 & 0x02) != 0) {
						ysv_ext0 += 1;
						dy_ext0 -= 1;
						ysv_ext1 += 2;
						dy_ext1 -= 2;
					} else if ((c1 & 0x04) != 0) {
						zsv_ext0 += 1;
						dz_ext0 -= 1;
						zsv_ext1 += 2;
						dz_ext1 -= 2;
					} else {
						wsv_ext0 += 1;
						dw_ext0 -= 1;
						wsv_ext1 += 2;
						dw_ext1 -= 2;
					}
					
					//One contribution is a permutation of (1,1,1,-1) based on c2
					xsv_ext2 = xsb + 1;
					ysv_ext2 = ysb + 1;
					zsv_ext2 = zsb + 1;
					wsv_ext2 = wsb + 1;
					dx_ext2 = dx0 - 1 - 2 * _squish4D;
					dy_ext2 = dy0 - 1 - 2 * _squish4D;
					dz_ext2 = dz0 - 1 - 2 * _squish4D;
					dw_ext2 = dw0 - 1 - 2 * _squish4D;
					if ((c2 & 0x01) == 0) {
						xsv_ext2 -= 2;
						dx_ext2 += 2;
					} else if ((c2 & 0x02) == 0) {
						ysv_ext2 -= 2;
						dy_ext2 += 2;
					} else if ((c2 & 0x04) == 0) {
						zsv_ext2 -= 2;
						dz_ext2 += 2;
					} else {
						wsv_ext2 -= 2;
						dw_ext2 += 2;
					}
				} else { //Both closest points on the smaller side
					//One of the two extra points is (1,1,1,1)
					xsv_ext2 = xsb + 1;
					ysv_ext2 = ysb + 1;
					zsv_ext2 = zsb + 1;
					wsv_ext2 = wsb + 1;
					dx_ext2 = dx0 - 1 - 4 * _squish4D;
					dy_ext2 = dy0 - 1 - 4 * _squish4D;
					dz_ext2 = dz0 - 1 - 4 * _squish4D;
					dw_ext2 = dw0 - 1 - 4 * _squish4D;
					
					//Other two points are based on the shared axes.
					byte c = (byte)(aPoint & bPoint);
					
					if ((c & 0x01) != 0) {
						xsv_ext0 = xsb + 2;
						xsv_ext1 = xsb + 1;
						dx_ext0 = dx0 - 2 - 3 * _squish4D;
						dx_ext1 = dx0 - 1 - 3 * _squish4D;
					} else {
						xsv_ext0 = xsv_ext1 = xsb;
						dx_ext0 = dx_ext1 = dx0 - 3 * _squish4D;
					}
					
					if ((c & 0x02) != 0) {
						ysv_ext0 = ysv_ext1 = ysb + 1;
						dy_ext0 = dy_ext1 = dy0 - 1 - 3 * _squish4D;
						if ((c & 0x01) == 0)
						{
							ysv_ext0 += 1;
							dy_ext0 -= 1;
						} else {
							ysv_ext1 += 1;
							dy_ext1 -= 1;
						}
					} else {
						ysv_ext0 = ysv_ext1 = ysb;
						dy_ext0 = dy_ext1 = dy0 - 3 * _squish4D;
					}
					
					if ((c & 0x04) != 0) {
						zsv_ext0 = zsv_ext1 = zsb + 1;
						dz_ext0 = dz_ext1 = dz0 - 1 - 3 * _squish4D;
						if ((c & 0x03) == 0)
						{
							zsv_ext0 += 1;
							dz_ext0 -= 1;
						} else {
							zsv_ext1 += 1;
							dz_ext1 -= 1;
						}
					} else {
						zsv_ext0 = zsv_ext1 = zsb;
						dz_ext0 = dz_ext1 = dz0 - 3 * _squish4D;
					}
					
					if ((c & 0x08) != 0)
					{
						wsv_ext0 = wsb + 1;
						wsv_ext1 = wsb + 2;
						dw_ext0 = dw0 - 1 - 3 * _squish4D;
						dw_ext1 = dw0 - 2 - 3 * _squish4D;
					} else {
						wsv_ext0 = wsv_ext1 = wsb;
						dw_ext0 = dw_ext1 = dw0 - 3 * _squish4D;
					}
				}
			} else { //One point on each "side"
				byte c1, c2;
				if (aIsBiggerSide) {
					c1 = aPoint;
					c2 = bPoint;
				} else {
					c1 = bPoint;
					c2 = aPoint;
				}
				
				//Two contributions are the bigger-sided point with each 1 replaced with 2.
				if ((c1 & 0x01) != 0) {
					xsv_ext0 = xsb + 2;
					xsv_ext1 = xsb + 1;
					dx_ext0 = dx0 - 2 - 3 * _squish4D;
					dx_ext1 = dx0 - 1 - 3 * _squish4D;
				} else {
					xsv_ext0 = xsv_ext1 = xsb;
					dx_ext0 = dx_ext1 = dx0 - 3 * _squish4D;
				}
				
				if ((c1 & 0x02) != 0) {
					ysv_ext0 = ysv_ext1 = ysb + 1;
					dy_ext0 = dy_ext1 = dy0 - 1 - 3 * _squish4D;
					if ((c1 & 0x01) == 0) {
						ysv_ext0 += 1;
						dy_ext0 -= 1;
					} else {
						ysv_ext1 += 1;
						dy_ext1 -= 1;
					}
				} else {
					ysv_ext0 = ysv_ext1 = ysb;
					dy_ext0 = dy_ext1 = dy0 - 3 * _squish4D;
				}
				
				if ((c1 & 0x04) != 0) {
					zsv_ext0 = zsv_ext1 = zsb + 1;
					dz_ext0 = dz_ext1 = dz0 - 1 - 3 * _squish4D;
					if ((c1 & 0x03) == 0) {
						zsv_ext0 += 1;
						dz_ext0 -= 1;
					} else {
						zsv_ext1 += 1;
						dz_ext1 -= 1;
					}
				} else {
					zsv_ext0 = zsv_ext1 = zsb;
					dz_ext0 = dz_ext1 = dz0 - 3 * _squish4D;
				}
				
				if ((c1 & 0x08) != 0) {
					wsv_ext0 = wsb + 1;
					wsv_ext1 = wsb + 2;
					dw_ext0 = dw0 - 1 - 3 * _squish4D;
					dw_ext1 = dw0 - 2 - 3 * _squish4D;
				} else {
					wsv_ext0 = wsv_ext1 = wsb;
					dw_ext0 = dw_ext1 = dw0 - 3 * _squish4D;
				}

				//One contribution is a permutation of (1,1,1,-1) based on the smaller-sided point
				xsv_ext2 = xsb + 1;
				ysv_ext2 = ysb + 1;
				zsv_ext2 = zsb + 1;
				wsv_ext2 = wsb + 1;
				dx_ext2 = dx0 - 1 - 2 * _squish4D;
				dy_ext2 = dy0 - 1 - 2 * _squish4D;
				dz_ext2 = dz0 - 1 - 2 * _squish4D;
				dw_ext2 = dw0 - 1 - 2 * _squish4D;
				if ((c2 & 0x01) == 0) {
					xsv_ext2 -= 2;
					dx_ext2 += 2;
				} else if ((c2 & 0x02) == 0) {
					ysv_ext2 -= 2;
					dy_ext2 += 2;
				} else if ((c2 & 0x04) == 0) {
					zsv_ext2 -= 2;
					dz_ext2 += 2;
				} else {
					wsv_ext2 -= 2;
					dw_ext2 += 2;
				}
			}
			
			//Contribution (1,1,1,0)
			double dx4 = dx0 - 1 - 3 * _squish4D;
			double dy4 = dy0 - 1 - 3 * _squish4D;
			double dz4 = dz0 - 1 - 3 * _squish4D;
			double dw4 = dw0 - 3 * _squish4D;
			double attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
			if (attn4 > 0) {
				attn4 *= attn4;
				value += attn4 * attn4 * extrapolate(xsb + 1, ysb + 1, zsb + 1, wsb + 0, dx4, dy4, dz4, dw4);
			}

			//Contribution (1,1,0,1)
			double dx3 = dx4;
			double dy3 = dy4;
			double dz3 = dz0 - 3 * _squish4D;
			double dw3 = dw0 - 1 - 3 * _squish4D;
			double attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
			if (attn3 > 0) {
				attn3 *= attn3;
				value += attn3 * attn3 * extrapolate(xsb + 1, ysb + 1, zsb + 0, wsb + 1, dx3, dy3, dz3, dw3);
			}

			//Contribution (1,0,1,1)
			double dx2 = dx4;
			double dy2 = dy0 - 3 * _squish4D;
			double dz2 = dz4;
			double dw2 = dw3;
			double attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
			if (attn2 > 0) {
				attn2 *= attn2;
				value += attn2 * attn2 * extrapolate(xsb + 1, ysb + 0, zsb + 1, wsb + 1, dx2, dy2, dz2, dw2);
			}

			//Contribution (0,1,1,1)
			double dx1 = dx0 - 3 * _squish4D;
			double dz1 = dz4;
			double dy1 = dy4;
			double dw1 = dw3;
			double attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
			if (attn1 > 0) {
				attn1 *= attn1;
				value += attn1 * attn1 * extrapolate(xsb + 0, ysb + 1, zsb + 1, wsb + 1, dx1, dy1, dz1, dw1);
			}
			
			//Contribution (1,1,0,0)
			double dx5 = dx0 - 1 - 2 * _squish4D;
			double dy5 = dy0 - 1 - 2 * _squish4D;
			double dz5 = dz0 - 0 - 2 * _squish4D;
			double dw5 = dw0 - 0 - 2 * _squish4D;
			double attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5 - dw5 * dw5;
			if (attn5 > 0) {
				attn5 *= attn5;
				value += attn5 * attn5 * extrapolate(xsb + 1, ysb + 1, zsb + 0, wsb + 0, dx5, dy5, dz5, dw5);
			}
			
			//Contribution (1,0,1,0)
			double dx6 = dx0 - 1 - 2 * _squish4D;
			double dy6 = dy0 - 0 - 2 * _squish4D;
			double dz6 = dz0 - 1 - 2 * _squish4D;
			double dw6 = dw0 - 0 - 2 * _squish4D;
			double attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6 - dw6 * dw6;
			if (attn6 > 0) {
				attn6 *= attn6;
				value += attn6 * attn6 * extrapolate(xsb + 1, ysb + 0, zsb + 1, wsb + 0, dx6, dy6, dz6, dw6);
			}

			//Contribution (1,0,0,1)
			double dx7 = dx0 - 1 - 2 * _squish4D;
			double dy7 = dy0 - 0 - 2 * _squish4D;
			double dz7 = dz0 - 0 - 2 * _squish4D;
			double dw7 = dw0 - 1 - 2 * _squish4D;
			double attn7 = 2 - dx7 * dx7 - dy7 * dy7 - dz7 * dz7 - dw7 * dw7;
			if (attn7 > 0) {
				attn7 *= attn7;
				value += attn7 * attn7 * extrapolate(xsb + 1, ysb + 0, zsb + 0, wsb + 1, dx7, dy7, dz7, dw7);
			}
			
			//Contribution (0,1,1,0)
			double dx8 = dx0 - 0 - 2 * _squish4D;
			double dy8 = dy0 - 1 - 2 * _squish4D;
			double dz8 = dz0 - 1 - 2 * _squish4D;
			double dw8 = dw0 - 0 - 2 * _squish4D;
			double attn8 = 2 - dx8 * dx8 - dy8 * dy8 - dz8 * dz8 - dw8 * dw8;
			if (attn8 > 0) {
				attn8 *= attn8;
				value += attn8 * attn8 * extrapolate(xsb + 0, ysb + 1, zsb + 1, wsb + 0, dx8, dy8, dz8, dw8);
			}
			
			//Contribution (0,1,0,1)
			double dx9 = dx0 - 0 - 2 * _squish4D;
			double dy9 = dy0 - 1 - 2 * _squish4D;
			double dz9 = dz0 - 0 - 2 * _squish4D;
			double dw9 = dw0 - 1 - 2 * _squish4D;
			double attn9 = 2 - dx9 * dx9 - dy9 * dy9 - dz9 * dz9 - dw9 * dw9;
			if (attn9 > 0) {
				attn9 *= attn9;
				value += attn9 * attn9 * extrapolate(xsb + 0, ysb + 1, zsb + 0, wsb + 1, dx9, dy9, dz9, dw9);
			}
			
			//Contribution (0,0,1,1)
			double dx10 = dx0 - 0 - 2 * _squish4D;
			double dy10 = dy0 - 0 - 2 * _squish4D;
			double dz10 = dz0 - 1 - 2 * _squish4D;
			double dw10 = dw0 - 1 - 2 * _squish4D;
			double attn10 = 2 - dx10 * dx10 - dy10 * dy10 - dz10 * dz10 - dw10 * dw10;
			if (attn10 > 0) {
				attn10 *= attn10;
				value += attn10 * attn10 * extrapolate(xsb + 0, ysb + 0, zsb + 1, wsb + 1, dx10, dy10, dz10, dw10);
			}
		}
 
		//First extra vertex
		double attn_ext0 = 2 - dx_ext0 * dx_ext0 - dy_ext0 * dy_ext0 - dz_ext0 * dz_ext0 - dw_ext0 * dw_ext0;
		if (attn_ext0 > 0)
		{
			attn_ext0 *= attn_ext0;
			value += attn_ext0 * attn_ext0 * extrapolate(xsv_ext0, ysv_ext0, zsv_ext0, wsv_ext0, dx_ext0, dy_ext0, dz_ext0, dw_ext0);
		}

		//Second extra vertex
		double attn_ext1 = 2 - dx_ext1 * dx_ext1 - dy_ext1 * dy_ext1 - dz_ext1 * dz_ext1 - dw_ext1 * dw_ext1;
		if (attn_ext1 > 0)
		{
			attn_ext1 *= attn_ext1;
			value += attn_ext1 * attn_ext1 * extrapolate(xsv_ext1, ysv_ext1, zsv_ext1, wsv_ext1, dx_ext1, dy_ext1, dz_ext1, dw_ext1);
		}

		//Third extra vertex
		double attn_ext2 = 2 - dx_ext2 * dx_ext2 - dy_ext2 * dy_ext2 - dz_ext2 * dz_ext2 - dw_ext2 * dw_ext2;
		if (attn_ext2 > 0)
		{
			attn_ext2 *= attn_ext2;
			value += attn_ext2 * attn_ext2 * extrapolate(xsv_ext2, ysv_ext2, zsv_ext2, wsv_ext2, dx_ext2, dy_ext2, dz_ext2, dw_ext2);
		}

		return value / _norm4D;
	}
  */
