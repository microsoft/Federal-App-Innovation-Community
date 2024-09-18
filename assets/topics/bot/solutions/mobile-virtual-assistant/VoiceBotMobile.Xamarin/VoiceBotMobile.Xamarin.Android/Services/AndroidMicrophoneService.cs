using Android;
using Android.App;
using Android.Content;
using Android.Content.PM;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using AndroidX.Core.App;
using Google.Android.Material.Snackbar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using VoiceBotMobile.Xamarin.Droid.Services;
using VoiceBotMobile.Xamarin.Services;
using Xamarin.Forms;

namespace VoiceBotMobile.Xamarin.Droid.Services
{
    internal class AndroidMicrophoneService : IMicrophoneService
    {
        public const int REQUEST_MIC = 1;
        private TaskCompletionSource<bool> tcsPermissions;
        private readonly string[] permissions = new string[] { Manifest.Permission.RecordAudio, Manifest.Permission.ReadExternalStorage };

        public Task<bool> GetPermissionAsync()
        {
            tcsPermissions = new TaskCompletionSource<bool>();

            if ((int)Build.VERSION.SdkInt < 23)
            {
                tcsPermissions.TrySetResult(true);
            }
            else
            {
                var currentActivity = MainActivity.Instance;
                RequestMicPermission();
                if ((ActivityCompat.CheckSelfPermission(currentActivity, Manifest.Permission.RecordAudio) != (int)Android.Content.PM.Permission.Granted) ||
                    ActivityCompat.CheckSelfPermission(currentActivity, Manifest.Permission.ReadExternalStorage) != (int)Android.Content.PM.Permission.Granted)
                {
                    RequestMicPermission();
                }
                else
                {
                    tcsPermissions.TrySetResult(true);
                }
            }

            return tcsPermissions.Task;
        }

        private void RequestMicPermission()
        {
            var currentActivity = MainActivity.Instance;
            if (ActivityCompat.ShouldShowRequestPermissionRationale(currentActivity, Manifest.Permission.RecordAudio))
            {
                Snackbar.Make(currentActivity.FindViewById((Android.Resource.Id.Content)), "App requires microphone permission.", Snackbar.LengthIndefinite).SetAction("Ok", v =>
                {
                    ((Activity)currentActivity).RequestPermissions(permissions, REQUEST_MIC);
                }).Show();
            }
            else
            {
                ActivityCompat.RequestPermissions(((Activity)currentActivity), permissions, REQUEST_MIC);
            }
        }

        public void OnRequestPermissionResult(bool isGranted)
        {
            tcsPermissions.TrySetResult(isGranted);
        }
    }
}