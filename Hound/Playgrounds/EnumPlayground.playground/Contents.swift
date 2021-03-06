
//TEST: enum case is equal to a value, can be used to reference one another, if you have one you ccan find the other

enum Test: String {
    case test1 = "testone"
    case test2 = "testtwo"
}

var apple = Test(rawValue: "testone")
apple?.rawValue


//TEST: what do the () do after the case, see example below

enum Test2: Error {
    case test1(String)
    case test2(String)
    case test3
}

func testFunc() throws{
    throw Test2.test1("str")
}

do{
    try testFunc()
}
catch Test2.test1("str"){
    print("first case")
}
catch Test2.test1("strrr"){
    print("second case")
}
catch Test2.test1{
    print("third case")
}

// TESTING the if case CustomErrorClass.certainError = passedError, see below

func testFunc2() throws{
    throw Test2.test3
}

func errorPasser(error: Test2){
    if case Test2.test1("str") = error {
        print("abc")
    }
    else if case Test2.test3 = error{
        print("def")
    }
}

do{
    try testFunc2()
}
catch{
    errorPasser(error: error as! Test2)
}
