public class Path {
  LinkedList<Pos> path;
  
  public Path() {
    path = new LinkedList<Pos>();
  }
  
  public Path(Pos p) {
    path = new LinkedList<Pos>();
    this.addStep(p);
  }
  
  public Path(Pos p, Path path) {
    this.path = (LinkedList<Pos>) path.path.clone();
    this.addStep(p);
  }
  
  public void addStep(Pos p) {
    path.addLast(p);
  }
  
  public Pos removeStep() {
    return path.remove();
  }
  
  public Pos peekStep() {
    return path.getFirst();
  }
}
