package github.daisukiKaffuChino;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.widget.TextView;

import com.google.android.material.tabs.TabLayout;

import java.util.ArrayList;
import java.util.Arrays;

import github.daisukiKaffuChino.reopenlua.R;

public class LuaFileTabView extends TabLayout {
    private String nowPath = "";

    public LuaFileTabView(Context context, AttributeSet attrs) {
        super(context, attrs);
        addListener();
        setContext(context);
    }

    public LuaFileTabView(Context context) {
        super(context);
        addListener();
        setContext(context);
    }

    private void setContext(Context context) {
    }

    public String getPath() {
        return nowPath;
    }

    public void setDirectPath(String path) {
        nowPath = path;
    }


    public void setPath(String path) {
        setPath(path, true);
    }

    public void setPath(String path, final boolean selectable) {
        ArrayList array = new ArrayList(Arrays.asList(path.split("/")));
        array.remove(0);
        ArrayList lastArray = new ArrayList(Arrays.asList(nowPath.split("/")));
        lastArray.remove(0);

        if (array.size() <= lastArray.size()) {
            for (int i = 0; i < lastArray.size() - array.size(); i++) {
                removeTabAt(getTabCount() - 1);
            }
        }

        for (int i = 0; i < array.size(); i++) {
            int tabCount = getTabCount();
            Tab tab = getTabAt(i);
            if (tab != null) {
                //Log.i("FileTagView", i + "\tAccess Ok");
                tab.setText((String) array.get(i));
                TextView textView=(TextView)tab.view.getChildAt(1);
                textView.setAllCaps(false);
                //textView.setTextSize(12);
            } else {
                //Log.i("FileTagView",i+"\tAccess Failed As a null object");
                tab = newTab().setIcon(R.drawable.ic_round_chevron_left_24);
                addTab(tab);
                tab.setText((String) array.get(i));
                TextView textView=(TextView)tab.view.getChildAt(1);
                textView.setAllCaps(false);
                //textView.setTextSize(12);
            }
            if (i == array.size() - 1) {
                final Tab finalTab = tab;
                new Handler().postDelayed(new Runnable(){
                    @Override
                    public void run() {

                        if (selectable) {
                            finalTab.select();
                        }
                        final float toX=finalTab.view.getX();
                        if (toX > 0) {
                            smoothScrollTo((int)toX, 0);
                        }
                    }
                }, 1);
            }
        }



        nowPath = path;
    }

    private void addListener() {
        addOnTabSelectedListener(new OnTabSelectedListener() {

            @Override
            public void onTabSelected(Tab tab) {
                int mTabCount=getTabCount();
                int mPosition=tab.getPosition();
                ArrayList nowPaths = new ArrayList(Arrays.asList(nowPath.split("/")));
                nowPaths.remove(0);

                if (mPosition < mTabCount) {
                    for (int i = 0; i < mTabCount - 1 - mPosition; i++) {
                        removeTabAt(getTabCount() - 1);
                        nowPaths.remove(nowPaths.size() - 1);
                    }
                    StringBuilder path = new StringBuilder();
                    for (int i = 0; i < nowPaths.size(); i++) {
                        path.append("/").append(nowPaths.get(i));
                    }

                    new Handler().postDelayed(new Runnable(){
                        @Override
                        public void run() {
                            Tab finalTab = getTabAt(getTabCount() - 1);
                            assert finalTab != null;
                            final float toX=finalTab.view.getX();
                            if (toX > 0) {
                                smoothScrollTo((int)toX, 0);
                            }
                        }
                    }, 1);
                    setDirectPath(path.toString());
                    //selectListener(path);

                }
            }

            @Override
            public void onTabUnselected(Tab tab) {

            }

            @Override
            public void onTabReselected(Tab tab) {

            }
        });
    }

}
