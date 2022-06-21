package pt.ua.icm.icmtqsproject.ui

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.preference.PreferenceManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import pt.ua.icm.icmtqsproject.R
import pt.ua.icm.icmtqsproject.ui.admin.view.AdminPage
import pt.ua.icm.icmtqsproject.ui.home.view.HomePage

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Check if logged in already or not
        val riderId: String? = sharedPreferences.getString("riderId", "")
        if (riderId != "") {
            // Go to admin page if logged in as admin
            if (riderId  == "admin@gmail.com") {
                val intent = Intent(this, AdminPage::class.java)
                startActivity(intent)
            }else{
                // Go to home page if logged in already
                val intent = Intent(this, HomePage::class.java)
                startActivity(intent)
            }
        }

        // Text Fields
        val emailField: EditText = findViewById(R.id.editEmailAddress)
        val passwordField: EditText = findViewById(R.id.editPassword)

        // Action buttons
        val signinButton: Button = findViewById(R.id.SignInButton)
        val registerButton: TextView = findViewById(R.id.registerText)

        // Buttons listeners
        signinButton.setOnClickListener {
            signin(emailField, passwordField, sharedPreferences)
        }

        registerButton.setOnClickListener {
            register()
        }

    }

    private fun register() {
        // Got to register page
        val intent = Intent(this, RegisterPage::class.java)
        startActivity(intent)
    }

    private fun signin(emailField: EditText, passwordField: EditText, prefs: SharedPreferences) {
        val email: String = emailField.text.toString()
        val password: String = passwordField.text.toString()

        if (email == "admin@gmail.com") {
            // Call login api endpoint for Admin
            val adminId: String = "admin@gmail.com"

            // Set on preferences
            val editor = prefs.edit()
            editor.putString("riderId", adminId)
            editor.apply()

            // Got to admin page
            val intent = Intent(this, AdminPage::class.java)
            startActivity(intent)
        } else {
            // Call login api endpoint for Rider
            // TODO

            // Set on preferences
            val editor = prefs.edit()
            editor.putString("riderId", email)
            editor.apply()

            // Got to main page
            val intent = Intent(this, HomePage::class.java)
            startActivity(intent)
        }
    }
}