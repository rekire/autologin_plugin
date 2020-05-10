package eu.rekisoft.flutter.autologin

import android.content.Intent
/*
class ActivityResultSpy : ActivityResultListener, ActivityResultObservable {
    private val listeners = mutableMapOf<Int, MutableList<ActivityResultListener>>()

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        listeners[requestCode]?.forEach {
            it.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun addActivityResultListener(requestCode: Int, activityResultListener: ActivityResultListener) {
        listeners.getOrPut(requestCode) { mutableListOf() } += activityResultListener
    }

    override fun removeActivityResultListener(activityResultListener: ActivityResultListener) {
        val emptyLists = mutableListOf<Int>()
        listeners.forEach { (code, listeners) ->
            listeners -= activityResultListener
            if (listeners.isEmpty()) {
                emptyLists += code
            }
        }
        emptyLists.forEach {
            listeners.remove(it)
        }
    }

    fun clear() = listeners.clear()
}

interface ActivityResultListener {
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?)
}

interface ActivityResultObservable {
    fun addActivityResultListener(requestCode: Int, activityResultListener: ActivityResultListener)
    fun removeActivityResultListener(activityResultListener: ActivityResultListener)
}

fun ActivityResultObservable.addActivityResultListener(requestCode: Int, listener: ActivityResultListener.(resultCode: Int, data: Intent?) -> Unit): ActivityResultListener {
    val realListener = object : ActivityResultListener {
        override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
            listener.invoke(this, requestCode, data)
        }
    }
    addActivityResultListener(requestCode, realListener)
    return realListener
}*/
