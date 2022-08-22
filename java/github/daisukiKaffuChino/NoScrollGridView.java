package github.daisukiKaffuChino;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.GridView;

public class NoScrollGridView extends GridView {
    /* JADX INFO: super call moved to the top of the method (can break code semantics) */
    public NoScrollGridView(Context context) {
        super(context);
    }

    /* JADX INFO: super call moved to the top of the method (can break code semantics) */
    public NoScrollGridView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
    }

    @Override
    public void onMeasure(int i, int i2) {
        super.onMeasure(i, View.MeasureSpec.makeMeasureSpec(0x1fffffff, MeasureSpec.AT_MOST));
    }
}
