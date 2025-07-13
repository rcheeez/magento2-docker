FROM varnish:alpine

COPY default.vcl /etc/varnish/default.vcl

CMD [\"varnishd\", \"-F\", \"-f\", \"/etc/varnish/default.vcl\", \"-a\", \":6081\", \"-b\", \"nginx:443\", \"-s\", \"malloc,256m\"]