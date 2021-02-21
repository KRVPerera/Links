import ballerina/io;

public class DataLoader {

public function loadData() returns Link[]|error? {
        string csvFilePath1 = "./links/files/data/default_data.csv";
        // string[][] csvContent = [["1", "James", "10000"], ["2", "Nathan", "150000"], ["3", "Ronald", "120000"], 
        // ["4", "Roy", "6000"], ["5", "Oliver", "1100000"]];

        // check io:fileWriteCsv(csvFilePath1, csvContent);

        Link[] linksFromCsv = [];

        string[][] readCsv = check io:fileReadCsv(csvFilePath1);

        foreach var linkData in readCsv {
            Link readLink = {};
            readLink.name = linkData[0];
            readLink.path = linkData[1];
            readLink.group = linkData[2];
            io:println("readLink : ", readLink);

            linksFromCsv.push(readLink);
        }

        return linksFromCsv;
    }
}
