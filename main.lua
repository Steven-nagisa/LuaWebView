actionbar_color=4278249547 
require "import"
import "android.view.*"
import "android.widget.*"
import "android.webkit.*"
import "android.net.*"
import "android.content.*"
import "android.app.*"
import "android.webkit.*"
import "android.graphics.*"
import "android.graphics.drawable.*"
import "android.os.*"

function sleep(n)
  local t0 = os.clock()
  while os.clock() - t0 <= n do end
end
sleep(1)

obj=luajava.bindClass("com.android.internal.R$dimen")()
h=activity.getResources().getDimensionPixelSize( obj.status_bar_height )--获取状态栏高度
wm=activity.getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
win={
  width = wm.getDefaultDisplay().getWidth(),
  height = wm.getDefaultDisplay().getHeight()
}--获取屏幕的高度和宽度
lp=WindowManager.LayoutParams()
lp.format = PixelFormat.RGBA_8888
lp.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
lp.type=WindowManager.LayoutParams.TYPE_PHONE
lp.width=WindowManager.LayoutParams.WRAP_CONTENT
lp.height=WindowManager.LayoutParams.WRAP_CONTENT
lp.gravity=Gravity.RIGHT
function destroy() --退出
  wm.removeView(mylayout)
  print("已退出")
end
layout={
  LinearLayout ,
  id="mylayout",
  Orientation=0,
  layout_width='fill_parent',
  layout_height='fill_parent',
  --width=200, height=200,通过设置layout宽高不能填充，scaleTyle不适用
}
lastX=0
lastY=0
vx=0
vy=0
imgs={
  right = loadbitmap("http://pzhsz.ltd/index.jpg"), --吸附在右边的图片
  left = loadbitmap("http://pzhsz.ltd/index.jpg"), --吸附在左边的图片
  center =loadbitmap("https://mynagisa.com/touxiang.png") --获得焦点（中间）的图片
}
function animation(sx, ex, step, y) --自动吸附的函数，sx是开始的X坐标，ex是结束的坐标，step是步长，可以调整改变吸附的移动速度
  lp.y=y --设置高度
  for i=sx,ex,step do
    --[[while (sx-ex) < 1 do
if sx > ex then
sx = sx - 1
else
sx = sx + 1
end 用while容易陷入死循环]]
    lp.gravity=Gravity.LEFT|Gravity.TOP --调整悬浮窗口至左上角
    lp.x=i --移动的相对位置
    wm.updateViewLayout(mylayout,lp)
  end
end
lay=loadlayout(layout)
imgshow=ImageView(activity)
--imgshow.setScaleType("matrix")
imgshow.setMaxHeight(200)
imgshow.setMaxWidth(200)
imgshow.setAdjustViewBounds(true)
--imgs.right.setTileModeXY(TileMode.REPEAT , TileMode.REPEAT )
--imgshow.setPadding(3,0,0,0)
--imgshow.setBackground("/sdcard/DCIM/icon/fb.png")
imgshow.setImageBitmap(imgs.right)--初始化在右边界
imgshow.setOnTouchListener(View_OnTouchListener {onTouch = function(v,e) --设置触摸事件
    ry=e.getRawY()--获取触摸绝对Y位置
    rx=e.getRawX()--获取触摸绝对X位置
    --print(math.ceil(rx)) rx是个float数，for需要整数，此处调试
    if e.getAction() == MotionEvent.ACTION_DOWN then --获取焦点
      imgshow.setImageBitmap(imgs.center) --获取焦点，改变图片为center
      start = e.getEventTime() --按下的时间
      vy=ry-e.getY() --获取视图的Y位置
      vx=rx-e.getX()--获取视图的X位置
      lastY=ry --记录按下的Y位置
      lastX=rx --记录按下的X位置
    elseif e.getAction() == MotionEvent.ACTION_MOVE then --移动中
      lp.gravity=Gravity.LEFT|Gravity.TOP --调整悬浮窗口至左上角
      lp.x=vx+(rx-lastX)--移动的相对位置
      lp.y=vy+(ry-lastY)-h--移动的相对位置
      wm.updateViewLayout(mylayout,lp)--调整悬浮窗至指定的位置
    elseif e.getAction() == MotionEvent.ACTION_UP then --失去焦点
      if (e.getEventTime() - start) <= 65 then --如果触摸时间小于65毫秒就销毁悬浮窗
        wm.removeView(mylayout)
        activity.finish()
        print("已结束应用程序！")
      end
      if rx > win.width/2 then --以中轴判断失去焦点时的触摸点的X坐标
        animation(math.ceil(rx), win.width-10, 2, math.ceil(ry)) --调用吸附函数
        imgshow.setImageBitmap(imgs.right) --更新图片
      else
        animation(rx, 1, -2, ry)
        imgshow.setImageBitmap(imgs.left)
      end
    end
    return true
  end
})
lay.addView(imgshow)
wm.addView(lay,lp )


