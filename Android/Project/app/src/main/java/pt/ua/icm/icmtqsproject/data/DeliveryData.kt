package pt.ua.icm.icmtqsproject.data

import okhttp3.*
import org.json.JSONObject
import pt.ua.icm.icmtqsproject.R
import pt.ua.icm.icmtqsproject.model.Delivery

class DeliveryData {

    fun getDeliveryList(): List<Delivery> {
        /*return arrayListOf(
            Delivery(
                id = 1,
                titleResourceId = R.string.aveiro,
                weatherFor = getWeather("102742611")
            )

            )*/
        //TODO: How to deal with comm failures?
        return getDeliveries()
        //return arrayListOf(Delivery(0,"","","",1.1,2.2,""))
    }

// UNTESTED!!!

    private fun getDeliveries(): List<Delivery> {
        val client = OkHttpClient()
        val request = Request.Builder()
            .url(R.string.API_URL.toString()+"/deliveries")
            .get()
            .build()
        return parseResponse(client.newCall(request).execute())
    }

    private fun parseResponse(response: Response): List<Delivery> {
        val deliveriesJSONArray = JSONObject(response.body!!.string()).getJSONArray("")

       var  result = emptyList<Delivery>().toMutableList()
        for (i in 0 until deliveriesJSONArray.length()) {
            result[i]= Delivery(deliveriesJSONArray.getJSONObject(i).getInt("id"),
                deliveriesJSONArray.getJSONObject(i).getString("customerId"),
                deliveriesJSONArray.getJSONObject(i).getString("originAddr"),
                deliveriesJSONArray.getJSONObject(i).getString("deliveryAddr"),
                deliveriesJSONArray.getJSONObject(i).getDouble("lat"),
                deliveriesJSONArray.getJSONObject(i).getDouble("lon"),"SOME_STATE") // TODO verify state with rodrigo

        }
        return result.toList()
    }
}

