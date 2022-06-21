package pt.ua.icm.icmtqsproject.ui.home.view

import android.content.Intent
import android.content.SharedPreferences
import android.location.Location
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.ProgressBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.birjuvachhani.locus.Locus
import io.karn.notify.Notify
import pt.ua.icm.icmtqsproject.R
import pt.ua.icm.icmtqsproject.data.api.ApiHelper
import pt.ua.icm.icmtqsproject.data.api.RetrofitBuilder
import pt.ua.icm.icmtqsproject.data.model.Delivery
import pt.ua.icm.icmtqsproject.databinding.ActivityHomePageBinding
import pt.ua.icm.icmtqsproject.DeliveriesTrackingActivity
import pt.ua.icm.icmtqsproject.ui.base.ViewModelFactory
import pt.ua.icm.icmtqsproject.ui.home.adapter.HomeAdapter
import pt.ua.icm.icmtqsproject.ui.home.viewmodel.HomePageViewModel
import pt.ua.icm.icmtqsproject.utils.Status
import java.util.*
import kotlin.collections.ArrayList


class HomePage : AppCompatActivity() {
    private lateinit var viewModel: HomePageViewModel
    private lateinit var adapter: HomeAdapter
    private lateinit var timer: Timer
    private val noDelay = 0L
    private val everyFiveSeconds = 5000L

    private fun setupViewModel() {
        viewModel = ViewModelProviders.of(
            this,
            ViewModelFactory(ApiHelper(RetrofitBuilder.apiService))
        ).get(HomePageViewModel::class.java)
    }

    private fun retrieveList(deliveries: List<Delivery>) {
        adapter.apply {
            notifyDataSetChanged()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Check if Rider is already assigned to work
        val isAssigned = sharedPreferences.getString("isAssigned", "")
        if (isAssigned.equals("true")){
            val intent = Intent(this, DeliveriesTrackingActivity::class.java)
            startActivity(intent)
        }

        val binding : ActivityHomePageBinding =
            DataBindingUtil.setContentView(this, R.layout.activity_home_page)

        // Recycler view api call
        setupViewModel()
        Locus.getCurrentLocation(this) { result ->
            result.location?.let {
                // Recycler View
                viewModel.getDeliveries().observe(this, Observer {

                    val recyclerView: RecyclerView = findViewById(R.id.recyclerView)
                    val progressBar: ProgressBar = findViewById(R.id.progressBar)

                    // Used to get Distance
                    val startPoint = Location("locationA")
                    startPoint.latitude = result.location!!.latitude
                    startPoint.longitude = result.location!!.longitude

                    // Display data retrieved from API
                    it?.let { resource ->
                        when (resource.status) {
                            Status.SUCCESS -> {
                                println("SUCCESS")
                                println("Data retrieved: " + resource.data)
                                recyclerView.adapter = HomeAdapter(resource.data as ArrayList<Delivery>, startPoint)
                                recyclerView.layoutManager = LinearLayoutManager(this)
                                recyclerView.visibility = View.VISIBLE
                                progressBar.visibility = View.GONE
                                retrieveList(resource.data)
                            }
                            Status.ERROR -> {
                                println("ERROR")
                                recyclerView.visibility = View.VISIBLE
                                progressBar.visibility = View.GONE
                                Toast.makeText(this, it.message, Toast.LENGTH_LONG).show()
                                println(it.message)
                            }
                            Status.LOADING -> {
                                println("LOADING")
                                progressBar.visibility = View.VISIBLE
                                recyclerView.visibility = View.GONE
                            }
                        }
                    }
                })

            }
            result.error?.let { /* Received error! */ }
        }

        // Check if rider was assigned on any work
        val timerTask = object : TimerTask() {
            override fun run() {
                runOnUiThread {
                    // Retrieve data from UI
                    viewModel.getDeliveries().observe(this@HomePage, Observer {
                        // Display data retrieved from API
                        it?.let { resource ->
                            when (resource.status) {
                                Status.SUCCESS -> {
                                    println("SUCCESS")
                                    if (resource.data?.any { delivery -> delivery.riderId == sharedPreferences.getString("riderId", "") } == true){
                                        // Notification
                                        Notify
                                            .with(this@HomePage)
                                            .content { // this: Payload.Content.Default
                                                title = "Work assigned successfully"
                                                text = "The delivery you showed interest, was assigned to you."
                                            }
                                            .show()

                                        // Set on preferences
                                        val editor = sharedPreferences.edit()
                                        editor.putString("isAssigned", "true")
                                        editor.apply()

                                        onPause()
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
                    })
                }
            }
        }

        timer = Timer()
        timer.schedule(timerTask, noDelay, everyFiveSeconds)
    }

    override fun onPause() {
        super.onPause()

        timer.cancel()
        timer.purge()
        // Shared Preferences
        val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)

        // Check if Rider is already assigned to work
        val isAssigned = sharedPreferences.getString("isAssigned", "")
        if (isAssigned.equals("true")){
            val intent = Intent(this, DeliveriesTrackingActivity::class.java)
            startActivity(intent)
        }
    }
}

