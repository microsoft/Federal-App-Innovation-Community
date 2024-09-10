# AI Based IVR using Power Virtual Agent and OmniChannel
An Interactive Voice Reponse (IVR) Bot that will answer your questions when you a dial a phone number. If need be it will escalate to an agent who will jump on the same call and help you out. 

## Pre-requisites
1. License and access to configure Voice OmniChannel in Dynamics 365
2. CDonfigure OmniChannel for Power Virtual Agent integration
3. Power Platform license with Power Virtual Agent License
4. Access to create and configure Azure Communications Serices in Azure
5. Access to create and configure Azure OpenAI service in Azure
6. AI Builder License
7. Access to create Azure Speech Services
8. Access to create App Registrations in Azure Active Directory


## Reference Architecture

![IVR Bot](ReferenceArchitecture.png)


## Setup

### Azure Communication Services
1. Create Azure Communication Services (ACS) in Azure for [Email](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/create-email-communication-resource) and [Phone nuber](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/telephony/get-phone-number?tabs=windows&pivots=platform-azp)

### Azure OpenAI services
1. Create [Azure OpenAI](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/quickstart?pivots=programming-language-studio) services in Azure and note down the key and url

### Azure Speech Services
1. Create [Azure Speech Services](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/get-started-speech-to-text?tabs=windows%2Cterminal&pivots=programming-language-rest) in Azure and note down the url and keys

### OmniChannel (OC) and Power Virtual Agent (PVA)
1. Create and configure [PVA for OC Voice](https://learn.microsoft.com/en-us/dynamics365/customer-service/voice-channel-pva-bots)


## Run
1. Clone the repo or download the attached zip file
2. [Import the solution](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/import-update-export-solutions) into your Power Platform Environment
3. Update the values of the environment variables as noted in the Pre-Requsites and Setup
4. Save and publish
5. Follow steps in setup - "OmniChannel (OC) and Power Virtual Agent (PVA)" to configure PVA in OC voice
5. Open OC Customer Service Dashboard in another tab
6. Call the number in OC Voice and talk to your bot



That's it folks!!!

----------------------------
