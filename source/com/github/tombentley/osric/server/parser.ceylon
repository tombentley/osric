import ceylon.test {
    TestResult,
    TestDescription,
    TestRunner,
    TestRunResult,
    TestState
}
import ceylon.json {
    parse,
    JsonObject,
    JsonArray
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    ClassDeclaration
}
import ceylon.collection {
    ArrayList
}
import ceylon.test.event {
    TestSkippedEvent,
    TestRunStartedEvent,
    TestRunFinishedEvent,
    TestErrorEvent,
    TestAbortedEvent,
    TestFinishedEvent,
    TestStartedEvent,
    TestExcludedEvent
}
import ceylon.test.engine {
    DefaultTestRunResult,
    TestSkippedException,
    TestAbortedException
}

TestDescription createTestDescription(JsonObject obj) {
    assert(is String name = obj["name"]);
    FunctionDeclaration? functionDeclaration = null;
    ClassDeclaration? classDeclaration = null;
    value children = ArrayList<TestDescription>();
    if (is JsonArray c = obj["children"]) {
        for (child in c) {
            assert(is JsonObject child);
            children.add(createTestDescription(child));
        }
    }
    TestDescription td = TestDescription(name, functionDeclaration, classDeclaration, children.sequence());
    if (is String variant=obj["variant"]) {
        assert(is Integer variantIndex=obj["variantIndex"]);
        return td.forVariant(variant, variantIndex);
    } else {
        return td;
    }
}

class MyRunner(description, TestRunResult result) satisfies TestRunner {
    shared actual TestDescription description;
    
    shared actual TestRunResult run() => result;
}

TestRunStartedEvent parseRunStartedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    value description = createTestDescription(obj);
    return TestRunStartedEvent(MyRunner(description, DefaultTestRunResult()), description);
}


TestRunResult createTestRunResult(JsonObject obj) {
    assert(is Integer abortedCount_ = obj["abortedCount"]);
    assert(is Integer elapsedTime_ = obj["elapsedTime"]);
    assert(is Integer endTime_ = obj["endTime"]);
    assert(is Integer errorCount_ = obj["errorCount"]);
    assert(is Integer excludedCount_ = obj["excludedCount"]);
    assert(is Integer failureCount_ = obj["failureCount"]);
    assert(is Boolean isFailed_ = obj["isFailed"]);
    assert(is Boolean isSuccess_ = obj["isSuccess"]);
    
    assert(is JsonArray results = obj["results"]);
    value res = ArrayList<TestResult>();
    for (result in results) {
        assert(is JsonObject result);
        res.add(createTestResult(result));
    }
    
    assert(is Integer runCount_ = obj["runCount"]);
    assert(is Integer skippedCount_ = obj["skippedCount"]);
    assert(is Integer startTime_ = obj["startTime"]);
    assert(is Integer successCount_ = obj["successCount"]);
    
    return object satisfies TestRunResult {
        abortedCount = abortedCount_;
        elapsedTime = elapsedTime_;
        endTime = endTime_;
        errorCount = errorCount_;
        excludedCount = excludedCount_;
        failureCount = failureCount_;
        isFailed = isFailed_;
        isSuccess = isSuccess_;
        results = res.sequence();
        runCount = runCount_;
        skippedCount = skippedCount_;
        startTime = startTime_;
        successCount = successCount_;
    };
}

TestRunFinishedEvent parseRunFinishedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    assert(is JsonObject desc = obj["description"]);
    assert(is JsonObject res = obj["result"]);
    value description = createTestDescription(desc);
    value result = createTestRunResult(res);
    return TestRunFinishedEvent(MyRunner(description, result), result);
}

TestStartedEvent parseTestStartedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    value description = createTestDescription(obj);
    return TestStartedEvent(description, null);
}

TestResult createTestResult(JsonObject obj) {
    assert(is JsonObject description=obj["description"]);
    assert(is Integer elapsedTime=obj["elapsedTime"]);
    assert(is String state=obj["state"]);
    assert(is Boolean combined=obj["combined"]);
    Throwable? exception;
    if (is JsonObject ex=obj["exception"]) {
        exception = createThrowable(ex);
    } else {
        exception = null;
    }
    return TestResult {
        description = createTestDescription(description);
        state = switch(state) 
        case("success") TestState.success 
        case("failure") TestState.failure
        case("aborted") TestState.aborted
        case("error") TestState.error
        case("skipped") TestState.skipped
        else nothing;
        combined = combined;
        exception = exception;
        elapsedTime = elapsedTime;
    };
}


TestAbortedEvent parseTestAbortedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    return TestAbortedEvent(createTestResult(obj));
}

Throwable? createThrowable(JsonObject ex) {
    Throwable? exception;
    assert(is String message = ex["message"]);
    assert(is String type = ex["type"]);
    switch(type) 
    case ("ceylon.test.engine::TestSkippedException") {
        exception = TestSkippedException(message);
    }
    case ("ceylon.test.engine::TestAbortedException") {
        exception = TestAbortedException(message);
    }
    case ("ceylon.language::AssertionError") {
        exception = AssertionError(message);
    }
    else {
        
        Throwable? cause;
        if (is JsonObject c=ex["cause"]) { 
            cause = createThrowable(c);
        } else {
            cause = null; 
        }
        // TODO the right exception type
        exception = Exception(message, cause);
    }
    if (is String st = ex["stacktrace"]) {
        // TODO how to attach a stacktrace to an exception
        //print(st);
    }
 
    return exception;
}

TestFinishedEvent parseTestFinishedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    return TestFinishedEvent(createTestResult(obj));
}

TestSkippedEvent parseTestSkippedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    return TestSkippedEvent(createTestResult(obj));
}

TestErrorEvent parseTestErrorEvent(String json) {
    assert(is JsonObject obj = parse(json));
    return TestErrorEvent(createTestResult(obj));
}

TestExcludedEvent parseTestExcludedEvent(String json) {
    assert(is JsonObject obj = parse(json));
    return TestExcludedEvent(createTestDescription(obj));
}