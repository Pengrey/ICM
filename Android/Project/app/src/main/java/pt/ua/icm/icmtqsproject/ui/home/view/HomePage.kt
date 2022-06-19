package pt.ua.icm.icmtqsproject.ui.home.view

import android.content.SharedPreferences
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.Button
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
import pt.ua.icm.icmtqsproject.ui.base.ViewModelFactory
import pt.ua.icm.icmtqsproject.ui.home.adapter.HomeAdapter
import pt.ua.icm.icmtqsproject.ui.home.viewmodel.HomePageViewModel
import pt.ua.icm.icmtqsproject.utils.Status


class HomePage : AppCompatActivity() {
    private lateinit var viewModel: HomePageViewModel
    private lateinit var adapter: HomeAdapter

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

                    // Notification
                    Notify
                        .with(this)
                        .content { // this: Payload.Content.Default
                            title = "Work assigned successfully"
                            text = "The delivery you showed interest, was assigned to you."
                        }
                        .show()
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

        // Recycler view api call
        setupViewModel()

        viewModel.getDeliveries().observe(this, Observer {

            val recyclerView: RecyclerView = findViewById(R.id.recyclerView)
            val progressBar: ProgressBar = findViewById(R.id.progressBar)

            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        println("SUCCESS")
                        println("Data retrieved: " + resource.data)
                        recyclerView.adapter = HomeAdapter(resource.data as ArrayList<Delivery>)
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
}

