FROM openresty/openresty:1.21.4.1-0-alpine

# Needed to make opm (OpenResty Package Manager) operable on Alpine flavour

RUN apk add --no-cache curl perl

# I had thought I would need to install Lua CJSON module, but OpenResty provides its own
# fork: https://openresty.org/en/lua-cjson-library.html and this is enabled by default.

# While we don't need to install CJSON, we will benefit from having a library
# for formulating Prometheus metrics such as histograms.

# https://opm.openresty.org/package/knyar/nginx-lua-prometheus/
RUN opm get knyar/nginx-lua-prometheus
