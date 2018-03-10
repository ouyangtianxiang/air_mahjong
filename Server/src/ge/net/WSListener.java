package ge.net;

import javax.servlet.ServletRequest;
import javax.servlet.ServletRequestEvent;
import javax.servlet.ServletRequestListener;
import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

@WebListener
public class WSListener implements ServletRequestListener {

	public void requestInitialized(ServletRequestEvent sre) {
		ServletRequest sr = sre.getServletRequest();
		HttpSession session = ((HttpServletRequest) sr).getSession();
		session.setAttribute("sr", sr);
	}
}