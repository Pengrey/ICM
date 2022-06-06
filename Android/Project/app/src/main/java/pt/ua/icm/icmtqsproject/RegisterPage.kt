package pt.ua.icm.icmtqsproject

import android.content.Intent
import android.content.SharedPreferences
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.widget.Button
import android.widget.EditText

class RegisterPage : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register_page)

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Text Fields
        val emailField: EditText = findViewById(R.id.editEmailAddress)
        val cidField: EditText = findViewById(R.id.editCID)
        val passwordField: EditText = findViewById(R.id.editPassword)

        // Action buttons
        val registerButton: Button = findViewById(R.id.RegisterButton)

        // Buttons listeners
        registerButton.setOnClickListener {
            register(emailField, cidField, passwordField, sharedPreferences)
        }
    }

    private fun register(emailField: EditText, passwordField: EditText, cidField: EditText, prefs: SharedPreferences) {
        val email: String = emailField.text.toString()
        val cid: String = cidField.text.toString()
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
}