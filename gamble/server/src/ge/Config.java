package ge;

import ge.utils.Util;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Properties;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Config {
	public static int version;
	private static final HashMap<String, String> config = new HashMap<String, String>();

	static {
		InputStream is = Config.class.getResourceAsStream("/META-INF/MANIFEST.MF");
		Properties p = new Properties();
		try {
			p.load(is);
			version = Integer.parseInt((String) p.get("Game-Version"));
		} catch (Exception e) {
		}
	}

	public static String Init(String url) {
		try {
			parse(url);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return config.toString();
	}

	private static void parse(String url) throws Exception {
		System.out.println(url);
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document document = db.parse(url);
		Node root = document.getFirstChild();
		NodeList list = root.getChildNodes();
		for (int j = 0; j < list.getLength(); j++) {
			Node node = list.item(j);
			if (node.getNodeType() == 1) {
				String k = node.getNodeName().trim().toLowerCase();
				String v = node.getTextContent().trim();
				config.put(k.toLowerCase(), Util.Env(v));
			}
		}
	}

	public static String get(String key) {
		return config.get(key.toLowerCase());
	}
}
