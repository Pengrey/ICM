package com.example.android.weather.data

import com.example.android.weather.R
import com.example.android.weather.model.City
import okhttp3.*
import org.json.JSONArray
import org.json.JSONObject


/**
 * City data
 */
object CitiesData {
    fun getCityData(): ArrayList<City> {
        return arrayListOf(
            City(
                id = 1,
                titleResourceId = R.string.aveiro,
                weatherFor = getWeather("102742611")
            ),
            City(
                id = 2,
                titleResourceId = R.string.porto,
                weatherFor = getWeather("102735943")
            ),
            City(
                id = 3,
                titleResourceId = R.string.lisboa,
                weatherFor = getWeather("102267057")
            ),
            City(
                id = 4,
                titleResourceId = R.string.braga,
                weatherFor = getWeather("101275339")
            ),
            City(
                id = 5,
                titleResourceId = R.string.esmoriz,
                weatherFor = getWeather("102739915")
            ),
            City(
                id = 6,
                titleResourceId = R.string.espinho,
                weatherFor = getWeather("102739915")
            ),
            City(
                id = 7,
                titleResourceId = R.string.paramos,
                weatherFor = getWeather("102737949")
            ),
            City(
                id = 8,
                titleResourceId = R.string.londres,
                weatherFor = getWeather("102739915")
            ),
            City(
                id = 9,
                titleResourceId = R.string.barcelona,
                weatherFor = getWeather("103128760")
            ),
            City(
                id = 10,
                titleResourceId = R.string.valadares,
                weatherFor = getWeather("102740519")
            ),
            City(
                id = 11,
                titleResourceId = R.string.cortegaça,
                weatherFor = getWeather("102740519")
            )
        )
    }

    private fun getWeather(cityId: String): String {
        val client = OkHttpClient()
        val request = Request.Builder()
            .url("https://foreca-weather.p.rapidapi.com/forecast/daily/$cityId?alt=0&tempunit=C&windunit=MS&periods=8&dataset=standard")
            .get()
            .addHeader("X-RapidAPI-Host", "foreca-weather.p.rapidapi.com")
            .addHeader("X-RapidAPI-Key", "422282fb07msh7d426d35972d527p17359bjsnf4da7ac31769")
            .build()
        return parseResponse(client.newCall(request).execute())
    }

    private fun parseResponse(response: Response): String {
        val daysJSONArray = JSONObject(response.body()!!.string()).getJSONArray("forecast")

        var result = ""
        for (i in 0 until daysJSONArray.length()) {
            val day = daysJSONArray.getJSONObject(i)
            result += "Day: " + day.get("date") + "\n\tMin: " + day.get("minTemp") + "\n\tMax: " + day.get("maxTemp") + "\n\n"
        }
        return result
    }
}

