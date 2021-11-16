// Aran, 25/03/21 18:30 Created class, takes a column from the table for the x axis and cases as the y //<>// //<>// //<>// //<>// //<>// //<>//
// Aran, 27/03/21, 02:34, Made the labeling on the x axis more visible by rotating the text
// Aran, 8/04/21, Added functionality to hover over chart and display information
// Daniel, 17/04/21, created funcitonality to click on a state and be taken to its stats page
// Aran, 21/04/21, adapted click functionality to display information about selected state. Creates widgets that allow to filter chart and to go to stats page.

class BarChart {

  int x, y, width, height;
  ArrayList columnNames;
  ArrayList casesPerColumn;
  int maxCases, searchInt;
  float time;
  int type;   // type: 1 = barChart, 2 = lineChart
  String search, title;
  int hoverState, clickedState;
  float barWidth;
  Widget toStatsPage; 
  ArrayList<RadioButton> filterChart;
  boolean isFiltered;

  // searchInt: 1 = state/county, 2 = date, 3 = area, 4 = geoid
  BarChart(int x, int y, int width, int height, int searchInt) {    
    this.x=x; 
    this.y=y;  
    this.width=width; 
    this.height=height;
    time = 0;
    textSize(20);
    hoverState = -1;
    createChart(searchInt);
    toStatsPage = null;
  }

  void draw() {

    textAlign(LEFT, TOP);            
    switch(type) {
    case 1:                // if it's a bar chart
      fill(white);
      stroke(black);
      textFont(stdFont);
      rect(x, y, width, height);
      barWidth = (float) width / columnNames.size();    // barWidth is the distance between each entry on the x axis.

      noStroke();
      for (int i = 0; i < casesPerColumn.size(); i++) { // for each column
        drawBarChart(i);                                  // draw a column
        rotateText(i);                                    // write the name of the column
      }

      for (int i = 0; i < casesPerColumn.size(); i++) { // a separate for loop to ensure that its contents is drawn over the contents of the previous loop

        drawBarMouse(i);                                  // checks if cursor is hovering over a bar and displays information if so
      }

      if (clickedState == -1 && !isFiltered) {
        toStatsPage = null;
        filterChart =  new ArrayList<RadioButton>();
      } else {
        drawClickedState();
      }

      break;

    case 2:        // if it's a line chart
      fill(white);                                    //
      stroke(black);                                  //
      textFont(stdFont);                              //
      rect(x, y, width, height);                      //
      barWidth = (float) width / columnNames.size();  // depending on how it goes this part can be removed from the switch and just put in the draw

      for (int i = 0; i < casesPerColumn.size(); i++) {
        drawLineChart(i);                             // draws a line
        rotateText(i);                                // at the start of a month it writes the name of the month
      }
      for (int i = 0; i < casesPerColumn.size(); i++) {     
        drawLineMouse(i);                             // if cursor is hovering, displays information
      }

      if (isFiltered) {
        drawClickedState();
      }
      break;
    }

    time+= 10;    
    textSize(50);
    fill(textColour);
    textAlign(CENTER, CENTER);
    text(title, SCREEN_X/2, 50);
    textAlign(LEFT, TOP);
  }

  // method to rotate text 90 degrees and display it on screen
  void rotateText(int i) {
    rotate(radians(270));
    fill(black);
    String xAxis;
    int day = 1;
    if (search.equalsIgnoreCase("date")) { // if it's a chart of dates
      int date = (Integer) columnNames.get(i);
      int year = date/10000;
      int month = (date/100)%100;
      textSize(30);
      if (i != 0 )
        day = date%100;    // if it's the day of the dataset, keeps the day at 1 so that it writes the month

      if (day == 1) {      // if it's the first day of the month, writes the month and the year.
        xAxis = MONTHS[month-1] + "  " + Integer.toString(year);
        text(xAxis, -(y+height*2/3), x+(barWidth*(i-0.1)));
      }
    } else {  // if it's a chart of anything other than dates (eg: county/state)
      if (barWidth > 40) {
        textSize(36);
      } else {
        textSize(barWidth*0.9);
      }      
      xAxis = (String) columnNames.get(i);
      textAlign(CENTER, CENTER);
      text(xAxis, -(y+height*1/2), x+(barWidth*(i+0.35))); // writes each state at its appropriate position
      textAlign(LEFT, TOP);
    }
    rotate(radians(90));  //unrotates
  }


