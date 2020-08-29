"
This script generates bootstrap.image, together with some files

The .hermes files can be loaded directly without a compiler.
We use the hermes files to bootstrap a compiler.
With the compiler, we are able to load some Smalltalk (st) files.
We use Smalltalk files to load monticello.
We then use monticello to load metacello.
Finally, with metacello we can load the Pharo baseline.

The bootstrap process reads the Pharo Bootstrap baseline (BaselineOfPharoBootstrap) and generates the smallest image from the baseline.
This baseline is used to generate the mcz files in the package cache (pharo-local/package-cache), as well as the .hermes files.
Both the .mcz and .hermes files are necessary as the .hermes files do not contain source code.
The .mcz files are then reloaded so that all the classes will have source code and correct package information.
"

PBBootstrap fromCommandLine bootstrap