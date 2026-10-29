require "webmock/rspec"

# Specs never reach the internet: an HTTP call nobody stubbed raises
# WebMock::NetConnectNotAllowedError instead of calling a real API.
WebMock.disable_net_connect!
