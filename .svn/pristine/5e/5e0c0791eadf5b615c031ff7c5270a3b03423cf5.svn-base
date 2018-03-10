package game.room.ncmahjong;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Vector;

import game.data.bean.T_tile;

/**
 * 平胡
 * 
 */
public class PingHU {

	protected HashMap<Number, Boolean> tmp = new HashMap<>();
	public boolean hu;
	public TT tt;
	public TTT[] ttts;
	private byte any = 0;

	/**
	 * 德国=*2+5
	 */
	public boolean isDeGuo() {
		return any == 0;
	}

	/**
	 * 七大对(11122233344455)
	 */
	public boolean isMaxSevenPairs;

	public PingHU(Vector<T_tile> tiles) {

		ArrayList<TT> tts = TTs(tiles);
		hu(tts, tiles);
	}

	protected PingHU() {
	}

	protected void hu(ArrayList<TT> tts, Vector<T_tile> tiles) {

		for (TT tt : tts) {
			this.tt = tt;
			ArrayList<T_tile> list = new ArrayList<>(tiles);
			list.remove(tt.a);
			list.remove(tt.b);

			int num = list.size() / 3;
			if (num == 0) {
				hu = true;
				return;
			}

			ArrayList<TTT> ttts = TTTs(list);
			if (ttts.size() >= num) {
				switch (num) {
				case 1:
					hu = G1(ttts);
					break;
				case 2:
					hu = G2(ttts);
					break;
				case 3:
					hu = G3(ttts);
					break;
				case 4:
					hu = G4(ttts);
					break;
				}
				if (hu) {
					return;
				}
			}
		}
	}

	protected ArrayList<TT> TTs(Vector<T_tile> tiles) {
		tmp.clear();
		ArrayList<TT> arr = new ArrayList<>();
		int len = tiles.size();
		for (int i = 0; i < len; i++) {
			T_tile a = tiles.get(i);
			for (int j = i + 1; j < len; j++) {
				T_tile b = tiles.get(j);
				TT tt = new TT(a, b);
				if (tt.ok && !tmp.containsKey(tt.code)) {
					tmp.put(tt.code, true);
					arr.add(tt);
					if (tt.any) {
						any++;
					}
				}
			}
		}
		return arr;
	}

	private ArrayList<TTT> TTTs(ArrayList<T_tile> list) {
		tmp.clear();
		ArrayList<TTT> arr = new ArrayList<>();
		int len = list.size();
		for (int i = 0; i < len; i++) {
			T_tile a = list.get(i);
			for (int j = (i + 1); j < len; j++) {
				T_tile b = list.get(j);
				for (int k = (j + 1); k < len; k++) {
					T_tile c = list.get(k);
					TTT ttt = new TTT(a, b, c);
					if (ttt.ok && !tmp.containsKey(ttt.code)) {
						tmp.put(ttt.code, true);
						arr.add(ttt);
					}
				}
			}
		}
		return arr;
	}

	/**
	 * 去除重复搭配
	 */
	private boolean perfect(TTT[] arr) {
		tmp.clear();
		byte pang = 0;
		for (TTT ttt : arr) {
			if (tmp.containsKey(ttt.a.id) || tmp.containsKey(ttt.b.id) || tmp.containsKey(ttt.c.id)) {
				return false;
			}
			tmp.put(ttt.a.id, true);
			tmp.put(ttt.b.id, true);
			tmp.put(ttt.c.id, true);
			if (ttt.any) {
				any++;
			}
			if (!ttt.chi) {
				pang++;
			}
		}
		isMaxSevenPairs = pang == 4;
		this.ttts = arr;
		return true;
	}

	private boolean G1(ArrayList<TTT> list) {
		TTT[] arr = new TTT[] { list.get(0) };
		return perfect(arr);
	}

	private boolean G2(ArrayList<TTT> list) {
		TTT[] arr = new TTT[2];
		int len = list.size();
		for (int i = 0; i < len; i++) {
			arr[0] = list.get(i);
			for (int j = (i + 1); j < len; j++) {
				arr[1] = list.get(j);
				if (perfect(arr)) {
					return true;
				}
			}
		}
		return false;
	}

	private boolean G3(ArrayList<TTT> list) {
		TTT[] arr = new TTT[3];
		int len = list.size();
		for (int i = 0; i < len; i++) {
			arr[0] = list.get(i);
			for (int j = (i + 1); j < len; j++) {
				arr[1] = list.get(j);
				for (int k = (j + 1); k < len; k++) {
					arr[2] = list.get(k);
					if (perfect(arr)) {
						return true;
					}
				}
			}
		}
		return false;
	}

	private boolean G4(ArrayList<TTT> list) {
		TTT[] arr = new TTT[4];
		int len = list.size();
		for (int i = 0; i < len; i++) {
			arr[0] = list.get(i);
			for (int j = (i + 1); j < len; j++) {
				arr[1] = list.get(j);
				for (int k = (j + 1); k < len; k++) {
					arr[2] = list.get(k);
					for (int l = (k + 1); l < len; l++) {
						arr[3] = list.get(l);
						if (perfect(arr)) {
							return true;
						}
					}
				}
			}
		}
		return false;
	}
}
