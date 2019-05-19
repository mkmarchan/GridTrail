public class CheckPosState {
  Pos checkPos;
  boolean[][] travelled;
  boolean checked;
  List<CheckPosState> nextMoves;
  
  public CheckPosState(Pos checkPos, boolean[][] travelled) {
    this.checkPos = checkPos;
    nextMoves = new LinkedList<CheckPosState>();
    checked = false;
    this.travelled = new boolean[travelled.length][travelled[0].length];
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        this.travelled[i][j] = travelled[i][j];
      }
    }
  }
  
  public void addNextMoves(List<Pos> moves) {
    for (Pos move : moves) {
      travelled[move.y][move.x] = true;
      nextMoves.add(new CheckPosState(move, travelled));
      travelled[move.y][move.x] = false;
    }
  }
  
  public boolean leadsToDeadEnd() {
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        if (!travelled[i][j] && nextMoves.isEmpty()) {
          return true;
        }
      }
    }
    
    return false;
  }
  
}
