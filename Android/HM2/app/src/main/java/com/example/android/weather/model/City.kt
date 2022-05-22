package com.example.android.weather.model

/**
 * Data model for each row of the RecyclerView
 */
data class City(
    val id: Int,
    val titleResourceId: Int,
    val weatherFor: String
)
