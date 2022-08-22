package github.daisukiKaffuChino;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ListView;

public class NoScrollListView extends ListView {
    /* JADX INFO: super call moved to the top of the method (can break code semantics) */
    public NoScrollListView(Context context) {
        super(context);
    }

    /* JADX INFO: super call moved to the top of the method (can break code semantics) */
    public NoScrollListView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
    }

    @Override
    public void onMeasure(int i, int i2) {
        super.onMeasure(i, View.MeasureSpec.makeMeasureSpec(0x1fffffff, MeasureSpec.AT_MOST));
    }
}
