import java.util.Map;
import java.util.Date;
import java.util.Arrays;
import java.util.List;
import java.util.Collections;
import processing.sound.*;
import java.text.DecimalFormat;
import java.lang.*;


HashMap<Integer, String> states;
Table table;
PFont stdFont;
Data data;
PImage map, mapDark, mapColored, cursor, logo, darkMode;
SoundFile elevator, click;
Screen currentScreen, titleScreen, statScreen, mapScreen, chartScreen, stateScreen, mapStat, previousScreen;
int startDate, screenState;
color background, textColour, widgetColour, accentColour, emptyColour, accent2;
boolean darkmode;


void settings() {
  size(SCREEN_X, SCREEN_Y);
}


void setup() {
  background(white);
  stdFont = createFont("SourceSansPro-Light.ttf", 32);
  click = new SoundFile(this, "Click.wav");
}


void draw() {
  switch(screenState) {
  case 0:
    textFont(stdFont);
    textSize(72);
    fill(black);
    text("loading...", 200, 700);
    elevator = new SoundFile(this, "elevator.wav");
    elevator.amp(0.1);
    elevator.loop();
    screenState = 1;
    break;
  case 1:
    //loading screen and elevator music while waiting for the table to load
    strokeWeight(1);
    darkmode = false;
    background = yellow; 
    widgetColour = darkerYellow;
    accentColour = darkerGrey;
    textColour = black;
    emptyColour = white;
    accent2 = lighterGrey;
    stroke(0);

    data = new Data();
    table = loadTable("daily-10k.csv", "header"); 

    //Remove whitespace
    table.trim();

    table.addColumn("dateSorted");
    table.addColumn("casesSorted");
    table.addColumn("geoidSorted");

    for (int i = 0; i <= table.lastRowIndex(); i++) {
      table.setInt(i, "dateSorted", dateInt(table.getString(i, "date")));
      table.setString(i, "casesSorted", appendZeros(table.getInt(i, "cases")));
      table.setString(i, "geoidSorted", appendZeros(table.getInt(i, "geoid")));
    }

    //Creates lists of all the unique strings for each column and sorts the lists. They are used then in sorting the table, by taking each value of the list
    //and finding the matching rows
    data.areaList.addAll(Arrays.asList(table.getUnique("area")));
    data.stateList.addAll(Arrays.asList(table.getUnique("county/state")));
    data.dateList.addAll(Arrays.asList(table.getUnique("dateSorted")));
    data.casesList.addAll(Arrays.asList(table.getUnique("casesSorted")));
    data.geoidList.addAll(Arrays.asList(table.getUnique("geoidSorted")));

    Collections.sort(data.areaList);
    Collections.sort(data.casesList);
    Collections.sort(data.geoidList);
    Collections.sort(data.stateList);
    data.areaList.add(0, "area");
    data.stateList.add(0, "county/state");
    data.dateList.add(0, "dateSorted");
    data.geoidList.add(0, "geoidSorted");
    data.casesList.add(0, "casesSorted");

    table.setColumnType("dateSorted", Table.INT);
    table.setColumnType("geoid", Table.STRING);

    startDate = table.getInt(table.lastRowIndex(), "dateSorted");
    map = loadImage("mapOfUSA1.png");
    mapDark = loadImage("mapOfUSA2.png");
    mapColored = loadImage("mapOfUSA.png");
    cursor = loadImage("cursor.png");
    logo = loadImage("Case Tracker.png");
    darkMode = loadImage("darkMode.png");
    cursor(cursor);


    //Create Screens
    titleScreen = new Screen(0);
    statScreen = new Screen(1);
    mapScreen = new Screen(2, map);
    chartScreen = new Screen(3);

    currentScreen = titleScreen;
    elevator.stop();
    strokeWeight(1);
    stroke(0);
    screenState = 2;
    break;

  case 2:
    elevator.stop();
    currentScreen.draw();
    for (Widget aWidget : currentScreen.widgetList) {
      aWidget.strokeColour();
    }
    break;
  }
}


void keyPressed() {
  if (currentScreen.focus != null)
    currentScreen.focus.append(key, keyCode);
}


void mouseDragged() {
  currentScreen.dragged();
}


void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  for (Slider sSlider : currentScreen.sliderList)
    sSlider.scroll(scroll);
}


void mousePressed() {
  if (currentScreen.screenType == 3 && currentScreen.displayChart.type == 1) {
    BarChart chart = currentScreen.displayChart;
    
    if (chart.hoverState != -1) {      
      chart.setClickedState(chart.hoverState); 
    } else if ((chart.getClickedState() != -1 || chart.isFiltered ) && chart.toStatsPage.getEvent(mouseX, mouseY) == EVENT_CHART_TO_STAT){
      click.play();
      previousScreen = chartScreen;
      if (chart.isFiltered)
        currentScreen = new Screen(4, chart.title);
      else
        currentScreen = new Screen(4, chart.getStateString(chart.clickedState));
      currentScreen.resetSliders();
    }
  }
  if (currentScreen.screenType==2) {
    if (states.get(mapColored.get(mouseX, mouseY))!=null) {
      println(states.get(mapColored.get(mouseX, mouseY)));
      currentScreen = new Screen(4, states.get(mapColored.get(mouseX, mouseY)));
      previousScreen = mapScreen;
      currentScreen.resetSliders();
      click.play();
    }
  }
  if (currentScreen.noData || currentScreen.duplicateFilter) {
    currentScreen.noData = false;
    currentScreen.duplicateFilter = false;
  } else
    currentScreen.getEvents();
  //println(mapColored.get(mouseX, mouseY)+", "+mouseX+", "+mouseY);    //Code to show the exact location of curor and color of pixle for testing purposes - Dillon
}



//Convert date string into an integer YYYYMMDD (Aran)
int dateInt(String date) {
  String[] dmy = date.split("/");
  int year = Integer.parseInt(dmy[2]) % 10;
  int month = Integer.parseInt(dmy[1]);
  int day = Integer.parseInt(dmy[0]);
  return (10000 * year + 100 * month + day);
}


String appendZeros(int cases) {
  DecimalFormat df = new DecimalFormat("000000");
  return df.format(cases);
}
