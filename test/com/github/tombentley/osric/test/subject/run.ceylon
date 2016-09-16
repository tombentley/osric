import ceylon.test{test,
    assertTrue,
    ignore,
    assumeTrue}

test
shared void testSuccess() {
    
}

test
shared void testFail() {
    assertTrue(false, "a failed assertion");
}

test
shared void testError() {
    throw Exception("an error");
}

test
ignore
shared void testIgnored() {
    
}

test
shared void testAborted() {
    assumeTrue(false, "a failed assumption");
}