package pt.ua.icm.icmtqsproject

import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BlendMode
import android.graphics.BlendModeColorFilter
import android.opengl.Visibility
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.birjuvachhani.locus.Locus
import com.google.zxing.integration.android.IntentIntegrator
import io.karn.notify.Notify
import pt.ua.icm.icmtqsproject.R
import pt.ua.icm.icmtqsproject.data.api.ApiHelper
import pt.ua.icm.icmtqsproject.data.api.RetrofitBuilder
import pt.ua.icm.icmtqsproject.data.model.Delivery
import pt.ua.icm.icmtqsproject.ui.base.ViewModelFactory
import pt.ua.icm.icmtqsproject.ui.home.viewmodel.HomePageViewModel
import pt.ua.icm.icmtqsproject.utils.Status



class DeliveriesTrackingActivity : AppCompatActivity() {
    private lateinit var viewModel: HomePageViewModel
    val deliveryStages : List<String> = listOf("Fetched","Delivered","Finish")
    var stage  = 0
    private lateinit var  myDelivery : Delivery
    private fun setupViewModel() {
        viewModel = ViewModelProviders.of(
            this,
            ViewModelFactory(ApiHelper(RetrofitBuilder.apiService))
        ).get(HomePageViewModel::class.java)
    }

    private fun doPostApi(){
        //TODO do a post to api
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        var result = IntentIntegrator.parseActivityResult(resultCode, data)
        if (result != null) {  doPostApi()  }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_deliveries_tracking)

        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val deliveryStatus: TextView = findViewById(R.id.deliveryStatus)
        val instruction: TextView = findViewById(R.id.instructionContent)
        val tooltip: TextView = findViewById(R.id.tooltip)
        val instructionLabel :TextView = findViewById(R.id.instructionLabel)
        // Finish delivery button
        val finishButton: Button = findViewById(R.id.finishButton)
        //finishButton.background.colorFilter = BlendModeColorFilter(R.color.purple_700, BlendMode.HUE)
        deliveryStatus.text = "Fetching"
        doPostApi()
        finishButton.setOnClickListener {
            // Set on preferences
            if (this::myDelivery.isInitialized)
            when (stage) {
                0->{stage++
                    deliveryStatus.text="In Delivery"

                    finishButton.text = "Deliver"
                    //finishButton.background.colorFilter = BlendModeColorFilter(R.color.green, BlendMode.HUE)
                    tooltip.visibility = View.VISIBLE
                    instruction.text = myDelivery.deliveryAddr
                    instructionLabel.text = "Deliver to:"
                    doPostApi()

                }
                1->{
                    stage++
                    deliveryStatus.text = "Finished"
                    finishButton.text = "Go Back"
                   // finishButton.background.colorFilter = BlendModeColorFilter(R.color.blue, BlendMode.HUE)
                    tooltip.visibility = View.INVISIBLE
                    instruction.visibility = View.INVISIBLE
                    instructionLabel.visibility = View.INVISIBLE
                    val intentIntegrator = IntentIntegrator(this)
                    intentIntegrator.setDesiredBarcodeFormats(listOf(IntentIntegrator.QR_CODE))
                    intentIntegrator.initiateScan()
                }
                2->   {
                    val editor = sharedPreferences.edit()
                    editor.putString("isAssigned", "false")
                    editor.apply()
                    this.finish()
            }}
        }

        setupViewModel()

        viewModel.getDeliveries().observe(this@DeliveriesTrackingActivity, Observer {
            // Display data retrieved from API
            if (!this::myDelivery.isInitialized){
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        if (resource.data?.any { delivery -> delivery.riderId == sharedPreferences.getString("riderId", "") } == true){
                           val delivery : Delivery? = resource.data.find { delivery -> delivery.riderId == sharedPreferences.getString("riderId", "")   }
                            if(delivery != null) {
                                myDelivery = delivery
                                instruction.text = myDelivery.originAddr
                            }
                        }
                    }
                    Status.ERROR -> {
                        println("ERROR")
                    }
                    Status.LOADING -> {
                        println("LOADING")
                    }
                }
            }
        }
        })

    }
}