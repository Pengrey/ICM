package pt.ua.icm.icmtqsproject

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Check if logged in already or not
        val riderId: String? = sharedPreferences.getString("riderId", "")
        if (riderId != "") {
            val intent = Intent(this, HomePage::class.java)
            startActivity(intent)
        }

        // Text Fields
        val emailField: EditText = findViewById(R.id.editEmailAddress)
        val passwordField: EditText = findViewById(R.id.editPassword)

        // Action buttons
        val signinButton: Button = findViewById(R.id.SignInButton)

        // Char buttons
        signinButton.setOnClickListener {
            signin(emailField, passwordField, sharedPreferences)
        }

    }

    private fun signin(emailField: EditText, passwordField: EditText, prefs: SharedPreferences) {
        val email: String = emailField.text.toString()
        val password: String = passwordField.text.toString()

        // Call login api endpoint
        val riderId: String = "rider@email.com"

        // Set on preferences
        val editor = prefs.edit()
        editor.putString("riderId", riderId)
        editor.apply()

        // Got to main page
        val intent = Intent(this, HomePage::class.java)
        startActivity(intent)
    }

    private fun register(view: View) {

    }
}