if yjms==nil then
  layout={LuaWebView;
    id="mWebView",
  };
else
  layout={FrameLayout;

    {LuaWebView;
      id="mWebView",
      layout_width="fill",
      layout_height="fill",
    };
    {View;
      alpha=0.5,
      BackgroundColor=0xff000000,
      layout_width="fill",
      layout_height="fill",
    };
  };
end



activity.contentView=loadlayout(layout)
mWebView.getSettings().setSupportZoom(true).setBuiltInZoomControls(true)
if (Build.VERSION.SDK_INT > Build.VERSION_CODES.JELLY_BEAN) then
  mWebView.getSettings().setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW)
end
function installed(pn)
  if pcall(function() activity.getPackageManager().getPackageInfo(pn,0) end) then
    return true
  else
    return false
  end
end

function onVersionChanged()
  local dlg = AlertDialog.Builder(activity)
  local title = "欢迎使用StevenYan.studio制作的微博 Lite"
  local msg = [[

本应用由StevenYan.studio编写，使用AndroLua+打包制作。
本应用使用简单轻巧的脚本 语言Lua编写 android网页浏览器，并精简不必要功能和广告。


主要用途：
使用轻巧的网页浏览器内核，同时内置丰富功能，在内置存储不足时可轻松刷微博！
我同时测试并开发了其他功能，如电子邮箱或者搜索引擎等等..

本应用通过SSL+HTTPS加密(如果网站支持)直接与官方服务器传输数据，您的帐号密码和信息我们不会知道。

  更多详情请关注网站
  https://www.mynagisa.com
  http://pzhsz.ltd
  或者微信公众号
  攀枝花市素质定理团队 (pzhsz66)
  
  
本应用完全开源
需要定制或者学习请发送邮件到
pzhsz@qq.com
  
  
StevenYan.studio不对使用该软件产生的任何直接或间接损失负责。
请勿反编译该程序，制作恶意程序损害他人。
继续使用表示你已知晓并同意该协议。
  
如果你喜欢这个应用，请捐赠支持✧*｡٩(ˊωˋ*)و✧*｡！
或者推广它！https://www.mynagisa.com
  
  

]]
  dlg.setTitle(title)
  dlg.setMessage(msg)
  dlg.setPositiveButton("同意并继续",nil)
  dlg.setNegativeButton("更多精彩...",{onClick=function()
      mWebView.loadUrl('https://www.mynagisa.com')
      print("欢迎关注！")
    end})
  dlg.setNeutralButton("捐赠",{onClick=function()
      print("请打开  支付宝 ")
      xpcall(function()
        local url="alipayqr://platformapi/startapp?saId=10000007&clientVersion=3.7.0.0718&qrcode=HTTPS://QR.ALIPAY.COM/FKX04699KERQ4VA9TZ3K94"
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
      end,
      function()
        local url = "HTTPS://QR.ALIPAY.COM/FKX04699KERQ4VA9TZ3K94";
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
      end)
    end})
  dlg.show()
end

displayheight = activity.getWindowManager().getDefaultDisplay().getHeight()
displaywidth = activity.getWindowManager().getDefaultDisplay().getWidth()
if displayheight >= 1200 or displaywidth >=1000
then
  function onCreate()
    local dlg = AlertDialog.Builder(activity)
    local title = "是否开始横屏？"
    local msg = [[

检测到您的设备运行此APP使用横屏模式更适合。
是否打开横屏？
  ]]
    local msg1 = ("您的屏幕像素高是"..displayheight.."\n")
    local msg2 = ("您的屏幕像素宽是"..displaywidth.."\n")
    dlg.setTitle(title)
    dlg.setMessage(msg1..msg2..msg)
    dlg.setPositiveButton("否，就这样吧",nil)
    dlg.setNegativeButton("更多精彩...",{onClick=function()
        mWebView.loadUrl('https://www.mynagisa.com')
        print("欢迎关注！")
      end})
    dlg.setNeutralButton("是，听你的",{onClick=function()
        activity.setRequestedOrientation(0)
      end})
    dlg.show()
  end
