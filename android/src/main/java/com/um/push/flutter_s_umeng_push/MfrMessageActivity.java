package com.um.push.flutter_s_umeng_push;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.umeng.message.UmengNotifyClick;
import com.umeng.message.entity.UMessage;

import androidx.annotation.Nullable;

/**
 * @author sujialong
 * @date 2022/11/2
 */
class MfrMessageActivity extends Activity {

    private static final String TAG = "MfrMessageActivity";

    private final UmengNotifyClick mNotificationClick = new UmengNotifyClick() {

        @Override
        protected void onMessage(UMessage uMessage) {
            final String body = uMessage.getRaw().toString();
            Log.d(TAG, "body: " + body);
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mNotificationClick.onCreate(this, getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        mNotificationClick.onNewIntent(intent);
    }
}
