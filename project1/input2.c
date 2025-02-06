#include <stdio.h>

void swap( int *array, int idx1, int idx2 ){
    int temp = 0;
    temp = array[idx1];
    array[idx1] = array[idx2];
    array[idx2] = temp;
}

/* This
   is 
   a 
   gcd
   function
*/
int gcd( int m, int n ){
    while( n != 0 ){ 
        int r = m % n; 
        m = n; 
        n = r; 
    } 
    return m;
}

// Test file
int main(){
    char* hello = "Hello World";
    char c = 'C';

    printf( "%s, %c\n", hello, c );

    short a = 77;
    int b = 123;
    long d = 343696;
    
    b++;
    a--;

    long beef = 0xdeadbeef;
    
    float e = 1.732f;
    double f = 7414.7414d;

    double g = e+4;

    printf( "%lf\n", g );

    int array[2] = { 87, 78 };
    
    swap( array, 0, 1 );
    printf( "%d %d\n", array[0], array[1] );

    printf( "%d\n", gcd( 250, 100 ) );

    return 0;
}
