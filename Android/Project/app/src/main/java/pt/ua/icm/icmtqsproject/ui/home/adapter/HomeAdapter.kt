package pt.ua.icm.icmtqsproject.ui.home.adapter

import android.location.Location
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import pt.ua.icm.icmtqsproject.R
import pt.ua.icm.icmtqsproject.data.model.Delivery
import kotlin.math.roundToInt

class HomeAdapter(private val deliveries: ArrayList<Delivery>, private val startPoint: Location) : RecyclerView.Adapter<HomeAdapter.ViewHolder>() {
    class ViewHolder(view: View, startPoint: Location) : RecyclerView.ViewHolder(view) {
        val textViewDeliveryAddr: TextView
        val textViewOriginAddr: TextView
        val textViewDistance: TextView

        init {
            textViewDeliveryAddr = view.findViewById(R.id.textViewDeliveryAddr)
            textViewOriginAddr = view.findViewById(R.id.textViewOriginAddr)
            textViewDistance = view.findViewById(R.id.textViewDistance)
        }

        fun bind(delivery: Delivery, startPoint: Location) {
            itemView.apply {
                textViewDeliveryAddr.text = delivery.deliveryAddr
                textViewOriginAddr.text = delivery.originAddr

                // Calculate distance
                val endPoint = Location("locationB")
                endPoint.latitude = delivery.latitude
                endPoint.longitude = delivery.longitude
                textViewDistance.text = (startPoint.distanceTo(endPoint)/1000).roundToInt().toString() + "Km";
            }
        }
    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(viewGroup.context)
            .inflate(R.layout.item_layout, viewGroup, false)

        return ViewHolder(view, startPoint)
    }

    override fun getItemCount() = deliveries.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(deliveries[position], startPoint)
    }

}