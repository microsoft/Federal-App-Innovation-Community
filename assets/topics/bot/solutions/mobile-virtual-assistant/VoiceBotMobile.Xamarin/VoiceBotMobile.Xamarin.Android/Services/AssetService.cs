using Android.App;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using VoiceBotMobile.Xamarin.Services;

namespace VoiceBotMobile.Xamarin.Droid.Services
{
    internal class AssetService : IAssetService
    {
        private Java.IO.File cacheFile;

        public string GetAssetPath(string filename)
        {
            var context = MainActivity.Instance;
            cacheFile = new Java.IO.File(context.CacheDir, filename);

            if (!cacheFile.Exists())
            {
                using (var br = new BinaryReader(Application.Context.Assets.Open(filename)))
                {
                    using (var bw = new BinaryWriter(new FileStream(cacheFile.AbsolutePath, FileMode.Create)))
                    {
                        byte[] buffer = new byte[2048];
                        int length = 0;
                        while ((length = br.Read(buffer, 0, buffer.Length)) > 0)
                        {
                            bw.Write(buffer, 0, length);
                        }
                    }
                }
            }
            return cacheFile.AbsolutePath;
        }
    }
}