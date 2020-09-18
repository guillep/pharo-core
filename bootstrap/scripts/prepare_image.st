"Load the code for the Pharo bootstrap process, together with some packages to do the bootstrap"

[ | repositoryPathString |

  Iceberg enableMetacelloIntegration: true.
  Iceberg remoteTypeSelector: #httpsUrl.

  repositoryPathString := ((Smalltalk os environment at: 'BOOTSTRAP_REPOSITORY' ifAbsent: ['.']) asFileReference / 'bootstrap' / 'src') fullName.

  Transcript show: '    [+] Loading tonel code to dump files for the Pharo bootstrap process from ' , repositoryPathString; cr.

  Metacello new
	baseline: 'PharoBootstrapProcess';
	repository: 'tonel://', repositoryPathString;
	load.
] on: Warning do: #resume.
