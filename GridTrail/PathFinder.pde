// todo: check skip free and buckets

public class PathFinder {
  boolean failed;
  int initXPos, initYPos;
  int xPos, yPos;
  int tileSize;
  boolean[][] travelled;
  boolean[][] travelledCheck;
  int gridWidth, gridHeight;
  boolean checkingIslandSplit;
  Queue<Pair<Integer, Integer>> q;
  int xPosA, yPosA, xPosB, yPosB;
  int xPosC, yPosC, checkedXPos, checkedYPos;
  Set<Pair<Integer, Integer>> buckets;
  Set<Pair<Integer, Integer>> islandSplitsToCheck;
  Map<Pair<Integer, Integer>, Boolean> posWontSplitIsland;
  

  public PathFinder(int gridWidth, int gridHeight, int xPos, int yPos, int tileSize) {
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    initXPos = xPos;
    initYPos = yPos;
    this.tileSize = tileSize;
    reset();
  }

  public void reset() {
    failed = false;
    xPos = initXPos;
    yPos = initYPos;
    travelled = new boolean[gridHeight][gridWidth];
    checkingIslandSplit = false;
    travelled[initYPos][initXPos] = true;
    buckets = new HashSet<Pair<Integer, Integer>>();
    islandSplitsToCheck = new HashSet<Pair<Integer, Integer>>();
    posWontSplitIsland = new HashMap<Pair<Integer, Integer>, Boolean>();
  }

  public void update() {
    println("\n\nPre xPos: " + xPos + " yPos: " + yPos);
    choosePosition();
    if (failed || (!checkingIslandSplit && posWontSplitIsland.isEmpty() && islandSplitsToCheck.isEmpty()) && travelled[yPos][xPos] == true) {
      println("BUG!");
      while (true) {
      }
    }

    travelled[yPos][xPos] = true;
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

    if (checkingIslandSplit) {
      fill(255, 0, 0);
      for (int i = 0; i < travelled.length; i++) {
        for (int j = 0; j < travelled[i].length; j++) {
          if (travelledCheck[i][j]) {
            rect(j * tileSize, i * tileSize, floor(tileSize / 2), floor(tileSize / 2));
          }
        }
      }
    }

    fill(128);
    rect(xPos * tileSize, yPos * tileSize, floor(tileSize / 2), floor(tileSize / 2));
  }

