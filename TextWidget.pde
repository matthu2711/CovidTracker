//Matt - Created Class and added UI implementation
class TextWidget extends Widget {

  int maxLen;
  String input;

  TextWidget(int x, int y, int widgetWidth, int widgetHeight, int event, String label, color widgetColour, int fontSize, int type, int textX, int textY, int shape, int maxLen) {
    super(x, y, widgetWidth, widgetHeight, event, label, fontSize, type, textX, textY, shape);
    this.maxLen = maxLen;
    input = "";
  }


  //Adds the key pressed to the widget label is it is in focus. If the key is SHIFT or CAPSLOCK it is ignored. If it is ENTER then the label is added as a
  //filter to the current table. If BACKSPACE it removes the added letters.
  void append(char s, int a) {
    if (a != 16 && a != 20) {
      if (s == BACKSPACE) {
        if (!input.equals(""))
          input = input.substring(0, input.length()-1);
      } else if (s == ENTER && currentScreen.labelList.size() < 18) {
        if (label != null) {
          currentScreen.label = input;
          input = "";
        }
        else{
          currentScreen.noData = true;
          currentScreen.label = null;
          currentScreen.duplicateFilter = false;
        }
      } else if (input.length() < maxLen)
        input = input + str(s);
    }
  }


  //Draws the textwidget box and displays the label inside it as letters are appended
  void draw() {
    strokeWeight(1);
    stroke(stroke);
    fill(white);
    rect(x, y, widgetWidth, widgetHeight);
    stroke(0);
    fill(textColour);
    textSize(fontSize);
    textAlign(LEFT, TOP);
    text(label, textX, textY);
    fill(black);
    text(input, x + 5, y + 5);
    textSize(20);
    if (!currentScreen.labelList.isEmpty()) {
      for (int i = 0, j = 0; i < currentScreen.labelList.size(); i++) {
        String labelPrint = "GeoidID: ";
        if (currentScreen.indexList.get(i).equalsIgnoreCase("county/state"))
          labelPrint = "State: ";
        else if (currentScreen.indexList.get(i).equalsIgnoreCase("area"))
          labelPrint = "Area: ";
        labelPrint = labelPrint + currentScreen.labelList.get(i);
        if (i % 2 == 0) {
          fill(widgetColour);
          rect(x - 10, (y+widgetHeight + 10) + 35 * j, widgetWidth/2 + 10, 30);
          fill(textColour);
          text(labelPrint, x - 7, (y+widgetHeight + 10) + 35 * j);
        } else {
          fill(widgetColour);
          rect(x + widgetWidth/2 + 10, (y+widgetHeight + 10) + 35 * j, widgetWidth/2 + 10, 30);
          fill(textColour);
          text(labelPrint, x + widgetWidth/2 + 13, (y+widgetHeight + 10) + 35 * j++);
        }
      }
    }
  }

  //Returns the event to focus the tectwidget is the mouse is clicked and within it's boundaries. If we click one of the existing labels, that label is removed
  //and the table is updted accordingly
  int getEvent(int mX, int mY) {         
    if (mX > x && mX < x + widgetWidth && mY > y && mY < y + widgetHeight) {
      return event;
    } else {
      if (currentScreen.screenType == 1 || currentScreen.screenType == 4) {
        for (int i = 0, j = 0; i < currentScreen.labelList.size(); i++) {
          if (i % 2 == 0 && i != 0)
            j++;
          if ((i % 2 == 0 && mX > x - 10 && mY > (y+widgetHeight + 10) + (35 * j) && mX < x + (widgetWidth/2 + 10) && mY < (y+widgetHeight + 10) + (35 * j) + 30) ||
            (i % 2 == 1 && mX > x + (widgetWidth/2 + 10) && mY > (y+widgetHeight + 10) + (35 * j) && mX < x + (widgetWidth + 10) &&
            mY < (y+widgetHeight + 10) + (35 * j) +  30)) {
            currentScreen.displayTable = data.removeLabel(currentScreen.labelList.get(i), currentScreen.indexList.get(i), currentScreen.displayTable);              
            currentScreen.resetSliders();
          } else if (i % 2 == 1 && mX > x + (widgetWidth/2 + 5) && mY > (y+widgetHeight + 10) + (35 * j) && mX < x + (widgetWidth - 5) &&
            mY < (y+widgetHeight + 10) + (35 * j) +  30) {
            currentScreen.displayTable = data.removeLabel(currentScreen.labelList.get(i), currentScreen.indexList.get(i), currentScreen.displayTable);
            currentScreen.resetSliders();
          }
        }
      }
    }
    return EVENT_NULL;
  }
}
