// todo: check skip free and buckets

public class PathFinder {
  Pos initPos;
  Pos currentPos;
  Pos curCheckPos;
  CheckPosState curCheckState;
  List<Pos> availablePositions;
  Queue<Pos> toCheck;
  Stack<CheckPosState> s;
  List<Pos> areGood;
  int tileSize;
  boolean[][] travelled;
  int gridWidth, gridHeight;
  

  public PathFinder(int gridWidth, int gridHeight, int xPos, int yPos, int tileSize) {
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    initPos = new Pos(xPos, yPos);
    this.tileSize = tileSize;
    reset();
  }

  public void reset() {
    curCheckState = null;
    toCheck = new LinkedList<Pos>();
    areGood = new ArrayList<Pos>();
    currentPos = initPos.getCopy();
    travelled = new boolean[gridHeight][gridWidth];
    travelled[currentPos.y][currentPos.x] = true;
  }
  
  // if checked or no available positions and leads to dead end, don't add to areGood and pop curCheckState
  // if no available positions and does not lead to dead end, add to are good and stop checking
  // if available positions, add available positions to stack

  public void update() {
    if (toCheck.isEmpty() && curCheckState == null) {
      if (areGood.isEmpty()) {
        //println("Current Position: " + currentPos);
        availablePositions = availablePositions(currentPos, travelled);
        //println("Available position: " + availablePositions);
        toCheck.addAll(availablePositions);
      } else {
        currentPos = areGood.get(floor(random(areGood.size())));
        areGood.clear();
        
        if (travelled[currentPos.y][currentPos.x] == true) {
          //println("BUG!");
          while (true) {
          }
        }
        
        travelled[currentPos.y][currentPos.x] = true;
      }
    } else {
      if (curCheckState == null) {
        s = new Stack<CheckPosState>();
        curCheckState = new CheckPosState(toCheck.remove(), travelled);
        curCheckPos = curCheckState.checkPos;
        
        curCheckState.travelled[curCheckState.checkPos.y][curCheckState.checkPos.x] = true;
        curCheckState.checked = true;
        curCheckState.addNextMoves(availablePositions(curCheckState.checkPos, curCheckState.travelled));
        
        s.push(curCheckState);
        for (CheckPosState move : curCheckState.nextMoves) {
          s.push(move);
        }
      }
      
      // no possible trail found
      if (s.isEmpty()) {
        curCheckState = null;
      } else {
        curCheckState = s.pop();
        
        if (isDone(curCheckState.travelled)){
          curCheckState = null;
          areGood.add(curCheckPos);
          return;
        } else if (curCheckState.checked) {
          return;
        } else {
          curCheckState.checked = true;
          curCheckState.addNextMoves(availablePositions(curCheckState.checkPos, curCheckState.travelled));
          for (CheckPosState move : curCheckState.nextMoves) {
            s.push(move);
          }
        }
      }
    }
  }

  public void display() {
    stroke(0);
    fill(255);
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        if (travelled[i][j]) {
          rect(j * tileSize, i * tileSize, tileSize, tileSize);
        }
      }
    }

    if (curCheckState != null) {
      fill(0, 0, 255);
      for (int i = 0; i < travelled.length; i++) {
        for (int j = 0; j < travelled[i].length; j++) {
          if (curCheckState.travelled[i][j]) {
            rect(j * tileSize, i * tileSize, floor(tileSize / 2), floor(tileSize / 2));
          }
        }
      }
    }
    
    for (int i = 0; i < availablePositions.size(); i++) {
      Pos thisPos = availablePositions.get(i);
      fill(0, 255, 0);
      rect(thisPos.x * tileSize + floor(tileSize / 2), thisPos.y * tileSize, floor(tileSize / 2), floor(tileSize / 2));
    }

    fill(128);
    rect(currentPos.x * tileSize, currentPos.y * tileSize, floor(tileSize / 2), floor(tileSize / 2));
  }
  
  private List<Pos> availablePositions(Pos curPos, boolean[][] travelled) {
    List<Pos> choices = new ArrayList<Pos>();
    
    for (int i = 0; i < 4; i++) {
      int xOffset = (int) ((abs(1.5 - i) - 0.5) * Math.signum(1.5 - i));
      int yOffset = (int) ((1 - abs(xOffset)) * Math.signum(1.5 - i));
      Pos thisPos = new Pos(curPos.x + xOffset, curPos.y + yOffset);
      //println("Checking: " + thisPos);
      //println("isFree: " + isFree(thisPos, travelled));
      if (isFree(thisPos, travelled)) {
        choices.add(thisPos);
      }
    }
    
    return choices;
  }
  
  private boolean isFree(Pos p, boolean[][] travelled) {
    if (p.x < 0 || p.x == gridWidth) {
      return false;
    }
    
    if (p.y < 0 || p.y == gridHeight) {
      return false;
    }
    
    return !travelled[p.y][p.x];
  }

  public boolean isDone() {
    return isDone(travelled);
  }
  
  private boolean isDone(boolean[][] travelled) {
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        if (!travelled[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
}
