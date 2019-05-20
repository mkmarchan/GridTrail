// todo: bug when not choosing tile on path

public class PathFinder {
  Pos initPos;
  Pos currentPos;
  Pos randomPreChoice;
  CheckPosState curCheckState;
  List<Pos> availablePositions;
  Queue<Pos> toCheck;
  Stack<CheckPosState> s;
  List<Pos> areGood;
  List<Path> goodPaths;
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
    goodPaths = new ArrayList<Path>();
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
        
        randomPreChoice = availablePositions.get(floor(random(availablePositions.size())));
        for (Pos p : availablePositions) {
          int xDiff = p.x - currentPos.x;
          int yDiff = p.y - currentPos.y;
          boolean onPath = false;
          boolean isGood = false;
          
          for (Path path : goodPaths) {
            if (path.peekStep().Equals(p)) {
              isGood = true;
              areGood.add(p);
              onPath = true;
              break;
            }
          }
          
          if (!onPath) {
            if (false && isFree(new Pos(p.x + xDiff, p.y + yDiff), travelled) && isFree(new Pos(p.x + 2 * xDiff, p.y + 2 * yDiff), travelled)) {
              isGood = true;
              areGood.add(p);
            } else {
              toCheck.add(p);
            }
          }
          if (isGood && p.Equals(randomPreChoice)) {
            toCheck.clear();
            break;
          }
            
        }
      } else {
        if (areGood.contains(randomPreChoice)) {
          currentPos = randomPreChoice;
        } else {
          currentPos = areGood.get(floor(random(areGood.size())));
        }
        areGood.clear();
        availablePositions.clear();
        
        Path onPath = null;
        
        for (Path path : goodPaths) {
          if (path.peekStep().Equals(currentPos)) {
            onPath = path;
            path.removeStep();
            break;
          }
        }
        
        goodPaths = new ArrayList<Path>();
        if (onPath != null) {
          goodPaths.add(onPath);
        }
        
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
        Pos newCheckPos = toCheck.remove();
        curCheckState = new CheckPosState(newCheckPos, travelled, new Path(newCheckPos));
        
        curCheckState.travelled[curCheckState.checkPos.y][curCheckState.checkPos.x] = true;
        curCheckState.checked = true;
        
        List<Pos> nextMoves = availablePositions(curCheckState.checkPos, curCheckState.travelled);
        
        s.push(curCheckState);
        for (Pos move : nextMoves) {
          curCheckState.travelled[move.y][move.x] = true;
          s.push(new CheckPosState(move, curCheckState.travelled, curCheckState.path));
          curCheckState.travelled[move.y][move.x] = false;
        }
      }
      
      // no possible trail found
      if (s.isEmpty()) {
        curCheckState = null;
      } else {
        curCheckState = s.pop();
        List<Pos> nextMoves = availablePositions(curCheckState.checkPos, curCheckState.travelled);
        
        if (nextMoves.isEmpty() && isDone(curCheckState.travelled)){
          areGood.add(curCheckState.path.peekStep());
          curCheckState.path.removeStep();
          goodPaths.add(curCheckState.path);
          
          if (randomPreChoice.Equals(curCheckState.path.peekStep())) {
            toCheck.clear();
          }
          curCheckState = null;
          return;
        } else if (curCheckState.checked) {
          return;
        } else {
          curCheckState.checked = true;
          for (Pos move : nextMoves) {
            curCheckState.travelled[move.y][move.x] = true;
            s.push(new CheckPosState(move, curCheckState.travelled, curCheckState.path));
            curCheckState.travelled[move.y][move.x] = false;
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
            rect(j * tileSize + floor(3 * tileSize / 8), i * tileSize + floor(3 * tileSize / 8), floor(tileSize / 4), floor(tileSize / 4));
          }
        }
      }
    }
    
    
    for (int i = 0; i < availablePositions.size(); i++) {
      Pos thisPos = availablePositions.get(i);
      if (areGood.contains(thisPos)) {
        fill(0, 255, 0);
      } else if (toCheck.contains(thisPos) || curCheckState != null && curCheckState.path.peekStep().Equals(thisPos)) {
        fill(0, 0, 255);
      } else {
        fill(255, 0, 0);
      }
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
