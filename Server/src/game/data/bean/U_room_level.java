package game.data.bean;

import ge.annotation.Delete;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Update;
import ge.db.Bean;
import ge.db.Table;

/**
 *  (9)
 */
@SyncKey(0)
@PrimaryKey(0)
@Insert("insert into u_room_level values(?,?,?,?,?,?,?,?,?)")
@Update("update u_room_level set roomId=?,level=?,index=?,userId=?,score=?,jing=?,jingLevel=?,baWangJing=? where id=?")
@Delete("delete from u_room_level where id=?")
public class U_room_level extends Bean {
	/**
	 * 
	 * @param id
	 *            $
	 * @param roomId
	 *            房间ID
	 * @param level
	 *            局次
	 * @param index
	 *            Index
	 * @param userId
	 *            用户ID
	 * @param score
	 *            得分数
	 * @param jing
	 *            精
	 * @param jingLevel
	 *            精冲关
	 * @param baWangJing
	 *            霸王精
	 */
	public U_room_level(Table<U_room_level> table, int id, int roomId, byte level, byte index, int userId, int score, int jing, byte jingLevel, boolean baWangJing) {
		super(table, id, roomId, level, index, userId, score, jing, jingLevel, baWangJing);
	}

	// init
	public U_room_level(Table<U_room_level> table, Object[] v) {
		super(table, v);
	}

	// mysql
	public U_room_level(Object[] v, Table<U_room_level> table) {
		super(v, table);
	}

	/**
	 * $
	 */
	public int id;

	/**
	 * 房间ID
	 */
	public int roomId;

	/**
	 * 局次
	 */
	public byte level;

	/**
	 * Index
	 */
	public byte index;

	/**
	 * 用户ID
	 */
	public int userId;

	/**
	 * 得分数
	 */
	public int score;

	/**
	 * 精
	 */
	public int jing;

	/**
	 * 精冲关
	 */
	public byte jingLevel;

	/**
	 * 霸王精
	 */
	public boolean baWangJing;

}