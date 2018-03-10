package game.data.bean;

import ge.annotation.Delete;
import ge.annotation.Insert;
import ge.annotation.PrimaryKey;
import ge.annotation.SyncKey;
import ge.annotation.Update;
import ge.db.Bean;
import ge.db.Table;

/**
 *  (15)
 */
@SyncKey(0)
@PrimaryKey(0)
@Insert("insert into u_room_hu values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
@Update("update u_room_hu set roomId=?,level=?,index=?,fangPao=?,tianHU=?,minSevenPairs=?,thirteenRotten=?,mevius=?,deGuo=?,maxSevenPairs=?,qiangGang=?,gangKai=?,deZhongDe=?,jingDiao=? where id=?")
@Delete("delete from u_room_hu where id=?")
public class U_room_hu extends Bean {
	/**
	 * 
	 * @param id
	 *            $
	 * @param roomId
	 *            
	 * @param level
	 *            
	 * @param index
	 *            
	 * @param fangPao
	 *            
	 * @param tianHU
	 *            
	 * @param minSevenPairs
	 *            
	 * @param thirteenRotten
	 *            
	 * @param mevius
	 *            
	 * @param deGuo
	 *            
	 * @param maxSevenPairs
	 *            
	 * @param qiangGang
	 *            
	 * @param gangKai
	 *            
	 * @param deZhongDe
	 *            
	 * @param jingDiao
	 *            
	 */
	public U_room_hu(Table<U_room_hu> table, int id, int roomId, byte level, byte index, byte fangPao, boolean tianHU, boolean minSevenPairs, boolean thirteenRotten, boolean mevius, boolean deGuo, boolean maxSevenPairs, boolean qiangGang, boolean gangKai, boolean deZhongDe, boolean jingDiao) {
		super(table, id, roomId, level, index, fangPao, tianHU, minSevenPairs, thirteenRotten, mevius, deGuo, maxSevenPairs, qiangGang, gangKai, deZhongDe, jingDiao);
	}

	// init
	public U_room_hu(Table<U_room_hu> table, Object[] v) {
		super(table, v);
	}

	// mysql
	public U_room_hu(Object[] v, Table<U_room_hu> table) {
		super(v, table);
	}

	/**
	 * $
	 */
	public int id;

	/**
	 * 
	 */
	public int roomId;

	/**
	 * 
	 */
	public byte level;

	/**
	 * 
	 */
	public byte index;

	/**
	 * 
	 */
	public byte fangPao;

	/**
	 * 
	 */
	public boolean tianHU;

	/**
	 * 
	 */
	public boolean minSevenPairs;

	/**
	 * 
	 */
	public boolean thirteenRotten;

	/**
	 * 
	 */
	public boolean mevius;

	/**
	 * 
	 */
	public boolean deGuo;

	/**
	 * 
	 */
	public boolean maxSevenPairs;

	/**
	 * 
	 */
	public boolean qiangGang;

	/**
	 * 
	 */
	public boolean gangKai;

	/**
	 * 
	 */
	public boolean deZhongDe;

	/**
	 * 
	 */
	public boolean jingDiao;

}