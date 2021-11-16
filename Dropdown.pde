//Matt - Created Class and added UI implementation
class Dropdown extends Widget {

  ArrayList<String> optionList;
  ArrayList<Integer> eventList;
  boolean menuDisplay;
  String currentOption;
  int menuY;


  //Creates a dropdown menu where choices can be independently added with different events
  Dropdown(int x, int y, int widgetWidth, int widgetHeight, int event, String label, color widgetColour, int fontSize, int type, 
    int textX, int textY, int shape, String option) {
    super(x, y, widgetWidth, widgetHeight, event, label, fontSize, type, textX, textY, shape);

    optionList = new ArrayList<String>();
    optionList.add(option);

    eventList = new ArrayList<Integer>();
    eventList.add(event);
    menuDisplay = false;
    currentOption = option;
    menuY = y + 30;
  }


  //Adds a new dropdown option and sets it's event
  void addOption(int event, String option) {
    eventList.add(event);
    optionList.add(option);
  }
  

  //Removes an option from the dropdown menu
  void removeOption(int index) {
    eventList.remove(index);
    optionList.remove(index);
  }


  //Returns the correct event for the chosen option and updates the UI to display the correct one inside of the dropdown box
  int getEvent() {
    if (menuDisplay && mouseX > x && mouseX < x + widgetWidth && mouseY > y && mouseY < y + menuY) {
      for (int i = 0; i < optionList.size(); i++) {
        if (mouseY > y + widgetHeight + (30 * i) && mouseY < y + widgetHeight + (30 * i) + 30) {
          currentOption = optionList.get(i);
          menuDisplay = false;
          return eventList.get(i);
        }
      }
    } else if (mouseX > x && mouseX < x+ widgetWidth && mouseY > y && mouseY < y + widgetHeight) {
      menuDisplay=true;
      return -1;
    } else {
      menuDisplay = false;
      return -1;
    }
    return -1;
  }


  //If the menu is open, it displays the entire list of options. If not it shows the current choice inside the menu box
  void draw() {
    strokeWeight(1);
    stroke(stroke);
    fill(background);
    rect(x, y, widgetWidth, widgetHeight);
    if (menuDisplay) {
      menuY = optionList.size() * 30 + widgetHeight;
      rect(x, y, widgetWidth, menuY);
      fill(textColour);
      text(currentOption, x + 6, y + 5);
      int i = 0;
      for (String option : optionList)
        text(option, x + 6, (y + widgetHeight) + (i++ * 30));
    } else {
      fill(textColour);
      text(currentOption, x + 6, y + 5);
    }
    stroke(0);
    textSize(fontSize);
    textAlign(LEFT, TOP);
    text(label, textX, textY);
  }
}
