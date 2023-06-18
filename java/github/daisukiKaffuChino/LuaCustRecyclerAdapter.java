package github.daisukiKaffuChino;

import android.view.ViewGroup;
import android.widget.Filter;
import android.widget.Filterable;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class LuaCustRecyclerAdapter extends RecyclerView.Adapter {
    public AdapterCreator adapterCreator;

    public LuaCustRecyclerAdapter(AdapterCreator adapterCreator) {
        this.adapterCreator = adapterCreator;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return this.adapterCreator.onCreateViewHolder(parent, viewType);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        this.adapterCreator.onBindViewHolder(holder, position);
    }

    @Override
    public int getItemCount() {
        return (int) this.adapterCreator.getItemCount();
    }

    @Override
    public int getItemViewType(int position) {
        return (int) this.adapterCreator.getItemViewType(position);
    }

}
