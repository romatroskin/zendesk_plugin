package com.cygnati.zendesk.zendesk_plugin

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import androidx.annotation.NonNull
import com.zendesk.logger.Logger
import com.zendesk.service.ErrorResponse
import com.zendesk.service.ZendeskCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import zendesk.answerbot.AnswerBot
import zendesk.answerbot.AnswerBotEngine
import zendesk.core.AnonymousIdentity
import zendesk.core.JwtIdentity
import zendesk.core.Zendesk
import zendesk.messaging.Engine
import zendesk.messaging.MessagingActivity
import zendesk.support.Support
import zendesk.support.SupportEngine
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.guide.ViewArticleActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity

/** ZendeskPlugin */
public class ZendeskPlugin() : FlutterPlugin, MethodCallHandler, ActivityAware {
    private val TAG = "ZendeskPlugin"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zendesk_plugin")
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "zendesk_plugin")
            val plugin = ZendeskPlugin()
            plugin.activity = registrar.activity()
            channel.setMethodCallHandler(plugin)
        }
    }

    public var activity: Activity? = null

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "init" -> {
                init(call.argument<String>("zendeskUrl"), call.argument<String>("appId"), call.argument<String>("clientId"))
                result.success(null)
            }
            "setAnonymousIdentity" -> {
                setAnonymousIdentity(call.argument<String>("name"), call.argument<String>("email"))
                result.success(null)
            }
            "setJWTIdentity" -> {
                setJWTIdentity(call.argument<String>("jwtIdentifier"))
                result.success(null)
            }
            "registerPushProvider" -> {
                registerPushProvider(call.argument<String>("instanceId"));
                result.success(null)
            }
            "showMessagingActivity" -> {
                showMessagingActivity(call.argument<Boolean>("withAnswerBotEngine"), call.argument<Boolean>("withSupportEngine"))
                result.success(null)
            }
            "showHelpCenterActivity" -> {
                showHelpCenterActivity(call.argument<Boolean>("withAnswerBotEngine"), call.argument<Boolean>("withSupportEngine"))
                result.success(null)
            }
            "showViewArticleActivity" -> {
                showViewArticleActivity(call.argument<String>("articleId"), call.argument<Boolean>("withAnswerBotEngine"), call.argument<Boolean>("withSupportEngine"))
                result.success(null)
            }
            "showRequestActivity" -> {
                showRequestActivity()
                result.success(null)
            }
            "showRequestListActivity" -> {
                showRequestListActivity()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun init(@NonNull zendeskUrl: String?, @NonNull appId: String?, @NonNull clientId: String?) {
        Logger.setLoggable(true)
        if (zendeskUrl != null && appId != null) {
            Zendesk.INSTANCE.init(activity!!, zendeskUrl, appId, clientId)
            Support.INSTANCE.init(Zendesk.INSTANCE);
            AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE)
        }
    }

    private fun setAnonymousIdentity(@NonNull name: String?, @NonNull email: String?) {
        val identity = AnonymousIdentity.Builder().withNameIdentifier(name).withEmailIdentifier(email).build();
        Zendesk.INSTANCE.setIdentity(identity)

    }

    private fun setJWTIdentity(jwdIdentifier: String?) {
        val identity = JwtIdentity(jwdIdentifier)
        Zendesk.INSTANCE.setIdentity(identity)
    }

    private fun registerPushProvider(instanceId: String?) {
        instanceId?.let {
            Zendesk.INSTANCE.provider()?.pushRegistrationProvider()?.registerWithDeviceIdentifier(
                    it, object: ZendeskCallback<String>() {
                override fun onSuccess(p0: String?) {
                    Log.d("ZENDESK", "Push Provider Registered Successfully")
                }

                override fun onError(p0: ErrorResponse?) {
                    Log.d("ZENDESK", p0.toString())
                }
            })
        };
    }

    private fun showMessagingActivity(@NonNull withAnswerBotEngine: Boolean?, @NonNull withSupportEngine: Boolean?) {
        val engines = mutableListOf<Engine>()
        if (withAnswerBotEngine!!)
            AnswerBotEngine.engine()?.let { engines.add(it) }
        if (withSupportEngine!!)
            engines.add(SupportEngine.engine())

        MessagingActivity.builder().withEngines(engines).show(activity!!)
    }

    private fun showHelpCenterActivity(@NonNull withAnswerBotEngine: Boolean?, @NonNull withSupportEngine: Boolean?) {
        val engines = mutableListOf<Engine>()
        if (withAnswerBotEngine!!)
            AnswerBotEngine.engine()?.let { engines.add(it) }
        if (withSupportEngine!!)
            engines.add(SupportEngine.engine())

        HelpCenterActivity.builder().withEngines(engines).show(activity!!)
    }

    private fun showViewArticleActivity(@NonNull articleId: String?, @NonNull withAnswerBotEngine: Boolean?, @NonNull withSupportEngine: Boolean?) {
        val engines = mutableListOf<Engine>()
        if (withAnswerBotEngine!!)
            AnswerBotEngine.engine()?.let { engines.add(it) }
        if (withSupportEngine!!)
            engines.add(SupportEngine.engine())

        articleId?.let { ViewArticleActivity.builder(it.toLong()).withEngines(engines).show(activity!!) }
    }

    private fun showRequestActivity() {
        RequestActivity.builder().show(activity!!)
    }

    private fun showRequestListActivity() {
        RequestListActivity.builder().show(activity!!)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Zendesk.INSTANCE.provider()?.pushRegistrationProvider()?.unregisterDevice(object: ZendeskCallback<Void>(){
            override fun onSuccess(p0: Void?) {
                Log.d("ZENDESK", "Push Provider Unregistered Successfully")
            }

            override fun onError(p0: ErrorResponse?) {
                Log.d("ZENDESK", p0.toString())
            }
        })
    }
}
