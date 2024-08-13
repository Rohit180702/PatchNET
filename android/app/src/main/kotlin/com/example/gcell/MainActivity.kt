package com.example.gcell


import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.telephony.CellInfo
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val channel = "cell_info_channel"
    private val locationPermissionCode = 1

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "getCellInfo") {
                if (checkLocationPermission()) {
                    getCellInfo(result)
                } else {
                    requestLocationPermission()
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun checkLocationPermission(): Boolean {
        val permission = android.Manifest.permission.ACCESS_FINE_LOCATION
        return PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(this, permission)
    }

    private fun requestLocationPermission() {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), locationPermissionCode)
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private fun getCellInfo(result: MethodChannel.Result) {
        if (checkLocationPermission()) {
            try {
                val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                val cellInfoList: List<CellInfo>? = telephonyManager.allCellInfo
                if (cellInfoList != null && cellInfoList.isNotEmpty()) {
                    val cellInfo = cellInfoList[0]
                    val cellInfoMap: String = when (cellInfo) {
                        is CellInfoGsm -> {
                            val cellIdentity = cellInfo.cellIdentity
                            val mcc = cellIdentity.mccString ?: "Unknown"
                            val mnc = cellIdentity.mncString ?: "Unknown"
                            val tac = cellIdentity.lac ?: "Unknown"
                            val cid = cellIdentity.cid ?: "Unknown"
                            val signalStrength = (cellInfo as CellInfoGsm).cellSignalStrength.dbm
                            val simOperatorName = telephonyManager.simOperatorName ?: "Unknown"

                            // Convert to a JSON string
                            val jsonObject = JSONObject()
                            jsonObject.put("mnc", mnc)
                            jsonObject.put("mcc", mcc)
                            jsonObject.put("lac", tac)
                            jsonObject.put("cid", cid)
                            jsonObject.put("signal_strength", signalStrength)
                            jsonObject.put("sim_operator_name", simOperatorName)
                            jsonObject.toString()
                        }
                        is CellInfoLte -> {
                            val cellIdentity = cellInfo.cellIdentity
                            val mcc = cellIdentity.mccString ?: "Unknown"
                            val mnc = cellIdentity.mncString ?: "Unknown"
                            val tac = cellIdentity.tac?.toString() ?: "Unknown"
                            val ci = cellIdentity.ci?.toString() ?: "Unknown"
                            val signalStrength = (cellInfo as CellInfoLte).cellSignalStrength.dbm
                            val simOperatorName = telephonyManager.simOperatorName ?: "Unknown"

                            // Convert to a JSON string
                            val jsonObject = JSONObject()
                            jsonObject.put("mnc", mnc)
                            jsonObject.put("mcc", mcc)
                            jsonObject.put("tac", tac)
                            jsonObject.put("cid", ci)
                            jsonObject.put("signal_strength", signalStrength)
                            jsonObject.put("sim_operator_name", simOperatorName)
                            jsonObject.toString()
                        }
                        else -> "{}" // Return an empty JSON object for other cases
                    }
                    result.success(cellInfoMap)
                }
                // Handle the case when no GSM or LTE cell info is available or other errors.
            } catch (e: Exception) {
                result.error("Error", e.message, null)
            }
        } else {
            // Handle the case when permission is not granted.
            result.error("Permission Denied", "Location permission is not granted.", null)
        }
    }
}
