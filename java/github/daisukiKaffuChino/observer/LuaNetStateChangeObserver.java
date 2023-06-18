package github.daisukiKaffuChino.observer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class LuaNetStateChangeObserver {
    private static boolean isRegister = false;
    private static NetStateChangeObserver listener;
    private static final BroadcastReceiver Receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
                ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
                NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
                if (null != activeNetwork) {
                    if (activeNetwork.getType() == ConnectivityManager.TYPE_WIFI | activeNetwork.getType() == ConnectivityManager.TYPE_MOBILE) {
                        if (listener != null) listener.onConnect();
                    } else {
                        if (listener != null) listener.onDisconnect();
                    }
                } else {
                    if (listener != null) listener.onDisconnect();
                }
            }
        }
    };

    public static void registerReceiver(Context context, NetStateChangeObserver lis) {
        listener = lis;
        IntentFilter intentFilter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
        context.getApplicationContext().registerReceiver(Receiver, intentFilter);
        isRegister = true;
    }

    public static void unRegisterReceiver(Context context) {
        try {
            if (isRegister) {
                context.getApplicationContext().unregisterReceiver(Receiver);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public interface NetStateChangeObserver {

        void onDisconnect();

        void onConnect();

    }
}
