import ceylon.test.engine {
    DefaultLoggingListener
}
import java.lang {
    Thread
}
/*
Browser[] findBrowsers() {
    if (exists path = process.environmentVariableValue("PATH")) {
        for (dir in path.split((ch) => ch == ':')) {
            
        }
    } else {
        return [];
    }
}
*/

shared void run() {
    if (exists modVer = process.arguments.first?.split((ch) => ch == '/')?.sequence()) {
        assert(exists mod = modVer[0]);
        assert(exists ver = modVer[1]);
        runTest(mod, ver);
    }
}

shared void runTest(String testModule, String version) {
    
    value listener = DefaultLoggingListener();
    value server = Server(testModule, version, listener);
    server.start();
    value browser = firefox(server.serverAddress);
    while (!server.finished) {
        Thread.currentThread().sleep(1000);
    }
    print("tests finished");
    browser.kill();
    print("browser killed");
    server.stop();
    print("server stopped");
    
}