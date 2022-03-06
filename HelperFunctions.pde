public String insert(String source, String keyword, int[] indexes) {
  String output = "";
  if (indexes.length == 0) return source;
  if (indexes.length == 1) {
    return source.substring(0, indexes[0]) + keyword + source.substring(indexes[0]);
  }
  for (int i = 0; i < indexes.length; i++) {
    if (i == 0)
      output += source.substring(0, indexes[i]) + keyword;
    else 
      output += source.substring(indexes[i-1] , indexes[i]) + keyword;
  }
  
  output += source.substring(indexes[indexes.length - 1]);

  return output;
}

public PImage replace(PImage source, color oldColor, color newColor) {
  PImage output = source.copy();
  output.loadPixels();
  source.loadPixels();
  
  for (int i = 0; i < output.pixels.length; i++) {
    if (source.pixels[i] == oldColor)
      output.pixels[i] = newColor;
  }
  output.updatePixels();
  
  return output;
}
