資工三 許智凱 407410030

File description:

	myCompiler.g:
		(1)	支援int和float兩種data type。
		(2)	支援arithmetic statement，且可使用括號表示優先序。
		(3)	支援assignment statement，等號右邊可以是arithmetic statement、identifier或constant( int、float )。
		(4)	支援comparison expression。
		(5)	支援nested if-then/if-then-else statement。
		(6)	支援多個參數的printf()，data type: %d、%f，且參數可以是arithmetic statement或identifier。
		(7)	支援nested for-loop statement。

		當 type checking 檢測出有 error 時，會直接停止 code generation，並印出錯誤訊息及
		錯誤發生的所在行數。

	myCompiler_test.java:
		A program to call compiler to perform code generation.

	test1.c:
		這個檔案主要用來測試一些基本的宣告和四則運算，並將運算的結果印出來，且 printf 的參數可以是四則運算。
	
	test2.c:
		這個檔案主要用來測試一些基本的宣告、四則運算、nested if-then-else statement 和 printf。

	test3.c:
		這個檔案主要用來測試一些基本的宣告、printf、nested for-loop 和 nested if-then-else statement。

	Makefile:
		Compile:
			首先，從 .g 檔產生 .java 檔:
				java -cp ./antlr-3.5.2-complete-no-st3.jar org.antlr.Tool myCompiler.g
			
			這個 command 會產生 myCheckerLexer.java, myCheckerParser.java 和 myChecker.tokens。

			接著，將上面產生的 .java 檔和 myChecker_test.java 一起 compile 產生執行檔( .class ):
				javac -cp ./antlr-3.5.2-complete-no-st3.jar *.java
			
			這個 command 會產生相對應的 .class 檔。

		Execute:
		    java -cp ./antlr-3.5.2-complete-no-st3.jar: myCompiler_test [c file]
			
			將 .c 檔傳入 myChecker_test 即可執行。

			java -cp ./antlr-3.5.2-complete-no-st3.jar: myCompiler_test [c file] > [ll file]
			可寫檔出來，並可以使用 lli 將其執行。


