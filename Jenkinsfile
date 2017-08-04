def isWindows(){
    return env.NODE_LABELS.toLowerCase().contains('windows')
}

def shell(params){
    if(isWindows()) bat(params) 
    else sh(params)
}

node('unix') {
	cleanWs()
	def builders = [:]
	def architectures = ['32', '64']
	for (arch in architectures) {
    // Need to bind the label variable before the closure - can't do 'for (label in labels)'
    def architecture = arch

	builders[architecture] = {
		dir(architecture) {
		
		try{
		stage ("Fetch Requirements-${architecture}") {	
			checkout scm
			shell 'wget -O - get.pharo.org/vm60 | bash	'
			shell 'wget https://github.com/guillep/PharoBootstrap/releases/download/v1.1.1/bootstrapImage.zip'
			shell 'unzip bootstrapImage.zip'
			shell './pharo Pharo.image bootstrap/scripts/prepare_image.st --save --quit'
	    }

		stage ("Bootstrap-${architecture}") {
			shell "mkdir -p bootstrap-cache #required to generate hermes files"
			shell "./pharo Pharo.image ./bootstrap/scripts/generateHermesFiles.st --quit"
			shell "./pharo ./Pharo.image bootstrap/scripts/bootstrap.st --ARCH=${architecture} --quit"
	    }

		stage ("Full Image-${architecture}") {
			shell "BOOTSTRAP_ARCH=${architecture} bash ./bootstrap/scripts/build.sh -a ${architecture}"
			stash includes: "bootstrap-cache/*.zip,bootstrap-cache/*.sources,bootstrap/scripts/**", name: "bootstrap${architecture}"
	    }
		} finally {
			archiveArtifacts artifacts: 'bootstrap-cache/*.zip,bootstrap-cache/*.sources', fingerprint: true
		}
		
		// platforms for Jenkins node types we will build on
		def platforms = ['unix', 'osx', 'windows']
		def testers = [:]
		for (platf in platforms) {
	        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
	        def platform = platf
		    testers["${platform}-${architecture}"] = {
	            node(platform) { stage("Tests-${platform}-${architecture}"){
				try {
					cleanWs()
					unstash "bootstrap${architecture}"
					
					shell "bash -c 'bootstrap/scripts/runTests.sh ${architecture}'"
					
					} finally {
						archiveArtifacts allowEmptyArchive: true, artifacts: '*.xml', fingerprint: true
						junit allowEmptyResults: true, testResults: '*.xml'
					}
				}}
		    }
		}
		parallel testers
		
		}
	} // end build block
	
	} // end for architectures
	
	parallel builders
	cleanWs()
	
} // end node
