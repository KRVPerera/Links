// import ballerina/io;
import ballerina/test;

# Before Suite Function
@test:BeforeSuite
function beforeSuiteFunc() {
// io:println("I'm the before suite function!");
}

# Before test function
function beforeFunc() {
// io:println("I'm the before function!");
}

@test:Config {
    before: beforeFunc,
    after: afterFunc
}
function testFunction() returns error? {
    DataLoader loader = new DataLoader();
    Link[]? loadData = check loader.loadData();
    if (loadData is Link[]) {
        test:assertEquals("personal", loadData[0].group);
        return;
    }
    test:assertFalse(true);
}

# Test function
@test:Config {
    before: beforeFunc,
    after: afterFunc
}
function testFunction2() {
    Link link1 = {
        name: "Me",
        path: "https://github.com/KRVPerera",
        group: "ballerina"
    };
    test:assertEquals("ballerina", link1.group);
}

# After test function
function afterFunc() {
// io:println("I'm the after function!");
}

# After Suite Function
@test:AfterSuite {}
function afterSuiteFunc() {
// io:println("I'm the after suite function!");
}
