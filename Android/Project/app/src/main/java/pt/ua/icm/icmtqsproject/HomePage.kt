package pt.ua.icm.icmtqsproject

import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.widget.Button
import androidx.databinding.DataBindingUtil
import pt.ua.icm.icmtqsproject.databinding.ActivityHomePageBinding
import com.birjuvachhani.locus.Locus

class HomePage : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding :  ActivityHomePageBinding=
            DataBindingUtil.setContentView(this, R.layout.activity_home_page)
        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Delivery State Button
        val deliveryStateButton: Button = findViewById(R.id.deliveryStateButton)

        deliveryStateButton.setOnClickListener{
            Locus.getCurrentLocation(this) { result ->
                result.location?.let {
                    // Bind Location to text on page
                    binding.locationText = "${result.location!!.latitude}, ${result.location!!.longitude}"
                }
                result.error?.let { /* Received error! */ }
            }
        }

        // Bind Id to text on page
        val riderId: String? = sharedPreferences.getString("riderId", "")
        if (riderId != "") {
            binding.welcomingText = "$riderId"
        }else{
            binding.welcomingText = "No Rider!"
        }
    }
}

