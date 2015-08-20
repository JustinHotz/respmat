#This pages summarizes all the issues that can occur during the installation of the Matlab Runtime Component (MRCInstaller.exe)

Unfortunately, the installation of the MCR from Matlab has been proven to be a non-trivial task, in particular, the strict software security policies within hospitals, makes the installation sometimes problematic. If you experience trouble, it is wise at this stage to contact your network administrator or a local computer scientist.

## Sources of information ##
You can :
**Read more about the installation process on this [page](http://www.mathworks.fr/help/toolbox/compiler/f12-999353.html)** look a user’s report similar to yours or post your problem on this [plateform](http://www.mathworks.fr/matlabcentral/?s_cid=global_nav)


## Known problems ##
Here are the “error messages” we know about and their way around:

### Impossible to copy autorun.ini ###
#Right click on the installer and select “extract here”
#Lauch Setup.exe manually

### Microsoft Visual Studio 2005 redistribuable “command line option syntax error” ###
**Please refer to: http://support.microsoft.com/kb/952211** Alternatively Ignore and continue installation


### Mclmcr initialization failed ###
No way around yet. Find free to update this page.

### 0xc000…5 MCRInstaller could not initialize correctly ###
**Manually unzip the installer and start installation manually**