  // method to draw the bars of the bar chart
  void drawBarChart(int i) {

    float curCases = (int) casesPerColumn.get(i);      // total cases for this column
    float barHeight = curCases / maxCases * (height - 10);    // height of the column is equal to this column's cases divided by the number of cases of the higherst column

    if (darkmode) {
      if (i == clickedState) {
        fill (darkerGrey);
        noStroke();
      } else if (mouseX >= x+(barWidth*(i)) && mouseX < x+(barWidth*(i+1)) && mouseY > y && mouseY < y + height) {
        fill(blueish);
        stroke(white);      // if it's being hovered over, fill it in yellow and highlighted
      } else {
        fill(greyish);        // else fill it in black
        noStroke();
      }      
    } else {
      if (i == clickedState) {
        fill (darkerGrey);
        noStroke();
      } else if (mouseX >= x+(barWidth*(i)) && mouseX < x+(barWidth*(i+1)) && mouseY > y && mouseY < y + height) {
        fill(yellow);
        stroke(white);      // if it's being hovered over, fill it in yellow and highlighted
      } else {
        fill(greyish);        // else fill it in black
        noStroke();
      }
    }

    if (time < barHeight)  // bars grow over time until reaching max height
      rect(x+barWidth*(i+0.15), y+height-time, barWidth*0.7, time);    // bars are a bit thinner than barWidth to create gaps between them
    else
      rect(x+barWidth*(i+0.15), y+height-barHeight, barWidth*0.7, barHeight);
  }


