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
                titleResourceId = R.string.baseball,
            ),
            City(
                id = 2,
                titleResourceId = R.string.badminton,
            ),
            City(
                id = 3,
                titleResourceId = R.string.basketball,
            ),
            City(
                id = 4,
                titleResourceId = R.string.bowling,
            ),
            City(
                id = 5,
                titleResourceId = R.string.cycling,
            ),
            City(
                id = 6,
                titleResourceId = R.string.golf,
            ),
            City(
                id = 7,
                titleResourceId = R.string.running,
            ),
            City(
                id = 8,
                titleResourceId = R.string.soccer,
            ),
            City(
                id = 9,
                titleResourceId = R.string.swimming,
            ),
            City(
                id = 10,
                titleResourceId = R.string.table_tennis,
            ),
            City(
                id = 11,
                titleResourceId = R.string.tennis,
            )
        )
    }
}
