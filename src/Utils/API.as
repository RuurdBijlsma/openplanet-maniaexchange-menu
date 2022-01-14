namespace API
{
    Net::HttpRequest@ Get(const string &in url) {
        print("Starting URL request: '" + url + "'");
        
        auto request = Net::HttpRequest();
        dictionary headers = {{'Content-Type', "application/json"}};
        @request.Headers = headers;
        request.Method = Net::HttpMethod::Get;
        request.Url = url;
        request.Start();
        return request;
    }
    
    bool DownloadToFile(string url, string destinationPath) {
        auto request = Get(url);
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

    Json::Value GetAsync(string url) {
        print("Requesting url: '" + url + "'");

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
            return Json::Parse(request.String());
        }

        auto contentType = request.ResponseHeader('Content-Type');
        if(!contentType.Contains('application/json')){
            warn("Wrong response type, expected application/json, got '" + contentType + "'");
            return Json::Parse(request.String());
        }

        auto requestString = request.String();
        print("Request string result: " + requestString);
        return Json::Parse(requestString);
    }
}