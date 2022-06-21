/*
 * Copyright (c) 2021 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.weather

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.android.weather.data.CitiesData
import com.example.android.weather.model.City

class CitiesViewModel : ViewModel() {

    private var _currentCity: MutableLiveData<City> = MutableLiveData<City>()
    val currentCity: LiveData<City>
        get() = _currentCity

    private var _weatherData: ArrayList<City> = ArrayList()
    val weatherData: ArrayList<City>
        get() = _weatherData

    init {
        // Initialize the weather data.
        _weatherData = CitiesData.getCityData()
        _currentCity.value = _weatherData[0]
    }

    fun updateCurrentCity(city: City) {
        _currentCity.value = city
    }
}
