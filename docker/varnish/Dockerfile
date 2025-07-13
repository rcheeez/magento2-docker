FROM varnish:7.4.2-alpine

COPY default.vcl /etc/varnish/default.vcl

EXPOSE 6081

CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl", "-s", "malloc,256m", "-a", "0.0.0.0:6081"]
