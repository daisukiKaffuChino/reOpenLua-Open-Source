package github.daisukiKaffuChino;

import android.content.Context;
import android.view.Window;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.DialogTitle;

import github.daisukiKaffuChino.reopenlua.R;
import github.daisukiKaffuChino.utils.LuaThemeUtil;

public class LuaMaterialDialog extends AlertDialog.Builder {

    Context context;

    public LuaMaterialDialog(Context context) {
        super(context);
        this.context = context;
    }

    /*
     @Override
     protected void onCreate(Bundle savedInstanceState) {
     super.onCreate(savedInstanceState);
     Window window = this.getWindow();
     if (window != null) {
     //设置动画
     window.setWindowAnimations(R.style.BaseDialogAnim);
     }
     }
     */
    public AlertDialog show() {
        AlertDialog dialog = LuaMaterialDialog.super.show();
        DialogTitle title = dialog.findViewById(androidx.appcompat.R.id.alertTitle);
        TextView msg = dialog.findViewById(android.R.id.message);
        LuaThemeUtil luaThemeUtil = new LuaThemeUtil(context);
        assert title != null;
        title.setTextColor(luaThemeUtil.getColorPrimary());
        assert msg != null;
        //msg.setTextColor(luaThemeUtil.getSubTitleTextc());
        title.setTextSize(18);
        msg.setTextSize(14);
        Window it = dialog.getWindow();
        if (it != null) {
            it.setWindowAnimations(R.style.BaseDialogAnim);
        }
        return dialog;
    }

}
