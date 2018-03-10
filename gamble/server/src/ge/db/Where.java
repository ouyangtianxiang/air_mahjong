package ge.db;

public class Where {
	public static Where[] toWhere(Table<? extends Bean> table, String[] str) {
		Where[] where = new Where[str.length];
		for (int i = 0; i < str.length; i++) {
			where[i] = new Where(table, str[i]);
		}
		return where;
	}

	private char i;
	private String k;
	private Object v;
	private int field;

	private Where(Table<? extends Bean> table, String where) {
		String kv[] = where.split("!");
		if (kv.length == 2) {
			i = '!';
		} else {
			kv = where.split("=");
			if (kv.length == 2) {
				i = '=';
			} else {
				kv = where.split("<");
				if (kv.length == 2) {
					i = '<';
				} else {
					kv = where.split(">");
					if (kv.length == 2) {
						i = '>';
					} else {
						throw new Error("Where Error:" + where);
					}
				}
			}
		}
		k = kv[0];
		v = kv[1];
		for (int i = 0; i < table.cols; i++) {
			if (table.fields[i].getName().equals(k)) {
				field = i;
				break;
			}
		}
		try {
			switch (table.types[field]) {
			case BYTE:
				v = Byte.valueOf(v.toString());
				break;
			case SHORT:
				v = Short.valueOf(v.toString());
				break;
			case INT:
				v = Integer.valueOf(v.toString());
				break;
			case LONG:
				v = Long.valueOf(v.toString());
				break;
			case FLOAT:
				v = Float.valueOf(v.toString());
				break;
			case DOUBLE:
				v = Double.valueOf(v.toString());
				break;
			case STRING:
				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public boolean fairly(Bean b) {
		double r = 0;
		Object o = null;
		o = b.get(field);
		if (o instanceof Number) {
			r = ((Number) o).doubleValue() - ((Number) v).doubleValue();
		} else if (o instanceof String) {
			r = ((String) o).compareTo(v.toString());
		} else {
			throw new Error("不支持的类型：" + o.getClass().getName());
		}
		switch (i) {
		case '!':
			return r != 0;
		case '=':
			return r == 0;
		case '<':
			return r < 0;
		case '>':
			return r > 0;
		default:
			return false;
		}
	}
}