  private void choosePosition() {
    if (islandSplitsToCheck.size() > 0) {
      Iterator<Pair<Integer, Integer>> it = islandSplitsToCheck.iterator();
      Pair<Integer, Integer> posToCheck = it.next();
      it.remove();
      setUpIslandSplitCheck(posToCheck.getKey(), posToCheck.getValue());
    }
    
    if (!checkingIslandSplit) {
      ArrayList<Integer> choices = new ArrayList<Integer>();
      boolean rightFree = xPos < gridWidth - 1 && !travelled[yPos][xPos + 1];
      boolean rightSkipFree = xPos < gridWidth - 2 && !travelled[yPos][xPos + 2];
      boolean rightDoubleSkipFree = xPos < gridWidth - 3 && !travelled[yPos][xPos + 3];
      boolean upRightFree = xPos < gridWidth - 1  && yPos > 0 && !travelled[yPos - 1][xPos + 1];
      boolean downRightFree = xPos < gridWidth - 1  && yPos < gridHeight - 1 && !travelled[yPos + 1][xPos + 1];
      boolean upFree = yPos > 0 && !travelled[yPos - 1][xPos];
      boolean upSkipFree = yPos > 1 && !travelled[yPos - 2][xPos];
      boolean upDoubleSkipFree = yPos > 3 && !travelled[yPos - 3][xPos];
      boolean upLeftFree = xPos > 0 && yPos > 0 && !travelled[yPos - 1][xPos - 1];
      boolean leftFree = xPos > 0 && !travelled[yPos][xPos - 1];
      boolean leftSkipFree = xPos > 1 && !travelled[yPos][xPos - 2];
      boolean leftDoubleSkipFree = xPos > 2 && !travelled[yPos][xPos - 3];
      boolean downLeftFree = xPos > 0 && yPos < gridHeight - 1 && !travelled[yPos + 1][xPos - 1];
      boolean downFree = yPos < gridHeight - 1 && !travelled[yPos + 1][xPos];
      boolean downSkipFree = yPos < gridHeight - 2 && !travelled[yPos + 2][xPos];
      boolean downDoubleSkipFree = yPos < gridHeight - 3 && !travelled[yPos + 3][xPos];
      
      Map<Pair<Integer, Integer>, Set<Pair<Integer, Integer>>> bucketsToAdd = new HashMap<Pair<Integer, Integer>, Set<Pair<Integer, Integer>>>();
      Set<Integer> makeBucketChoices = new HashSet<Integer>();

      if (choices.size() == 0) {
        // Phase B
        if (rightFree) {
          println("checking right");
          int newXPos = xPos + 1;
          int newYPos = yPos;
          Pair<Integer, Integer> thisPos = new Pair(newXPos, newYPos);
          boolean isGood = false;
          boolean checkedIslandSplit = posWontSplitIsland.containsKey(thisPos);
          
          if (!upRightFree || !downRightFree) {
            isGood = true;
          } else if (rightSkipFree) {
            isGood = true;
          } else if (checkedIslandSplit) {
            if (posWontSplitIsland.get(thisPos)) {
              isGood = true;
            }
          } else if (!rightSkipFree && !checkedIslandSplit) {
            islandSplitsToCheck.add(thisPos);
          }

          if (isGood) {
            boolean upRightMakesABucket = upRightFree && willMakeABucket(newXPos, newYPos, newXPos, newYPos - 1);
            boolean downRightMakesABucket = downRightFree && willMakeABucket(newXPos, newYPos, newXPos, newYPos + 1);
            boolean rightSkipMakesABucket = rightSkipFree && willMakeABucket(newXPos, newYPos, newXPos + 1, newYPos);
            boolean willMakeABucket = upRightMakesABucket || downRightMakesABucket || rightSkipMakesABucket;
            Set<Pair<Integer, Integer>> createdBuckets = new HashSet<Pair<Integer, Integer>>();
            
            if (willMakeABucket) {
              makeBucketChoices.add(0);
            }
            if (buckets.isEmpty() || !willMakeABucket || buckets.contains(thisPos)) {
              if (upRightMakesABucket) {
                createdBuckets.add(new Pair(newXPos, newYPos - 1));
              }
              if (downRightMakesABucket) {
                createdBuckets.add(new Pair(newXPos, newYPos + 1));
              }
              if (rightSkipMakesABucket) {
                createdBuckets.add(new Pair(newXPos + 1, newYPos));
              }
              choices.add(0);
            }
            bucketsToAdd.put(thisPos, createdBuckets);
          }
        }
        if (upFree) {
          println("checking up");
          int newXPos = xPos;
          int newYPos = yPos - 1;
          Pair<Integer, Integer> thisPos = new Pair(newXPos, newYPos);
          boolean isGood = false;
          boolean checkedIslandSplit = posWontSplitIsland.containsKey(thisPos);
          
          if (!upRightFree || !upLeftFree) {
            isGood = true;
          } else if (upSkipFree) {
            isGood = true;
          } else if (checkedIslandSplit) {
            if (posWontSplitIsland.get(thisPos)) {
              isGood = true;
            }
          } else if (!upSkipFree && !checkedIslandSplit) {
            islandSplitsToCheck.add(thisPos);
          }
          
          if (isGood) {
            boolean upRightMakesABucket = upRightFree && willMakeABucket(newXPos, newYPos, newXPos + 1, newYPos);
            boolean upLeftMakesABucket = upLeftFree && willMakeABucket(newXPos, newYPos, newXPos - 1, newYPos);
            boolean upSkipMakesABucket = upSkipFree && willMakeABucket(newXPos, newYPos, newXPos, newYPos - 1);
            boolean willMakeABucket = upRightMakesABucket || upLeftMakesABucket || upSkipMakesABucket;
            Set<Pair<Integer, Integer>> createdBuckets = new HashSet<Pair<Integer, Integer>>();
            
            if (willMakeABucket) {
              makeBucketChoices.add(1);
            }
            if (buckets.isEmpty() || !willMakeABucket || buckets.contains(thisPos)) {
              if (upRightMakesABucket) {
                createdBuckets.add(new Pair(newXPos + 1, newYPos));
              }
              if (upLeftMakesABucket) {
                createdBuckets.add(new Pair(newXPos - 1, newYPos));
              }
              if (upSkipMakesABucket) {
                createdBuckets.add(new Pair(newXPos, newYPos - 1));
              }
              
              choices.add(1);
            }
            bucketsToAdd.put(thisPos, createdBuckets);
          }
        }
        if (leftFree) {
          println("checking left");
          int newXPos = xPos - 1;
          int newYPos = yPos;
          Pair<Integer, Integer> thisPos = new Pair(newXPos, newYPos);
          boolean isGood = false;
          boolean checkedIslandSplit = posWontSplitIsland.containsKey(thisPos);
          
          if (!upLeftFree || !downLeftFree) {
            isGood = true;
          } else if (leftSkipFree) {
            isGood = true;
          } else if (checkedIslandSplit) {
            if (posWontSplitIsland.get(thisPos)) {
              isGood = true;
            }
          } else if (!leftSkipFree && !checkedIslandSplit) {
            islandSplitsToCheck.add(thisPos);
          }
          
          if (isGood) {
            boolean downLeftMakesABucket = downLeftFree && willMakeABucket(newXPos, newYPos, newXPos, newYPos + 1);
            boolean upLeftMakesABucket = upLeftFree && willMakeABucket(newXPos, newYPos, newXPos, newYPos - 1);
            boolean leftSkipMakesABucket = leftSkipFree && willMakeABucket(newXPos, newYPos, newXPos - 1, newYPos);
            boolean willMakeABucket = downLeftMakesABucket || upLeftMakesABucket || leftSkipMakesABucket;
            Set<Pair<Integer, Integer>> createdBuckets = new HashSet<Pair<Integer, Integer>>();
            
            if (willMakeABucket) {
              makeBucketChoices.add(2);
            }
            if (buckets.isEmpty() || !willMakeABucket || buckets.contains(thisPos)) {
              if (downLeftMakesABucket) {
                createdBuckets.add(new Pair(newXPos, newYPos + 1));
              }
              if (upLeftMakesABucket) {
                createdBuckets.add(new Pair(newXPos, newYPos - 1));
              }
              if (leftSkipMakesABucket) {
                createdBuckets.add(new Pair(newXPos - 1, newYPos));
              }
              
              choices.add(2);
            }
            bucketsToAdd.put(thisPos, createdBuckets);
          }
        }
        if (downFree) {
          println("checking down");
          int newXPos = xPos;
          int newYPos = yPos + 1;
          Pair<Integer, Integer> thisPos = new Pair(newXPos, newYPos);
          boolean isGood = false;
          boolean checkedIslandSplit = posWontSplitIsland.containsKey(thisPos);
          
          if (!downLeftFree || !downRightFree) {
            isGood = true;
          } else if (downSkipFree) {
            isGood = true;
          } else if (checkedIslandSplit) {
            if (posWontSplitIsland.get(thisPos)) {
              isGood = true;
            }
          } else if (!downSkipFree && !checkedIslandSplit) {
            islandSplitsToCheck.add(thisPos);
          }
          
          if (isGood) {
            boolean downLeftMakesABucket = downLeftFree && willMakeABucket(newXPos, newYPos, newXPos - 1, newYPos);
            boolean downRightMakesABucket = downRightFree && willMakeABucket(newXPos, newYPos, newXPos + 1, newYPos);
            boolean downSkipMakesABucket = downSkipFree && willMakeABucket(newXPos, newYPos, newXPos, newYPos + 1);
            boolean willMakeABucket = downLeftMakesABucket || downRightMakesABucket || downSkipMakesABucket;
            Set<Pair<Integer, Integer>> createdBuckets = new HashSet<Pair<Integer, Integer>>();

            if (willMakeABucket) {
              makeBucketChoices.add(3);
            }
            if (buckets.isEmpty() || !willMakeABucket || buckets.contains(thisPos)) {
              if (downLeftMakesABucket) {
                createdBuckets.add(new Pair(newXPos - 1, newYPos));
              }
              if (downRightMakesABucket) {
                createdBuckets.add(new Pair(newXPos + 1, newYPos));
              }
              if (downSkipMakesABucket) {
                createdBuckets.add(new Pair(newXPos, newYPos + 1));
              }
              
              choices.add(3);
            }
            bucketsToAdd.put(thisPos, createdBuckets);
          }
        }
      }
      
      if (islandSplitsToCheck.size() > 0) {
        return;
      }
      
      if (choices.size() == 0) {
        choices.addAll(makeBucketChoices);
        if (choices.size() == 0) {
          if (rightFree && !upFree && !leftFree && !downFree) {
            choices.add(0);
          } else if (!rightFree && upFree && !leftFree && !downFree) {
            choices.add(1);
          } else if (!rightFree && !upFree && leftFree && !downFree) {
            choices.add(2);
          } else if (!rightFree && !upFree && !leftFree && downFree) {
            choices.add(3);
          }
        }
      }


      println(choices);
      if (choices.size() > 0) {
        switch(choices.get(floor(random(choices.size())))) {
        case 0:
          this.xPos += 1;
          break;
        case 1:
          this.yPos -= 1;
          break;
        case 2:
          this.xPos -= 1;
          break;
        case 3:
          this.yPos += 1;
          break;
        }
        
        buckets.remove(new Pair(xPos, yPos));
        Set<Pair<Integer, Integer>> bucketsBeingAdded = bucketsToAdd.get(new Pair(xPos, yPos));
        println("buckets to add: " + bucketsToAdd);
        println("buckets being added: " + bucketsBeingAdded);
        if (bucketsBeingAdded != null) {
          buckets.addAll(bucketsBeingAdded);
        }
        posWontSplitIsland.clear();
      } else {
        println("No choices.");
        failed = true;
        println("bucketSize: " + buckets.size());
        for (Pair<Integer, Integer> pos : buckets) {
          println(pos);
        }
      }
    } else {
      if (!q.isEmpty()) {
        println(q);
        //delay(500);
        Pair<Integer, Integer> pos = q.remove();
        xPosC = pos.getKey();
        yPosC = pos.getValue();
        println("IslandCheckingPos " + xPosC + " " + yPosC);
        if (xPosC == xPosB && yPosC == yPosB) {
          checkingIslandSplit = false;
          posWontSplitIsland.put(new Pair(checkedXPos, checkedYPos), true);
          println("WONT SPLIT MOVING TO " + checkedXPos + " " + checkedYPos);
          return;
        }

        // right
        if (xPosC  < gridWidth - 1 && !travelledCheck[yPosC][xPosC + 1]) {
          travelledCheck[yPosC][xPosC + 1] = true;
          q.add(new Pair(xPosC + 1, yPosC));
        }
        // up
        if (yPosC > 0 && !travelledCheck[yPosC - 1][xPosC]) {
          travelledCheck[yPosC - 1][xPosC] = true;
          q.add(new Pair(xPosC, yPosC - 1));
        }
        // left
        if (xPosC > 0 && !travelledCheck[yPosC][xPosC - 1]) {
          travelledCheck[yPosC][xPosC - 1] = true;
          q.add(new Pair(xPosC - 1, yPosC));
        }
        // down
        if (yPosC < gridWidth - 1 && !travelledCheck[yPosC + 1][xPosC]) {
          travelledCheck[yPosC + 1][xPosC] = true;
          q.add(new Pair(xPosC, yPosC + 1));
        }
      } else {
        checkingIslandSplit = false;
        posWontSplitIsland.put(new Pair(checkedXPos, checkedYPos), false);
        println("WILL SPLIT MOVING TO " + checkedXPos + " " + checkedYPos);
      }
    }
  } 

