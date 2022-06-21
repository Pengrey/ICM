package pt.ua.icm.icmtqsproject

import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.widget.Button
import com.birjuvachhani.locus.Locus
import pt.ua.icm.icmtqsproject.R

class DeliveriesTrackingActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_deliveries_tracking)

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Finish delivery button
        val finishButton: Button = findViewById(R.id.finishButton)
        finishButton.setOnClickListener {
            // Set on preferences
            val editor = sharedPreferences.edit()
            editor.putString("isAssigned", "false")
            editor.apply()
            this.finish()
        }
    }
}