import ceylon.test {
    TestListener,
    createTestRunner,
    TestResult,
    TestDescription,
    TestRunResult
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
import ceylon.language.meta {
    modules
}
import ceylon.json {
    JsonValue=Value,
    JsonObject,
    JsonArray
}

class BrowserTestListener() satisfies TestListener {
    
    void log(String msg) {
        dynamic {
            console.log(msg);
        }
    }
    
    void post(String path, JsonValue json=null) {
        log("making request to ``path``");
        dynamic {
            dynamic xhr = XMLHttpRequest();
            xhr.onreadystatechange = void() {
                //log("onreadystatechange");
                if (xhr.readyState == 4) {
                    if (xhr.status == 200) {
                        log("made request to ``path``");
                    } else {
                        log("problem with request to ``path``");
                    }
                } else {
                    //log("not ready: ``path``");
                }
            };
            xhr.open("POST", path, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(json?.string else "null");
        }
    }
    
    "Called before any tests have been run."
    shared actual default void testRunStarted(
        "The event object."
        TestRunStartedEvent event) {
        String url = "/callback/run/started";
        post(url, serializeDescription(event.description));
    }
    
    "Called after all tests have finished."
    shared actual default void testRunFinished(
        "The event object."
        TestRunFinishedEvent event) {
        String url = "/callback/run/finished";
        post(url, JsonObject{
                "description"->serializeDescription(event.runner.description),
                "result"->serializeRunResult(event.result)
            }
        );
        /*dynamic{
            window.open("", "_self", ""); window.close();
        }*/
    }
    
    "Called when a test is about to be started."
    shared actual default void testStarted(
        "The event object."
        TestStartedEvent event) {
        String url = "/callback/test/started";
        post(url, serializeDescription(event.description));
    }
    
    "Called when a test has finished, whether the test succeeds or not."
    shared actual default void testFinished(
        "The event object."
        TestFinishedEvent event) {
        String url = "/callback/test/finished";
        post(url, serializeResult(event.result));
    }
    
    "Called when a test has been skipped, because its condition wasn't fullfiled."
    shared actual default void testSkipped(
        "The event object."
        TestSkippedEvent event) {
        String url = "/callback/test/skipped";
        post(url, serializeResult(event.result));
    }
    
    "Called when a test has been aborted, because its assumption wasn't met."
    shared actual default void testAborted(
        "The event object."
        TestAbortedEvent event) {
        String url = "/callback/test/aborted";
        post(url, serializeResult(event.result));
    }
    
    "Called when a test will not be run, because some error has occurred.
     For example a invalid test function signature."
    shared actual default void testError(
        "The event object."
        TestErrorEvent event) {
        String url = "/callback/test/error";
        post(url, serializeResult(event.result));
    }
    
    "Called when a test is excluded from the test run due [[TestFilter]]"
    shared actual default void testExcluded(
        "The event object."
        TestExcludedEvent event) {
        String url = "/callback/test/excluded";
        post(url, serializeDescription(event.description));
    }
    
}

JsonValue serializeRunResult(TestRunResult result) {
    return JsonObject{
        "abortedCount"->result.abortedCount,
        "elapsedTime"->result.elapsedTime,
        "endTime"->result.endTime,
        "errorCount"->result.errorCount,
        "excludedCount"->result.excludedCount,
        "failureCount"->result.failureCount,
        "isFailed"->result.isFailed,
        "isSuccess"->result.isSuccess,
        "results"->JsonArray{for (r in result.results) serializeResult(r)},
        "runCount"->result.runCount,
        "skippedCount"->result.skippedCount,
        "startTime"->result.startTime,
        "successCount"->result.successCount
    };
}

JsonValue serializeResult(TestResult result) {
    return JsonObject{
        "description"->serializeDescription(result.description),
        "elapsedTime"->result.elapsedTime,
        "state"->result.state.string,
        "combined"->result.combined,
        "exception"->serializeException(result.exception)
    };
}

JsonValue serializeDescription(TestDescription desc) {
    return JsonObject{
        "name"->desc.name,
        "classDeclaration"->desc.classDeclaration?.string,
        "functionDeclaration"->desc.functionDeclaration?.string,
        "variant"->desc.variant,
        "variantIndex"->desc.variantIndex,
        "children"->JsonArray({for (child in desc.children) serializeDescription(child)})
    };
}

JsonValue serializeException(Throwable? throwable) {
    if (exists throwable) {
        value sb = StringBuilder();
        printStackTrace(throwable, sb.append);
        return JsonObject{
            "type"->className(throwable),
            "message"->throwable.message,
            "stacktrace"->sb.string,
            "cause"->serializeException(throwable.cause)
        };
    } else{
        return null;
    }
}

shared void run(String moduleName, String moduleVersion) {
    print("running `` `module` ``");
    
    assert(exists mod = modules.find(moduleName, moduleVersion));
    value runner = createTestRunner([mod], [BrowserTestListener()]);
    runner.run();
}