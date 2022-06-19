package pt.ua.icm.icmtqsproject.data.api

class ApiHelper(private val apiService: ApiService) {

    suspend fun getDeliveries() = apiService.getDeliveries()

    suspend fun sendBid() = apiService.sendBid()
}