package github.daisukiKaffuChino.utils;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class LuaReflectionUtil {
    //private static final String TAG = "LuaReflectionUtil";

    public static boolean hasMethod(String className, String method, Class[] params) {
        try {
            Class<?> targetClass = Class.forName(className);
            if (params != null) {
                targetClass.getMethod(method, params);
                return true;
            }
            targetClass.getMethod(method);
            return true;
        } catch (SecurityException | NoSuchMethodException | ClassNotFoundException | IllegalArgumentException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static Method getMethod(String className, String method, Class[] params) {
        try {
            return Class.forName(className).getDeclaredMethod(method, params);
        } catch (SecurityException | NoSuchMethodException | IllegalArgumentException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static Field getField(String className, String name) {
        try {
            return Class.forName(className).getDeclaredField(name);
        } catch (SecurityException | ClassNotFoundException | NoSuchFieldException | IllegalArgumentException e) {
            e.printStackTrace();
            return null;
        }
    }
}
