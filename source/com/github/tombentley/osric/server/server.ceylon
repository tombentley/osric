import ceylon.http.server {
    newServer,
    HttpEndpoint,
    Matcher,
    Endpoint,
    Request,
    Response,
    isRoot,
    pathEquals=equals,
    AsynchronousEndpoint,
    startsWith
}
import ceylon.http.common {
    get,
    post,
    contentType
}
import ceylon.io {
    SocketAddress
}
import ceylon.language.meta {
    modules
}
import ceylon.test.engine {
    DefaultTestRunner
}
import ceylon.html {
    Html,
    Head,
    Body,
    Link,
    Script
}
import ceylon.http.server.endpoints {
    serveStaticFile,
    RepositoryEndpoint
}
import ceylon.buffer.charset {
    utf8
}
import ceylon.test {
    TestListener
}
import ceylon.test.event {
    TestStartedEvent,
    TestRunStartedEvent,
    TestAbortedEvent,
    TestFinishedEvent,
    TestSkippedEvent,
    TestRunFinishedEvent,
    TestErrorEvent,
    TestExcludedEvent
}


"Run the module `com.github.tombentley.osric.server`."
class Server(String moduleName, String moduleVersion, TestListener listener) {
    shared variable Boolean finished = false;
    value server = newServer{
        Endpoint{
            path=isRoot();
            acceptMethod = {get};
            void service(Request request, Response response) {
                response.addHeader(contentType("text/html", utf8));
                response.writeString(Html{
                    Head {
                    },
                    Body {
                        Script { 
                            src = "js/require.js";
                            attributes = ["data-main"->"js/test"];
                        }
                    }
                }.string);
            }
        },
        AsynchronousEndpoint{
            path=pathEquals("/js/require.js");
            acceptMethod = {get};
            service = serveStaticFile {
                externalPath = ".";
                fileMapper(Request request)
                        => request.path;
            };
        },
        Endpoint{
            path=pathEquals("/js/test.js");
            acceptMethod = {get};
            void service(Request request, Response response) {
                response.writeString("console.log('bootstrapping');");
                response.writeString("require.config({ 'baseUrl': 'modules'});");
                response.writeString("require([
                                      'com/github/tombentley/osric/client/1.0.0/com.github.tombentley.osric.client-1.0.0',
                                      '``moduleName.replace(".", "/")``/``moduleVersion``/``moduleName``-``moduleVersion``'], 
                                      function(client, subject) { 
                                        client.run('``moduleName``', '``moduleVersion``');
                                      });");
            }
        },
        RepositoryEndpoint("/modules"),
        Endpoint{
            path=startsWith("/callback/");
            acceptMethod = {post, get};
            void service(Request request, Response response) {
                //print(request.path);
                value json = request.read();
                //print(json);
                response.addHeader(contentType("application/json", utf8));
                response.writeString("OK");
                response.flush();
                response.close();
                switch (request.path)
                case("/callback/run/started") {
                    // TODO parse the json
                    TestRunStartedEvent evt = parseRunStartedEvent(json);
                    listener.testRunStarted(evt);
                }
                case("/callback/test/started") {
                    // TODO parse the json
                    TestStartedEvent evt = parseTestStartedEvent(json);
                    listener.testStarted(evt);
                }
                case("/callback/test/aborted") {
                    // TODO parse the json
                    TestAbortedEvent evt = parseTestAbortedEvent(json);
                    listener.testAborted(evt);
                }
                case("/callback/test/finished") {
                    // TODO parse the json
                    TestFinishedEvent evt = parseTestFinishedEvent(json);
                    listener.testFinished(evt);
                }
                case("/callback/test/skipped") {
                    // TODO parse the json
                    TestSkippedEvent evt = parseTestSkippedEvent(json);
                    listener.testSkipped(evt);
                }
                case("/callback/test/error") {
                    // TODO parse the json
                    TestErrorEvent evt = parseTestErrorEvent(json);
                    listener.testError(evt);
                }
                case("/callback/test/excluded") {
                    // TODO parse the json
                    TestExcludedEvent evt = parseTestExcludedEvent(json);
                    listener.testExcluded(evt);
                }
                case("/callback/run/finished") {
                    // TODO parse the json
                    TestRunFinishedEvent evt = parseRunFinishedEvent(json);
                    listener.testRunFinished(evt);
                    finished = true;
                }
                
                else {
                    throw Exception("event not supported!");
                }
                
            }
        }
    };
    shared SocketAddress serverAddress
        => SocketAddress("localhost", 8080);
    shared void start() {
        server.startInBackground(serverAddress);
    }
    shared void stop() {
        server.stop();
    }
}