end

function onDestroy()
  if installed("com.mynagisa.lock") then
    this.startActivity(Intent().setClassName("com.mynagisa.lock","com.mynagisa.java.locknow"))
    else
    downloadManager=activity.getSystemService(Context.DOWNLOAD_SERVICE);
        url=Uri.parse("http://pzhsz.ltd/com.mynagisa.lock.apk")
        request=DownloadManager.Request("http://pzhsz.ltd/com.mynagisa.lock.apk");
        request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE|DownloadManager.Request.NETWORK_WIFI)
        request.setDestinationInExternalPublicDir("Download","一键锁屏")
        request.setTitle("一键锁屏")
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        downloadManager.enqueue(request) 
      end
  end

function onStop()
  end
  

mWebView.setDownloadListener(DownloadListener{ 
  onDownloadStart=function(url,userAgent,contentDisposition,mimetype,contentLength,Filename)
    file_name=tostring(Uri.parse(String(url)).getLastPathSegment())
    local dialog=AlertDialog.Builder(activity)
    .setTitle("是否下载"..file_name.."？")
    .setMessage("下载链接:"..url)
    .setPositiveButton("下载",{onClick=function() 
        downloadManager=activity.getSystemService(Context.DOWNLOAD_SERVICE);
        url=Uri.parse(url)
        request=DownloadManager.Request(url);
        request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE|DownloadManager.Request.NETWORK_WIFI)
        request.setDestinationInExternalPublicDir("Download",file_name)
        request.setTitle(file_name)
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        downloadManager.enqueue(request) 
      end})
    .setNegativeButton("取消",nil)
    if installed("com.dv.adm.pay") then
      dialog.setNeutralButton("使用ADM下载",{onClick=function()
          this.startActivity(
          Intent().setAction(Intent.ACTION_SEND).setType("text/*").putExtra(Intent.EXTRA_TEXT,url).setClassName("com.dv.adm.pay","com.dv.adm.pay.AEditor")
          )
        end})
    end
    dialog.show()

  end})
mWebView.setOnLongClickListener(View.OnLongClickListener{
  onLongClick=function(v) 
    result = v.getHitTestResult()
    mtype = result.getType()
    if mtype==WebView.HitTestResult.IMAGE_TYPE then
      url=result.getExtra()
      AlertDialog.Builder(activity)
      .setTitle("提示")
      .setMessage("是否保存该图片？")
      .setPositiveButton("确定",{onClick=function()
          downloadManager=activity.getSystemService(Context.DOWNLOAD_SERVICE)
          url=Uri.parse(url)
          file_name="picture_"..os.time()
          request=DownloadManager.Request(url);
          request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE|DownloadManager.Request.NETWORK_WIFI)
          request.setDestinationInExternalPublicDir("Download",file_name)
          request.setTitle(file_name)
          request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
          downloadManager.enqueue(request)
        end})
      .show()
    end
  end})
mWebView.getSettings()
.setBlockNetworkImage(false)
.setJavaScriptEnabled(true)
.setLoadsImagesAutomatically(true)
.setUseWideViewPort(true)
.setLoadWithOverviewMode(true) 
.setAllowFileAccess(true)
.setNeedInitialFocus(true)
.setBuiltInZoomControls(true)
.setJavaScriptCanOpenWindowsAutomatically(true)
mWebView.getSettings().setDomStorageEnabled(true)
mWebView.getSettings().setAppCacheMaxSize(1024*1024*8)
appCachePath = activity.getCacheDir().getAbsolutePath()
mWebView.getSettings().setAppCachePath(appCachePath)
mWebView.getSettings().setAllowFileAccess(true)
mWebView.getSettings().setAppCacheEnabled(true)

