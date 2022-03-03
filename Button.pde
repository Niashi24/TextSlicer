public class Button {
  int x, y, w, h;
  String label;
  
  color def = color(216);
  color dark = color(128);
  
  boolean highlighted = false;
  
  public Button(int x, int y, int w, int h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  public void paint() {
    fill(highlighted ? dark : def);
    stroke(0);
    rect(x, y, w, h);
    
    fill(0);
    text(label, x + 10, y + h/2);
  }
  
  public void update() {
    if (contains(mouseX, mouseY)) {
      highlighted = true;
    } else {
      highlighted = false;
    }
  }
  
  public boolean pressed() {
    return mousePressed && contains(mouseX, mouseY);
  }
  
  public boolean contains(int x, int y) {
    //println("x: " + this.x + ", y: " + this.y + ", w: " + w + ", h: " + h);
    //println("x: " + x + ", y: " + y);
    return x > this.x && x < this.x + w && y < this.h + this.y && y > this.y;
  }
}
