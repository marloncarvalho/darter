library darter.http.path;

/**
 * Its main goals is to turn it easy to:
 * 1. compare whether two paths are equal or not.
 *  2. get subpaths from paths.
 *  3. efficiently handle path parts.
 */
class Path {
  List<String> parts = [];

  Path() {
  }

  /**
   * Create a new instance from a String that represents a URI.
   */
  Path.fromString(String path) {
    if (path != null) {
      for (String part in path.split("/")) {
        if (part != null && !part.isEmpty) parts.add(part);
      }
    }
  }

  /**
   * Create a child path from this one.
   */
  Path subPath({int start, int end}) {
    Path result = null;

    if (start != null) {
      if (parts.getRange(start, end).length > 0) {
        result = new Path();
        parts.getRange(start, end).forEach((String p) => result.parts.add(p));
      }
    }

    return result;
  }

  /**
   * How many parts this path is composed of?
   */
  int get length {
    return parts.length;
  }

  /**
   * Join two paths.
   */
  Path join(Path path) {
    if(path == null) {
      throw new ArgumentError();
    }

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