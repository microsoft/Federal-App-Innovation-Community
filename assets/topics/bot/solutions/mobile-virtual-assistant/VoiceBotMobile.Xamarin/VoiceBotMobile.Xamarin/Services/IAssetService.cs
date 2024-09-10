using System;
using System.Collections.Generic;
using System.Text;

namespace VoiceBotMobile.Xamarin.Services
{
    public interface IAssetService
    {
        string GetAssetPath(string filename);
    }
}