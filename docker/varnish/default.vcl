vcl 4.1;

backend default {
    .host = "nginx";
    .port = "443";
}

sub vcl_recv {
    if (req.method != \"GET\" &&
        req.method != \"HEAD\" &&
        req.method != \"PUT\" &&
        req.method != \"POST\" &&
        req.method != \"TRACE\" &&
        req.method != \"OPTIONS\" &&
        req.method != \"DELETE\") {
        return (pipe);
    }

    if (req.method != \"GET\" && req.method != \"HEAD\") {
        return (pass);
    }

    if (req.url ~ \"(?i)\\.(php|xml)$\") {
        return (pass);
    }
}

sub vcl_backend_response {
    set beresp.ttl = 5m;
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = \"HIT\";
    } else {
        set resp.http.X-Cache = \"MISS\";
    }
}
