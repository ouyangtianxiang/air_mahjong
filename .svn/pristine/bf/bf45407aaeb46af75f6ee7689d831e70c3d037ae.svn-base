package ge.db;

import ge.annotation.Exclude;
import ge.net.Sync;
import ge.pthread.SwapThread;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Iterator;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class TData implements Runnable {

	// ---------------------------------------------------------------
	private ConcurrentLinkedQueue<Table<?>> tables = new ConcurrentLinkedQueue<Table<?>>();
	private ConcurrentLinkedQueue<Table<?>> exclude = new ConcurrentLinkedQueue<Table<?>>();
	private ConcurrentHashMap<String, Table<?>> map = new ConcurrentHashMap<String, Table<?>>();

	protected void init() {
		Field[] fields = this.getClass().getDeclaredFields();
		for (Field field : fields) {
			try {
				if (field.getType().equals(Table.class)) {
					Table<?> o = (Table<?>) field.get(this);
					if (o.c.getAnnotation(Exclude.class) == null) {
						exclude.add(o);
					}
					tables.add(o);
					map.put(o.name + (o.alias.length() > 0 ? o.alias : ""), o);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public Table<?> table(String name) {
		return map.get(name);
	}

	public void Get(Sync sync) {
		if (sync != null) {
			Iterator<Table<?>> it = exclude.iterator();
			while (it.hasNext()) {
				it.next().Get(sync);
			}
		}
	}

	public void addListener(Sync sync) {
		if (sync != null) {
			Iterator<Table<?>> it = exclude.iterator();
			while (it.hasNext()) {
				it.next().addListener(sync);
			}
		}
	}

	public void removeListener(Sync sync) {
		if (sync != null) {
			Iterator<Table<?>> it = exclude.iterator();
			while (it.hasNext()) {
				it.next().removeListener(sync);
			}
		}
	}

	public void fill(Fill fillData, HashMap<String, Object> var) {
		Iterator<Table<?>> it = tables.iterator();
		while (it.hasNext()) {
			fillData.fill(it.next(), var);
		}
	}

	private boolean isEmpty = true;

	public final boolean isEmpty() {
		return isEmpty;
	}

	public void forceLoad() {
		Iterator<Table<?>> it = tables.iterator();
		while (it.hasNext()) {
			it.next().forceLoad();
		}
	}

	public void load() {
		if (isEmpty) {
			Iterator<Table<?>> it = tables.iterator();
			while (it.hasNext()) {
				it.next().load();
			}
			isEmpty = false;
		}
	}

	/**
	 * 保存数据，交给另外线程处理
	 */
	public void save() {
		SwapThread.IT.push(this);
	}

	/**
	 * save
	 */
	public void run() {
		Iterator<Table<?>> it = tables.iterator();
		while (it.hasNext()) {
			it.next().save();
		}
	}

	protected void clear() {
		Iterator<Table<?>> it = tables.iterator();
		while (it.hasNext()) {
			it.next().clear();
		}
		tables.clear();
		exclude.clear();
		map.clear();
	}
}
