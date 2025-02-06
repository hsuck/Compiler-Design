資工三 許智凱 407410030

File description:

	myparser.g:
		程式可以包含多個函式

		Declaration:
			支援一般變數、一維陣列的宣告與初始化，並包含 storage class(extern、static)、type specifier(const、volatile)。
		expression:
			支援算術、邏輯與賦值等運算。
		statement:
			支援 selection(if-then、if-then-else)、
				 iteration(while、do-while、for)、
				 jump(goto、continue、break、return)、
				 expression(arithmetic、logical、assignment)、
				 compound(nested statement)、
				 printf(any number of parameters) 等 statements。
				 
		在我的程式當中，會印出一些 parse 的資訊，用來觀察 parser 在 parse 時的行為，可以透過 TRACEON
		這個變數來選擇是否要印出這些資訊。 
		
		Information about parsing:
			1. functions
			2. declarations: 印出變數名稱與是否初始化。
			3. expression: 印出是 assignment expression 或是 conditional expression(arithmetic、logical)。
			4. statements: 印出是 statement 的類別(selection、iteration、jump、...)。


	testParser.java:
		A program to call parser.

	test1.c:
		這個檔案(contain comment //, /**/)主要用來測試 iteration statement，其中包含 (nested)for-loop、
		while-loop 和 do-while-loop。loop 內也包含  (nested)if-then, expressions 或
		jump statements。
	
	test2.c:
		這個檔案(contain comment //, /**/)主要用來測試 (nested)if-then-else statement，
		另外還有 multiple functions、return statements、expressions 與一些基本的變數、陣列宣告、初始化。

	test3.c:
		這個檔案(contain comment //, /**/)主要用來測試 printf、if-then-else statement 與
		一些基本的變數宣告、初始化。

	Makefile:
		Compile:
			首先，從 .g 檔產生 .java 檔:
				java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myparser.g
			
			這個 command 會產生 myparserLexer.java, myparserParser.java 和 myparser.tokens。

			接著，將上面產生的 .java 檔和 testParser.java 一起 compile 產生執行檔( .class ):
				javac -cp ./antlr-3.5.2-complete-no-st3.jar:. testParser.java
			
			這個 command 會產生相對應的 .class 檔。

		Execute:
		    java -cp ./antlr-3.5.2-complete-no-st3.jar testParser [.c file]
			
			將 .c 檔傳入 testParser 即可執行。



