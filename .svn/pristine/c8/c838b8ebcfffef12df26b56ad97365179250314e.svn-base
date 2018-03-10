package ge.db;

import ge.net.Handler;

public abstract class OnTable<E extends Bean> {
	private boolean insert;
	private boolean delete;
	private boolean[] update;
	private byte[] updateIndex;

	/**
	 * 
	 * @param insert是否侦听插入
	 * @param delete是否侦听删除
	 * @param updateIndex侦听更新的字段序号
	 */
	public OnTable(boolean insert, boolean delete, byte... updateIndex) {
		this.insert = insert;
		this.delete = delete;
		this.updateIndex = updateIndex;
	}

	void init(int size) {
		update = new boolean[size];
		for (byte i : updateIndex) {
			update[i] = true;
		}
	}

	public boolean method(int code) {
		return code == Handler.thmethod.get(Thread.currentThread());
	}

	public void insert(E obj) {
		if (insert) {
			onInsert(obj);
		}
	}

	public void delete(E obj) {
		if (delete) {
			onDelete(obj);
		}
	}

	public void update(byte index, E obj, Object value) {
		if (update[index]) {
			onUpdate(index, obj, value);
		}
	}

	public void onInsert(E obj) {

	}

	public void onDelete(E obj) {

	}

	public void onUpdate(byte index, E obj, Object value) {

	}
}
