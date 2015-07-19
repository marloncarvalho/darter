library darter.parameters;

class Parameters {
  Map<String, Object> _values = new Map();

  Parameters(Map values): _values = values;

  String getString(String name) {
    Object result = null;

    if (_values.containsKey(name)) {
      result = _values[name];
    }

    return result;
  }

  int getInt(String field) {
    return int.parse(getString(field));
  }

  double getDouble(String field) {
    return double.parse(getString(field));
  }

  num getNum(String field) {
    return num.parse(getString(field));
  }

  bool getBool(String field) {
    return getString(field) == "true";
  }

}