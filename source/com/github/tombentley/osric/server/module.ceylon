"A test runner which:
 
 1. Fires up an http server
 2. Fires up a browser
 3. Browser loads page and runs ceylon.test tests in the browser
 4. As tests run progress is reported back to the server
 
 In this way we can run tests in the browser"
native("jvm")
module com.github.tombentley.osric.server "1.0.0" {
    import ceylon.http.server "1.3.0";
    import ceylon.http.common "1.3.0";
    import ceylon.process "1.3.0";
    shared import ceylon.io "1.3.0";
    shared import ceylon.test "1.3.0";
    import ceylon.html "1.3.0";
    import ceylon.json "1.3.0";
    
    // for providing a tool
    shared import com.redhat.ceylon.cli "1.3.0";
    shared import com.redhat.ceylon.common "1.3.0";
    import ceylon.runtime "1.3.0";
    import ceylon.interop.java "1.3.0";
}
