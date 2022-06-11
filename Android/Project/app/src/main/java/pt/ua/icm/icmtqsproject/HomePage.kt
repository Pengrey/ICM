package pt.ua.icm.icmtqsproject

import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.location.Location
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Looper
import android.preference.PreferenceManager
import android.widget.Button
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.databinding.DataBindingUtil
import com.google.android.gms.location.*
import pt.ua.icm.icmtqsproject.databinding.ActivityHomePageBinding

class HomePage : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding :  ActivityHomePageBinding=
            DataBindingUtil.setContentView(this, R.layout.activity_home_page)

        // Location
        initView()

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Bind Id to text on page
        val riderId: String? = sharedPreferences.getString("riderId", "")
        if (riderId != "") {
            binding.welcomingText = "$riderId"
        }else{
            binding.welcomingText = "No Rider!"
        }

        // Bind Location to text on page
        val lastLocation: String? = sharedPreferences.getString("lastLocation", "")
        if (lastLocation != "") {
            binding.locationText = "$lastLocation"
        }else{
            binding.locationText = "No Location Registered!"
        }
    }

    private fun initView() {
        // Delivery State Button buttons
        val deliveryStateButton: Button = findViewById(R.id.deliveryStateButton)
        
        deliveryStateButton.setOnClickListener {
            if (ContextCompat.checkSelfPermission(
                    applicationContext,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                    REQUEST_CODE_LOCATION_PERMISSION
                )
            } else {
                if (isLocationServiceRunning()) {
                    stopLocationService()
                    println("STOP")
                } else {
                    startLocationService()
                    println("START")
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == REQUEST_CODE_LOCATION_PERMISSION && grantResults.isNotEmpty()) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startLocationService()
            } else {
                Toast.makeText(this, "Permission denied", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun isLocationServiceRunning(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        activityManager.getRunningServices(Integer.MAX_VALUE).forEach {
            if (LocationService::class.java.name == it.service.className) {
                if (it.foreground) {
                    return true
                }
            }
        }
        return false
    }

    private fun startLocationService() {
        if (!isLocationServiceRunning()) {
            val intent = Intent(applicationContext, LocationService::class.java)
            intent.action =
                Constants.ACTION_START_LOCATION_SERVICE
            startService(intent)
        }
    }

    private fun stopLocationService() {
        if (isLocationServiceRunning()) {
            val intent = Intent(applicationContext, LocationService::class.java)
            intent.action =
                Constants.ACTION_STOP_LOCATION_SERVICE
            startService(intent)
        }
    }

    companion object {
        private val REQUEST_CODE_LOCATION_PERMISSION = 1
    }
}

