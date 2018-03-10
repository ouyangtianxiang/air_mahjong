using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;
using System.Text;
using System;
using System.Security.Cryptography;

public class CreateAssetBundles
{
	[MenuItem ("资源打包/Android")]
	static void DoAndroid ()
	{
		string platform = RuntimePlatform.Android.ToString ();
		BuildAssetBundles (platform, BuildAssetBundleOptions.None, BuildTarget.Android);
	}

	[MenuItem ("资源打包/IOS")]
	static void DoIOS ()
	{
		string platform = RuntimePlatform.IPhonePlayer.ToString ();
		BuildAssetBundles (platform, BuildAssetBundleOptions.None, BuildTarget.iOS);
	}

	[MenuItem ("资源打包/Web")]
	static void DoWeb ()
	{
		string platform = RuntimePlatform.WebGLPlayer.ToString ();
		BuildAssetBundles (platform, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows64);
	}

	[MenuItem ("资源打包/ALL")]
	static void DoALL ()
	{
		DoIOS ();
		DoAndroid ();
		DoWeb ();
	}

	static void BuildAssetBundles (string platform, BuildAssetBundleOptions options, BuildTarget target)
	{
		DirectoryInfo dirInfo = new DirectoryInfo ("../lua/" + platform);
		Debug.Log (dirInfo.FullName);
		if (!dirInfo.Exists) {
			dirInfo.Create ();
		}
		BuildPipeline.BuildAssetBundles (dirInfo.FullName, options, target);
	}

	private static string PATH = "E:\\air_mahjong\\gamble\\lua\\";

	[MenuItem ("资源打包/生成版本")]
	static void Release ()
	{
		String version = DateTime.Now.Ticks.ToString();
		VersionInfo (RuntimePlatform.Android.ToString ());
		VersionInfo (RuntimePlatform.IPhonePlayer.ToString ());
		VersionInfo (RuntimePlatform.WebGLPlayer.ToString ());
		SaveFile (PATH + "version", version);
		Debug.Log (version);
	}

	static void SaveFile (string fileName, string txt)
	{
		File.WriteAllText (fileName, txt);
	}

	static void VersionInfo (String platform)
	{
		String str = dirInfo (PATH + platform);
		str += dirInfo (PATH + "src");
		SaveFile (PATH + platform + ".version", str);
	}

	static String dirInfo (String filename)
	{
		return dirInfo (new DirectoryInfo (filename));
	}

	static string dirInfo (DirectoryInfo dir)
	{
		if (dir.Name.Equals (".svn")) {
			return "";
		}
		string str = "";
		FileInfo[] files = dir.GetFiles ();
		DirectoryInfo[] dirs = dir.GetDirectories ();

		foreach (FileInfo file in files) {
			String name = file.FullName;
			if (!name.EndsWith (".manifest")) {
				str += name.Substring (PATH.Length).Replace ("\\", "/") + "," + Kye (file) + "," + file.Length + "\n";
			}
		}
		foreach (DirectoryInfo file in dirs) {
			str += dirInfo (file);
		}
		return str;
	}

	static string Kye (FileInfo file)
	{
		byte[] bytes = File.ReadAllBytes (file.FullName);
		return MD5 (bytes);
	}

	static string MD5 (byte[] bytes)
	{
		int len = Math.Min (1024 * 64, bytes.Length);
		return BitConverter.ToString ((new MD5CryptoServiceProvider ()).ComputeHash (bytes, 0, len)).ToLower ().Replace ("-", "");
	}
}