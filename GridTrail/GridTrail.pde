import java.util.*;
import javafx.util.Pair;

PathFinder p;
int width, height;
int pixelSize;

void setup() {
  width = 600;
  height = 600;
  pixelSize = 120;
  int xPos = 0 / pixelSize;
  int yPos = 0 / pixelSize;
  size(600, 600);
  p = new PathFinder(width / pixelSize, height / pixelSize, xPos, yPos, pixelSize);
}

void draw() {
  background(0);
  p.update();
  p.display();
  if (p.isDone()) {
    println("Success! Restarting...");
    p.reset();
  }
  delay(1);
}
  
