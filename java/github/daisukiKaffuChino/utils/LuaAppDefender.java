package github.daisukiKaffuChino.utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class LuaAppDefender {
    @SuppressLint("StaticFieldLeak")
    protected static Context ct;
    public LuaAppDefender() {
    }
    public LuaAppDefender(Context c) {
        ct = c;
    }
    public void setContext(Context c) {
        ct = c;
    }
    private static String prepare() throws PackageManager.NameNotFoundException, PackageManager.NameNotFoundException, PackageManager.NameNotFoundException {
        return prepare(ct);
    }
    private static String prepare(Context c) throws PackageManager.NameNotFoundException, PackageManager.NameNotFoundException, PackageManager.NameNotFoundException {
        String PATH_PackageParser = "android.content.pm.PackageParser";
        String apkPath=c.getPackageManager().getApplicationInfo(getName(), 0).sourceDir;
        try {
            // apk包的文件路径
            // 这是一个Package 解释器, 是隐藏的
            // 构造函数的参数只有一个, apk文件的路径
            // PackageParser packageParser = new PackageParser(apkPath);
            @SuppressLint("PrivateApi") Class<?> pkgParserCls = Class.forName(PATH_PackageParser);
            Class[] typeArgs = new Class[1];
            typeArgs[0] = String.class;
            // 这个是与显示有关的, 里面涉及到一些像素显示等等, 我们使用默认的情况
            DisplayMetrics metrics = new DisplayMetrics();
            metrics.setToDefaults();
            Constructor pkgParserCt;
            Object pkgParser;
            {
                pkgParserCt = pkgParserCls.getConstructor();
                pkgParser = pkgParserCt.newInstance();
                @SuppressLint("DiscouragedPrivateApi") Method pkgParser_parsePackageMtd = pkgParserCls.getDeclaredMethod("parsePackage", File.class, int.class);
                Object pkgParserPkg = pkgParser_parsePackageMtd.invoke(pkgParser, new File(apkPath), PackageManager.GET_SIGNATURES);
                if (Build.VERSION.SDK_INT >= 28) {
                    assert pkgParserPkg != null;
                    Method pkgParser_collectCertificatesMtd = pkgParserCls.getDeclaredMethod("collectCertificates", pkgParserPkg.getClass(), Boolean.TYPE);
                    pkgParser_collectCertificatesMtd.invoke(pkgParser, pkgParserPkg, false);
					/*
					 Method pkgParser_collectCertificatesMtd = pkgParserCls.getDeclaredMethod("collectCertificates", pkgParserPkg.getClass(), Boolean.TYPE);
					 pkgParser_collectCertificatesMtd.invoke(pkgParser, pkgParserPkg, Build.VERSION.SDK_INT>28);
					 //迷之操作
					 Method _pkgParser_collectCertificatesMtd = pkgParserCls.getDeclaredMethod("collectCertificates", pkgParserPkg.getClass(), Boolean.TYPE);
					 _pkgParser_collectCertificatesMtd.invoke(pkgParser, pkgParserPkg, false);
					 */
                    Field mSigningDetailsField = pkgParserPkg.getClass().getDeclaredField("mSigningDetails"); // SigningDetails
                    mSigningDetailsField.setAccessible(true);
                    Object mSigningDetails =  mSigningDetailsField.get(pkgParserPkg);
                    assert mSigningDetails != null;
                    Field infoField = mSigningDetails.getClass().getDeclaredField("signatures");
                    infoField.setAccessible(true);
                    Signature[] info = (Signature[]) infoField.get(mSigningDetails);
                    assert info != null;
                    return info[0].toCharsString();
                } else {
                    assert pkgParserPkg != null;
                    Method pkgParser_collectCertificatesMtd = pkgParserCls.getDeclaredMethod("collectCertificates", pkgParserPkg.getClass(), Integer.TYPE);
                    pkgParser_collectCertificatesMtd.invoke(pkgParser, pkgParserPkg, PackageManager.GET_SIGNATURES);
                    Field packageInfoFld = pkgParserPkg.getClass().getDeclaredField("mSignatures");
                    Signature[] info = (Signature[]) packageInfoFld.get(pkgParserPkg);
                    assert info != null;
                    return info[0].toCharsString();
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private static String getName(){
        PackageManager manager = ct.getPackageManager();
        try {
            PackageInfo info = manager.getPackageInfo(ct.getPackageName(), 0);
            return info.packageName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    private static String apply(String text) {
        try{
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            byte[] bytes = md5.digest(text.getBytes(StandardCharsets.UTF_8));

            StringBuilder builder = new StringBuilder();

            for (byte aByte : bytes) {
                builder.append(Integer.toHexString((0x000000FF & aByte) | 0xFFFFFF00).substring(6));
            }
            return builder.toString();
        }catch (Exception e){
            return "";
        }

    }

    public static String get(Context c) throws PackageManager.NameNotFoundException {
        return apply(prepare(c));
    }

}
