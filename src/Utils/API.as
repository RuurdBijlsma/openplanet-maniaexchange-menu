namespace API {
    Net::HttpRequest@ Get(const string &in url) {
        print("Get: '" + url + "'");
        auto request = Net::HttpRequest();
        dictionary headers = {{'Content-Type', "application/json"}};
        @request.Headers = headers;
        request.Method = Net::HttpMethod::Get;
        request.Url = url;
        request.Start();
        return request;
    }
    
    bool DownloadToFile(const string &in url, const string &in destinationPath) {
        auto request = Net::HttpGet(url);
        while(!request.Finished())
            yield();
        auto code = request.ResponseCode();
        if(code < 200 || code >= 300) {
            warn("Error making request to '" + url + "' error code: " + code);
            return false;
        }
        request.SaveToFile(destinationPath);
        return true;
    }

    Json::Value GetAsync(const string &in url) {
        print("GetAsync: '" + url + "'");
        auto request = Net::HttpRequest();
        request.Url = url;
        dictionary headers = {{'Content-Type', "application/json"}};
        @request.Headers = headers;
        request.Start();
        while(!request.Finished())
            yield();
        auto code = request.ResponseCode();
        if(code < 200 || code >= 300) {
            warn("Error making request to '" + url + "' error code: " + code);
            return Json::Object();
        }

        auto contentType = request.ResponseHeader('Content-Type');
        if(!contentType.Contains('application/json')){
            warn("Wrong response type, expected application/json, got '" + contentType + "'");
            return Json::Object();
        }

        auto requestString = request.String();
        auto jsonResult = Json::Parse(requestString);
        if(requestString.Length > 1000000) {
            warn("Very big response size!");
            return Json::Object();
        }
        return jsonResult;
    }
}