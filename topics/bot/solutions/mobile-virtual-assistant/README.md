# Voice Assistant Bot for Android
A bot based Voice Assistant (like Cortana) for Android using Azure Speech Service, DirectLine Speech and Bot Framework

## Reference Architecture
![Voice Assistant DirectLine Speech](ReferenceArchitecture.png)

## Pre-Requisites
1. Visual Studio 2022
2. Access to create resources in Azure and app registrations in Azure Active Directory
2. Follow [this instruction](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/tutorial-voice-enable-your-bot-speech-sdk) to have Azure Speech Service, Bot Framework Bot, DirectLine Speech installed and configured
   1. Keep note of where you download the custom keyword model file.
3. [Install Xamarin](https://docs.microsoft.com/en-us/xamarin/get-started/installation/?pivots=windows) on your desktop

## Quickstart

1. Clone/download this project to your computer
2. Open the `VoiceBotMobile.sln` in VS2022
3. Click `Build Solution` from the Build menu to restore the nuget packages
4. Open `Constants.cs` file in the project `..\VoiceBotMobile.Xamarin\VoiceBotMobile.Xamarin`
5. Paste the Azure Speech Service (that you created as part of Pre-requisites) Key for the variable `CognitiveServicesApiKey`
6. Paste the Azure Speech Service (that you created as part of Pre-requisites) Region/location for the variable `CognitiveServicesRegion`
7. Click Save
8. Click on `Tools\Android\Android Device Manager` menu and create a profile for `Pixel` and model and `x86` as the processor.
   1. This is needed as the Speech SDK current version does not support other processor types yet.
9. Open `MainPage.xaml.cs` file and update the value of `kwsModelFile` to the keyword model file that you downloaded as Pre-Requisite
   1. Add the model file to the `Assets` folder inside `VoiceBotMobile.Xamarin.Android\Assets` project and set its build action to `AndroidAsset`
10. Once create, click `Start` to start the emulator.
11. In VS 2022, select the profile you created in step 8 in the `Run` drop down tool bar and click F5
    1. This will take few mins to build and run the app in the simulator
12. When finished, you should see the app load with 2 buttons
13. Click the `Enable Microphone` to allow microphone
14. Then in the emulator, click the `...` on the side bar to open settings
15. Click on `Settings` and under `General` make sure the toggle switch to use host audio input is selected
    1. This is so that when you speak, the app will recognize it from the mic associated with you laptop
16. Now, click `Start speech recognition` button to initiate voice chat
17. You should hear the bot say `Hello and welcome`. IT should also be displayed in a text area above the buttons
18. Now you can say into the mic of your system, `<<wake keyword that you configured as pre-requisite>> good morning `.
19. The app should now respond by echoing what you stated.

## References

1. [Voice Enable Bot](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/tutorial-voice-enable-your-bot-speech-sdk)
2. [Speech service in Xamarin](https://github.com/Azure-Samples/cognitive-services-speech-sdk/tree/master/samples/csharp/xamarin/kws-xamarin)