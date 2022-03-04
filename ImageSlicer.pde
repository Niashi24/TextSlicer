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
