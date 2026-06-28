class ThemeJsScripts {
  static const String roundedCorners = """
  "#app{"+
    "border-radius: 15px !important;"+
  "}"+
""";

  static const String removeDownloadForWindows = """
  "section[data-testid=\\"intro-panel\\"] > :first-child {" +
      "display: none !important;" +
  "}"+
  "div[data-tab=\\"4\\"]:has(span[data-icon=\\"wa-square-icon\\"]) {" +
      "display: none !important;" +
  "}"+
""";

  static const String lightModeJS = """
  var style = document.createElement("style");
  style.innerHTML =

  $roundedCorners

  $removeDownloadForWindows

  "body{"+
    "background:#fff !important;"+
  "}"+

  "._ap4q::after {"+
    "background-color: #fff !important;"+
  "}";

  var ref = document.querySelector("script");
  ref.parentNode.insertBefore(style, ref);
  document.getElementsByTagName("body")[0].classList = [""];
""";

  static const String darkModeJS = """
  var style = document.createElement("style");
  style.innerHTML =

  $roundedCorners

  $removeDownloadForWindows

  "body{"+
    "background:#000 !important;"+
  "}"+

  "._ap4q::after {"+
    "background-color: #000 !important;"+
  "}";

  var ref = document.querySelector("script");
  ref.parentNode.insertBefore(style, ref);
  document.getElementsByTagName("body")[0].classList = ["dark"];
""";
}
