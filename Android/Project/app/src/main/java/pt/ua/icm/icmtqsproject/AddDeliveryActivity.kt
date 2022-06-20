package pt.ua.icm.icmtqsproject

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import com.birjuvachhani.locus.Locus
import pt.ua.icm.icmtqsproject.data.model.NewDelivery

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
            val customerId = customerIDValue.text.toString()
            val deliveryAddress = deliveryAddressValue.text.toString()
            val originAddress = originAddressValue.text.toString()
            val latitude = latValue.text.toString()
            val longitude = longValue.text.toString()


            if(customerId.isNotEmpty() && deliveryAddress.isNotEmpty() && originAddress.isNotEmpty() && latitude.isNotEmpty() && longitude.isNotEmpty()) {
                val newDelivery: NewDelivery = NewDelivery(customerId, deliveryAddress, originAddress, latitude, longitude)
                Toast.makeText(applicationContext, "Delivery Added", Toast.LENGTH_SHORT).show()
                println(newDelivery)
                // TODO: API CALL
                this.finish()
            }
        }

        cancelButton.setOnClickListener {
            this.finish()
        }
    }
}