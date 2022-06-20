package pt.ua.icm.icmtqsproject

import android.location.Location
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.birjuvachhani.locus.Locus
import pt.ua.icm.icmtqsproject.data.model.Delivery
import pt.ua.icm.icmtqsproject.ui.home.adapter.HomeAdapter
import pt.ua.icm.icmtqsproject.utils.Status

class AddDeliveryActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_add_delivery)
        // Fields Content
        val customerIDValue: EditText = findViewById(R.id.customerID_text)
        val deliveryAddressValue: EditText = findViewById(R.id.delivery_address_text)
        val originAddressValue: EditText = findViewById(R.id.origin_address_text)
        val latValue: EditText = findViewById(R.id.lat_text)
        val longValue: EditText = findViewById(R.id.long_text)


        // Char buttons
        val autoLocationButton: Button = findViewById(R.id.autoLocation)
        val saveButton: Button = findViewById(R.id.SaveDeliveryButton)
        val cancelButton: Button = findViewById(R.id.CancelAddButton)

        // Char buttons
        autoLocationButton.setOnClickListener {
            // Get current location to fill the fields
            Locus.getCurrentLocation(this) { result ->
                result.location?.let {
                    latValue.setText(result.location!!.latitude.toString())
                    longValue.setText(result.location!!.longitude.toString())
                }
                result.error?.let { /* Received error! */ }
            }

        }

        saveButton.setOnClickListener {
        }

        cancelButton.setOnClickListener {
            this.finish()
        }
    }
}