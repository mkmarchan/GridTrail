public class CheckPosState {
  Pos checkPos;
  boolean[][] travelled;
  boolean checked;
  Path path;
  
  public CheckPosState(Pos checkPos, boolean[][] travelled, Path p) {
    this.checkPos = checkPos;
    checked = false;
    this.travelled = new boolean[travelled.length][travelled[0].length];
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        this.travelled[i][j] = travelled[i][j];
      }
    }
    path = new Path(checkPos, p);
  }
  
  public boolean isDone() {
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        if (!travelled[i][j]) {
          return true;
        }
      }
    }
    
    return false;
  }
  
}
