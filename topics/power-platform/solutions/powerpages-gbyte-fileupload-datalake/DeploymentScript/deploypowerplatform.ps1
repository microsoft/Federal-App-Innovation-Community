#log in to your tenan with GA credentials
Connect-AzAccount
#one time -  create and admin profile
pac auth create --kind ADMIN
#pac auth list 
#list all the environments
pac admin list

#Create a new Dataverse Environment
pac admin create --name Portal2 --currency USD --region unitedstates --type Sandbox --domain Portal2