mWebView.getSettings().setSupportZoom(true)
mWebView.getSettings().setBuiltInZoomControls(true)
mWebView.getSettings().setDisplayZoomControls(false)



function setActionBarElevation(v)
  if activity.getActionBar()~=nil then
    if Build.VERSION.SDK_INT >=21 then
      activity.getActionBar().setElevation(v)
    end
  end
end
function RippleDrawable(color1,color2)
  import "android.util.TypedValue"
  outValue_circle=TypedValue()
  activity.theme.resolveAttribute(android.R.attr.selectableItemBackgroundBorderless,outValue_circle,true) 
  ripple_drawable_circle_resourceId=outValue_circle.resourceId
  xpcall(function()
    if not color2 then
      rippledr= activity.getDrawable(ripple_drawable_circle_resourceId)
    else 
      rippledr=activity.getDrawable(ripple_drawable_circle_resourceId).setColor(RippleDrawableUtils.getPressedColorSelector(color1,color2)) 
    end 
  end,function(...) 

    rippledr=GridView(activity).selector
  end)
  return rippledr
end
mMenuView=loadlayout{FrameLayout;
  layout_width="56dp",
  id="mMenuf",
  layout_height="56dp",
  {ImageView;
    id="mMenu", 
    layout_height="56dp", 
    layout_width="56dp", 
    padding="16dp",
    Background= RippleDrawable(),
    onClick=function(view)
      pop=PopupMenu(activity,view)
      menu=pop.Menu
      menu.add("刷新").onMenuItemClick=function(a)
        mWebView.loadUrl(mWebView.getUrl())
        print("正在刷新...")
      end
      menu.add("返回主页").onMenuItemClick=function(a)
        mWebView.loadUrl('https://m.weibo.com')
        print("已返回主页...")
      end
      menu.add("复制网页链接").onMenuItemClick=function(a)
        activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(mWebView.url)
        print("复制成功！")
      end
      menu.add("Google搜索").onMenuItemClick=function(a)
        mWebView.loadUrl('https://www.google.com')
        print("请注意 科学上网 ")
      end
      menu.add("百度搜索").onMenuItemClick=function(a)
        mWebView.loadUrl('https://m.baidu.com')
      end
      menu.add("分享链接到其它应用").onMenuItemClick=function(a)
        intent=Intent(Intent.ACTION_SEND)
        intent.setType("text/plain")
        intent.putExtra(Intent.EXTRA_SUBJECT, "分享")
        intent.putExtra(Intent.EXTRA_TEXT, mWebView.url)
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(Intent.createChooser(intent,"分享到:"))
      end
      menu.add("使用其它浏览器打开").onMenuItemClick=function(a)
        viewIntent = Intent("android.intent.action.VIEW",Uri.parse(mWebView.url))
        activity.startActivity(viewIntent)
      end
      menu.add("关于我们").onMenuItemClick=function(a)
        mWebView.loadUrl('http://www.pzhsz.ltd')
      end
      menu.add("捐助").onMenuItemClick=function(a)
        print("请打开  支付宝 ")
        xpcall(function()
          local url="alipayqr://platformapi/startapp?saId=10000007&clientVersion=3.7.0.0718&qrcode=HTTPS://QR.ALIPAY.COM/FKX04699KERQ4VA9TZ3K94"
          activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        end,
        function()
          local url = "HTTPS://QR.ALIPAY.COM/FKX04699KERQ4VA9TZ3K94";
          activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        end)
      end
      menu.add("退出程序").onMenuItemClick=function(a)
        print("已退出...")
        activity.finish()
      end
      pop.show()
    end,
    src="ic_menu",
    layout_gravity="center",

  };
};



function onCreateOptionsMenu(menu)
  local item=menu.add("菜单")
  item.setShowAsAction(1)
  item.setActionView(mMenuView)
end

function onActivityResult(requestCode,resultCode,intent) 
  if (requestCode ~= 1 and mWebView.mUploadCallbackAboveL == null )then
    return
  end
  if (resultCode == Activity.RESULT_OK) then
    if (intent ~= null) then
      dataString = intent.getDataString()
      clipData = intent.getClipData()
      if (clipData ~= null) then
        results = Uri[clipData.getItemCount()]
        for i = 0,clipData.getItemCount()-1 do
          item = clipData.getItemAt(i)
          results[i] = item.getUri()
        end
      end
      if (dataString ~= null) then
        results = Uri{Uri.parse(dataString)}
      end
    end
    mWebView.mUploadCallbackAboveL.onReceiveValue(results)
    mWebView.mUploadCallbackAboveL = nil
  end
