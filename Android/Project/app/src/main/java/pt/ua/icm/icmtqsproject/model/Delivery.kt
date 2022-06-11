package pt.ua.icm.icmtqsproject.model

data class Delivery   (
    val id: Int,
    val customerId:String,
    val originAddr:String,
    val deliveryAddr:String,
    val lat:Double,
    val lon:Double,


    // Is this correct here?
    val _state:String
)