package game;

import java.io.IOException;

import ge.Protocol;
import ge.utils.Util;

public class CreateProtocol {
	public static void main(String[] args) throws IOException, ClassNotFoundException {
		String javaFile = "E:\\air_mahjong\\Server\\src\\game\\utils\\Protocol.java";
		String asFile = "E:\\air_mahjong\\Client\\assets\\Script\\net\\Protocol.ts";
		new Protocol(game.utils.Protocol.class, Util.Env(javaFile), Util.Env(asFile));
	}
}
