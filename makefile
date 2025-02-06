all: testLexer mylexer.java

mylexer.java: mylexer.g
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool mylexer.g

testLexer: testLexer.java mylexer.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar testLexer.java mylexer.java

clean:
	rm -rf *.class mylexer.java mylexer.tokens
