using System;
using Android.App;
using Android.Content.PM;
using Android.Runtime;
using Android.OS;
using Xamarin.Essentials;
using VoiceBotMobile.Xamarin.Services;
using Xamarin.Forms;
using VoiceBotMobile.Xamarin.Droid.Services;

namespace VoiceBotMobile.Xamarin.Droid
{
    [Activity(Label = "VoceBotMobile", Icon = "@mipmap/icon", Theme = "@style/MainTheme", MainLauncher = true, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation)]
    public class MainActivity : global::Xamarin.Forms.Platform.Android.FormsAppCompatActivity
    {
        private const int RECORD_AUDIO = 1;
        private IMicrophoneService micService;
        internal static MainActivity Instance { get; private set; }

        protected override void OnCreate(Bundle savedInstanceState)
        {
            Instance = this;
            TabLayoutResource = Resource.Layout.Tabbar;
            ToolbarResource = Resource.Layout.Toolbar;

            base.OnCreate(savedInstanceState);

            Platform.Init(this, savedInstanceState);
            global::Xamarin.Forms.Forms.Init(this, savedInstanceState);
            LoadApplication(new App());
            DependencyService.Register<IMicrophoneService, AndroidMicrophoneService>();
            micService = DependencyService.Get<IMicrophoneService>();

            DependencyService.Register<IAssetService, AssetService>();
        }

        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, [GeneratedEnum] Android.Content.PM.Permission[] grantResults)
        {
            Platform.OnRequestPermissionsResult(requestCode, permissions, grantResults);

            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);

            switch (requestCode)
            {
                case RECORD_AUDIO:
                    {
                        micService.OnRequestPermissionResult(true);
                        //if (grantResults[0] == Permission.Granted)
                        //{
                        //    micService.OnRequestPermissionResult(true);
                        //}
                        //else
                        //{
                        //    micService.OnRequestPermissionResult(false);
                        //}
                    }
                    break;
            }
        }
    }
}