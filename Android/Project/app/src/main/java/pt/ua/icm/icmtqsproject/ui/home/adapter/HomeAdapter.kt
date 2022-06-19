package pt.ua.icm.icmtqsproject.ui.home.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import pt.ua.icm.icmtqsproject.R
import pt.ua.icm.icmtqsproject.data.model.Delivery

class HomeAdapter(private val deliveries: ArrayList<Delivery>) : RecyclerView.Adapter<HomeAdapter.ViewHolder>() {
    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val textViewCustomerId: TextView
        val textViewDeliveryAddr: TextView
        val textViewOriginAddr: TextView
        val textViewDeliveryState: TextView

        init {
            // Define click listener for the ViewHolder's View.
            textViewCustomerId = view.findViewById(R.id.textViewCustomerId)
            textViewDeliveryAddr = view.findViewById(R.id.textViewDeliveryAddr)
            textViewOriginAddr = view.findViewById(R.id.textViewOriginAddr)
            textViewDeliveryState = view.findViewById(R.id.textViewDeliveryState)
        }

        fun bind(delivery: Delivery) {
            itemView.apply {
                textViewCustomerId.text = delivery.customerId
                textViewDeliveryAddr.text = delivery.deliveryAddr
                textViewOriginAddr.text = delivery.originAddr
                textViewDeliveryState.text = delivery.deliveryState
            }
        }
    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ViewHolder {
        // Create a new view, which defines the UI of the list item
        val view = LayoutInflater.from(viewGroup.context)
            .inflate(R.layout.item_layout, viewGroup, false)

        return ViewHolder(view)
    }

    override fun getItemCount() = deliveries.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(deliveries[position])
    }

}