# Items in shared

Think of this as housing the shared resources needed for proper API operation
Focuses on shared "data-plane" resources

Goal here is if I were to 1) redeploy and instance of APIM, then once that is complete, I could then use this folder to setup all the global resources needed to operate/organize/manage the APIs. Technically though since no APIs have been defined yet, APIM is still not functional

- /products
    - /groups
    - /policies (group specific policies)
    - /tags
    - /apis - NOT SURE ON THIS ONE YET, MAY NEED TO LIVE UNDER /APIs
- /policies (global policies)
- /identityProviders