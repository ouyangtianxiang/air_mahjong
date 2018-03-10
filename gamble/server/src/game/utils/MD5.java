package game.utils;


/**
 * MD5的算法在RFC1321 中定义
 * 在RFC 1321中，给出了Test suite用来检验你的实现是否正确： 
 * MD5 ("") = d41d8cd98f00b204e9800998ecf8427e 
 * MD5 ("a") = 0cc175b9c0f1b6a831c399e269772661 
 * MD5 ("abc") = 900150983cd24fb0d6963f7d28e17f72 
 * MD5 ("message digest") = f96b697d7cb7938d525a2f31aaf161d0 
 * MD5 ("abcdefghijklmnopqrstuvwxyz") = c3fcd3d76192e4007dfb496cca67e13b
 * @author user1
 *
 */
public class MD5 {
	
//	final transient static Logger log = LoggerFactory
//	.getLogger(MD5.class);
	
  public static String getMD5(byte[] source) {
    String s = null;
    char hexDigits[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    try{
      java.security.MessageDigest md = java.security.MessageDigest.getInstance( "MD5" );
      md.update( source );
      byte tmp[] = md.digest();
      char str[] = new char[16 * 2];
      int k = 0;
      for (int i = 0; i < 16; i++) {
        byte byte0 = tmp[i];
        str[k++] = hexDigits[byte0 >>> 4 & 0xf];
        str[k++] = hexDigits[byte0 & 0xf];
      }
      s = new String(str);
    }catch( Exception e ){
//      	log.warn("",e);
    }
    return s;
  }
}

