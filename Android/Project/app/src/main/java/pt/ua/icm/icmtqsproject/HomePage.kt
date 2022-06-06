package pt.ua.icm.icmtqsproject

import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import androidx.databinding.DataBindingUtil
import pt.ua.icm.icmtqsproject.databinding.ActivityHomePageBinding

class HomePage : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding :  ActivityHomePageBinding=
            DataBindingUtil.setContentView(this, R.layout.activity_home_page)

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Bind Id to text on page
        val riderId: String? = sharedPreferences.getString("riderId", "")
        if (riderId != "") {
            binding.welcomingText = "$riderId"
        }else{
            binding.welcomingText = "No Rider!"
        }
    }
}