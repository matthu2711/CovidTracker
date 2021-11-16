//Matt
class RadioButton extends Widget {

  boolean radioChecked;

  RadioButton(int x, int y, int widgetWidth, int widgetHeight, int event, String label, int fontSize, int type, int textX, int textY, 
    int shape, boolean radioChecked) {
    super(x, y, widgetWidth, widgetHeight, event, label, fontSize, type, textX, textY, shape);
    this.radioChecked = radioChecked;
  }

  //Draws each circle option and fills in the selected one
  void draw() {
    ellipseMode(CENTER);
    stroke(0);
    fill(white);
    ellipse(x, y, widgetWidth, widgetHeight);
    fill(textColour);
    textSize(fontSize);
    textAlign(LEFT, CENTER);
    text(label, textX, textY);
    if (radioChecked) {
      fill(0);
      ellipse(x, y, widgetWidth * 2/3, widgetHeight * 2/3);
    }
  }


  //Returns the event for the specific option, and if any other option was selected prior it is deselcted, as only one can be action at a time
  int getEvent(ArrayList<RadioButton> radioList) {
    if (currentScreen.screenType == 3) {
      if (dist(x, y, mouseX, mouseY) <= widgetWidth) {
        if (!radioChecked) {
          for (RadioButton rWidget : radioList)
            rWidget.radioChecked = false;
          radioChecked = true; 
          return event;
        }
      }
    } else if (currentScreen.menu != null) {
      if (!currentScreen.menu.menuDisplay && (currentScreen.screenType == 1 || currentScreen.screenType == 4)) {
        if (dist(x, y, mouseX, mouseY) <= widgetWidth) {
          if (radioChecked == false) {
            for (RadioButton rWidget : radioList)
              rWidget.radioChecked = false;
            radioChecked = true; 
            return event;
          }
        }
      }
    }
    return EVENT_NULL;
  }
}
