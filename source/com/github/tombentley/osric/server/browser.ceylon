import ceylon.process {
    Process,
    createProcess
}
import ceylon.io {
    SocketAddress
}

 

class BrowserProcess(Process proc) {
    shared default void kill() {
        print(proc.exitCode);
        proc.kill();
    }
    shared default Integer waitFor() {
        return proc.waitForExit();
    }
}

BrowserProcess firefox(SocketAddress server, String executable="firefox", String profileName = "ceylon-test-profile") {
    // create a test profile first 
    value p = createProcess(executable, ["-no-remote", "-CreateProfile", profileName]);
    p.waitForExit();
    // then launch FF with this profile
    // otherwise, if ff is already running, we launch in a new window, not a new process
    return object extends BrowserProcess(createProcess(executable, [ 
        "-P", profileName, 
        "-no-remote", // a new instance
        "http://``server.address``:``server.port``/"])) {
        /*shared actual void kill() {
            super.kill();
            //createProcess(executable, ["-no-remote", "-P", profileName, "-killAll"]);
        }*/
    };
}





