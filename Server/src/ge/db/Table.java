package ge.db;

import java.lang.reflect.Field;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import ge.annotation.Delete;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Update;
import ge.net.Buffer;
import ge.net.Handler;
import ge.net.Sync;

/**
 * 某个表的记录集
 * 
 * @author txoy
 */
public class Table<E extends Bean> {
	private static ConcurrentHashMap<Class<?>, Byte> HC = new ConcurrentHashMap<Class<?>, Byte>();

	private synchronized static byte HC(Class<?> c2) {
		Byte hc = HC.get(c2);
		if (hc == null) {
			hc = (byte) (HC.size() + 1);
			HC.put(c2, hc);
		}
		return hc;
	}

	enum TYPE {
		SYS, USER, TEMP
	}

	public final Class<E> c;
	private final ConcurrentHashMap<Object, E> data = new ConcurrentHashMap<Object, E>();
	public final byte key;
	public final Field[] fields;
	public final HashMap<String, Integer> hashfield = new HashMap<String, Integer>();
	public final long[] offsets;
	public final byte[] types;
	public final int cols;
	public final String name;
	public final byte hc;
	private final Buffer head;
	public final short pkindex;
	public final String pkname;
	public final String sql;
	public final String insert;
	public final String delete;
	public final String update;
	public final TYPE type;

	/**
	 * 系统表
	 * 
	 * @param c
	 * @param key
	 */
	public Table(Class<E> c) {
		this(c, TYPE.SYS, "select * from " + c.getSimpleName().toLowerCase());
	}

	/**
	 * 临时表
	 * 
	 * @param c
	 * @param sql
	 * @param key
	 */
	public Table(Class<E> c, String sql) {
		this(c, TYPE.TEMP, sql);
	}

	/**
	 * 用户表
	 * 
	 * @param fdb
	 * @param c
	 * @param where
	 * @param key
	 */
	public Table(Class<E> c, String key, Object value) {
		this(c, TYPE.USER, "select * from " + c.getSimpleName().toLowerCase() + " where " + key + "='" + value + "'");
	}

	private Table(Class<E> c, TYPE type, String sql) {
		this.hc = HC(c);
		this.name = c.getSimpleName();
		this.c = c;
		this.type = type;
		this.sql = sql;
		this.fields = c.getFields();
		this.cols = fields.length;
		this.offsets = new long[cols];
		this.insert = c.getAnnotation(Insert.class).value();
		this.delete = c.getAnnotation(Delete.class).value();
		this.update = c.getAnnotation(Update.class).value();
		this.key = c.getAnnotation(SyncKey.class).value();
		this.types = new byte[cols];
		this.pkindex = c.getAnnotation(PrimaryKey.class).value();
		this.pkname = fields[pkindex].getName();

		head = new Buffer();
		head.putByte((byte) 0);
		head.putByte(this.hc);
		head.putUTF(this.name);
		head.putByte((byte) key);

		head.putShort((short) cols);
		for (int i = 0; i < cols; i++) {
			Field field = fields[i];
			types[i] = Handler.pTypes.get(field.getType());
			offsets[i] = Bean.unsafe.objectFieldOffset(field);
			String fieldName = field.getName();
			hashfield.put(fieldName, i);
			head.putUTF(fieldName);
			head.putByte(types[i]);
		}
		head.flip();
	}

	int field(String fieldName) {
		return hashfield.get(fieldName);
	}

	/**
	 * 获得记录数
	 * 
	 * @return 记录数
	 */
	public short size() {
		return (short) data.size();
	}

	private Buffer buffer;

	private Buffer toBuffer() {
		if (type != TYPE.SYS || buffer == null) {
			buffer = new Buffer();
			buffer.putByte((byte) 1);
			buffer.putByte(hc);
			buffer.putShort(size());
			Iterator<E> it = it();
			while (it.hasNext()) {
				it.next().toBuffer(buffer);
			}
			buffer.flip();
		}
		buffer.rewind();
		return buffer;
	}

	public void forceLoad() {
		buffer = null;
		load();
	}

