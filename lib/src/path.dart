library darter.http.path;

/**
 * Turns it easy to:
 * 1. compare whether two paths are equal or not.
 * 2. get subpaths from paths.
 * 3. handle path parts.
 */
class Path {
  List<String> parts = [];

  Path() {
  }

  Path.fromString(String path) {
    for (String part in path.split("/")) {
      if (part != null && !part.isEmpty) parts.add(part);
    }
  }

  Path subPath({int start, int end}) {
    Path result = null;

    if (start != null) {
      if(parts.getRange(start, end).length > 0){
        result = new Path();
        parts.getRange(start, end).forEach((String p) => result.parts.add(p));
      }
    }

    return result;
  }

  int get length {
    return parts.length;
  }

  String getPathParams(String url) {

  }

  bool hasPathParam() {
    bool result = false;

    for (var i = 0;i < parts.length; i++) {
      if (parts[i].indexOf(":") > 0) {
        result = true;
        break;
      }
    }

    return result;
  }

  Path join(Path path) {
    Path result = new Path();
    parts.forEach((p) => result.parts.add(p));
    path.parts.forEach((p) => result.parts.add(p));

    return result;
  }

  String toString() {
    String result = "";
    parts.forEach((p) => result += p);

    return result;
  }

  bool operator ==(other) {
    bool result = true;

    if (other is Path) {
      Path path = other;

      if (parts.length == path.parts.length) {
        for (var i = 0; i < parts.length; i++) {
          var part = parts[i];
          var partOther = other.parts[i];
          if (part != partOther) {
            result = false;
            break;
          }
        }
      } else {
        result = false;
      }
    } else {
      result = false;
    }

    return result;
  }
}