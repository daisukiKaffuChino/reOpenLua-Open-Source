package github.daisukiKaffuChino;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;

import androidx.viewpager.widget.ViewPager;


public class CustomViewPager extends ViewPager {

    private boolean isSwipeable;

    public CustomViewPager(Context context) {
        super(context);
    }

    public CustomViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.isSwipeable = false;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouchEvent(MotionEvent e) {
        if (this.isSwipeable) {
            return super.onTouchEvent(e);
        }
        return false;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent e) {
        if (this.isSwipeable) {
            return super.onInterceptTouchEvent(e);
        }
        return false;
    }

    public void setSwipeable(boolean b) {
        this.isSwipeable = b;
    }
}