  // method to draw the box that appears if you hover over bars of the chart
  void drawBarMouse(int i) {
    if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
      if (mouseX >= x+(barWidth*(i)) && mouseX < x+(barWidth*(i+1)) && mouseY > y && mouseY < y + height) {
        int curCases = (int) casesPerColumn.get(i);
        stroke(black);
        fill(widgetColour);
        textSize(20);
        hoverState = i;
        String stateString = getStateString(hoverState); 
        String cases = (curCases + " cases");

        int boxWidth, offset;            // find out how long the box is
        if (stateString.length() > cases.length()) {
          if (stateString.length() > 15)
            boxWidth = stateString.length()*9;
          else 
          boxWidth = stateString.length()*12;
        } else 
        boxWidth = cases.length()*10;

        if (mouseX + boxWidth + 50 > SCREEN_X)  // offset so the box does not go offscreen
          offset = -(boxWidth + 30);
        else 
        offset = 30;

        rect(mouseX+offset, mouseY, boxWidth, 50);
        fill(textColour);
        text(stateString, mouseX+5+offset, mouseY);
        text(cases, mouseX+5+offset, mouseY+20);
      }
    } else
      hoverState = -1;
  }


  // method to draw the line chart
  void drawLineChart(int i) {

    float curCases = (int) casesPerColumn.get(i);
    float barHeight = curCases / maxCases * (height - 10);
    if (time > barWidth * i && i < casesPerColumn.size()-1) {
      stroke(blue);
      float nextCases = (int) casesPerColumn.get(i+1);
      float nextHeight = nextCases / maxCases * (height - 10);
      strokeJoin(MITER);
      line(x+(barWidth*i), y+(height) - barHeight, x+(barWidth*(i+1)), y+(height) - nextHeight);
    }
  }

  // draw the box that appears if you hover over the line chart
  void drawLineMouse(int i) {
    if (mouseX >= x+(barWidth*(i)) && mouseX < x+(barWidth*(i+1)) && mouseY > y && mouseY < y + height) {
      float curCases = (int) casesPerColumn.get(i);
      float barHeight = curCases / maxCases * (height - 10);
      fill(blue);
      ellipse(x+(barWidth*(i)), y+(height) - barHeight, 7, 7);
      stroke(textColour);
      fill(widgetColour);
      textSize(20);
      int date = (Integer) columnNames.get(i);
      int year = date/10000;
      int month = (date/100)%100;
      int day = date%100;
      String dateInWords =(Integer.toString(day) + " " + MONTHS[month-1] + " " + (Integer.toString(year)));      
      String cases = (curCases + " cases");
      int boxWidth, offset;      
      boxWidth = dateInWords.length()*10;

      if (mouseX > SCREEN_X/2)
        offset = -(boxWidth + 20);
      else 
      offset = 20;

      rect(x+(barWidth*(i)) + offset, y+height-barHeight - 10, boxWidth, 50);
      fill(textColour);
      text(dateInWords, x+(barWidth*(i)+5) + offset - 5, y+height-barHeight - 10);
      text(cases, x+(barWidth*(i)+5) + offset - 5, y+height-barHeight+10);
    }
  }


  int dateInt(String date) {
    String[] dmy = date.split("/");
    int year = Integer.parseInt(dmy[2]);
    int month = Integer.parseInt(dmy[1]);
    int day = Integer.parseInt(dmy[0]);
    return (10000 * year + 100 * month + day);
  }

  // some getter methods
  int getType() {
    return type;
  }

  int getSearch() {
    return searchInt;
  }


  // fills two arrays, one with the names for each column and one for the cases associated with it
  // eg: if columnNames[6] is New York and casesPerColumn[6] is 517, then there were 517 cases in New York
  // also sets the type of chart depending on search
  void createChart(int searchNumber) {

    columnNames = new ArrayList();
    casesPerColumn = new ArrayList();
    maxCases = 0;


    switch(searchNumber) {
      case (1):
      search  = "county/state";
      type = 1;
      break;
      case (2):
      search  = "date";
      type = 2;
      break;
      case (3):
      search = "area";
      type = 1;
      break;
    }

    for (TableRow row : table.rows()) {
      String columnName = row.getString(search);

      int index;
      if (search.equalsIgnoreCase("date"))                   // finds the appropriate index for the current row in columnNames
        index = columnNames.indexOf(dateInt(columnName));    // if it is a date, converts the date string into an appropriate integer first
      else
        index = columnNames.indexOf(columnName);             // eg: if search is county/state and columnNames[6] is New York, then index will be 6 for rows that have New York

      if (index == -1) {                                  // if there is no appropriate index in columnNames, it adds it to the end
        if (type == 2)
          columnNames.add(dateInt(columnName));
        else
          columnNames.add(columnName);

        casesPerColumn.add(0);
        index = columnNames.size() -1;
      }

      int cases = row.getInt("cases");                    // then it adds the number of cases in this row to the equivalent index in casesPerColumn
      int prevCases = (int)casesPerColumn.get(index);
      casesPerColumn.set(index, cases+prevCases);
    }

    for (int i = 0; i < casesPerColumn.size(); i++) {
      int curCases =(int) casesPerColumn.get(i);
      if (curCases > maxCases) {
        maxCases = curCases;                              // finds which entry has the most total cases
      }
    }
    time = 0;
    clickedState = -1;
    isFiltered = false;
    title = "United States";
  }

  // for int i which is associated with a state, return the name of the state. 
  String getStateString(int i) {
    if (i == -1) {
      return "";
    }   
    return (String) columnNames.get(i);
  }

  // sets the clicked state and, if the chart isn't filtered, creates widgets associated with that state
  void setClickedState(int i) {
    if (!isFiltered) {
      createWidgets();
    }     
    clickedState = i;
  }

  int getClickedState() {
    if (isFiltered)
      return clickedState;
    return clickedState;
  }

  // creates widgets associated with the state that has been clicked on
  void createWidgets() {
    toStatsPage = new Widget (770, 680, 130, 90, EVENT_CHART_TO_STAT, "STATE \nSTATS", 30, 1, 795, 683, 0);
    filterChart = new ArrayList<RadioButton>();
    filterChart.add(new RadioButton(1000, 685, 25, 25, EVENT_FILTER_NONE, "Full chart", 20, 3, 1045, 685, 1, true));
    filterChart.add(new RadioButton(1000, 725, 25, 25, EVENT_FILTER_AREA, "Area", 20, 3, 1045, 725, 1, false));
    filterChart.add(new RadioButton(1000, 765, 25, 25, EVENT_FILTER_DATE, "Date", 20, 3, 1045, 765, 1, false));
  }

  // things to draw only if a state has been clicked on (if the chart is filtered that also counts)
  void drawClickedState() {
    String stateString = getStateString(getClickedState());
    textSize(30);
    fill(textColour);
    text(stateString, 500, 650);

    // draws widgets for that state
    toStatsPage.draw();
    for (int i = 0; i < filterChart.size(); i++) {
      filterChart.get(i).draw();
    }

    // displays information associated with the state/area that has been clicked on
    if (!isFiltered) {
      String areaMostCases = findMostCases(clickedState, "area");    
      text("Area with most cases: " + areaMostCases, 400, 720);

      String mostDailyCases = findMostCases(clickedState, "date");
      text("Most daily cases: " + mostDailyCases, 400, 750);
    } else if (clickedState != -1) {
      String mostDailyCases = findMostCases(clickedState, "date");
      text("Most daily cases: " + mostDailyCases, 400, 750);
    }
  }

  // in given state, finds the date/area with the most cases. Can also find date with most cases in given area.
  String findMostCases(int state, String column) {

    String stateString = getStateString(state);
    ArrayList<String> columnList = new ArrayList();        // creates two ArrayLists, one of the names and one of the number of cases associated with that name
    ArrayList<Integer> casesList = new ArrayList();        // eg: if columnList.get(10) is Orange and casesList.get(10) is 50 then there were 50 cases in Orange

    String searchColumn = (isFiltered) ? "area" : "county/state" ;    

    for (TableRow row : table.rows()) {

      if (row.getString(searchColumn).equals(stateString)) {

        String columnString = row.getString(column);
        int cases = row.getInt("cases");
        int index = columnList.indexOf(columnString);

        if (index == -1) {
          columnList.add(columnString);
          casesList.add(cases);
        } else {
          int casesSoFar = casesList.get(index);
          casesList.set(index, cases+casesSoFar);
        }
      }
    }

    int indexMost = 0;    
    int mostCases = -1;

    for (int i = 0; i < casesList.size(); i++) {        // goes through the ArrayList and find the index with the most cases

      int curCases = casesList.get(i);

      if (curCases > mostCases) {
        indexMost = i;
        mostCases = curCases;
      } else if (curCases == mostCases) {
        indexMost = -1;
      }
    }

    // returns a String composed of the number of cases and the name of the date/area. If multiple were tied, string instead says "multiple"
    if (indexMost == -1)
      return Integer.toString(mostCases) + ", multiple";

    return Integer.toString(mostCases) + ", " + columnList.get(indexMost);
  }


  // this method is like createChart, but only adds entries that are in a certain county/state. Sets isFiltered to true
  void createFilteredChart(int searchNumber, String stateString) {    

    columnNames = new ArrayList();
    casesPerColumn = new ArrayList();
    maxCases = 0;
    title = stateString;

    switch(searchNumber) {
      case (1):
      search  = "area";
      type = 1;
      break;
      case (2):
      search  = "date";
      type = 2;
      break;
    }

    for (TableRow row : table.rows()) {

      if (row.getString("county/state").equals(stateString)) {    // this if statement is what differs from createChart; only adds data to the arrays if the state in the row is as filtered for
        String columnName = row.getString(search);

        int index;
        if (search.equalsIgnoreCase("date"))                   
          index = columnNames.indexOf(dateInt(columnName));  
        else
          index = columnNames.indexOf(columnName);            

        if (index == -1) {                               
          if (type == 2)
            columnNames.add(dateInt(columnName));
          else
            columnNames.add(columnName);

          casesPerColumn.add(0);
          index = columnNames.size() -1;
        }

        int cases = row.getInt("cases");                   
        int prevCases = (int)casesPerColumn.get(index);
        casesPerColumn.set(index, cases+prevCases);
      }
    }

    for (int i = 0; i < casesPerColumn.size(); i++) {
      int curCases =(int) casesPerColumn.get(i);
      if (curCases > maxCases) {
        maxCases = curCases;
      }
    }

    time = 0;
    isFiltered = true;
    clickedState = -1;
  }


  // checks radio buttons to create filtered charts
  void getEvents() {
    if (filterChart != null) {
      for (RadioButton rWidget : filterChart) {

        int event = rWidget.getEvent(filterChart);

        switch(event) {

          case(EVENT_FILTER_NONE):
          if (isFiltered) {
            createChart(1);
          }
          break;

          case(EVENT_FILTER_AREA):
          if (isFiltered)
            createFilteredChart(1, title);
          else
            createFilteredChart(1, getStateString(clickedState));
          break;

          case(EVENT_FILTER_DATE):
          if (isFiltered)
            createFilteredChart(2, title);
          else
            createFilteredChart(2, getStateString(clickedState));
          break;
        }
      }
    }
  }
}
