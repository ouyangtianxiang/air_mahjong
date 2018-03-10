package game.data.bean;

import ge.annotation.Delete;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Update;
import ge.db.Bean;
import ge.db.Table;

/**
 *  (4)
 */
@SyncKey(0)
@PrimaryKey(0)
@Insert("insert into t_play values(?,?,?,?)")
@Update("update t_play set value1=?,value2=?,value3=? where index=?")
@Delete("delete from t_play where index=?")
public class T_play extends Bean {
	/**
	 * 
	 * @param index
	 *            $
	 * @param value1
	 *            
	 * @param value2
	 *            
	 * @param value3
	 *            
	 */
	public T_play(Table<T_play> table, short index, short value1, short value2, short value3) {
		super(table, index, value1, value2, value3);
	}

	// init
	public T_play(Table<T_play> table, Object[] v) {
		super(table, v);
	}

	// mysql
	public T_play(Object[] v, Table<T_play> table) {
		super(v, table);
	}

	/**
	 * $
	 */
	public short index;

	/**
	 * 
	 */
	public short value1;

	/**
	 * 
	 */
	public short value2;

	/**
	 * 
	 */
	public short value3;

}