  public void setUpIslandSplitCheck(int newXPos, int newYPos) {
    checkedXPos = newXPos;
    checkedYPos = newYPos;
    checkingIslandSplit = true;
    int xDiff = newXPos - xPos;
    int yDiff = newYPos - yPos;
    travelledCheck = new boolean[gridHeight][gridWidth];
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        travelledCheck[i][j] = travelled[i][j];
      }
    }

    travelledCheck[newYPos][newXPos] = true;
    xPosA = newXPos + yDiff;
    yPosA = newYPos + xDiff;
    xPosB = newXPos - yDiff;
    yPosB = newYPos - xDiff;
    xPosC = xPosA;
    yPosC = yPosA;
    q = new LinkedList<Pair<Integer, Integer>>();
    q.add(new Pair(xPosC, yPosC));
    travelledCheck[newYPos][newXPos] = true;
  }

  public boolean isDone() {
    for (int i = 0; i < travelled.length; i++) {
      for (int j = 0; j < travelled[i].length; j++) {
        if (!travelled[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  private boolean willMakeABucket(int xPosCheck, int yPosCheck, int xPos, int yPos) {
    int numOpen = 4;
    travelled[yPosCheck][xPosCheck] = true;
    if (xPos == gridWidth - 1 || xPos < gridWidth - 1 && travelled[yPos][xPos + 1]) {
      numOpen--;
    }
    if (yPos == 0 || yPos > 0 && travelled[yPos - 1][xPos]) {
      numOpen--;
    }
    if (xPos == 0 || xPos > 0 && travelled[yPos][xPos - 1]) {
      numOpen--;
    }
    if (yPos == gridHeight - 1 || yPos < gridHeight - 1 && travelled[yPos + 1][xPos]) {
      numOpen--;
    }
    boolean willMakeABucket = numOpen == 1;
    travelled[yPosCheck][xPosCheck] = false;
    return willMakeABucket;
  }
}
