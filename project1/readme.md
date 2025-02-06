下載完 antlr-3.5.2-complete-no-st3.jar 後，我將 antlr-3.5.2-complete-no-st3.jar 配置到環境變數 CLASSPATH 當中，在使用 antlr-3.5.2-complete-no-st3.jar 這個套件時，java 會根據 CLASSPATH 中的路徑來尋找，因此在 compile 時，可以省去 -cp 的 flag。
command: export CLASSPATH=~/pathToYourJarFile/antlr-3.5.2-complete-no-st3.jar:$CLASSPATH

這邊我有附上 antlr-3.5.2-complete-no-st3.jar，並在 makefile 中下 -cp 的 flag。

Compile:
	首先，從 .g 檔產生 .java 檔:
		java org.antlr.Tool mylexer.g
		或是 java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool mylexer.g
	
	這個 command 會產生 mylexer.java 和 mylexer.tokens。

	接著，將上面產生的 .java 檔和 testLexer.java 一起 compile 產生執行檔( .class ):
		javac testLexer.java mylexer.java
		或是 javac -cp ./antlr-3.5.2-complete-no-st3.jar testLexer.java mylexer.java
	
	這個 command 會產生相對應的 .class 檔。

Execute:
	java testLexer [.c file]
	或是 java -cp ./antlr-3.5.2-complete-no-st3.jar testLexer [.c file]
	
	將 .c 檔傳入 testLexer 即可執行。
	
	
