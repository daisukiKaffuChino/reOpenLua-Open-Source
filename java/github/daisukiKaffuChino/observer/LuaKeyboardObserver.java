package github.daisukiKaffuChino.observer;

import android.app.Activity;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;

import java.lang.ref.WeakReference;

public class LuaKeyboardObserver {
    private final WeakReference<Activity> activityRef;
    private WeakReference<View> rootViewRef;
    private WeakReference<OnKeyboardToggleListener> onKeyboardToggleListenerRef;
    private ViewTreeObserver.OnGlobalLayoutListener viewTreeObserverListener;

    public LuaKeyboardObserver(Activity activity) {
        activityRef = new WeakReference<>(activity);
        initialize();
    }

    public void setListener(OnKeyboardToggleListener onKeyboardToggleListener) {
        onKeyboardToggleListenerRef = new WeakReference<>(onKeyboardToggleListener);
    }

    public void destroy() {
        if (rootViewRef.get() != null)
            rootViewRef.get().getViewTreeObserver().removeOnGlobalLayoutListener(viewTreeObserverListener);
    }

    private void initialize() {
        if (hasAdjustResizeInputMode()) {
            viewTreeObserverListener = new GlobalLayoutListener();
            rootViewRef = new WeakReference<>(activityRef.get().findViewById(Window.ID_ANDROID_CONTENT));
            rootViewRef.get().getViewTreeObserver().addOnGlobalLayoutListener(viewTreeObserverListener);
        } else {
            throw new IllegalArgumentException("AXML缺少属性windowSoftInputMode adjustResize");
        }
    }

    private boolean hasAdjustResizeInputMode() {
        return (activityRef.get().getWindow().getAttributes().softInputMode & WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE) != 0;
    }

    private class GlobalLayoutListener implements ViewTreeObserver.OnGlobalLayoutListener {
        int initialValue;
        boolean hasSentInitialAction;
        boolean isKeyboardShown;

        @Override
        public void onGlobalLayout() {
            if (initialValue == 0) {
                initialValue = rootViewRef.get().getHeight();
            } else {
                if (initialValue > rootViewRef.get().getHeight()) {
                    if (onKeyboardToggleListenerRef.get() != null) {
                        if (!hasSentInitialAction || !isKeyboardShown) {
                            isKeyboardShown = true;
                            onKeyboardToggleListenerRef.get().onObservedKeyboardShown(initialValue - rootViewRef.get().getHeight());
                        }
                    }
                } else {
                    if (!hasSentInitialAction || isKeyboardShown) {
                        isKeyboardShown = false;
                        rootViewRef.get().post(new Runnable() {
                            @Override
                            public void run() {
                                if (onKeyboardToggleListenerRef.get() != null) {
                                    onKeyboardToggleListenerRef.get().onObservedKeyboardHide();
                                }
                            }
                        });
                    }
                }
                hasSentInitialAction = true;
            }
        }
    }

    public interface OnKeyboardToggleListener {
        void onObservedKeyboardShown(int keyboardSize);

        void onObservedKeyboardHide();
    }
}
