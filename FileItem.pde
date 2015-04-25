// Code from Visualizing Data, First Edition, Copyright 2008 Ben Fry.


class FileItem extends SimpleMapItem {
  FolderItem parent;    
  File file;
  String name;
  int level;

  String [] textPreview;
  PImage image;
  color c;
  float hue;
  float brightness;

  float textPadding = 8;

  float boxLeft, boxTop;
  float boxRight, boxBottom;


  FileItem(FolderItem parent, File file, int level, int order) {
    this.parent = parent;
    this.file = file;
    this.order = order;
    this.level = level;

    name = file.getName();
    size = file.length();

    modTimes.add(file.lastModified());

    if (name.indexOf(".txt") >= 0 || name.indexOf(".TXT") >= 0) {
      textPreview = loadStrings(file.getAbsolutePath());
    }  

    if (name.indexOf(".jpg") >= 0 || name.indexOf(".jpeg") >= 0 || name.indexOf(".png") >= 0 || name.indexOf(".JPG") >= 0 || name.indexOf(".JPEG") >= 0 || name.indexOf(".PNG") >= 0) {
      image = loadImage(file.getAbsolutePath());
    }
  }


  void updateColors() {
    if (parent != null) {
      hue = map(order, 0, parent.getItemCount(), 0, 360);
    }
    brightness = modTimes.percentile(file.lastModified()) * 100;

    colorMode(HSB, 360, 100, 100);
    if (parent == zoomItem) {
      c = color(hue, 80, 80);
    } else if (parent != null) {
      c = color(parent.hue, 80, brightness);
    }
    colorMode(RGB, 255);
  }


  void calcBox() {
    boxLeft = zoomBounds.spanX(x, 0, width);
    boxRight = zoomBounds.spanX(x+w, 0, width);
    boxTop = zoomBounds.spanY(y, 0, height);
    boxBottom = zoomBounds.spanY(y+h, 0, height);
  }


  void draw() {
    calcBox();

    if (name.indexOf(".jpg") >= 0 || name.indexOf(".jpeg") >= 0 || name.indexOf(".png") >= 0 || name.indexOf(".JPG") >= 0 || name.indexOf(".JPEG") >= 0 || name.indexOf(".PNG") >= 0) {
      image.resize((int)(boxRight - boxLeft), (int)(boxBottom - boxTop));
      image(image, boxLeft, boxTop);
    } else {  

      if (name.indexOf(".txt") >= 0 || name.indexOf(".TXT") >= 0) {
        if (textPreviewFits()) {
          
        fill(255);
        rect(boxLeft, boxTop, boxRight, boxBottom);
          fill(0);
          drawPreview();
        }
      } else {

        fill(c);
        rect(boxLeft, boxTop, boxRight, boxBottom);

        if (textFits()) {
          drawTitle();
        } else if (mouseInside()) {
          rolloverItem = this;
        }
      }
    }
  }



  void drawTitle() {
    fill(255, 200);

    float middleX = (boxLeft + boxRight) / 2;
    float middleY = (boxTop + boxBottom) / 2;
    if (middleX > 0 && middleX < width && middleY > 0 && middleY < height) {
      if (boxLeft + textWidth(name) + textPadding*2 > width) {
        textAlign(RIGHT);
        text(name, width - textPadding, boxBottom - textPadding);
      } else {
        textAlign(LEFT);
        text(name, boxLeft + textPadding, boxBottom - textPadding);
      }
    }
  }

  void drawPreview() {
    fill(0);

    float middleX = (boxLeft + boxRight) / 2;
    float middleY = (boxTop + boxBottom) / 2;
    if (middleX > 0 && middleX < width && middleY > 0 && middleY < height) {
      if (boxLeft + textWidth(textPreview[0]) + textPadding*2 > width) {
        textAlign(RIGHT);
        text(textPreview[0], width - textPadding, boxBottom - textPadding);
      } else {
        textAlign(LEFT);
        text(textPreview[0], boxLeft + textPadding, boxBottom - textPadding);
      }
    }
  }


  boolean textFits() {
    float wide = textWidth(name) + textPadding*2;
    float high = textAscent() + textDescent() + textPadding*2;
    return (boxRight - boxLeft > wide) && (boxBottom - boxTop > high);
  }

  boolean textPreviewFits() {
    if(textPreview.length > 0){
      float wide = textWidth(textPreview[0]) + textPadding*2;
    float high = textAscent() + textDescent() + textPadding*2;
    return (boxRight - boxLeft > wide) && (boxBottom - boxTop > high);
    } else {
    return false; 
    } 
}

  boolean mouseInside() {
    return (mouseX > boxLeft && mouseX < boxRight && 
      mouseY > boxTop && mouseY < boxBottom);
  }


  boolean mousePressed() {
    if (mouseInside()) {
      if (mouseButton == LEFT) {
        if (parent == zoomItem) {
          open(file.getAbsolutePath());
        } else {
          parent.zoomIn();
          return true;
        }
      } else if (mouseButton == RIGHT) {
        if (parent == zoomItem) {
          parent.zoomOut();
        } else {
          parent.hideContents();
        }
        return true;
      }
    }
    return false;
  }
}

