void f2(){
    int a = 89;
    char b = 'c';
    return 1024 ;
}
void f1( int a ){
    return a ;
}
int main( int argc )
{
   /* this file mainly test for if-else control flow */
    
    int never_loses = 2015, nlnlOUO = 0, overload;

    int qqpr[10] = { 1, 2, 3 };
    
    if ( argc != 5 ) {
        never_loses = 0;
    }
    else{
        never_loses = 1;
    }
    
    nlnlOUO = 3;
    
    if( nlnlOUO == 3 ){
        nlnlOUO = 87;
        if( never_loses )
            overload = 8;
        else
            overload = 9;
    }

    return 0 ;
}
