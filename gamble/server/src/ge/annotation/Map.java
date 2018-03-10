package ge.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * 客户端字段映射标识
 * 
 * @author Administrator
 * 
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
public @interface Map {
	boolean[] value();
}