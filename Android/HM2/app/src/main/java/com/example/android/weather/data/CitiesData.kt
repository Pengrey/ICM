package com.example.android.weather.data

import com.example.android.weather.R
import com.example.android.weather.model.City

/**
 * City data
 */
object CitiesData {
    fun getCityData(): ArrayList<City> {
        return arrayListOf(
            City(
                id = 1,
                titleResourceId = R.string.aveiro,
            ),
            City(
                id = 2,
                titleResourceId = R.string.porto,
            ),
            City(
                id = 3,
                titleResourceId = R.string.lisboa,
            ),
            City(
                id = 4,
                titleResourceId = R.string.braga,
            ),
            City(
                id = 5,
                titleResourceId = R.string.esmoriz,
            ),
            City(
                id = 6,
                titleResourceId = R.string.espinho,
            ),
            City(
                id = 7,
                titleResourceId = R.string.paramos,
            ),
            City(
                id = 8,
                titleResourceId = R.string.londres,
            ),
            City(
                id = 9,
                titleResourceId = R.string.barcelona,
            ),
            City(
                id = 10,
                titleResourceId = R.string.valadares,
            ),
            City(
                id = 11,
                titleResourceId = R.string.cortegaça,
            )
        )
    }
}
