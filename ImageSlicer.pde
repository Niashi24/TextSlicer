public abstract class ImageSlicer
{
  public abstract boolean applies(PImage source);

  public abstract ArrayList<PImage> process(PImage source);

  String outputText;
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

  //public void saveText(String outputText) {
  //  selectOutput("Select output for text", "saveTextFile", null, this);
  //}

  public void saveTextFile(File f) {
    println("here");
  }
}
