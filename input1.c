#include <stdio.h>
#include <stdlib.h>

// Fibonacci Sequence
int fib( int n ){
    if( n == 1 || n == 2 )
        return 1;
    if( n >= 3 )
        return fib( n - 1 ) + fib( n - 2 );
}

int main(){
    int num = 0;

    scanf( "%d", &num );

    printf( "%d\n", fib( num ) );

    return 0;
}
