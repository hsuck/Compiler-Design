int main(){
    int i;
    int j;
    int k;
    int l;
    for( i = 0; i < 5; i = i + 1 ){
        if( i == 1 ){
            printf( "H3ll0 W0r1d\n" );
        }
        else{
            printf( "i = %d\n", i );
        }
        for( j = 0; j < 3; j = j + 1 ){
            if( j == 0 ){
                if( i == 1 ){
                    printf( "    0xDEADBEEF\n" );
                }
                else{
                    printf( "    0xDEADDEAD\n" );
                }
            }
            else{
                printf( "    j = %d\n", j );
            }
            for( k = 0; k < 2; k = k + 1 ){
                printf( "        k = %d\n", k );
            }
        }
        for( l = 0; l < 4; l = l + 1 ){
            printf( "    l = %d\n", l );
        }
    }
}
