package ge;

import ge.db.DB;
import ge.log.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;
import java.util.Map.Entry;

public class MySqlToBean {

	private String javaPath = null;
	private String asPath = null;

	public MySqlToBean(String javaBeanPath, String asBeanPath) {
		javaPath = javaBeanPath;
		asPath = asBeanPath;
		File[] f1 = new File(javaPath).listFiles();
		File[] f2 = new File(asPath).listFiles();
		for (File file : f1) {
			file.delete();
		}
		for (File file : f2) {
			file.delete();
		}

		Statement statement;
		try {
			statement = DB.Conn().createStatement();

			ResultSet tables = statement.executeQuery("SHOW TABLE STATUS");
			HashMap<String, String> ts = new HashMap<String, String>();
			while (tables.next()) {
				ts.put(tables.getString("Name"), tables.getString("Comment"));
			}
			Iterator<Entry<String, String>> it = ts.entrySet().iterator();
			while (it.hasNext()) {
				Entry<String, String> t = it.next();
				String tableName = t.getKey();
				String tableComment = t.getValue();

				String javaFields = "";
				String javaStaticFields = "";
				String asFields = "";
				String asNames = "";
				String asType = "";
				String javaType = "";
				String poss = "";
				String sizes = "";
				String maps = "";
				Vector<String> types = new Vector<String>();
				Vector<String> fieldNames = new Vector<String>();
				Vector<String> fieldComments = new Vector<String>();
				Log.System(tableName + "...");
				ResultSet rs = statement.executeQuery("show full fields from " + tableName);

				int pos = 0;
				int num = 0;
				int primaryKey = 0;
				String _key = "";
				while (rs.next()) {
					String fieldName = rs.getString("Field").replaceAll(" ", "_");
					String fieldType = rs.getString("Type");
					String fieldComment = rs.getString("Comment");
					String key = rs.getString("Key");
					boolean map = fieldComment.isEmpty() || fieldComment.charAt(0) != '@';

					if (key.equals("PRI")) {
						primaryKey = num;
					}
					if (fieldComment.contains("$")) {
						_key += "," + num;
					}
					int size = typeSize(fieldType);

					javaType += ", " + javaTypeIndex(fieldType);
					poss += ", " + pos;
					sizes += ", " + size;
					maps += ", " + map;

					javaFields += javaField(fieldComment, javaType(fieldType), fieldName);
					javaStaticFields += javaStaticField(fieldComment, num, fieldName);

					types.add(javaType(fieldType));
					fieldNames.add(fieldName);
					fieldComments.add(fieldComment);

					asNames += ", \"" + fieldName + "\"";
					asType += ", " + asTypeIndex(fieldType);
					if (map) {
						asFields += asField(fieldComment, asType(fieldType), fieldName, pos, fieldType, tableName);
					}
					pos += size;

					num++;
				}
				_key = _key.substring(1);
				asNames = asNames.substring(2);
				asType = asType.substring(2);
				javaType = javaType.substring(2);
				poss = poss.substring(2);
				sizes = sizes.substring(2);
				maps = maps.substring(2);

				tableName = tableName.substring(0, 1).toUpperCase() + tableName.substring(1);
				String javaC = "";
				javaC += javaInsert(tableName, types, fieldNames, fieldComments);
				javaC += javaInit(tableName);
				javaC += javaMySql(tableName);

				javaFields += interfaces(javaStaticFields);

				save(javaBean(tableName, javaC, javaFields, javaType, poss, sizes, maps, tableComment, primaryKey, num, _key, fieldNames).getBytes("utf-8"), javaPath + tableName + ".java");
				save(asBean(tableName, asFields, asNames, asType, maps, tableComment, num, _key, pos).getBytes("utf-8"), asPath + tableName + ".as");

				Log.System(tableName + "OK");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private String interfaces(String string) {
		String str = "	public interface I {";
		str += "\r\n";
		str += string;
		str += "	}";
		str += "\r\n";
		return str;
	}

	private int typeSize(String fieldType) {
		if (fieldType.indexOf("tinyint") == 0) {
			return 1;
		} else if (fieldType.indexOf("smallint") == 0) {
			return 2;
		} else if (fieldType.indexOf("int") == 0) {
			return 4;
		} else if (fieldType.indexOf("float") == 0) {
			return 4;
		} else if (fieldType.indexOf("double") == 0) {
			return 8;
		} else if (fieldType.indexOf("char") >= 0) {
			return Integer.valueOf(fieldType.substring(fieldType.indexOf('(') + 1, fieldType.indexOf(')')));
		} else {
			throw new Error("不支持的类型：" + fieldType);
		}
	}

	private int asTypeIndex(String fieldType) {
		if (fieldType.indexOf("tinyint") == 0) {
			return 1;
		} else if (fieldType.indexOf("smallint") == 0) {
			return 2;
		} else if (fieldType.indexOf("int") == 0) {
			return 3;
		} else if (fieldType.indexOf("float") == 0) {
			return 4;
		} else if (fieldType.indexOf("double") == 0) {
			return 5;
		} else if (fieldType.indexOf("char") >= 0) {
			return 6;
		} else {
			throw new Error("不支持的类型：" + fieldType);
		}
	}

	private String javaTypeIndex(String fieldType) {
		if (fieldType.indexOf("tinyint") == 0) {
			return "Type.BYTE";
		} else if (fieldType.indexOf("smallint") == 0) {
			return "Type.SHORT";
		} else if (fieldType.indexOf("int") == 0) {
			return "Type.INT";
		} else if (fieldType.indexOf("float") == 0) {
			return "Type.FLOAT";
		} else if (fieldType.indexOf("double") == 0) {
			return "Type.DOUBLE";
		} else if (fieldType.indexOf("char") >= 0) {
			return "Type.STRING";
		} else {
			throw new Error("不支持的类型：" + fieldType);
		}
	}

	private String javaType(String fieldType) {
		if (fieldType.indexOf("tinyint") == 0) {
			return "byte";
		} else if (fieldType.indexOf("smallint") == 0) {
			return "short";
		} else if (fieldType.indexOf("int") == 0) {
			return "int";
		} else if (fieldType.indexOf("float") == 0) {
			return "float";
		} else if (fieldType.indexOf("double") == 0) {
			return "double";
		} else if (fieldType.indexOf("char") >= 0) {
			return "String";
		} else {
			throw new Error("不支持的类型：" + fieldType);
		}
	}

	private String asType(String fieldType) {
		if (fieldType.indexOf("tinyint") == 0) {
			return "int";
		} else if (fieldType.indexOf("smallint") == 0) {
			return "int";
		} else if (fieldType.indexOf("int") == 0) {
			return "int";
		} else if (fieldType.indexOf("float") == 0) {
			return "Number";
		} else if (fieldType.indexOf("double") == 0) {
			return "Number";
		} else if (fieldType.indexOf("char") >= 0) {
			return "String";
		} else {
			throw new Error("不支持的类型：" + fieldType);
		}
	}

	private String asTypeIO(String fieldType) {
		if (fieldType.indexOf("tinyint") == 0) {
			return "Byte";
		} else if (fieldType.indexOf("smallint") == 0) {
			return "Short";
		} else if (fieldType.indexOf("int") == 0) {
			return "Int";
		} else if (fieldType.indexOf("float") == 0) {
			return "Float";
		} else if (fieldType.indexOf("double") == 0) {
			return "Double";
		} else if (fieldType.indexOf("char") >= 0) {
			return "UTF";
		} else {
			throw new Error("不支持的类型：" + fieldType);
		}
	}

	private String javaField(String fieldComment, String type, String fieldName) {
		String code = "";
		code += "	/**";
		code += "\r\n";
		code += "	 * " + fieldComment;
		code += "\r\n";
		code += "	 */";
		code += "\r\n";
		code += "	public " + type + " " + fieldName + ";";
		code += "\r\n";
		code += "\r\n";
		return code;
	}

	private String javaStaticField(String fieldComment, int index, String fieldName) {
		String code = "";
		code += "		/**";
		code += "\r\n";
		code += "		 * " + fieldComment;
		code += "\r\n";
		code += "		 */";
		code += "\r\n";
		code += "		byte " + fieldName + " = " + index + ";";
		code += "\r\n";
		return code;
	}

	private String asField(String fieldComment, String type, String fieldName, int pos, String javaType, String beanName) {
		String code = "";
		code += "\r\n";
		code += "\r\n";
		code += "		/**";
		code += "\r\n";
		code += "		 * " + fieldComment;
		code += "\r\n";
		code += "		 */";
		if (type.equals("String")) {
			code += "\r\n";
			code += "		public var " + fieldName + ":" + type + ";";
		} else {
			code += "\r\n";
			code += "		public function get " + fieldName + "():" + type + "{";
			code += "\r\n";
			code += "			data.position=_" + fieldName + ";";
			code += "\r\n";
			code += "			return data.read" + asTypeIO(javaType) + "();";
			code += "\r\n";
			code += "		}";
			code += "\r\n";
			code += "\r\n";
			code += "		/**";
			code += "\r\n";
			code += "		 * " + fieldComment;
			code += "\r\n";
			code += "		 */";
			code += "\r\n";
			code += "		public function set " + fieldName + "(value:" + type + "):void{";
			code += "\r\n";
			code += "			data.position=_" + fieldName + "=_" + fieldName + "==0?pos:_" + fieldName + ";";
			code += "\r\n";
			code += "			data.write" + asTypeIO(javaType) + "(value);";
			code += "\r\n";
			code += "			pos=data.position;";
			code += "\r\n";
			code += "		}";
			code += "\r\n";
			code += "		private var _" + fieldName + ":int;";
		}
		code += "\r\n";
		return code;
	}

	private String javaInsert(String beanName, Vector<String> types, Vector<String> fieldName, Vector<String> comments) {
		String code = "";
		code += "	/**";
		code += "\r\n";
		code += "	 * ";
		code += "\r\n";
		String p1 = "";
		String p2 = "";
		for (int i = 0; i < types.size(); i++) {
			code += "	 * @param " + fieldName.get(i);
			code += "\r\n";
			code += "	 *            " + comments.get(i);
			code += "\r\n";
			p1 += ", " + types.get(i) + " " + fieldName.get(i);
			p2 += ", " + fieldName.get(i);
		}
		code += "	 */";
		code += "\r\n";
		code += "	public " + beanName + "(Table<" + beanName + "> table, " + p1.substring(2) + ") {";
		code += "\r\n";
		code += "		super(table, " + p2.substring(2) + ");";
		code += "\r\n";
		code += "	}";
		return code;
	}

	private String javaInit(String beanName) {
		String code = "";
		code += "\r\n";
		code += "\r\n";
		code += "	// init";
		code += "\r\n";
		code += "	public " + beanName + "(Table<" + beanName + "> table, Object[] v) {";
		code += "\r\n";
		code += "		super(table, v);";
		code += "\r\n";
		code += "	}";
		return code;
	}

	private String javaMySql(String beanName) {
		String code = "";
		code += "\r\n";
		code += "\r\n";
		code += "	// mysql";
		code += "\r\n";
		code += "	public " + beanName + "(Object[] v, Table<" + beanName + "> table) {";
		code += "\r\n";
		code += "		super(v, table);";
		code += "\r\n";
		code += "	}";
		return code;
	}

	private String javaBean(String beanName, String constructors, String fields, String typeIndex, String pos, String size, String maps, String comment, int primaryKey, int num, String keys, Vector<String> fieldNames) {
		String code = "";
		code += "package game.data.bean;";
		code += "\r\n";
		code += "\r\n";
		code += "import ge.annotation.Delete;";
		code += "\r\n";
		if (comment.contains("@")) {
			code += "import ge.annotation.Exclude;";
			code += "\r\n";
		}
		code += "import ge.annotation.Map;";
		code += "\r\n";
		code += "import ge.annotation.Insert;";
		code += "\r\n";
		code += "import ge.annotation.PrimaryKey;";
		code += "\r\n";
		code += "import ge.annotation.SyncKey;";
		code += "\r\n";
		code += "import ge.annotation.Type;";
		code += "\r\n";
		code += "import ge.annotation.Types;";
		code += "\r\n";
		code += "import ge.annotation.Update;";
		code += "\r\n";
		code += "import ge.db.Bean;";
		code += "\r\n";
		code += "import ge.db.Table;";
		code += "\r\n";
		code += "\r\n";
		code += "/**";
		code += "\r\n";
		code += " * " + comment + " (" + num + ")";
		code += "\r\n";
		code += " */";
		if (comment.contains("@")) {
			code += "\r\n";
			code += "@Exclude";
		}
		code += "\r\n";
		code += "@SyncKey({" + keys + "})";
		code += "\r\n";
		code += "@PrimaryKey(" + primaryKey + ")";
		code += "\r\n";
		code += "@Types({ " + typeIndex + " })";
		code += "\r\n";
		code += "@Map({ " + maps + " })";
		code += "\r\n";
		code += "@Insert(\"" + insertSql(beanName, fieldNames.get(primaryKey), fieldNames.size()) + "\")";
		code += "\r\n";
		code += "@Update(\"" + updateSql(beanName, fieldNames.get(primaryKey), fieldNames) + "\")";
		code += "\r\n";
		code += "@Delete(\"" + deleteSql(beanName, fieldNames.get(primaryKey)) + "\")";
		code += "\r\n";
		code += "public class " + beanName + " extends Bean {";
		code += "\r\n";
		code += constructors;
		code += "\r\n";
		code += "\r\n";
		code += fields;
		code += "}";
		return code;
	}

	private String deleteSql(String tableName, String pkname) {
		return "delete from " + tableName.toLowerCase() + " where " + pkname + "=?";
	}

	private String updateSql(String tableName, String pkname, Vector<String> fields) {
		String str = "";
		for (String string : fields) {
			if (!string.equals(pkname)) {
				str += "," + string + "=?";
			}
		}
		return "update " + tableName.toLowerCase() + " set " + str.substring(1) + " where " + pkname + "=?";
	}

	private String insertSql(String tableName, String pkname, int cols) {
		String value = "";
		for (int i = 0; i < cols; i++) {
			value += ",?";
		}
		return "insert into " + tableName.toLowerCase() + " values(" + value.substring(1) + ")";
	}

	private String asBean(String beanName, String fields, String names, String typeIndex, String maps, String comment, int num, String keys, int len) {
		String code = "";
		code += "package game.data.bean {";
		code += "\r\n";
		code += "	import ge.net.Bean;";
		code += "\r\n";
		code += "	import ge.net.Table;";
		code += "\r\n";
		code += "\r\n";
		code += "	/**";
		code += "\r\n";
		code += "	 * " + comment + " (" + num + ")";
		code += "\r\n";
		code += "	 */";
		code += "\r\n";
		code += "	public class " + beanName + " extends Bean {";
		code += "\r\n";
		code += "		public static const names : Array = [" + names + "];";
		code += "\r\n";
		code += "		public static const types : Array = [" + typeIndex + "];";
		code += "\r\n";
		code += "		public static const maps : Array = [" + maps + "];";
		code += "\r\n";
		code += "		public static const keys : Array = [" + keys + "];";
		code += "\r\n";
		code += "		public static const table : Table = new Table(" + beanName + ");";
		code += "\r\n";
		code += "		public static function view (alias:String): Table {";
		code += "\r\n";
		code += "			return Bean.view(" + beanName + ",alias);";
		code += "\r\n";
		code += "		}";
		code += "\r\n";
		code += fields;
		code += "	}";
		code += "\r\n";
		code += "}";
		return code;
	}

	private void save(byte[] code, String filename) throws Exception {
		FileOutputStream fos = new FileOutputStream(filename);
		fos.write(code);
		fos.close();
	}
}