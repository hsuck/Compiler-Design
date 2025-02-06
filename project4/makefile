all: myCompiler_test myCompiler.java

myCompiler.java: myCompiler.g
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myCompiler.g

myCompiler_test: myCompiler_test.java myCompiler.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar *.java

clean:
	rm -rf *.class myCompilerLexer.java myCompilerParser.java myCompiler.tokens
