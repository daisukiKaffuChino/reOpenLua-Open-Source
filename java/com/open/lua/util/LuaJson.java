package com.open.lua.util;

public class LuaJson {

    public static String setFormat(String str) {
        StringBuilder stringBuffer = new StringBuilder();
        int length = str.length();
        int i = 0;
        char c = (char) 0;
        for (int i2 = 0; i2 < length; i2++) {
            char charAt = str.charAt(i2);
            if (charAt == '[' || charAt == '{') {
                if (i2 - 1 > 0 && str.charAt(i2 - 1) == ':') {
                    stringBuffer.append('\n');
                    stringBuffer.append(indent(i));
                }
                stringBuffer.append(charAt);
                stringBuffer.append('\n');
                i++;
                stringBuffer.append(indent(i));
            } else if (charAt == ']' || charAt == '}') {
                stringBuffer.append('\n');
                i--;
                stringBuffer.append(indent(i));
                stringBuffer.append(charAt);
                if (i2 + 1 < length && str.charAt(i2 + 1) != ',') {
                    stringBuffer.append('\n');
                }
            } else if (charAt == ',') {
                stringBuffer.append(charAt);
                stringBuffer.append('\n');
                stringBuffer.append(indent(i));
            } else {
                stringBuffer.append(charAt);
            }
        }
        return stringBuffer.toString();
    }

    private static String indent(int i) {
        StringBuilder stringBuffer = new StringBuilder();
        for (int i2 = 0; i2 < i; i2++) {
            String SPACE = "  ";
            stringBuffer.append(SPACE);
        }
        return stringBuffer.toString();
    }
}
