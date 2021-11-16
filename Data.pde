class Data {

  List<String> areaList, stateList, dateList, casesList, geoidList;

  Data() {
    //initialise hashmap  -Dillon

    dateList = new ArrayList();
    areaList = new ArrayList();
    stateList = new ArrayList();
    geoidList = new ArrayList();
    casesList = new ArrayList();

    states = new HashMap<Integer, String>();
    states.put(-80698, "Washington"); 
    states.put(-1129729, "Oregon");  
    states.put(-3145786, "Idaho");  
    states.put(-58, "Montana");  
    states.put(-5047898, "California");
    states.put(-880750, "Nevada"); 
    states.put(-2056455, "Utah"); 
    states.put(-324, "Arizona"); 
    states.put(-1266256, "Wyoming"); 
    states.put(-6554230, "Colorado");
    states.put(-735030, "New Mexico");  
    states.put(-6098795, "Texas");  
    states.put(-197734, "Oklahoma");  
    states.put(-1612695, "Kansas"); 
    states.put(-592461, "Nebraska"); 
    states.put(-2524931, "South Dakota"); 
    states.put(-7806600, "North Dakota"); 
    states.put(-11709985, "Minnesota"); 
    states.put(-5839205, "Iowa"); 
    states.put(-2061057, "Missouri"); 
    states.put(-3844775, "Arkansas"); 
    states.put(-423, "Louisiana"); 
    states.put(-658277, "Wisconsin"); 
    states.put(-7828487, "Illinois"); 
    states.put(-8650908, "Kentucky");
    states.put(-1250381, "Tennessee"); 
    states.put(-3634977, "Mississippi");  
    states.put(-5682610, "Alabama"); 
    states.put(-3906840, "Indiana"); 
    states.put(-10487484, "Michigan");
    states.put(-1533283, "Ohio"); 
    states.put(-13371374, "Georgia"); 
    states.put(-8304745, "Florida"); 
    states.put(-4423293, "South Carolina"); 
    states.put(-5277245, "North Carolina");
    states.put(-2778211, "Virginia"); 
    states.put(-6645391, "West Verginia");
    states.put(-9520031, "Pennsylvania");
    states.put(-5739842, "Maryland");
    states.put(-9895932, "Delaware");
    states.put(-4869029, "New Jersey");
    states.put(-9948803, "New York");
    states.put(-12348107, "Connecticut");
    states.put(-1720588, "Rhode Island");
    states.put(-9427159, "Massachusetts");
    states.put(-7222393, "Vermont");
    states.put(-6777050, "New Hampshire");
    states.put(-1395969, "Maine");
    states.put(-3105564, "Alaska");
    states.put(-5678904, "Hawaii");
    states.put(-6279222, "Puerto Rico");
    states.put(-8963187, "Guam");
    states.put(-13913161, "Northern Mariana Islands");
    states.put(-14259604, "American Samoa");
    states.put(-11020582, "U.S. Virgin Islands");
  }


  //Matt
  //Writes whatever data sets are true at the passed x position.
  void drawValue(boolean date, int datePos, boolean area, int areaPos, boolean county, int countyPos, 
    boolean geoid, int geoidPos, boolean cases, int casesPos, boolean country, int countryPos, Table tableData) {

    if (tableData.getRowCount() > 0) {
      textAlign(LEFT, TOP);
      textFont(stdFont);
      fill(textColour);
      textSize(20);
      double ypos = 0;

      for (Slider sSlider : currentScreen.sliderList) {
        ypos = 40 - sSlider.offset;
      }

      //Write each row to the screen. The ypos changes with the sliders offset
      for (TableRow row : tableData.rows()) {
        if (ypos > 0 && ypos < SCREEN_Y) {
          if (date) {
            text(row.getString("date"), datePos, (float)ypos);
          }
          if (area) {
            text(row.getString("area"), areaPos, (float)ypos);
          }
          if (county) {
            text(row.getString("county/state"), countyPos, (float)ypos);
          }
          if (geoid) {
            text(row.getInt("geoid"), geoidPos, (float)ypos);
          }
          if (cases) {
            text(row.getInt("casesSorted"), casesPos, (float)ypos);
          }
          if (country) {
            text(row.getString("country"), countryPos, (float)ypos);
          }
        }
        ypos += 30;
      }


      //Write the headers
      textSize(30);
      noStroke();
      fill(widgetColour);
      rect(0, 0, SCREEN_X, 40);
      stroke(1);
      fill(textColour);
      if (date)
        text(tableData.getColumnTitle(0).toUpperCase(), datePos, 0);
      if (area)
        text(tableData.getColumnTitle(1).toUpperCase(), areaPos, 0);
      if (county)
        text(tableData.getColumnTitle(2).toUpperCase(), countyPos, 0);
      if (geoid)
        text(tableData.getColumnTitle(3).toUpperCase(), geoidPos, 0);
      if (cases)
        text(tableData.getColumnTitle(4).toUpperCase(), casesPos, 0);
      if (country)
        text(tableData.getColumnTitle(5).toUpperCase(), countryPos, 0);
      rect(0, 40, SCREEN_X - 100, 1);
    } else noData();
  }


  //Displays an error if no data is available in the current selected table. Must be fixed by removing filters
  void noData() {
    textAlign(CENTER, CENTER);
    fill(widgetColour);
    noStroke();
    rect(0, SCREEN_Y/2 - 75, SCREEN_X, 150);
    textSize(75);
    fill(red);
    text("No Data", SCREEN_X/2 - 120, SCREEN_Y/2 - 40);
    textSize(30);
    fill(black);
    text("Remove filter to dismiss", SCREEN_X/2 - 120, SCREEN_Y/2 + 40);
  }


  //Adds a filter to the passed table. This is done by finding rows in the reference table and added those with the matching criteria to the
  //existing table. It then sorts the table appropriately before passing it back
  Table addLabel(String label, String columnName, Table filteredTable) {
    if (filteredTable.getRowCount() == currentScreen.referenceTable.getRowCount())
      filteredTable = getEmptyTable();
    if (geoidList.contains(label) || areaList.contains(label) || stateList.contains(label)) {
      currentScreen.label = null;
      currentScreen.labelList.add(label);
      currentScreen.indexList.add(columnName);
      if (currentScreen.indexList.size() <= 1)
        filteredTable.clearRows();

      for (TableRow foundRow : currentScreen.referenceTable.findRows(label, columnName)) {
        filteredTable.addRow(foundRow);
      }

      currentScreen.noData = false;
      filteredTable = sortTable(filteredTable, currentScreen.sort, true);
      return filteredTable;
    }
    if (previousScreen != mapScreen) {
      currentScreen.labelList.remove(label);
      currentScreen.indexList.remove(columnName);
      currentScreen.duplicateFilter = false;
      currentScreen.noData = true;
    }
    return filteredTable;
  }

  //Removes a filter and updates the table to reflect so. Returns the reference table if no filters are left
  Table removeLabel(String label, String columnName, Table filteredTable) {
    currentScreen.indexList.remove(columnName);  
    currentScreen.labelList.remove(label);
    currentScreen.label = null;
    if (currentScreen.labelList.isEmpty()) {
      return data.sortTable(currentScreen.referenceTable, currentScreen.sort, true);
    } else {
      filteredTable.clearRows();
      for (int i = 0; i < currentScreen.indexList.size(); i++) {
        for (TableRow foundRow : currentScreen.referenceTable.findRows(currentScreen.labelList.get(i), currentScreen.indexList.get(i)))
          filteredTable.addRow(foundRow);
        data.sortTable(filteredTable, currentScreen.sort, true);
      }
      return filteredTable;
    }
  }


  //Orders the table by date. This is done by checking the reference table (which is already date ordered), starting from the most recent date and
  //creates a table with the right filters and whatever dates are in the correct duration.
  Table dateOrder(int days) {
    Table filteredTable = getEmptyTable();

    if (days <= 0) {
      if (currentScreen.labelList.isEmpty())
        return currentScreen.referenceTable;
      else {  
        for (int i = 0; i < currentScreen.indexList.size(); i++) {
          for (TableRow foundRow : currentScreen.referenceTable.findRows(currentScreen.labelList.get(i), currentScreen.indexList.get(i)))
            filteredTable.addRow(foundRow);
        }
        return filteredTable;
      }
    } else {
      if (currentScreen.labelList.isEmpty()) {
        for (int i = currentScreen.referenceTable.lastRowIndex(); i >= 0; i--)
          if (currentScreen.referenceTable.getInt(i, "dateSorted") >= startDate - days)
            filteredTable.addRow(currentScreen.referenceTable.getRow(i));
          else
            break;
      } else {
        for (int i = 0; i < currentScreen.indexList.size(); i++) {
          for (TableRow foundRow : currentScreen.referenceTable.findRows(currentScreen.labelList.get(i), currentScreen.indexList.get(i))) {
            if (foundRow.getInt("dateSorted") >= (startDate - days))
              filteredTable.addRow(foundRow);
          }
        }
      }
    }
    return filteredTable;
  }


  //returns a table composed of all the data for a specific state to be used on the map screen
  Table getStateTable(String state) {
    Table stateTable = getEmptyTable();
    stateTable.addRows(new Table(table.findRows(state, "county/state")));
    return sortTable(stateTable, dateList, true);
  }


  //Creates a table with the column headings of the imported table. Used in other methods
  Table getEmptyTable() {
    Table emptyTable = new Table();
    for (String columnTitle : table.getColumnTitles())
      emptyTable.addColumn(columnTitle);
    return emptyTable;
  }


  //Sorts the table by the passed value. Done by checking the arrays of sorted strings and adding the corresponding rows for each value.
  Table sortTable(Table filteredTable, List<String> label, boolean ascending) {
    String columnName = label.get(0);
    Table sortedTable = filteredTable.copy();
    int j = 0;
    if (ascending) {
      for (int i = 1; i < label.size() - 1; i++) {
        for (TableRow found : filteredTable.findRows(label.get(i), columnName)) { 
          sortedTable.setRow(j++, found);
        }
      }
      return sortedTable;
    } else {
      for (int i = label.size() - 1; i > 0; i--) {
        for (TableRow found : filteredTable.findRows(label.get(i), columnName)) { 
          sortedTable.setRow(j++, found);
        }
      }
      return sortedTable;
    }
  }
}
