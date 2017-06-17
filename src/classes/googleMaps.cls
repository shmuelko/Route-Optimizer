//I used example from the site "http://bulkified.com/How+to+use+the+Google+Maps+API+in+Salesforce.com" to get this google api to get the better route by car.
//Still not in use didn't had time to test it in the Algorithm.

// MOTI Class name should start with Capital letter by convention
public class googleMaps {

    public String duration {get;set;}
    public Integer travelTime {get;set;}
    public Decimal distance {get;set;}

    public googleMaps(String location1, String location2) {
        String jsonResults = getJsonResults(location1, location2);
        jsonResults = formatJsonResults(jsonResults);
        updateJsonSections(jsonResults);
    }

    public String getJsonResults(String location1, String location2) {

        HttpRequest req = new HttpRequest();
        Http http = new Http();

        req.setMethod('GET');

        String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
            + '?key=AIzaSyALnuAIZ4XWz65qCdBX0OtuO9wSImgoBEI'
            + '&origins=' + location1
            + '&destinations=' + location2
            + '&mode=driving'
            + '&sensor=false'
            + '&language=en'
            + '&units=metric';

        req.setEndPoint(url);

        HTTPResponse resp = http.send(req);

        String jsonResults = resp.getBody().replace('\n', '');

        return jsonResults;
    }

    public String formatJsonResults(String value) {

        value = value.replace('{', ', ');
        value = value.replace('}', ', ');
        value = value.replace('[', ', ');
        value = value.replace(']', ', ');
        value = value.replace('"', '');

        return value;
    }

    public void updateJsonSections(
        String jsonResults) {

        List<String> jsonSections = jsonResults.split(', ');

        for (Integer i = 0; i < jsonSections.size(); i++) {
            jsonSections[i] = jsonSections[i].trim();

            if (jsonSections[i].contains('duration :')) {
                duration = parseDuration(jsonSections[i + 1]);
                travelTime = parseTravelTime(duration);
            }

            if (jsonSections[i].contains('distance :')) {
                distance = parseDistance(jsonSections[i + 1]);
            }
        }
    }

    public Decimal parseDistance(String value) {
        value = value.replace('text : ', '');
        value = value.replace(' km', '');
        value = value.replace(' m', '');
        value = value.replace(',', '');
        value = value.trim();

        return Decimal.valueOf(value);
    }

    public String parseDuration(String value) {
        value = value.replace('text : ', '');

        return value;
    }

    public Integer parseTravelTime(String value) {

        Integer tmpMinutes = 0;

        List<String> durationNodes = value.split(' ');
        String prevDurationNode = '';

        for (String durationNode : durationNodes) {
            if (durationNode == 'day' || durationNode == 'days') {
                tmpMinutes += Integer.valueOf(prevDurationNode) * 1440;
            }
            if (durationNode == 'hour' || durationNode == 'hours') {
                tmpMinutes += Integer.valueOf(prevDurationNode) * 60;
            }
            if (durationNode == 'min' || durationNode == 'mins') {
                tmpMinutes += Integer.valueOf(prevDurationNode);
            }

            prevDurationNode = durationNode;
        }

        return tmpMinutes;
    }

}
