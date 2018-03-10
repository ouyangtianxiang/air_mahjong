package game.data.bean;

import ge.annotation.Delete;
import ge.annotation.Map;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Type;
import ge.annotation.Types;
import ge.annotation.Update;
import ge.db.Bean;
import ge.db.Table;

/**
 *  (3)
 */
@SyncKey({0})
@PrimaryKey(0)
@Types({ Type.INT, Type.BYTE, Type.INT })
@Map({ true, true, true })
@Insert("insert into u_data values(?,?,?)")
@Update("update u_data set state=?,roomCard=? where userId=?")
@Delete("delete from u_data where userId=?")
public class U_data extends Bean {
	/**
	 * 
	 * @param userId
	 *            $
	 * @param state
	 *            
	 * @param roomCard
	 *            
	 */
	public U_data(Table<U_data> table, int userId, byte state, int roomCard) {
		super(table, userId, state, roomCard);
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
	public int roomCard;

	public interface I {
		/**
		 * $
		 */
		byte userId = 0;
		/**
		 * 
		 */
		byte state = 1;
		/**
		 * 
		 */
		byte roomCard = 2;
	}
}