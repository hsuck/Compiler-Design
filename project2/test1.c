void qqpr( int a, int b ){
   return a;
}

/* main */
int main(){
   
    int result = 0;
    /* result  = result +1 +2 +3 +4 +5... */
    
    int i, b = 0, a[10];

    // this is a test for for loop
    for( i = 0 ; i <= 10 ; i++ )
        result += i;

    // this is a test for for loop + selection(if) + jump(break)
    for( i = 0 ; i <= 10 ; )
        if( i == 5 )
            if( b == 0 )
                break;

    // here is double loop (for + while)
    for( i = 0 ; i < b ; i += 1 ){
        b = 2;
        while( b < 10 ){
            b = 3;
        }
    }
    // do while 
    do { b = b + 1 ; }
    while( b < 10 );

    // this is a test for jump(return)
    return result;
}
