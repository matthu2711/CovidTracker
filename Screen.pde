class Screen { //< >// //< >// //< >// //< >// //< >// //< >// //<>//
  int screenType;
  TextWidget focus;
  Dropdown menu, filter, chartMenu;
  ArrayList<Widget> widgetList, choiceList;
  ArrayList<RadioButton> radioList, chartList;
  ArrayList<Slider> sliderList;
  ArrayList<TextWidget> textList;
  ArrayList<Image> imageList;
  ArrayList<String> labelList, indexList;
  List sort;
  PImage backgroundImage;
  String state, label, columnLabel;
  Boolean filtered, ascending, noData, duplicateFilter, statesStats, duplicate;
  BarChart displayChart;
  Table displayTable, referenceTable;


  //ScreenTypes: 0=title, 1=stat, 2=map, 3=chart, 4=statesStats
  Screen(int screenType) {
    widgetList = new ArrayList<Widget>();
    choiceList = new ArrayList<Widget>();
    radioList = new ArrayList<RadioButton>();
    chartList = new ArrayList<RadioButton>();
    sliderList = new ArrayList<Slider>();
    textList = new ArrayList<TextWidget>();
    imageList = new ArrayList<Image>();
    labelList = new ArrayList<String>();
    indexList = new ArrayList<String>();
    this.screenType = screenType;
    addWidgets();
    focus = null;
    filtered = false;
    sort = data.dateList;
    ascending = true;
    columnLabel = "area";
    noData = false;
    duplicateFilter = false;
    statesStats = false;
    displayTable = table;
    if (screenType == 3)
      displayChart = new BarChart(30, 90, SCREEN_X-75, 550, 1);
    referenceTable = table;
    duplicate = false;
    state = null;
  }


  Screen(int screenType, PImage background) {
    this(screenType);
    this.backgroundImage = background;
  }


  Screen(int screenType, String state) {
    this(screenType);
    statesStats = true;
    this.state = state;
    displayTable = data.getStateTable(state);
    referenceTable = displayTable;
  }


  void draw() {
    //println(displayTable.getRowCount());
    if (backgroundImage==null)    
      background(background);
    else image(backgroundImage, 0, 0);

    for (Image iImage : imageList)
      iImage.draw();

    //Checks if the label is null. If not, checks if the label already exists. If not adds the label to the current displayedTable and updates it
    if (screenType == 0) {
      fill(textColour);
      textSize(25);
      text("View All Stats", 170, SCREEN_Y - 100);
      text("View Charts of Stats", 600, SCREEN_Y - 100);
      text("View Stats by State", 1050, SCREEN_Y - 100);
    } else if (screenType == 1 || screenType == 4) {
      if (label != null) {
        label = capitalize(label);
        if (data.areaList.contains(label) & data.stateList.contains(label) && !duplicate)
          duplicate = true;

        if (!duplicate) {
          if (label.equals(" ")) {
            noData = true;
            label = null;
            duplicateFilter = false;
          } else if (labelList.contains(label)) {
            label = null;
            noData = false;
            duplicateFilter = true;
          } else if (data.geoidList.contains(label)) {
            displayTable = data.addLabel(label, "geoidSorted", displayTable);
            resetSliders();
          } else if (data.areaList.contains(label)) {
            displayTable = data.addLabel(label, "area", displayTable);
            resetSliders();
          } else if (data.stateList.contains(label)) {
            displayTable = data.addLabel(label, "county/state", displayTable);
            resetSliders();
          } else {
            noData = true;
            label = null;
            duplicateFilter = false;
          }
        }
      }

      data.drawValue(true, 40, true, 220, true, 420, true, 650, true, 770, true, 890, displayTable);
      fill(background);
      noStroke();
      textAlign(LEFT, TOP);
      rect(SCREEN_X - 350, 0, 350, SCREEN_Y);
    } else if (screenType == 2) {
      drawStateLabel();
      textSize(30);
      noStroke();
      fill(widgetColour);
      rect(0, 0, SCREEN_X, 40);
      fill(black);
      rect(0, 40, SCREEN_X, 2);
      stroke(1);
      textAlign(LEFT, TOP);
      textFont(stdFont);
      fill(textColour);
      textSize(30);
      text("Click a State to view it's Data", 50, 2);
    } else if (screenType == 3) {
      fill(background);
      noStroke();
      rect(0, 600, SCREEN_X, SCREEN_Y-600);
      drawChart();
      textAlign(LEFT, TOP);
      textSize(25);
      fill(textColour);
      text("Select Graph:", 70, SCREEN_Y-130);
    }


    for (Widget aWidget : widgetList)
      aWidget.draw();
    for (RadioButton rWidget : radioList)
      rWidget.draw();
    for (Slider sSlider : sliderList)
      sSlider.draw();
    for (TextWidget tWidget : textList)
      tWidget.draw();
    for (Image iImage : imageList)
      iImage.draw();
    for (RadioButton rWidget : chartList)
      rWidget.draw();


    if (screenType == 1 || screenType == 4)
      menu.draw();

    if (noData) {
      fill(widgetColour);
      noStroke();
      rect(0, SCREEN_Y/2 - 75, SCREEN_X, 150);
      textSize(75);
      fill(red);
      text("No Such Values", SCREEN_X/2 - 200, SCREEN_Y/2 - 70);
      textSize(30);
      fill(textColour);
      text("Click anywhere to dismiss", SCREEN_X/2 - 130, SCREEN_Y/2 + 20);
    }

    if (duplicateFilter) {
      fill(widgetColour);
      noStroke();
      rect(0, SCREEN_Y/2 - 75, SCREEN_X, 150);
      textSize(75);
      fill(red);
      text("Filter Already Exists", SCREEN_X/2 - 270, SCREEN_Y/2 - 70);
      textSize(30);
      fill(textColour);
      text("Click anywhere to dismiss", SCREEN_X/2 - 130, SCREEN_Y/2 + 20);
    }

    if (duplicate) {        
      fill(widgetColour);
      noStroke();
      rect(0, SCREEN_Y/2 - 75, SCREEN_X, 150);
      textSize(40);
      fill(textColour);
      textAlign(CENTER, TOP);
      text(label +": Select State or Area", SCREEN_X/2, SCREEN_Y/2 - 70);  

      for (Widget choice : choiceList)
        choice.draw();
    }

    if (screenType == 0) {
      darkMode.resize(75, 0);
      image(darkMode, SCREEN_X - 100, 25);
    }
  }


  //Add widgets to list 
  void addWidgets() {
    if (screenType != 0) {
      widgetList.add(new Widget(7, 7, 25, 25, EVENT_4, "<", 25, 1, 13, 3, 1));
    }

    if (screenType == 0) {
      imageList.add(new Image(100, 100, 1175, 500, logo));
      widgetList.add(new Widget(50, SCREEN_Y - 150, 400, 50, EVENT_1, "Statistics", 30, 1, 180, SCREEN_Y - 145, 0));
      widgetList.add(new Widget(500, SCREEN_Y - 150, 400, 50, EVENT_2, "Charts", 30, 1, 650, SCREEN_Y - 145, 0));
      widgetList.add(new Widget(950, SCREEN_Y - 150, 400, 50, EVENT_3, "Map", 30, 1, 1120, SCREEN_Y - 145, 0));
      widgetList.add(new Widget(SCREEN_X-100, 25, 75, 75, EVENT_COLOR_SCHEME, "", 30, 1, SCREEN_X-230, 25, 0));
    } else if (screenType == 1 || screenType == 4) {
      if (screenType == 1)
        textList.add(new TextWidget(SCREEN_X - 300, 400, 275, 40, EVENT_TEXT, "Filter by Area/State/GeoID:", white, 20, 4, SCREEN_X - 300, 373, 0, 30));
      sliderList.add(new Slider(SCREEN_X - 350, 0, 30, SCREEN_Y, ((table.getRowCount() * 30) - 750)));
      radioList.add(new RadioButton(SCREEN_X - 275, 180, 25, 25, EVENT_24, "Cases in last Day", 20, 3, SCREEN_X - 250, 180, 1, false));
      radioList.add(new RadioButton(SCREEN_X - 275, 230, 25, 25, EVENT_WEEK, "Cases in last Week", 20, 3, SCREEN_X - 250, 230, 1, false));
      radioList.add(new RadioButton(SCREEN_X - 275, 280, 25, 25, EVENT_MONTH, "Cases in last 30 Days", 20, 3, SCREEN_X - 250, 280, 1, false));
      radioList.add(new RadioButton(SCREEN_X - 275, 330, 25, 25, EVENT_ALL, "All Cases", 20, 3, SCREEN_X - 250, 330, 1, true));
      menu = new Dropdown(SCREEN_X - 300, 100, 225, 40, EVENT_SORT_DATE, "Sort by:", white, 20, 5, SCREEN_X - 300, 73, 0, "Date");
      menu.addOption(EVENT_SORT_AREA, "Area"); 
      menu.addOption(EVENT_SORT_COUNTY, "State"); 
      menu.addOption(EVENT_SORT_GEOID, "GeoID"); 
      widgetList.add(new Widget(SCREEN_X - 60, 100, 40, 40, EVENT_ASCENDING, "^v", 30, 1, SCREEN_X - 55, 100, 0));

      choiceList.add(new Widget(SCREEN_X/4, SCREEN_Y - 400, 280, 40, LABEL_STATE, "State", 30, 1, SCREEN_X/4 + 100, SCREEN_Y - 400, 0));
      choiceList.add(new Widget(SCREEN_X - 600, SCREEN_Y - 400, 280, 40, LABEL_AREA, "Area", 30, 1, SCREEN_X - 490, SCREEN_Y - 400, 0));
    } else if (screenType == 2) {
      //MapWidgets
    } else if (screenType == 3) {
      chartList.add(new RadioButton(100, SCREEN_Y - 70, 25, 25, EVENT_CHART_STATE, "State", 20, 3, 120, SCREEN_Y - 73, 1, true));
      chartList.add(new RadioButton(200, SCREEN_Y - 70, 25, 25, EVENT_CHART_DATE, "Date", 20, 3, 220, SCREEN_Y - 73, 1, false));

    } 
    if (screenType == 4) {
      textList.add(new TextWidget(SCREEN_X - 300, 400, 275, 40, EVENT_TEXT, "Filter by Area/GeoID:", white, 20, 4, SCREEN_X - 300, 373, 0, 30));
      menu.removeOption(2);
    }
  }


  //Gets the appropriate events for each widget when the mouse is clicked
  void getEvents() {
    if (!noData && !duplicateFilter) {
      for (Widget aWidget : widgetList) {
        int event = aWidget.getEvent(mouseX, mouseY);
        switch(event) {
        case EVENT_1:
          currentScreen = statScreen;
          break;
        case EVENT_2:   
          createChart();
          currentScreen = chartScreen;          
          break;
        case EVENT_3:
          currentScreen = mapScreen;           
          break;
        case EVENT_4:
          if (!statesStats) {
            displayTable = table.copy();
            indexList.clear();
            labelList.clear();
          }
          resetSliders();


          //Returns to previous screen
          switch(currentScreen.screenType) {
          case 4:
            currentScreen = previousScreen;
            previousScreen = null;
            break;
          case 3:
            currentScreen = titleScreen;
            createChart();
            break;
          default:
            currentScreen = titleScreen;
            break;
          }
          break;
        case EVENT_ASCENDING:
          screenState = 3;
          if (ascending) {
            displayTable = data.sortTable(displayTable, sort, false);          
            ascending = false;
          } else {
            displayTable = data.sortTable(displayTable, sort, true);
            ascending = true;
          }
          resetSliders();
          screenState = 2;
          break;
        case EVENT_COLOR_SCHEME:
          if (screenType == 0) {
            if (darkmode) {
              darkmode = false;
              background = yellow; 
              widgetColour = darkerYellow;
              accentColour = darkerGrey;
              textColour = black;
              emptyColour = white;
              accent2 = lighterGrey;
              mapScreen.backgroundImage=map;
            } else if (!darkmode) {
              darkmode = true;
              background = blackish;
              widgetColour = blueish;
              accentColour = black;
              accent2 = greyish;
              emptyColour = black;
              textColour = white;
              mapScreen.backgroundImage=mapDark;
            }
          }
        }
      }

      for (TextWidget tWidget : textList) {
        int event = tWidget.getEvent(mouseX, mouseY);
        switch(event) {
        case EVENT_TEXT:
          focus = (TextWidget)tWidget;
          break;
        }
      }

      if (label != null) {
        for (Widget choice : choiceList) {
          int event = choice.getEvent(mouseX, mouseY);
          switch(event) {
          case LABEL_STATE:
            for (int i = 0; i < labelList.size(); i++) {
              if (labelList.get(i).equalsIgnoreCase(label) && indexList.get(i).equalsIgnoreCase("county/state")) {
                label = null;
                noData = false;
                duplicateFilter = true;
              }
            }

            if (!duplicateFilter && screenType == 4 || screenType == 1) {
              displayTable = data.addLabel(label, "county/state", displayTable);
              resetSliders();
            }
            duplicate = false;

            break;
          case LABEL_AREA:
            for (int i = 0; i< labelList.size(); i++) {
              if (labelList.get(i).equalsIgnoreCase(label) && indexList.get(i).equalsIgnoreCase("area")) {
                label = null;
                noData = false;
                duplicateFilter = true;
              }
            }

            if (!duplicateFilter && screenType == 4 || screenType == 1) {
              displayTable = data.addLabel(label, "area", displayTable);
              resetSliders();
            }
            duplicate = false;

            break;
          }
        }
      }

      for (RadioButton rWidget : radioList) {
        int event = rWidget.getEvent(radioList);
        switch(event) {
        case EVENT_24:
          displayTable = data.dateOrder(1);
          resetSliders();
          break;
        case EVENT_WEEK:
          displayTable = data.dateOrder(7);
          resetSliders();
          break;
        case EVENT_MONTH:
          displayTable = data.dateOrder(100);
          resetSliders();
          break;
        case EVENT_ALL:
          displayTable = data.dateOrder(-1);
          resetSliders();
          break;
        }
      }

      //Sorts the table is ascending/descending order of the choice clicked in the dropdown menu
      if (screenType == 1 || screenType == 4) {
        int event = menu.getEvent();
        switch(event) {
        case EVENT_SORT_DATE:
          if (!(sort == data.dateList)) {
            displayTable = data.sortTable(displayTable, data.dateList, true);
            sort = data.dateList;
            resetSliders();
          }
          break;
        case EVENT_SORT_AREA:
          if (!(sort == data.areaList)) {
            displayTable = data.sortTable(displayTable, data.areaList, true);
            sort = data.areaList;
            resetSliders();
          }
          break;
        case EVENT_SORT_COUNTY:
          if (!(sort == data.stateList)) {
            displayTable = data.sortTable(displayTable, data.stateList, true);
            sort = data.stateList;
            resetSliders();
          }
          break;
        case EVENT_SORT_GEOID:
          if (!(sort == data.geoidList)) {
            displayTable = data.sortTable(displayTable, data.geoidList, true);
            sort = data.geoidList;
            resetSliders();
          }
          break;
        case EVENT_SORT_CASES:
          if (!(sort == data.casesList)) {
            displayTable = data.sortTable(displayTable, data.casesList, true);
            sort = data.casesList;
            resetSliders();
          }
          break;
        }
      }
    }

    //Changes the amount of data shown over a certain duration
    if (screenType == 3) {
      displayChart.getEvents();
      for (RadioButton radio : chartList) {
        int event = radio.getEvent(chartList);
        switch (event) {
        case EVENT_CHART_STATE:
          displayChart.createChart(1);
          break;
        case EVENT_CHART_DATE:
          displayChart.createChart(2);
          break;        
        }
      }
    }
  }

  //Moves the slider appropriately
  void dragged() {
    for (Slider sSlider : sliderList)
      sSlider.move(mouseX, mouseY);
  }


  void drawChart() {
    displayChart.draw();
  }


  void drawStateLabel() {
    if (states.get(mapColored.get(mouseX, mouseY))!=null) {
      if (mouseX >= SCREEN_X / 2) { 
        textAlign(LEFT, TOP);
      } else { 
        textAlign(RIGHT, TOP);
      }

      if (mouseX >= SCREEN_X / 2) { 
        textAlign(LEFT, TOP);
      } else { 
        textAlign(RIGHT, TOP);
      }


      if (mouseX >= SCREEN_X / 2) { 
        textAlign(RIGHT, TOP);
      } else { 
        textAlign(LEFT, TOP);
      }


      // get the text early so we can measure its length for the UI.
      String text = states.get(mapColored.get(mouseX, mouseY));

      fill(widgetColour);
      stroke(black);
      strokeWeight(3);
      int screenSide = ((mouseX >= SCREEN_X / 2) ? -1 : 1);
      rect(mouseX+(40*screenSide), mouseY+10, textWidth(text)*screenSide*1.9, 50);

      textFont(stdFont);
      fill(black);
      textSize(40);
      text(text, mouseX+(50*screenSide), mouseY+10);
      strokeWeight(1);
    }
  }


  //Matt - Capitalizes passed String
  String capitalize(String string) {
    if (string != null && !string.isEmpty()) {
      char[] chars = string.toLowerCase().toCharArray();
      boolean newWord = true;
      if (Character.isDigit(string.charAt(0)))
        return appendZeros(Integer.valueOf(string));
      else {
        for (int i = 0; i < chars.length; i++) {
          if (newWord && Character.isLetter(chars[i])) {
            chars[i] = Character.toUpperCase(chars[i]);
            newWord = false;
          } else if (Character.isWhitespace(chars[i]))
            newWord = true;
        }
      }
      return String.valueOf(chars);
    }
    return " ";
  }


  //Resets every slider when the table is updated to maintain correct ratios
  void resetSliders() {
    for (Slider sSlider : sliderList) {
      sSlider.max = (displayTable.getRowCount() * 30) - 750;
      sSlider.reset();
    }
  }
  
  void createChart(){  
      displayChart = new BarChart(30, 90, SCREEN_X-75, 550, 1);
      displayChart.createChart(1);
  }
}
