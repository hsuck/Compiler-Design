int main(){
    int a;
    int b;
    float c;
    float d;
    float e;
    a = ( 8 + 9 ) * 3;
    b = ( 3 + 14 ) * 3;

    if( a == b ){
        printf("a equals to b\n");
    }
    else{
        printf("a doesn't equal to b\n");
    }

    c = 9.6 + 1.2;
    d = ( c - 5.8 ) / 3.3;
    e = ( d + c ) * 0.99;
    if( a == b ){
        if( c > 2.83 ){
            printf( "c = %f, d = %f, e = %f\n", c, d, ( d + c ) * 0.99 );
        }
        else{
            printf( "c < d\n" );
        }
    }
    else{
        printf("a doesn't equal to b\n");
    }
}
