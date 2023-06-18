//
// author:@daisukiKaffuChino
//
package com.open.lua.util;

import android.annotation.SuppressLint;
import android.app.WallpaperManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.text.TextUtils;

import androidx.core.content.FileProvider;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

public class LuaWallpaper {
    public static void setWallpaper(Context context, String str) {
        String packageName = context.getPackageName();
        if (!TextUtils.isEmpty(str) && !TextUtils.isEmpty(packageName)) {
            Uri uriWithPath = getUriWithPath(context, str, packageName);
            if (isHuaweiRom()) {
                try {
                    ComponentName componentName = new ComponentName("com.android.gallery3d", "com.android.gallery3d.app.Wallpaper");
                    Intent intent = new Intent("android.intent.action.VIEW");
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    intent.setDataAndType(uriWithPath, "image/*");
                    intent.putExtra("mimeType", "image/*");
                    intent.setComponent(componentName);
                    context.startActivity(intent);
                } catch (Exception e) {
                    e.printStackTrace();
                    try {
                        WallpaperManager.getInstance(context.getApplicationContext()).setBitmap(getImageBitmap(str));
                    } catch (IOException e2) {
                        e2.printStackTrace();
                    }
                }
            } else if (isMiuiRom()) {
                try {
                    ComponentName componentName2 = new ComponentName("com.android.thememanager", "com.android.thememanager.activity.WallpaperDetailActivity");
                    Intent intent2 = new Intent("miui.intent.action.START_WALLPAPER_DETAIL");
                    intent2.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    intent2.setDataAndType(uriWithPath, "image/*");
                    intent2.putExtra("mimeType", "image/*");
                    intent2.setComponent(componentName2);
                    context.startActivity(intent2);
                } catch (Exception e3) {
                    e3.printStackTrace();
                    try {
                        WallpaperManager.getInstance(context.getApplicationContext()).setBitmap(getImageBitmap(str));
                    } catch (IOException e4) {
                        e4.printStackTrace();
                    }
                }
            } else {
                try {
                    Intent cropAndSetWallpaperIntent = WallpaperManager.getInstance(context.getApplicationContext()).getCropAndSetWallpaperIntent(uriWithPath);
                    cropAndSetWallpaperIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.getApplicationContext().startActivity(cropAndSetWallpaperIntent);
                } catch (IllegalArgumentException e5) {
                    try {
                        Bitmap bitmap = MediaStore.Images.Media.getBitmap(context.getApplicationContext().getContentResolver(), uriWithPath);
                        if (bitmap != null) {
                            WallpaperManager.getInstance(context.getApplicationContext()).setBitmap(bitmap);
                        }
                    } catch (IOException e6) {
                        e6.printStackTrace();
                    }
                }
            }
        }
    }

    private static Bitmap getImageBitmap(String str) {
        return BitmapFactory.decodeFile(str);
    }

    private static Uri getUriWithPath(Context context, String str, String str2) {
        return Build.VERSION.SDK_INT >= 24 ? FileProvider.getUriForFile(context.getApplicationContext(), str2, new File(str)) : Uri.fromFile(new File(str));
    }

    private static boolean isHuaweiRom() {
        return !TextUtils.isEmpty(getEmuiVersion()) && !getEmuiVersion().equals("");
    }


    private static boolean isMiuiRom() {
        return !TextUtils.isEmpty(getSystemProperty("ro.miui.ui.version.name"));
    }

    private static String getSystemProperty(String str) {
        BufferedReader bufferedReader = null;
        try {
            try {
                bufferedReader = new BufferedReader(new InputStreamReader(Runtime.getRuntime().exec("getprop " + str).getInputStream()), 1024);
                String readLine = bufferedReader.readLine();
                bufferedReader.close();
                try {
                    bufferedReader.close();
                } catch (IOException e) {
                }
                return readLine;
            } catch (IOException e2) {
                String str2 = null;
                if (bufferedReader != null) {
                    try {
                        bufferedReader.close();
                    } catch (IOException e3) {
                        e3.printStackTrace();
                    }
                }
                return str2;
            }
        } catch (Throwable th) {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException e4) {
                    e4.printStackTrace();
                }
            }
            throw th;
        }
    }

    private static boolean isFlymeRom(Context context) {
        new Boolean(isInstalledByPkgName(context, "com.meizu.flyme.update"));
        return isInstalledByPkgName(context, "com.meizu.flyme.update");
    }

    private static boolean isSmartisanRom(Context context) {
        new Boolean(isInstalledByPkgName(context, "com.smartisanos.security"));
        return isInstalledByPkgName(context, "com.smartisanos.security");
    }

    private static boolean isInstalledByPkgName(Context context, String str) {
        PackageInfo packageInfo;
        try {
            packageInfo = context.getPackageManager().getPackageInfo(str, 0);
        } catch (PackageManager.NameNotFoundException e) {
            packageInfo = null;
        }
        return packageInfo != null;
    }

    private static String getEmuiVersion() {
        Class<?>[] clsArr = new Class[1];
        try {
            clsArr[0] = Class.forName("java.lang.String");
            Object[] objArr = {"ro.build.version.emui"};
            try {
                @SuppressLint("PrivateApi") Class<?> cls = Class.forName("android.os.SystemProperties");
                String str = (String) cls.getDeclaredMethod("get", clsArr).invoke(cls, objArr);
                if (!TextUtils.isEmpty(str)) {
                    return str;
                }
            } catch (LinkageError | Exception e) {
                e.printStackTrace();
            }
            return "";
        } catch (ClassNotFoundException e6) {
            throw new NoClassDefFoundError(e6.getMessage());
        }
    }
}


