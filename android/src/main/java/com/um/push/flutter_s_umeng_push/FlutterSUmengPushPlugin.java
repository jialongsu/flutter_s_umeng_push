package com.um.push.flutter_s_umeng_push;

import android.app.Notification;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.PushAgent;
import com.umeng.message.UmengMessageHandler;
import com.umeng.message.UmengNotificationClickHandler;
import com.umeng.message.api.UPushAliasCallback;
import com.umeng.message.api.UPushRegisterCallback;
import com.umeng.message.api.UPushSettingCallback;
import com.umeng.message.api.UPushTagCallback;
import com.umeng.message.common.UPLog;
import com.umeng.message.common.inter.ITagManager;
import com.umeng.message.entity.UMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterSUmengPushPlugin */
public class FlutterSUmengPushPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  private static final String TAG = "UPush";

  private final Handler mHandler = new Handler(Looper.getMainLooper());

  private Context mContext = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_s_umeng_push");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method){
      case "umInit":
        umInit(call, result);
        break;
      case "register":
        register(result);
        break;
      case "getDeviceToken":
        getDeviceToken(call, result);
        break;
      case "enable":
        setPushEnable(call, result);
        break;
      case "setAlias":
        setAlias(call, result);
        break;
      case "removeAlias":
        removeAlias(call, result);
        break;
      case "addTag":
        addTags(call, result);
        break;
      case "removeTag":
        removeTags(call, result);
        break;
      case "getTags":
        getTags(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void umInit(MethodCall call, final Result result) {
    Map<String, Object> params = call.arguments();
    final Map<String, Object> res = new HashMap<>();
    String appKey = (String) params.get("appKey");
    String messageSecret = (String) params.get("messageSecret");
    String channel = (String) params.get("channel");
    Boolean logEnabled = (Boolean) params.get("logEnabled");
    Boolean notificationOnForeground = (Boolean) params.get("notificationOnForeground");
    UMConfigure.preInit(mContext, appKey, channel);
    UMConfigure.init(mContext, appKey, channel, UMConfigure.DEVICE_TYPE_PHONE, messageSecret);
    UMConfigure.setLogEnabled(logEnabled != null ? logEnabled : false);
    // 设置App处于前台时是否显示通知
    PushAgent.getInstance(mContext).setNotificationOnForeground(Boolean.TRUE.equals(notificationOnForeground));
    //注册推送
    PushAgent.getInstance(mContext).register(new UPushRegisterCallback() {

      @Override
      public void onSuccess(String deviceToken) {
        //注册成功后返回deviceToken，deviceToken是推送消息的唯一标志
        res.put("code", "200");
        res.put("msg", "注册成功 deviceToken:" + deviceToken);
        result.success(res);
      }

      @Override
      public void onFailure(String errCode, String errDesc) {
        result.error(errCode, "'error'" ,errDesc);
      }
    });
  }

  private void register(final Result result) {
    // 收到消息回调
    UmengMessageHandler messageHandler = new UmengMessageHandler() {
      @Override
      public Notification getNotification(Context context, final UMessage uMessage) {
        invokeMethodOnMainHandler("onReceiveNotification", groupInvokeMethodArgs(uMessage));
        return super.getNotification(context, uMessage);
      }

      @Override
      public void dealWithCustomMessage(Context context, final UMessage uMessage) {
        super.dealWithCustomMessage(context, uMessage);
        invokeMethodOnMainHandler("onMessage", groupInvokeMethodArgs(uMessage));
      }
    };
    PushAgent.getInstance(mContext).setMessageHandler(messageHandler);
    // 点击消息回调
    UmengNotificationClickHandler clickHandler = new UmengNotificationClickHandler() {

      @Override
      public void launchApp(Context context, UMessage uMessage) {
        super.launchApp(context, uMessage);
        invokeMethodOnMainHandler("onOpenNotification", groupInvokeMethodArgs(uMessage));
      }

      @Override
      public void openUrl(Context context, UMessage uMessage) {
        super.openUrl(context, uMessage);
        invokeMethodOnMainHandler("onOpenNotification", groupInvokeMethodArgs(uMessage));
      }

      @Override
      public void openActivity(Context context, UMessage uMessage) {
        super.openActivity(context, uMessage);
        invokeMethodOnMainHandler("onOpenNotification", groupInvokeMethodArgs(uMessage));
      }

      @Override
      public void dismissNotification(Context context, UMessage uMessage) {
        super.dismissNotification(context, uMessage);
        invokeMethodOnMainHandler("onOpenNotification", groupInvokeMethodArgs(uMessage));
      }
      @Override
      public void dealWithCustomAction(Context context, UMessage uMessage) {
        super.dealWithCustomAction(context, uMessage);
        invokeMethodOnMainHandler("onOpenNotification", groupInvokeMethodArgs(uMessage));
      }
    };
    PushAgent.getInstance(mContext).setNotificationClickHandler(clickHandler);
    PushAgent.getInstance(mContext).register(new UPushRegisterCallback() {
      @Override
      public void onSuccess(final String deviceToken) {
        UPLog.i(TAG, "register success deviceToken:" + deviceToken);
        invokeMethodOnMainHandler("onToken", deviceToken);
      }

      @Override
      public void onFailure(String s, String s1) {
        UPLog.i(TAG, "register failure s:" + s + " s1:" + s1);
      }
    });
    executeOnMain(result, null);
  }

  private void getDeviceToken(MethodCall call, Result result) {
    result.success(PushAgent.getInstance(mContext).getRegistrationId());
  }

  private void setPushEnable(MethodCall call, Result result) {
    final boolean enable = Boolean.TRUE.equals(call.arguments());
    UPushSettingCallback callback = new UPushSettingCallback() {
      @Override
      public void onSuccess() {
        UPLog.i(TAG, "setPushEnable success:" + enable);
      }

      @Override
      public void onFailure(String s, String s1) {
        UPLog.i(TAG, "setPushEnable failure:" + enable);
      }
    };
    if (enable) {
      PushAgent.getInstance(mContext).enable(callback);
    } else {
      PushAgent.getInstance(mContext).disable(callback);
    }
    executeOnMain(result, null);
  }

  private void setAlias(MethodCall call, final Result result) {
    String alias = getParam(call, result, "alias");
    String type = getParam(call, result, "type");
    PushAgent.getInstance(mContext).setAlias(alias, type, new UPushAliasCallback() {
      @Override
      public void onMessage(final boolean b, String s) {
        UPLog.i(TAG, "onMessage:" + b + " s:" + s);
        executeOnMain(result, b);
      }
    });
  }

  private void removeAlias(MethodCall call, final Result result) {
    String alias = getParam(call, result, "alias");
    String type = getParam(call, result, "type");
    PushAgent.getInstance(mContext).deleteAlias(alias, type, new UPushAliasCallback() {
      @Override
      public void onMessage(final boolean b, String s) {
        UPLog.i(TAG, "onMessage:" + b + " s:" + s);
        executeOnMain(result, b);
      }
    });
  }

  private void addTags(MethodCall call, final Result result) {
    List<String> arguments = call.arguments();
    String[] tags = new String[arguments.size()];
    arguments.toArray(tags);
    PushAgent.getInstance(mContext).getTagManager().addTags(new UPushTagCallback<ITagManager.Result>() {
      @Override
      public void onMessage(final boolean b, ITagManager.Result ret) {
        executeOnMain(result, b);
      }
    }, tags);
  }

  private void removeTags(MethodCall call, final Result result) {
    List<String> arguments = call.arguments();
    String[] tags = new String[arguments.size()];
    arguments.toArray(tags);
    PushAgent.getInstance(mContext).getTagManager().deleteTags(new UPushTagCallback<ITagManager.Result>() {
      @Override
      public void onMessage(final boolean b, ITagManager.Result ret) {
        executeOnMain(result, b);
      }
    }, tags);
  }

  private void getTags(MethodCall call, final Result result) {
    PushAgent.getInstance(mContext).getTagManager().getTags(new UPushTagCallback<List<String>>() {
      @Override
      public void onMessage(final boolean b, final List<String> list) {
        if (b) {
          executeOnMain(result, list);
        } else {
          executeOnMain(result, Collections.emptyList());
        }
      }
    });
  }

  private void invokeMethodOnMainHandler(final String method, final Object arguments) {
    mHandler.post(new Runnable() {
      @Override
      public void run() {
        try {
          if (channel != null) {
            channel.invokeMethod(method, arguments);
          }
        } catch (Throwable e) {
          Log.i("'error'", e.getMessage());
          e.printStackTrace();
        }
      }
    });
  }

  private String groupInvokeMethodArgs(UMessage uMessage) {
    JSONObject raw = uMessage.getRaw();
    try {
      if(!uMessage.extra.isEmpty()) {
        JSONObject extra = new JSONObject();
        for (String key: uMessage.extra.keySet()){
          extra.put(key, uMessage.extra.get(key));
        }
        raw.put("extra", extra);
      }
    } catch (JSONException e) {
      e.printStackTrace();
    }
    return raw.toString();
  }

  public static <T> T getParam(MethodCall methodCall, MethodChannel.Result result, String param) {
    T value = methodCall.argument(param);
    if (value == null) {
      result.error("missing param", "cannot find param:" + param, 1);
    }
    return value;
  }

  private void executeOnMain(final Result result, final Object param) {
    if (Looper.myLooper() == Looper.getMainLooper()) {
      try {
        result.success(param);
      } catch (Throwable throwable) {
        throwable.printStackTrace();
      }
      return;
    }
    mHandler.post(new Runnable() {
      @Override
      public void run() {
        try {
          result.success(param);
        } catch (Throwable throwable) {
          throwable.printStackTrace();
        }
      }
    });
  }

}
