package pt.ua.icm.icmtqsproject.ui

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.ImageView
import com.google.zxing.BarcodeFormat
import com.journeyapps.barcodescanner.BarcodeEncoder
import pt.ua.icm.icmtqsproject.R

class AdminPage : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_admin_page)

        val encoder = BarcodeEncoder()
        val qrcodeImage: ImageView = findViewById(R.id.qrcodeImage)
        qrcodeImage.setImageBitmap(encoder.encodeBitmap("https://62af0f88b735b6d16a4c2158.mockapi.io/api/v1/", BarcodeFormat.QR_CODE, 400, 400))
    }
}