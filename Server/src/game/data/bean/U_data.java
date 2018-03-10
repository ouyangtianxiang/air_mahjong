package game.data.bean;

import ge.annotation.Delete;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Update;
import ge.db.Bean;
import ge.db.Table;

/**
 *  (5)
 */
@SyncKey(0)
@PrimaryKey(0)
@Insert("insert into u_data values(?,?,?,?,?)")
@Update("update u_data set state=?,card=?,rmb=?,roomCode=? where userId=?")
@Delete("delete from u_data where userId=?")
public class U_data extends Bean {
	/**
	 * 
	 * @param userId
	 *            $
	 * @param state
	 *            
	 * @param card
	 *            
	 * @param rmb
	 *            
	 * @param roomCode
	 *            
	 */
	public U_data(Table<U_data> table, int userId, byte state, int card, int rmb, int roomCode) {
		super(table, userId, state, card, rmb, roomCode);
	}

	// init
	public U_data(Table<U_data> table, Object[] v) {
		super(table, v);
	}

	// mysql
	public U_data(Object[] v, Table<U_data> table) {
		super(v, table);
	}

	/**
	 * $
	 */
	public int userId;

	/**
	 * 
	 */
	public byte state;

	/**
	 * 
	 */
	public int card;

	/**
	 * 
	 */
	public int rmb;

	/**
	 * 
	 */
	public int roomCode;

}