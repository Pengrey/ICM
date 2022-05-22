package com.example.android.weather

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.android.weather.databinding.CitiesListItemBinding
import com.example.android.weather.model.City

class CitiesAdapter(private val onItemClicked: (City) -> Unit) :
    ListAdapter<City, CitiesAdapter.CityViewHolder>(DiffCallback) {

    private lateinit var context: Context

    class CityViewHolder(private var binding: CitiesListItemBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(city: City, context: Context) {
            binding.title.text = context.getString(city.titleResourceId)
        }
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): CityViewHolder {
        context = parent.context
        return CityViewHolder(
            CitiesListItemBinding.inflate(
                LayoutInflater.from(parent.context), parent, false
            )
        )
    }

    override fun onBindViewHolder(holder: CityViewHolder, position: Int) {
        val current = getItem(position)
        holder.itemView.setOnClickListener {
            onItemClicked(current)
        }
        holder.bind(current, context)
    }

    companion object {
        private val DiffCallback = object : DiffUtil.ItemCallback<City>() {
            override fun areItemsTheSame(oldItem: City, newItem: City): Boolean {
                return (
                    oldItem.id == newItem.id || oldItem.titleResourceId == newItem.titleResourceId
                    )
            }

            override fun areContentsTheSame(oldItem: City, newItem: City): Boolean {
                return oldItem == newItem
            }
        }
    }
}
