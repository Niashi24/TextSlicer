import javax.swing.*;
import java.io.*;

PImage img;

enum State {
  Waiting,
  LoadingImages,
  SlicingText,
  SavingImages
}

State state = State.Waiting;

Button loadImages = new Button(5, 5, 100, 100, "Load Images");
Button sliceText = new Button(110, 5, 100, 100, "Slice Text");
Button saveImages = new Button(215, 5, 100, 100, "Save Images");
void settings() {
  noSmooth();
  size(320,110);
}

ArrayList<PImage> characters;
ArrayList<ImageCharacterPair> pairs = new ArrayList<ImageCharacterPair>();
String outputText = null;

String printArrayAs2D(char[] input, int arrWidth, int arrHeight) {
  String output = "";
  int index = 0;
  for (int i = 0; i < arrHeight; i++) {
    for (int j = 0; j < arrWidth; j++) {
      output += input[index];
      index++;
    }
    output += '\n';
  }
  return output;
}

int index = 0;
boolean drawingThisFrame = true;
void draw() {
  clear();
  background(255);
  
  if (state == State.Waiting) {
    loadImages.update();
    sliceText.update();
    saveImages.update();
    
    loadImages.paint();
    sliceText.paint();
    saveImages.paint();
  } else if (state == State.SlicingText) {
    if (outputText == null) return;
    if (drawingThisFrame) {
      image(characters.get(index), 5, 5, 100, 100);
      drawingThisFrame = false;
    } else {
      outputText += getCharacter(pairs, characters.get(index));
      //arr[index] = getCharacter(pairs, characters.get(index));
      index++;
      if (index % 18 == 0) outputText += '\n';
      if (index >= characters.size()) {
        index = 0;
        saveText();
      }
      drawingThisFrame = true;
    }
  }
}

void mouseClicked() {
  if (state != State.Waiting) return;
  if (loadImages.contains(mouseX, mouseY)) {
    loadImages();
  } else if (sliceText.contains(mouseX, mouseY)) {
    sliceText();
  } else if (saveImages.contains(mouseX, mouseY)) {
    saveImages();
  }
}

void saveImages() {
  state = State.SavingImages;
  selectFolder("Select folder to save images", "saveImages2");
}

void saveImages2(File f) {
  if (f == null) {
    state = State.Waiting;
    return;
  }
  
  for (ImageCharacterPair icp : pairs) {
    icp.image.save(f.getAbsolutePath() + "\\" + icp.character + ".png");
  }
  state = State.Waiting;
}

void sliceText() {
  state = State.SlicingText;
  selectInput("Select input image", "sliceText2");
}

void sliceText2(File f) {
  if (f == null) {
    state = State.Waiting;
    return;
  }
  if (!isPNG(f)) 
  {
    state = State.Waiting;
    return;
  }
  img = loadImage(f.getAbsolutePath());
  img = img.get(24,168,288,48);
  characters = sliceRaw(img, 16);
  outputText = "";
  //for (int i = 0; i < arr.length; i++) {
  //  arr[i] = getCharacter(pairs, characters.get(i));
  //}
  //printArrayAs2D(arr, 18, 3);
}

void loadImages() {
  state = State.LoadingImages;
  selectFolder("Select folder with images", "onLoadImages");
}

void onLoadImages(File f) {
  if (f == null) {
    state = State.Waiting;
    return;
  }
  
  String[] pathNames = f.list();
  for (String s : pathNames) {
    if (isPNG(s)) {
      PImage img = loadImage(f.getAbsolutePath() + "\\" + s);
      String character = getFileName(s).substring(0, 1);
      if (!contains(pairs, img) && !contains(pairs, character))
        addItem(pairs, img, character);
    }
  }
  state = State.Waiting;
}

String getFileName(String fileName) {
  return fileName.substring(0, fileName.lastIndexOf("."));
}

void saveText() {
  state = State.Waiting;
  selectOutput("Select output for text", "saveText2");
}

void saveText2(File f) {
  if (f == null) {
    state = State.Waiting;
    outputText = null;
    return;
  }
  
  //String outputText = printArrayAs2D(arr, 18, 3);
  
  OutputStream outputStream = createOutput(f.getAbsolutePath());
  OutputStreamWriter osw = new OutputStreamWriter(outputStream, java.nio.charset.StandardCharsets.UTF_8);
  
  try {
    osw.write(outputText);
    osw.close();
    state = State.Waiting;
    outputText = null;
    return;
  } catch (Exception e) {
    state = State.Waiting;
    outputText = null;
    return;
  }
}

ImageCharacterPair addItem(ArrayList<ImageCharacterPair> list, PImage item, String character) {
  ImageCharacterPair newPair = new ImageCharacterPair(item, character);
  list.add(newPair);
  return newPair;
}

boolean isPNG(File f) {
  String path = f.getAbsolutePath();
  return isPNG(path);
}

boolean isPNG(String path) {
  int indexOfPeriod = path.lastIndexOf(".");
  if (indexOfPeriod == -1) return false;
  String extension = path.substring(indexOfPeriod);
  return extension.toLowerCase().equals(".png");
}

ArrayList<PImage> sliceRaw(PImage source, int tileWidth) {
  ArrayList<PImage> output = new ArrayList<PImage>();
 
  for (int j = 0; j < source.height; j += tileWidth) {
    for (int i = 0; i < source.width; i += tileWidth) {
      output.add(source.get(i,j,tileWidth,tileWidth));
    }
  }
 
  return output;
}


boolean contains(ArrayList<ImageCharacterPair> list, PImage item) {
  for (ImageCharacterPair icp : list) {
    PImage img = icp.image;
    if (imagesEqual(img, item))
      return true;
  }
 
  return false;
}

boolean contains(ArrayList<ImageCharacterPair> list, String item) {
  for (ImageCharacterPair icp : list) {
    if (icp.character.equals(item)) return true;
  }
  return false;
}

String getCharacter(ArrayList<ImageCharacterPair> list, PImage item) {
  for (ImageCharacterPair icp : list) {
    PImage img = icp.image;
    if (imagesEqual(img, item))
      return icp.character;
  }
 
  String newChar = createNewPair(item);
  addItem(list, item, newChar);
 
  return newChar;
}

String createNewPair(PImage img) {
  image(img, 0, 0, width, height);
  String input = null;
  while (input == null || input.length() != 1) {
    input = JOptionPane.showInputDialog(null, "Enter character for image");
    if (input != null && input.equals("-1"))
      exit();
  }
  return input;
}

boolean imagesEqual(PImage a, PImage b) {
  if (a.width != b.width || a.height != b.height) return false;
  a.loadPixels();
  b.loadPixels();
 
  for(int i = 0; i < a.pixels.length; i++) {
    if (a.pixels[i] != b.pixels[i]) {
      return false;
    }
  }
 
  return true;
}
