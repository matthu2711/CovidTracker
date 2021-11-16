//Matt
class Widget {
  int x, y, widgetWidth, widgetHeight, event, fontSize, type, textX, textY, shape;
  String label;
  color labelColour, stroke;
  PFont widgetFont;
  boolean checked;


  //Shape: 1=ellipse, 0=rect //Type : 
  //Type: 1=widget button, 2=checkbox, 3=radio button, 4=textWidget, 5=dropdwon
  Widget(int x, int y, int widgetWidth, int widgetHeight, int event, String label, int fontSize, int type, int textX, int textY, int shape) {
    this.x = x; 
    this.y = y; 
    this.widgetWidth = widgetWidth; 
    this.widgetHeight = widgetHeight; 
    this.event = event; 
    this.label = label; 
    this.fontSize = fontSize;
    this.textX = textX;
    this.textY = textY;
    stroke = black;
    labelColour = color(0);
    this.type = type;
    this.shape = shape;
    checked = false;
  }

  //Draws the correct shape for the widget
  void draw() {
    strokeColour();
    ellipseMode(CORNER);
    strokeWeight(1);
    stroke(stroke);
    fill(widgetColour);
    if (shape == 0)
      rect(x, y, widgetWidth, widgetHeight);
    else if (shape == 1)
      ellipse(x, y, widgetWidth, widgetHeight);
    stroke(0);
    fill(textColour);
    textSize(fontSize);
    textAlign(LEFT, TOP);
    text(label, textX, textY);
  }

  //Returns the widgets event when the mouse is clicked and the mouse is within it's boundaries
  int getEvent(int mX, int mY) {         
    if (mX > x && mX < x + widgetWidth && mY > y && mY < y + widgetHeight) {
      click.play();
      return event;
    } else
      return EVENT_NULL;
  }

  //Daniel
  //Changes the stroke colour of the widget is the mouse is within the boundary
  void strokeColour() {
      if (mouseX > x && mouseX < x + widgetWidth && mouseY > y && mouseY < y + widgetHeight)
        stroke = emptyColour;
      else
        stroke = textColour;
    }
}
