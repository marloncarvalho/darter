class CryogenAnnotation {
  const CryogenAnnotation();
}

class CryogenAnnotation2 {
  const CryogenAnnotation2();
}

@CryogenAnnotation()
@CryogenAnnotation2()
class AnnotatedClass {

  @CryogenAnnotation()
  int field1 = 1;

  @CryogenAnnotation()
  String field2 = "2";

  @CryogenAnnotation()
  double field3 = 3.0;

  String methodExists() {}

  String invokeMe() {
    return "Invoked";
  }

}