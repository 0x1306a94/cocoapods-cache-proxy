#!/bin/sh

set -ex

gem build cocoapods-cache-proxy.gemspec && gem install cocoapods-cache-proxy-0.0.1.gem --verbose