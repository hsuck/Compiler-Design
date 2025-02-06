; === prologue ====
declare dso_local i32 @printf(i8*, ...)
@.str.0 = private unnamed_addr constant [15 x i8] c"a equals to b\0A\00", align 1
@.str.1 = private unnamed_addr constant [22 x i8] c"a doesn't equal to b\0A\00", align 1
@.str.2 = private unnamed_addr constant [24 x i8] c"c = %f, d = %f, e = %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [7 x i8] c"c < d\0A\00", align 1
@.str.4 = private unnamed_addr constant [22 x i8] c"a doesn't equal to b\0A\00", align 1
define dso_local i32 @main()
{
	%t0 = alloca float
	%t1 = alloca float
	%t2 = alloca float
	%t3 = alloca i32, align 4
	%t4 = alloca i32, align 4
	%t5 = add nsw i32 8, 9
	%t6 = mul nsw i32 %t5, 3
	store i32 %t6, i32* %t4, align 4
	%t7 = add nsw i32 3, 14
	%t8 = mul nsw i32 %t7, 3
	store i32 %t8, i32* %t3, align 4
	%t9 = load i32, i32* %t4
	%t10 = load i32, i32* %t3
	%cond0 = icmp eq i32 %t9, %t10
	br i1 %cond0, label %L1, label %L2

L1:
	%t11 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.0, i64 0, i64 0))
	br label %L3

L2:
	%t12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.1, i64 0, i64 0))
	br label %L3

L3:
	%t13 = fadd float 0x4023333340000000, 0x3ff3333340000000
	store float %t13, float* %t2, align 4
	%t14 = load float, float* %t2
	%t15 = fsub float %t14, 0x4017333340000000
	%t16 = fdiv float %t15, 0x400a666660000000
	store float %t16, float* %t1, align 4
	%t17 = load float, float* %t1
	%t18 = load float, float* %t2
	%t19 = fadd float %t17, %t18
	%t20 = fmul float %t19, 0x3fefae1480000000
	store float %t20, float* %t0, align 4
	%t21 = load i32, i32* %t4
	%t22 = load i32, i32* %t3
	%cond1 = icmp eq i32 %t21, %t22
	br i1 %cond1, label %L4, label %L5

L4:
	%t23 = load float, float* %t2
	%cond2 = fcmp ogt float %t23, 0x4006a3d700000000
	br i1 %cond2, label %L6, label %L7

L6:
	%t24 = load float, float* %t2
	%t25 = fpext float %t24 to double
	%t26 = load float, float* %t1
	%t27 = fpext float %t26 to double
	%t28 = load float, float* %t1
	%t29 = load float, float* %t2
	%t30 = fadd float %t28, %t29
	%t31 = fmul float %t30, 0x3fefae1480000000
	%t32 = fpext float %t31 to double
	%t33 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.2, i64 0, i64 0), double %t25, double %t27, double %t32)
	br label %L8

L7:
	%t34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.3, i64 0, i64 0))
	br label %L8

L8:
	br label %L9

L5:
	%t35 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @.str.4, i64 0, i64 0))
	br label %L9

L9:

; === epilogue ===
	ret i32 0
}
