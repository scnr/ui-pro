FactoryGirl.define do
    factory :http_response do
        url 'http://test.com/stuff?pname=pvalue'
        code 404
        ip_address '127.0.0.2'
        headers({
            "Content-Type" => "text/html;charset=utf-8",
            "X-Cascade" => "pass",
            "Content-Length" => "443",
            "X-Xss-Protection" => "1; mode=block",
            "X-Content-Type-Options" => "nosniff",
            "X-Frame-Options" => "SAMEORIGIN",
            "Connection" => "keep-alive",
            "Server" => "thin 1.6.2 codename Doc Brown"
        })
        body <<EOHTML
<!DOCTYPE html>
<html>
<head>
  <style type="text/css">
  body { text-align:center;font-family:helvetica,arial;font-size:22px;
    color:#888;margin:20px}
  #c {margin:0 auto;width:500px;text-align:left}
  </style>
</head>
<body>
  <h2>Sinatra doesn&rsquo;t know this ditty.</h2>
  <img src='http://127.0.0.2:4567/__sinatra__/404.png'>
  <div id="c">
    Try this:
    <pre>post '/stuff' do
  "Hello World"
end
</pre>
  </div>
</body>
</html>
EOHTML
        time 0.012
        return_code 'ok'
        return_message "No error"
        raw_headers "HTTP/1.1 404 Not Found
Content-Type: text/html;charset=utf-8
X-Cascade: pass
Content-Length: 443
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Connection: keep-alive
Server: thin 1.6.2 codename Doc Brown
"
    end
end
