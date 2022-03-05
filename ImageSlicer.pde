public abstract class ImageSlicer
{
  public abstract boolean applies(PImage source);

  public abstract ArrayList<PImage> process(PImage source);

  protected String outputText;
  public void saveText(String outputText) {
    this.outputText = outputText;
    selectOutput("Select output for text", "saveTextFile", null, this);
  }

  public abstract void saveTextFile(File f);
}

public class RawDialogueSlicer extends ImageSlicer
{
  public final String type = "RawDialogueSlicer";
  public boolean applies(PImage source) {
    return source.width == 352 && source.height == 352;
  }

  public ArrayList<PImage> process(PImage source) {
    return sliceRaw(source.get(24, 168, 288, 48), 16);
  }

  public void saveTextFile(File f) {
    if (f == null) {
      state = State.Waiting;
      outputText = null;
      return;
    }

    //add
    this.outputText = insert(this.outputText, "\n", new int[] {18, 36});

    OutputStream outputStream = createOutput(f.getAbsolutePath());
    OutputStreamWriter osw = new OutputStreamWriter(outputStream, java.nio.charset.StandardCharsets.UTF_8);
    try {
      osw.write(this.outputText);
      osw.close();
      state = State.Waiting;
      outputText = null;
      return;
    }
    catch (Exception e) {
      state = State.Waiting;
      outputText = null;
      return;
    }
  }
}

public class RawImageSlicer extends ImageSlicer {
  public final String type = "RawImageSlicer";
  int imgWidth;
  int imgHeight;
  public boolean applies(PImage source) {
    return source.width % 16 == 0 && source.height % 16 == 0;
  }
  public ArrayList<PImage> process(PImage source) {
    imgWidth = source.width;
    imgHeight = source.height;
    return sliceRaw(source, 16);
  }
  
  public void saveTextFile(File f) {
    if (f == null) {
      state = State.Waiting;
      outputText = null;
      return;
    }
    
    this.outputText = insertLineEnds(this.outputText);

    OutputStream outputStream = createOutput(f.getAbsolutePath());
    OutputStreamWriter osw = new OutputStreamWriter(outputStream, java.nio.charset.StandardCharsets.UTF_8);
    try {
      osw.write(this.outputText);
      osw.close();
      state = State.Waiting;
      outputText = null;
      return;
    }
    catch (Exception e) {
      state = State.Waiting;
      outputText = null;
      return;
    }
  }
  
  String insertLineEnds(String outputText) {
    int tX = imgWidth / 16;
    int tY = imgHeight / 16;
    int[] indexes = new int[tY - 1];
    for (int i = 0; i < indexes.length - 1; i++) {
      indexes[i] = tX * (i + 1);
    }
    return insert(outputText, "\n", indexes);
  }
}
