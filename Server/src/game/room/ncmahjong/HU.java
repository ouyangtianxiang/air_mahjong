package game.room.ncmahjong;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Vector;

import game.data.bean.T_tile;

public class HU extends PingHU {
	/**
	 * 七小对
	 */
	public boolean isMinSevenPairs;
	public boolean thirteenRotten;
	public boolean mevius;

	public HU(Vector<T_tile> tiles) {
		ArrayList<TT> tts = TTs(tiles);
		if (minSevenPairs(tts)) {
			isMinSevenPairs = true;
			hu = true;
			return;
		}
		if (ThirteenRotten(tiles)) {
			hu = true;
			return;
		}
		hu(tts, tiles);
	}

	/**
	 * 是否7小对
	 */
	private boolean minSevenPairs(ArrayList<TT> arr) {
		tmp.clear();
		for (TT tt : arr) {
			if (tmp.containsKey(tt.a.id) || tmp.containsKey(tt.b.id)) {
				break;
			}
			tmp.put(tt.a.id, true);
			tmp.put(tt.b.id, true);
		}
		return tmp.size() == 14;
	}

	/**
	 * 十三烂
	 */
	private boolean ThirteenRotten(Vector<T_tile> tiles) {
		tiles.sort(new Comparator<T_tile>() {
			public int compare(T_tile a, T_tile b) {
				return a.value - b.value;
			}
		});
		int star = 0;
		int len = tiles.size();
		for (int i = 1; i < len; i++) {
			T_tile o = tiles.get(i);
			T_tile a = tiles.get(i - 1);
			if (T.loop(o)) {
				star++;
				if (o.value == a.value) {
					return false;
				}
			} else {
				if (Math.abs(o.value - a.value) < 2) {
					return false;
				}
			}
		}
		thirteenRotten = true;
		mevius = star == 7;

		return true;
	}
}
