package com.example.widgets

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.lifecycle.lifecycleScope
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.launch

class PocWidgetConfigurationActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val data = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val gson = GsonBuilder().create()
        val json = data.getString("cards", "")
        val cards: Array<Map<String, String>> = gson.fromJson(
            json,
            object : TypeToken<Array<Map<String, String>>>() {}.type
        )
        println(cards)
        setContent {
            SampleTheme {
                Scaffold {
                    LazyColumn(
                        content = {
                            items(items = cards, itemContent = {
                                Row(modifier = Modifier.fillMaxWidth()) {
                                    Button(onClick = { onItemClick(item = it) }) {
                                        Text(it["name"] ?: "not found")
                                    }
                                }
                            })
                        }
                    )
                }
            }
        }
    }

    fun onItemClick(item: Map<String, String>) {
        val context = this
        lifecycleScope.launch {
            val glanceId =
                GlanceAppWidgetManager(context).getGlanceIds(
                    PocWidget::class.java
                ).last()

            PocWidget().apply {
                updateAppWidgetState(context, glanceId) {
                    it[stringPreferencesKey("selected_path")] = item["content"] ?: ""
                }
                update(context, glanceId)
            }
            setResult(RESULT_OK, intent)
            finish()
        }
    }
}

@Composable
private fun SampleTheme(content: @Composable () -> Unit) {
    val darkTheme = isSystemInDarkTheme()
    val colorScheme = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> darkColorScheme()
        else -> lightColorScheme()
    }
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).apply {
                isAppearanceLightStatusBars = darkTheme
            }
        }
    }

    MaterialTheme(colorScheme = colorScheme, content = content)
}


