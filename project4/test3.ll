; === prologue ====
declare dso_local i32 @printf(i8*, ...)
@.str.0 = private unnamed_addr constant [13 x i8] c"H3ll0 W0r1d\0A\00", align 1
@.str.1 = private unnamed_addr constant [8 x i8] c"i = %d\0A\00", align 1
@.str.2 = private unnamed_addr constant [16 x i8] c"    0xDEADBEEF\0A\00", align 1
@.str.3 = private unnamed_addr constant [16 x i8] c"    0xDEADDEAD\0A\00", align 1
@.str.4 = private unnamed_addr constant [12 x i8] c"    j = %d\0A\00", align 1
@.str.5 = private unnamed_addr constant [16 x i8] c"        k = %d\0A\00", align 1
@.str.6 = private unnamed_addr constant [12 x i8] c"    l = %d\0A\00", align 1
define dso_local i32 @main()
{
	%t0 = alloca i32, align 4
	%t1 = alloca i32, align 4
	%t2 = alloca i32, align 4
	%t3 = alloca i32, align 4
	store i32 0, i32* %t3, align 4
	br label %L2

L2:
	%t4 = load i32, i32* %t3
	%cond0 = icmp slt i32 %t4, 5
	br i1 %cond0, label %L3, label %L4

L1:
	%t5 = load i32, i32* %t3
	%t6 = add nsw i32 %t5, 1
	store i32 %t6, i32* %t3, align 4
	br label %L2

L3:
	%t7 = load i32, i32* %t3
	%cond1 = icmp eq i32 %t7, 1
	br i1 %cond1, label %L5, label %L6

L5:
	%t8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.0, i64 0, i64 0))
	br label %L7

L6:
	%t9 = load i32, i32* %t3
	%t10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.1, i64 0, i64 0), i32 %t9)
	br label %L7

L7:
	store i32 0, i32* %t2, align 4
	br label %L9

L9:
	%t11 = load i32, i32* %t2
	%cond2 = icmp slt i32 %t11, 3
	br i1 %cond2, label %L10, label %L11

L8:
	%t12 = load i32, i32* %t2
	%t13 = add nsw i32 %t12, 1
	store i32 %t13, i32* %t2, align 4
	br label %L9

L10:
	%t14 = load i32, i32* %t2
	%cond3 = icmp eq i32 %t14, 0
	br i1 %cond3, label %L12, label %L13

L12:
	%t15 = load i32, i32* %t3
	%cond4 = icmp eq i32 %t15, 1
	br i1 %cond4, label %L14, label %L15

L14:
	%t16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i64 0, i64 0))
	br label %L16

L15:
	%t17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.3, i64 0, i64 0))
	br label %L16

L16:
	br label %L17

L13:
	%t18 = load i32, i32* %t2
	%t19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.4, i64 0, i64 0), i32 %t18)
	br label %L17

L17:
	store i32 0, i32* %t1, align 4
	br label %L19

L19:
	%t20 = load i32, i32* %t1
	%cond5 = icmp slt i32 %t20, 2
	br i1 %cond5, label %L20, label %L21

L18:
	%t21 = load i32, i32* %t1
	%t22 = add nsw i32 %t21, 1
	store i32 %t22, i32* %t1, align 4
	br label %L19

L20:
	%t23 = load i32, i32* %t1
	%t24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.5, i64 0, i64 0), i32 %t23)
	br label %L18

L21:
	br label %L8

L11:
	store i32 0, i32* %t0, align 4
	br label %L23

L23:
	%t25 = load i32, i32* %t0
	%cond6 = icmp slt i32 %t25, 4
	br i1 %cond6, label %L24, label %L25

L22:
	%t26 = load i32, i32* %t0
	%t27 = add nsw i32 %t26, 1
	store i32 %t27, i32* %t0, align 4
	br label %L23

L24:
	%t28 = load i32, i32* %t0
	%t29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), i32 %t28)
	br label %L22

L25:
	br label %L1

L4:

; === epilogue ===
	ret i32 0
}
