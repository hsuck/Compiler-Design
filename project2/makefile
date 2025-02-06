all: testParser myparser.java

myparser.java: myparser.g
	java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myparser.g

testParser: testParser.java myparser.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar:. testParser.java

clean:
	rm -rf *.class myparserLexer.java myparserParser.java myparser.tokens
