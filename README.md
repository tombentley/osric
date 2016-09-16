# Testing in the browser

This is a prototype for a Ceylon tool for running `ceylon.test` tests in a web browser.

This is useful because the existing `ceylon test-js` runs tests on node, which is a completely 
different environment to a browser.

## Theory

It works like this:

1. `ceylon test-browser org.example.module/1.0.0` runs the server module (a jvm module)
2. The server module starts a webserver on `localhost:8080`
3. The server module starts a web browser (currently only firefox is supported)
    pointed at http://localhost:8080/
4. The server module serves up a page which loads the client module (a js module) 
5. The client module uses `ceylon.test` to run the tests, passing the client module's `TestListener`
6. That `TestListener` `POST`s the results back to the server.
7. The tests finish, we kill the browser and stop the server and print the results.

## Practice

Assuming you've already cloned this repo...

    # compile the modules
    ceylon compile,compile-js
    
You've now got the server and client modules, plus a test module in your `./modules`.

    # install the ceylon test-browser plugin 
    ceylon plugin install com.github.tombentley.osric.server/1.0.0
    
You now have the `ceylon test-browser` tool (which is a shameless ripoff of the 
`ceylon test` tool).

    # finally run the tool on a module of tests
    ceylon test-browser com.github.tombentley.osric.test.subject/1.0.0
    
That will run the test module `com.github.tombentley.osric.test.subject` in the browser.

If it works you should see test results like these:

    ======================== TEST RESULTS ========================
    run:     3
    success: 1
    failure: 1
    error:   1
    skipped: 1
    aborted: 1
    time:    1s

## Issues

Off the top of my head

1. More browsers
2. Serializing exceptions (cross backend, yikes!)
3. Relationship to `ceylon.test` 

But there are sure to be plenty more.
