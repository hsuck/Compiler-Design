int main(){
   
   int ret = 0;
    /* this file mainly test for printf function */
   int number = 3;
   
   if( number == 3 )
      printf( "this is a test file %d\n", number );
   else{
      printf("error\n");
      ret = 1;
   }
   
   return ret ;
}
