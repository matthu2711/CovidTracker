class Image {
  
  int x, y, imageWidth, imageHeight;
  PImage imageToDisplay;
  
  Image (int x, int y, int imageWidth, int imageHeight, PImage imageToDisplay) {
    this.x = x;
    this.y = y;
    this.imageWidth = imageWidth;
    this.imageHeight = imageHeight;
    this.imageToDisplay = imageToDisplay;
  }
  
  void draw() {
    image(imageToDisplay, x, y, imageWidth, imageHeight);
  }
  
}
