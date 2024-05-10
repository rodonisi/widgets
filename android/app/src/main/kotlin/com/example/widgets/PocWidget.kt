package com.example.widgets

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import es.antonborri.home_widget.actionStartActivity

class PocWidget : GlanceAppWidget() {

    override val sizeMode: SizeMode = SizeMode.Exact
    override suspend fun provideGlance(context: Context, id: GlanceId) {

        provideContent {
            val data: Preferences = currentState()
            val imagePath = data[stringPreferencesKey("selected_path")]
            println(imagePath)
            Box(
                modifier = GlanceModifier.background(Color.White).padding(16.dp).fillMaxSize()
                    .clickable(onClick = actionStartActivity<MainActivity>(context))
            ) {
                imagePath?.let {
                    val bitmap = BitmapFactory.decodeFile(it)
                    Image(
                        ImageProvider(bitmap),
                        null,
                        modifier = GlanceModifier.fillMaxSize(),
                    )
                } ?: Text("No card selected")

            }
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: Preferences) {


    }
}