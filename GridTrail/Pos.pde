public class Pos {
  int x, y;
  
  public Pos(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public Pos getCopy() {
    return new Pos(x, y);
  }
  
  public String toString() {
    return "(" + x + "," + y + ")";
  }
  
  public boolean Equals(Pos p) {
    return x == p.x && y == p.y;
  }
  
}
