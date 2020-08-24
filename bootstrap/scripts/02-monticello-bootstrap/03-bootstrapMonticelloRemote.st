mcPackages := #(
 'Network-Kernel'
 'Network-MIME'
 'Network-Protocols'

 'MonticelloRemoteRepositories'

 'Zinc-HTTP'
 'Zinc-FileSystem'
 'Zodiac-Core'
 ).

(MonticelloBootstrap inDirectory: (CommandLineArguments new optionAt: 'BOOTSTRAP_PACKAGE_CACHE_DIR' ifAbsent: [ MCCacheRepository uniqueInstance directory ]) asFileReference)
  loadPackagesNamed: mcPackages.

InternetConfiguration initialize.
NetNameResolver initialize.
Socket initialize.
Base64MimeConverter initialize.

ZnBase64Encoder initialize.
ZnByteEncoder initialize.
ZnUTF8Encoder initialize.
ZnLogEvent initialize.
ZnConstants initialize.
ZnHeaders initialize.
ZnNetworkingUtils initialize.
ZnServer initialize.
ZnSingleThreadedServer initialize.
