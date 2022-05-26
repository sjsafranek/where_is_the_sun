
class Point {
  double x;
  double y;
  Point(this.x, this.y);

  String toWKT() {
    return "POINT($x $y)";
  }
}