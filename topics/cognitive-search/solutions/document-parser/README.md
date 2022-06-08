# Cognitive Search based Document and Audio Parser

A knowledge mining solution that uses Azure Cognitive Search and Azure Cognitive services to parse documents and audio file,  checks for duplicates and classify the documents based on user-defined search text.

*Note*:
- The classification can extended to leverage AzureML to support AI based classification.
- The code leverages in-process cache to check for duplicates. For robust solution, it needs to be modified to use a distribute cache like [Azure Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-dotnet-core-quickstart)

## Architecture

![Document Parser](DocumentParser_Architecture.png)

## [Supported File formats](https://docs.microsoft.com/en-us/azure/search/search-howto-indexing-azure-blob-storage#supported-document-formats)
- CSV
- EML
- EPUB
- GZ
- HTML
- JSON (see Indexing JSON blobs)
- KML (XML for geographic representations)
- Microsoft Office formats: DOCX/DOC/DOCM, XLSX/XLS/XLSM, PPTX/PPT/PPTM, MSG (Outlook emails), XML (both 2003 and 2006 WORD XML)
- Open Document formats: ODT, ODS, ODP
- PDF
- Plain text files (see also Indexing plain text)
- RTF
- XML
- ZIP

## Supported Audio files
- WAV
- MP3

## Pre-Requisites
1. The components in the above architecture
2. The following keys in your settings file
   1. *DocumentBlobStorage* with a container name `*documents*`
   2. *ServiceBusConnection*
   3. *CognitiveSearch.APIKEY*
   4. *CognitiveSearch_RefreshIndexer_URL*
   5. *CognitiveSearch_GetIndexStatus_URL*
   6. *CognitiveSearch_Search_URL*
   7. *ServiceBus_TopicName*
   8. *SServiceBus_CustomProperty*  - this the custom property that would be used by SQL Filter
   9. *CognitiveSearch_Document_Container**
   10. *SpeechToText_AudioFile_Container*
   11. *SpeechToText_APIKey*
   12. *SpeechToText_Url*
   13. *SpeechToText_TimeOut*
   14. *SpeechToText_ValidAudioFileExtensions*
3. Create a Topic that matches the key above, a subscription  and a SQL filter for the topic (this should match the value in the code `ServiceBusinessManager.cs, line 22`)
   1. `Organizations like '%Agriculture%'`

## References
1. [Azure Search Knowledge Mining](https://github.com/Azure-Samples/azure-search-knowledge-mining)
2. [Similarity matching in search](https://docs.microsoft.com/en-us/azure/search/index-similarity-and-scoring)