package game.data.bean;

import ge.annotation.Delete;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Update;
import ge.db.Bean;
import ge.db.Table;

/**
 *  (8)
 */
@SyncKey(1)
@PrimaryKey(0)
@Insert("insert into t_state values(?,?,?,?,?,?,?,?)")
@Update("update t_state set index=?,state=?,nickname=?,ip=?,url=?,exit=?,useVIP=? where userId=?")
@Delete("delete from t_state where userId=?")
public class T_state extends Bean {
	/**
	 * 
	 * @param userId
	 *            
	 * @param index
	 *            $
	 * @param state
	 *            状态
	 * @param nickname
	 *            昵称
	 * @param ip
	 *            IP地址
	 * @param url
	 *            头像URL
	 * @param exit
	 *            退出游戏
	 * @param useVIP
	 *            
	 */
	public T_state(Table<T_state> table, int userId, byte index, byte state, String nickname, int ip, String url, byte exit, byte useVIP) {
		super(table, userId, index, state, nickname, ip, url, exit, useVIP);
	}

	// init
	public T_state(Table<T_state> table, Object[] v) {
		super(table, v);
	}

	// mysql
	public T_state(Object[] v, Table<T_state> table) {
		super(v, table);
	}

	/**
	 * 
	 */
	public int userId;

	/**
	 * $
	 */
	public byte index;

	/**
	 * 状态
	 */
	public byte state;

	/**
	 * 昵称
	 */
	public String nickname;

	/**
	 * IP地址
	 */
	public int ip;

	/**
	 * 头像URL
	 */
	public String url;

	/**
	 * 退出游戏
	 */
	public byte exit;

	/**
	 * 
	 */
	public byte useVIP;

}