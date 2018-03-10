package ge.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * 远程方法注解，标有本注解的的ge.net.Application子类的public方法可以被客户端调用.
 * 
 * @远程方法参数类型:Buffer、byte、short、int、float、double、Byte[]、Short[]、Integer[]、Float[]、Double[]、String、String[]
 * @注：Buffer 应是单独的一个参数
 * 
 * @author Administrator {@value 消息码}
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
public @interface RemoteMethod {
	byte value();
}
