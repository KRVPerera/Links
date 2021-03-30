import ballerina/io;
import ballerina/http;

public type PayloadType string|xml|json;

public class LinksResponse {
    public http:Response res;

    public function init(int statusCode) {
        self.res = new();
        self.res.statusCode = statusCode;
    }

    public function build(int statusCode) returns LinksResponse {
        self.res = new();
        self.res.statusCode = statusCode;
        return self;
    }

    public function setPayload(PayloadType payload) returns LinksResponse {
        self.res.setPayload(payload);
        return self;
    }
}

public function hello() {
    io:println("Hello World!");
}