	public void load() {
		if (sql != null) {
			Statement statement = null;
			ResultSet rs = null;
			try {
				statement = DB.Conn().createStatement();
				rs = statement.executeQuery(sql);
				int cols = fields.length;
				while (rs.next()) {
					Object[] v = new Object[cols];
					for (int i = 0; i < cols; i++) {
						switch (types[i]) {
						case 2:
							v[i] = rs.getByte(i + 1);
							break;
						case 3:
							v[i] = rs.getShort(i + 1);
							break;
						case 4:
							v[i] = rs.getInt(i + 1);
							break;
						case 5:
							v[i] = rs.getLong(i + 1);
							break;
						case 6:
							v[i] = rs.getFloat(i + 1);
							break;
						case 7:
							v[i] = rs.getDouble(i + 1);
							break;
						case 8:
							v[i] = rs.getString(i + 1);
							break;
						}
					}
					E o = c.getConstructor(Object[].class, this.getClass()).newInstance(v, this);
					data.put(o.Key(), o);
				}
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("sql===========" + sql);
			} finally {
				try {
					if (rs != null) {
						rs.close();
						rs = null;
					}
					if (statement != null) {
						statement.close();
						statement = null;
					}
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
	}

	@SuppressWarnings("unchecked")
	void insert(Bean bean) {
		if (((Number) bean.get(pkindex)).intValue() == 0) {
			bean.set(pkindex, DB.get().Key(c));
		}
		data.put(bean.Key(), (E) bean);
	}

	public E get() {
		Iterator<E> it = it();
		if (it.hasNext()) {
			return it.next();
		}
		return null;
	}

	public Iterator<E> it() {
		return new TableIteratir<E>(data.values().iterator());
	}

	static class TableIteratir<T> implements Iterator<T> {
		Iterator<T> it;

		TableIteratir(Iterator<T> it) {
			this.it = it;
		}

		public boolean hasNext() {
			return it.hasNext();
		}

		public T next() {
			return it.next();
		}

		public void remove() {
			throw new Error("TableIteratir cannot remove");
		}
	}

	public E get(int key) {
		return data.get(key);
	}

	public E get(String key) {
		return data.get(key);
	}

	public Vector<E> getList(Where<E> where) {
		Vector<E> list = new Vector<E>();
		Iterator<E> it = it();
		while (it.hasNext()) {
			E o = it.next();
			if (where == null || where.where(o)) {
				list.add(o);
			}
		}
		return list;
	}

	public void del() {
		data.clear();
		Buffer buffer = new Buffer(4);
		buffer.putByte((byte) 2);
		buffer.putByte(hc);
		buffer.flip();
		sync(buffer);
	}

	public void del(int key) {
		E e = data.remove(key);
		if (e != null) {
			e.delete();
		}
	}

	/**
	 * 保存数据
	 */
	public void save() {
		if (type == TYPE.USER) {
			Iterator<E> it = it();
			while (it.hasNext()) {
				it.next().save();
			}
		}
	}

	public void clear() {
		Iterator<E> it = it();
		while (it.hasNext()) {
			it.next().clear();
		}
		data.clear();
		syncs.clear();
	}

	private ConcurrentLinkedQueue<Sync> syncs = new ConcurrentLinkedQueue<Sync>();

	/**
	 * 调用时推送数据，以后数据有更新再推送
	 * 
	 * @param sync
	 */
	public void addListener(Sync sync) {
		if (!syncs.contains(sync)) {
			syncs.add(sync);
			Get(sync);
		}
	}

	public void removeListener(Sync sync) {
		syncs.remove(sync);
		Buffer buffer = new Buffer(128);
		buffer.putByte((byte) 2);
		buffer.putByte(hc);
		buffer.flip();
		sync.Send(buffer);
	}

	/**
	 * 调用时推送数据，且只推送这一次，以后数据有更新不推送
	 * 
	 * @param sync
	 */
	public void Get(Sync sync) {
		head.rewind();
		sync.Send(head);
		GetData(sync);
	}

	public void GetData(Sync sync) {
		if (size() > 0) {
			sync.Send(toBuffer());
		}
	}

	void sync(Buffer buffer) {
		Iterator<Sync> it = syncs.iterator();
		while (it.hasNext()) {
			buffer.rewind();
			it.next().Send(buffer);
		}
	}

	interface Where<E> {
		boolean where(E e);
	}
}