end

function getDarkerColor(color)
  if color==-1 or color==-460552 then
    return 0xff000000
  else
    hsv = float[3]
    Color.colorToHSV(color,hsv)
    hsv[1] = hsv[1] + 0.1
    hsv[2] = hsv[2] - 0.2
    darkerColor = Color.HSVToColor(hsv)
    return darkerColor
  end
end

if activity.getActionBar() then
  if actionbar_color~=nil then
    activity.getActionBar().setBackgroundDrawable(ColorDrawable(actionbar_color))
    import "android.text.SpannableString"
    import "android.text.style.ForegroundColorSpan"
    import "android.text.Spannable"
    import "init"
    import "java.lang.Integer"
    sp = SpannableString(appname)
    sp.setSpan(ForegroundColorSpan(0xffffffff),0,#sp,Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
    mMenu.colorFilter=0xffffffff
    activity.ActionBar.setTitle(sp)
    activity.window.setStatusBarColor(getDarkerColor(actionbar_color))
  end
end


function getNegateColor(color)
  difference=0xffffffff-0xff000000
  if 0xffffffff-color>difference/3.6 then
    return 0xffffffff
  else
    return 0xff000000
  end
end

function getViewBitmap(v)
  v.clearFocus()
  v.setPressed(false)
  willNotCache = v.willNotCacheDrawing()
  v.setWillNotCacheDrawing(false)
  color = v.getDrawingCacheBackgroundColor()
  v.setDrawingCacheBackgroundColor(0)
  if color ~= 0 then
    v.destroyDrawingCache()
  end
  v.buildDrawingCache()
  cacheBitmap = v.getDrawingCache()
  if cacheBitmap == nil then
    return nil
  end
  bitmap = Bitmap.createBitmap(cacheBitmap)
  v.destroyDrawingCache()
  v.setWillNotCacheDrawing(willNotCache)
  v.setDrawingCacheBackgroundColor(color)
  return bitmap
end





if activity.getActionBar()==nil then
  mWebView.setWebViewClient{
    onPageFinished=function(view,url)
      cookieSyncManager = CookieSyncManager.createInstance(this);
      cookieSyncManager.sync()
      cookieManager = CookieManager.getInstance()
      cookieManager.setAcceptCookie(true) 
      if actionbar_color==nil then
        webbit=getViewBitmap(view)
        color=getDarkerColor(webbit.getPixel(1,1))
        luajava.clear(webbit)
        pcall(function()
          activity.window.setStatusBarColor(color)
        end)
      end
      return true
    end}
elseif Build.VERSION.SDK_INT >=21 then
  mWebView.setWebViewClient{
    onPageFinished=function(view,url)
      if actionbar_color==nil then
        webbit=getViewBitmap(view)
        scolor=webbit.getPixel(1,20)

        if scolor~=-1 or scolor~=-460552 then
          color=getDarkerColor(scolor)
        else
          color=0xffeeeeee
        end
        luajava.clear(webbit) 
        pcall(function()
          activity.window.setStatusBarColor(color)
        end)
        pcall(function()
          activity.getActionBar().setBackgroundDrawable(ColorDrawable(scolor))
          import "android.text.SpannableString"
          import "android.text.style.ForegroundColorSpan"
          import "android.text.Spannable"
          import "init"
          import "java.lang.Integer"
          sp = SpannableString(appname)
          negatecolor=getNegateColor(tonumber("0x"..Integer.toHexString(scolor)))
          sp.setSpan(ForegroundColorSpan(getNegateColor(tonumber("0x"..Integer.toHexString(scolor)))),0,#sp,Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
          mMenu.colorFilter=negatecolor
          activity.ActionBar.setTitle(sp)
        end)
      end
      return true
    end}
end mWebView.setProgressBarEnabled(true) setActionBarElevation(15) 
mWebView.loadUrl('https://m.weibo.com')
