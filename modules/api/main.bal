import ballerina/http;
import ballerina/jdbc;
import ballerina/sql;
import rukshanp/db;
import ballerina/log;


jdbc:Client|sql:Error linkdDbClient = db:getLinksDbClient();

@http:ServiceConfig {
    basePath: "/links",
    cors: {
            allowOrigins: ["http://localhost:3000", "http://www.krvperera.com/WFHManager/"]
        }
}
service contentBasedRouting on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/all",
        cors: {
            allowOrigins: ["http://localhost:3000", "http://www.krvperera.com/WFHManager/"]
        }
    }
    resource function allResource(http:Caller outboundEP, http:Request req) {
        var jsonMsg = req.getJsonPayload();
        if (jsonMsg is json) {
            log:printDebug(jsonMsg);
            json|error nameString = jsonMsg.name;

            http:Response|http:Payload|error response;
            if (nameString is json) {
                if (nameString.toString() == "all") {
                    http:Response res = new;
                    res.statusCode = 200;

                    log:printDebug("Hit all request");

                    if (linkdDbClient is jdbc:Client) {
                        json[] queryResult = db:getAllRecord(linkdDbClient);
                        log:printDebug("RECIEVED data from DB");
                        log:printDebug(queryResult);
                        res.setPayload(queryResult);
                    }

                    var result = outboundEP->respond(res);
                    if (result is error) {
                        log:printError("Error sending response", result);
                    }

                } else {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload("Invalid request");
                    var result = outboundEP->respond(res);
                    if (result is error) {
                        log:printError("Error sending response", result);
                    }
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(<@untainted>nameString.message());                
                var result = outboundEP->respond(res);
                if (result is error) {
                    log:printError("Error sending response", result);
                }
            }
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted>jsonMsg.message());            
            var result = outboundEP->respond(res);
            if (result is error) {
                log:printError("Error sending response", result);
            }
        }
    }
}
