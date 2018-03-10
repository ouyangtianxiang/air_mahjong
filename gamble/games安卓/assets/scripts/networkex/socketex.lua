require("EngineCore/network")
Socket.writeBinary = function(self, packetId, string, compress)
	return socket_write_string_compress(packetId, string, compress)
end