package pt.ua.icm.icmtqsproject.data.api

import pt.ua.icm.icmtqsproject.data.model.Delivery
import retrofit2.http.GET
import retrofit2.http.POST

interface ApiService {

    @GET("deliveries")
    suspend fun getDeliveries(): List<Delivery>

    @POST("deliveries/bid")
    suspend fun sendBid(): String
}