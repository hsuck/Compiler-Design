; === prologue ====
declare dso_local i32 @printf(i8*, ...)
@.str.0 = private unnamed_addr constant [36 x i8] c"a = %d, b = %d, c = %d, a + c = %d\0A\00", align 1
@.str.1 = private unnamed_addr constant [35 x i8] c"d = %f, e = %f, f = %f f - d = %f\0A\00", align 1
define dso_local i32 @main()
{
	%t0 = alloca float
	%t1 = alloca float
	%t2 = alloca float
	%t3 = alloca i32, align 4
	%t4 = alloca i32, align 4
	%t5 = alloca i32, align 4
	store i32 2, i32* %t5, align 4
	store i32 3, i32* %t4, align 4
	%t6 = load i32, i32* %t5
	%t7 = add nsw i32 %t6, 3
	%t8 = load i32, i32* %t5
	%t9 = load i32, i32* %t4
	%t10 = add nsw i32 %t8, %t9
	%t11 = mul nsw i32 %t7, %t10
	%t12 = sdiv i32 %t11, 5
	store i32 %t12, i32* %t3, align 4
	%t13 = load i32, i32* %t5
	%t14 = load i32, i32* %t4
	%t15 = load i32, i32* %t3
	%t16 = load i32, i32* %t5
	%t17 = load i32, i32* %t3
	%t18 = add nsw i32 %t16, %t17
	%t19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.0, i64 0, i64 0), i32 %t13, i32 %t14, i32 %t15, i32 %t18)
	%t20 = fadd float 0x3ff8000000000000, 0x4006666660000000
	store float %t20, float* %t2, align 4
	%t21 = fsub float 0x4021666660000000, 0x3ff1c710c0000000
	store float %t21, float* %t1, align 4
	%t22 = load float, float* %t2
	%t23 = load float, float* %t1
	%t24 = fmul float %t22, %t23
	%t25 = fdiv float %t24, 0x40019999a0000000
	store float %t25, float* %t0, align 4
	%t26 = load float, float* %t2
	%t27 = fpext float %t26 to double
	%t28 = load float, float* %t1
	%t29 = fpext float %t28 to double
	%t30 = load float, float* %t0
	%t31 = fpext float %t30 to double
	%t32 = load float, float* %t0
	%t33 = load float, float* %t2
	%t34 = fsub float %t32, %t33
	%t35 = fpext float %t34 to double
	%t36 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.1, i64 0, i64 0), double %t27, double %t29, double %t31, double %t35)

; === epilogue ===
	ret i32 0
}
