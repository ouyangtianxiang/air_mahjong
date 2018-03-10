package ge.net;

import java.util.Map;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpSession;
import javax.websocket.HandshakeResponse;
import javax.websocket.server.HandshakeRequest;
import javax.websocket.server.ServerEndpointConfig;

public class WSConfigurator extends ServerEndpointConfig.Configurator {

	@Override
	public void modifyHandshake(ServerEndpointConfig config, HandshakeRequest request, HandshakeResponse response) {
		HttpSession session = (HttpSession) request.getHttpSession();
		ServletRequest sr = (ServletRequest) session.getAttribute("sr");
		Map<String, Object> map = config.getUserProperties();
		map.put("RemoteAddr", sr.getRemoteAddr());
		map.put("RemoteHost", sr.getRemoteHost());
		map.put("RemotePort", sr.getRemotePort());
	}
}