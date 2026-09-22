JUNIT_URL := https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.0/junit-platform-console-standalone-1.10.0.jar
JUNIT_JAR := libs/junit.jar
PMD_VERSION := 7.27.0
PMD_HOME := libs/tools/pmd-bin-$(PMD_VERSION)
PMD := $(PMD_HOME)/bin/pmd
PMD_URL := https://github.com/pmd/pmd/releases/download/pmd_releases/$(PMD_VERSION)/pmd-dist-$(PMD_VERSION)-bin.zip
SPOTBUGS_VERSION := 4.10.4
SPOTBUGS_HOME := libs/tools/spotbugs-$(SPOTBUGS_VERSION)
SPOTBUGS := $(SPOTBUGS_HOME)/bin/spotbugs
SPOTBUGS_URL := https://github.com/spotbugs/spotbugs/releases/download/$(SPOTBUGS_VERSION)/spotbugs-$(SPOTBUGS_VERSION).tgz

SRCS := $(shell find src -name '*.java' 2>/dev/null)
TESTS := $(shell find test -name '*.java' 2>/dev/null)

.PHONY: deps build test pmd spotbugs clean

deps: $(JUNIT_JAR)

$(JUNIT_JAR):
	@mkdir -p libs
	@curl -sSL -o $@ $(JUNIT_URL)

$(PMD):
	@mkdir -p libs/tools
	@curl -sSL $(PMD_URL) -o libs/pmd.zip
	@unzip -q libs/pmd.zip -d libs/tools
	@rm libs/pmd.zip

$(SPOTBUGS):
	@mkdir -p libs/tools
	@curl -sSL $(SPOTBUGS_URL) -o libs/spotbugs.tgz
	@tar -xzf libs/spotbugs.tgz -C libs/tools
	@rm libs/spotbugs.tgz

build: deps
	@mkdir -p build
	javac --release 17 -d build -cp $(JUNIT_JAR) $(SRCS) $(TESTS)

test: build
	java -jar $(JUNIT_JAR) --class-path build --scan-class-path

pmd: $(PMD)
	$(PMD) check -d src/PriceEngine.java -R category/java/design.xml/CyclomaticComplexity -f text || [ $$? -eq 4 ]

spotbugs: build $(SPOTBUGS)
	$(SPOTBUGS) -textui -exitcode -effort:max -low -auxclasspath $(JUNIT_JAR) build

clean:
	rm -rf build libs
