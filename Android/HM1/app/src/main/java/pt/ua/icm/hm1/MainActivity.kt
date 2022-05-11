package pt.ua.icm.hm1

import android.app.Dialog
import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.Window
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton

class MainActivity : AppCompatActivity() {

    // Values
    private val zero: String = "0"
    private val one: String = "1"
    private val two: String = "2"
    private val three: String = "3"
    private val four: String = "4"
    private val five: String = "5"
    private val six: String = "6"
    private val seven: String = "7"
    private val eight: String = "8"
    private val nine: String = "9"

    private val plusVal = "+"
    private val hashtag= "#"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        // Char buttons
        val button0: Button = findViewById(R.id.button_0)
        val button1: Button = findViewById(R.id.button_1)
        val button2: Button = findViewById(R.id.button_2)
        val button3: Button = findViewById(R.id.button_3)
        val button4: Button = findViewById(R.id.button_4)
        val button5: Button = findViewById(R.id.button_5)
        val button6: Button = findViewById(R.id.button_6)
        val button7: Button = findViewById(R.id.button_7)
        val button8: Button = findViewById(R.id.button_8)
        val button9: Button = findViewById(R.id.button_9)
        val buttonPlus: Button = findViewById(R.id.button_plus)
        val buttonHash: Button = findViewById(R.id.button_hashtag)

        // Speed dial buttons
        val buttons0: Button = findViewById(R.id.button_speed0)
        val buttons1: Button = findViewById(R.id.button_speed1)
        val buttons2: Button = findViewById(R.id.button_speed2)

        // Action buttons
        val buttonCall: ImageButton = findViewById(R.id.button_call)
        val buttonDelete: ImageButton = findViewById(R.id.button_delete)

        // Number view
        val numberViewCurrentNumber: Button = findViewById(R.id.numberView)

        // Char buttons
        button0.setOnClickListener {
            onCharButtonClick(zero, numberViewCurrentNumber)
        }

        button1.setOnClickListener {
            onCharButtonClick(one, numberViewCurrentNumber)
        }

        button2.setOnClickListener {
            onCharButtonClick(two, numberViewCurrentNumber)
        }

        button3.setOnClickListener {
            onCharButtonClick(three, numberViewCurrentNumber)
        }

        button4.setOnClickListener {
            onCharButtonClick(four, numberViewCurrentNumber)
        }

        button5.setOnClickListener {
            onCharButtonClick(five, numberViewCurrentNumber)
        }

        button6.setOnClickListener {
            onCharButtonClick(six, numberViewCurrentNumber)
        }

        button7.setOnClickListener {
            onCharButtonClick(seven, numberViewCurrentNumber)
        }

        button8.setOnClickListener {
            onCharButtonClick(eight, numberViewCurrentNumber)
        }

        button9.setOnClickListener {
            onCharButtonClick(nine, numberViewCurrentNumber)
        }

        buttonPlus.setOnClickListener {
            onCharButtonClick(plusVal, numberViewCurrentNumber)
        }

        buttonHash.setOnClickListener {
            onCharButtonClick(hashtag, numberViewCurrentNumber)
        }

        // Speed dial buttons
        buttons0.setOnLongClickListener{
            onLongSpeedButtonClick(buttons0)
            true
        }

        buttons1.setOnLongClickListener{
            onLongSpeedButtonClick(buttons1)
            true
        }

        buttons2.setOnLongClickListener{
            onLongSpeedButtonClick(buttons2)
            true
        }

        // Action buttons
        buttonDelete.setOnClickListener {
            onDelButtonClick(numberViewCurrentNumber)
        }

    }
    // On char button click func
    private fun onCharButtonClick(char: String, numberViewCurrentNumber: Button) {

        var currentValue: String = numberViewCurrentNumber.text.toString()

        // If value is empty the start with new char, if not just append
        if (currentValue.isEmpty()){
            currentValue = char
        }else{
            if(currentValue.length <= 13)
                currentValue = StringBuilder().append(currentValue).append(char).toString()
        }

        numberViewCurrentNumber.text = currentValue
    }

    // On delete button click func
    private fun onDelButtonClick(numberViewCurrentNumber: Button) {

        var currentValue: String = numberViewCurrentNumber.text.toString()

        // If value is not empty then delete value
        if (currentValue.isNotEmpty()){
                currentValue = currentValue.substring(0,currentValue.length - 1)
        }

        numberViewCurrentNumber.text = currentValue
    }

    // On long speed button click func
    private fun onLongSpeedButtonClick(speedButton: Button) {
        // TODO persistence

        val dialog = Dialog(this)
        dialog.setContentView(R.layout.dialog_add_sd)
        val userName = dialog.findViewById(R.id.username) as EditText
        val phoneNumber = dialog.findViewById(R.id.phoneNumber) as EditText
        val saveBtn = dialog.findViewById(R.id.saveBtn) as Button
        val cancelBtn = dialog.findViewById(R.id.canBtn) as Button
        saveBtn.setOnClickListener {
            val names = userName.text.toString().split(" ")
            if(names.size >= 2){
                speedButton.text = StringBuilder().append(names[0][0]).append(".").append(names[1][0])
            }else if (names.size == 1 && userName.text.toString().isNotBlank()){
                speedButton.text = userName.text.toString()[0].toString()
            }
            dialog.dismiss()
        }
        cancelBtn.setOnClickListener { dialog.dismiss() }
        dialog.show()

    }
}