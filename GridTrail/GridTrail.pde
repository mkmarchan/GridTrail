import java.util.*;
import javafx.util.Pair;

PathFinder p;
int width, height;
int pixelSize;
Pos prevPos;

void setup() {
  width = 600;
  height = 600;
  pixelSize = 100;
  int xPos = 0 * floor(random(width) / pixelSize);
  int yPos = 0 * floor(random(height) / pixelSize);
  size(600, 600);
  p = new PathFinder(width / pixelSize, height / pixelSize, xPos, yPos, pixelSize);
}

void draw() {
  prevPos = p.currentPos;
  int startTime = millis();
  while (millis() - startTime < 1.0 / 60 && p.currentPos.Equals(prevPos)) {
      
    p.update();
  }
  if (true || !p.currentPos.Equals(prevPos)) {
    background(0);
    p.display();
  }
  if (p.isDone()) {
    println("Success! Restarting...");
    p.reset();
  }
  delay(0);
}
  
